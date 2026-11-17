package kotlin.reflect.jvm.internal.impl.types;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import kotlin.NoWhenBranchMatchedException;
import kotlin.collections.CollectionsKt;
import kotlin.jvm.internal.Intrinsics;
import kotlin.reflect.jvm.internal.impl.types.TypeCheckerState;
import kotlin.reflect.jvm.internal.impl.types.model.CaptureStatus;
import kotlin.reflect.jvm.internal.impl.types.model.CapturedTypeMarker;
import kotlin.reflect.jvm.internal.impl.types.model.DefinitelyNotNullTypeMarker;
import kotlin.reflect.jvm.internal.impl.types.model.IntersectionTypeConstructorMarker;
import kotlin.reflect.jvm.internal.impl.types.model.KotlinTypeMarker;
import kotlin.reflect.jvm.internal.impl.types.model.SimpleTypeMarker;
import kotlin.reflect.jvm.internal.impl.types.model.TypeArgumentListMarker;
import kotlin.reflect.jvm.internal.impl.types.model.TypeArgumentMarker;
import kotlin.reflect.jvm.internal.impl.types.model.TypeConstructorMarker;
import kotlin.reflect.jvm.internal.impl.types.model.TypeParameterMarker;
import kotlin.reflect.jvm.internal.impl.types.model.TypeSystemContext;
import kotlin.reflect.jvm.internal.impl.types.model.TypeVariableTypeConstructorMarker;
import kotlin.reflect.jvm.internal.impl.types.model.TypeVariance;
import kotlin.reflect.jvm.internal.impl.utils.SmartList;

/* compiled from: AbstractTypeChecker.kt */
/* loaded from: classes3.dex */
public final class AbstractTypeChecker {
    public static final AbstractTypeChecker INSTANCE = new AbstractTypeChecker();
    public static boolean RUN_SLOW_ASSERTIONS;

    /* compiled from: AbstractTypeChecker.kt */
    /* loaded from: classes3.dex */
    public /* synthetic */ class WhenMappings {
        public static final /* synthetic */ int[] $EnumSwitchMapping$0;
        public static final /* synthetic */ int[] $EnumSwitchMapping$1;

        static {
            int[] iArr = new int[TypeVariance.values().length];
            iArr[TypeVariance.INV.ordinal()] = 1;
            iArr[TypeVariance.OUT.ordinal()] = 2;
            iArr[TypeVariance.IN.ordinal()] = 3;
            $EnumSwitchMapping$0 = iArr;
            int[] iArr2 = new int[TypeCheckerState.LowerCapturedTypePolicy.values().length];
            iArr2[TypeCheckerState.LowerCapturedTypePolicy.CHECK_ONLY_LOWER.ordinal()] = 1;
            iArr2[TypeCheckerState.LowerCapturedTypePolicy.CHECK_SUBTYPE_AND_LOWER.ordinal()] = 2;
            iArr2[TypeCheckerState.LowerCapturedTypePolicy.SKIP_LOWER.ordinal()] = 3;
            $EnumSwitchMapping$1 = iArr2;
        }
    }

    private AbstractTypeChecker() {
    }

    public static /* synthetic */ boolean isSubtypeOf$default(AbstractTypeChecker abstractTypeChecker, TypeCheckerState typeCheckerState, KotlinTypeMarker kotlinTypeMarker, KotlinTypeMarker kotlinTypeMarker2, boolean z, int i, Object obj) {
        if ((i & 8) != 0) {
            z = false;
        }
        return abstractTypeChecker.isSubtypeOf(typeCheckerState, kotlinTypeMarker, kotlinTypeMarker2, z);
    }

    public final boolean isSubtypeOf(TypeCheckerState state, KotlinTypeMarker subType, KotlinTypeMarker superType, boolean z) {
        Intrinsics.checkNotNullParameter(state, "state");
        Intrinsics.checkNotNullParameter(subType, "subType");
        Intrinsics.checkNotNullParameter(superType, "superType");
        if (subType == superType) {
            return true;
        }
        if (state.customIsSubtypeOf(subType, superType)) {
            return completeIsSubTypeOf(state, subType, superType, z);
        }
        return false;
    }

    public final boolean equalTypes(TypeCheckerState state, KotlinTypeMarker a, KotlinTypeMarker b) {
        Intrinsics.checkNotNullParameter(state, "state");
        Intrinsics.checkNotNullParameter(a, "a");
        Intrinsics.checkNotNullParameter(b, "b");
        TypeSystemContext typeSystemContext = state.getTypeSystemContext();
        if (a == b) {
            return true;
        }
        AbstractTypeChecker abstractTypeChecker = INSTANCE;
        if (abstractTypeChecker.isCommonDenotableType(typeSystemContext, a) && abstractTypeChecker.isCommonDenotableType(typeSystemContext, b)) {
            KotlinTypeMarker prepareType = state.prepareType(state.refineType(a));
            KotlinTypeMarker prepareType2 = state.prepareType(state.refineType(b));
            SimpleTypeMarker lowerBoundIfFlexible = typeSystemContext.lowerBoundIfFlexible(prepareType);
            if (!typeSystemContext.areEqualTypeConstructors(typeSystemContext.typeConstructor(prepareType), typeSystemContext.typeConstructor(prepareType2))) {
                return false;
            }
            if (typeSystemContext.argumentsCount(lowerBoundIfFlexible) == 0) {
                return typeSystemContext.hasFlexibleNullability(prepareType) || typeSystemContext.hasFlexibleNullability(prepareType2) || typeSystemContext.isMarkedNullable(lowerBoundIfFlexible) == typeSystemContext.isMarkedNullable(typeSystemContext.lowerBoundIfFlexible(prepareType2));
            }
        }
        return isSubtypeOf$default(abstractTypeChecker, state, a, b, false, 8, null) && isSubtypeOf$default(abstractTypeChecker, state, b, a, false, 8, null);
    }

    private final boolean completeIsSubTypeOf(TypeCheckerState typeCheckerState, KotlinTypeMarker kotlinTypeMarker, KotlinTypeMarker kotlinTypeMarker2, boolean z) {
        TypeSystemContext typeSystemContext = typeCheckerState.getTypeSystemContext();
        KotlinTypeMarker prepareType = typeCheckerState.prepareType(typeCheckerState.refineType(kotlinTypeMarker));
        KotlinTypeMarker prepareType2 = typeCheckerState.prepareType(typeCheckerState.refineType(kotlinTypeMarker2));
        AbstractTypeChecker abstractTypeChecker = INSTANCE;
        Boolean checkSubtypeForSpecialCases = abstractTypeChecker.checkSubtypeForSpecialCases(typeCheckerState, typeSystemContext.lowerBoundIfFlexible(prepareType), typeSystemContext.upperBoundIfFlexible(prepareType2));
        if (checkSubtypeForSpecialCases != null) {
            boolean booleanValue = checkSubtypeForSpecialCases.booleanValue();
            typeCheckerState.addSubtypeConstraint(prepareType, prepareType2, z);
            return booleanValue;
        }
        Boolean addSubtypeConstraint = typeCheckerState.addSubtypeConstraint(prepareType, prepareType2, z);
        if (addSubtypeConstraint != null) {
            return addSubtypeConstraint.booleanValue();
        }
        return abstractTypeChecker.isSubtypeOfForSingleClassifierType(typeCheckerState, typeSystemContext.lowerBoundIfFlexible(prepareType), typeSystemContext.upperBoundIfFlexible(prepareType2));
    }

    private final Boolean checkSubtypeForIntegerLiteralType(TypeCheckerState typeCheckerState, SimpleTypeMarker simpleTypeMarker, SimpleTypeMarker simpleTypeMarker2) {
        TypeSystemContext typeSystemContext = typeCheckerState.getTypeSystemContext();
        if (typeSystemContext.isIntegerLiteralType(simpleTypeMarker) || typeSystemContext.isIntegerLiteralType(simpleTypeMarker2)) {
            if (typeSystemContext.isIntegerLiteralType(simpleTypeMarker) && typeSystemContext.isIntegerLiteralType(simpleTypeMarker2)) {
                return true;
            }
            if (typeSystemContext.isIntegerLiteralType(simpleTypeMarker)) {
                if (m16xd35c7e25(typeSystemContext, typeCheckerState, simpleTypeMarker, simpleTypeMarker2, false)) {
                    return true;
                }
            } else if (typeSystemContext.isIntegerLiteralType(simpleTypeMarker2) && (m17xabd2962a(typeSystemContext, simpleTypeMarker) || m16xd35c7e25(typeSystemContext, typeCheckerState, simpleTypeMarker2, simpleTypeMarker, true))) {
                return true;
            }
            return null;
        }
        return null;
    }

    /* renamed from: checkSubtypeForIntegerLiteralType$lambda-7$isTypeInIntegerLiteralType */
    private static final boolean m16xd35c7e25(TypeSystemContext typeSystemContext, TypeCheckerState typeCheckerState, SimpleTypeMarker simpleTypeMarker, SimpleTypeMarker simpleTypeMarker2, boolean z) {
        boolean z2;
        Collection<KotlinTypeMarker> possibleIntegerTypes = typeSystemContext.possibleIntegerTypes(simpleTypeMarker);
        if (!(possibleIntegerTypes instanceof Collection) || !possibleIntegerTypes.isEmpty()) {
            for (KotlinTypeMarker kotlinTypeMarker : possibleIntegerTypes) {
                if (Intrinsics.areEqual(typeSystemContext.typeConstructor(kotlinTypeMarker), typeSystemContext.typeConstructor(simpleTypeMarker2)) || (z && isSubtypeOf$default(INSTANCE, typeCheckerState, simpleTypeMarker2, kotlinTypeMarker, false, 8, null))) {
                    z2 = true;
                    continue;
                } else {
                    z2 = false;
                    continue;
                }
                if (z2) {
                    return true;
                }
            }
        }
        return false;
    }

    /* renamed from: checkSubtypeForIntegerLiteralType$lambda-7$isIntegerLiteralTypeInIntersectionComponents */
    private static final boolean m17xabd2962a(TypeSystemContext typeSystemContext, SimpleTypeMarker simpleTypeMarker) {
        boolean z;
        boolean z2;
        TypeConstructorMarker typeConstructor = typeSystemContext.typeConstructor(simpleTypeMarker);
        if (typeConstructor instanceof IntersectionTypeConstructorMarker) {
            Collection<KotlinTypeMarker> supertypes = typeSystemContext.supertypes(typeConstructor);
            if (!(supertypes instanceof Collection) || !supertypes.isEmpty()) {
                for (KotlinTypeMarker kotlinTypeMarker : supertypes) {
                    SimpleTypeMarker asSimpleType = typeSystemContext.asSimpleType(kotlinTypeMarker);
                    if (asSimpleType != null && typeSystemContext.isIntegerLiteralType(asSimpleType)) {
                        z = true;
                        continue;
                    } else {
                        z = false;
                        continue;
                    }
                    if (z) {
                        z2 = true;
                        break;
                    }
                }
            }
            z2 = false;
            if (z2) {
                return true;
            }
        }
        return false;
    }

    private final boolean hasNothingSupertype(TypeCheckerState typeCheckerState, SimpleTypeMarker simpleTypeMarker) {
        TypeCheckerState.SupertypesPolicy.LowerIfFlexible lowerIfFlexible;
        TypeSystemContext typeSystemContext = typeCheckerState.getTypeSystemContext();
        TypeConstructorMarker typeConstructor = typeSystemContext.typeConstructor(simpleTypeMarker);
        if (typeSystemContext.isClassTypeConstructor(typeConstructor)) {
            return typeSystemContext.isNothingConstructor(typeConstructor);
        }
        if (typeSystemContext.isNothingConstructor(typeSystemContext.typeConstructor(simpleTypeMarker))) {
            return true;
        }
        typeCheckerState.initialize();
        ArrayDeque<SimpleTypeMarker> supertypesDeque = typeCheckerState.getSupertypesDeque();
        Intrinsics.checkNotNull(supertypesDeque);
        Set<SimpleTypeMarker> supertypesSet = typeCheckerState.getSupertypesSet();
        Intrinsics.checkNotNull(supertypesSet);
        supertypesDeque.push(simpleTypeMarker);
        while (!supertypesDeque.isEmpty()) {
            if (supertypesSet.size() > 1000) {
                throw new IllegalStateException(("Too many supertypes for type: " + simpleTypeMarker + ". Supertypes = " + CollectionsKt.joinToString$default(supertypesSet, null, null, null, 0, null, null, 63, null)).toString());
            }
            SimpleTypeMarker current = supertypesDeque.pop();
            Intrinsics.checkNotNullExpressionValue(current, "current");
            if (supertypesSet.add(current)) {
                if (typeSystemContext.isClassType(current)) {
                    lowerIfFlexible = TypeCheckerState.SupertypesPolicy.None.INSTANCE;
                } else {
                    lowerIfFlexible = TypeCheckerState.SupertypesPolicy.LowerIfFlexible.INSTANCE;
                }
                if (!(!Intrinsics.areEqual(lowerIfFlexible, TypeCheckerState.SupertypesPolicy.None.INSTANCE))) {
                    lowerIfFlexible = null;
                }
                if (lowerIfFlexible == null) {
                    continue;
                } else {
                    TypeSystemContext typeSystemContext2 = typeCheckerState.getTypeSystemContext();
                    for (KotlinTypeMarker kotlinTypeMarker : typeSystemContext2.supertypes(typeSystemContext2.typeConstructor(current))) {
                        SimpleTypeMarker mo1759transformType = lowerIfFlexible.mo1759transformType(typeCheckerState, kotlinTypeMarker);
                        if (typeSystemContext.isNothingConstructor(typeSystemContext.typeConstructor(mo1759transformType))) {
                            typeCheckerState.clear();
                            return true;
                        }
                        supertypesDeque.add(mo1759transformType);
                    }
                    continue;
                }
            }
        }
        typeCheckerState.clear();
        return false;
    }

    /* JADX WARN: Code restructure failed: missing block: B:256:0x0114, code lost:
        if ((r3.getVariance(r9) == kotlin.reflect.jvm.internal.impl.types.model.TypeVariance.INV) != false) goto L53;
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    private final boolean isSubtypeOfForSingleClassifierType(kotlin.reflect.jvm.internal.impl.types.TypeCheckerState r19, kotlin.reflect.jvm.internal.impl.types.model.SimpleTypeMarker r20, kotlin.reflect.jvm.internal.impl.types.model.SimpleTypeMarker r21) {
        /*
            Method dump skipped, instructions count: 457
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: kotlin.reflect.jvm.internal.impl.types.AbstractTypeChecker.isSubtypeOfForSingleClassifierType(kotlin.reflect.jvm.internal.impl.types.TypeCheckerState, kotlin.reflect.jvm.internal.impl.types.model.SimpleTypeMarker, kotlin.reflect.jvm.internal.impl.types.model.SimpleTypeMarker):boolean");
    }

    private final boolean isTypeVariableAgainstStarProjectionForSelfType(TypeSystemContext typeSystemContext, KotlinTypeMarker kotlinTypeMarker, KotlinTypeMarker kotlinTypeMarker2, TypeConstructorMarker typeConstructorMarker) {
        TypeParameterMarker typeParameter;
        SimpleTypeMarker asSimpleType = typeSystemContext.asSimpleType(kotlinTypeMarker);
        if (asSimpleType instanceof CapturedTypeMarker) {
            CapturedTypeMarker capturedTypeMarker = (CapturedTypeMarker) asSimpleType;
            if (!typeSystemContext.isOldCapturedType(capturedTypeMarker) && typeSystemContext.isStarProjection(typeSystemContext.projection(typeSystemContext.typeConstructor(capturedTypeMarker))) && typeSystemContext.captureStatus(capturedTypeMarker) == CaptureStatus.FOR_SUBTYPING) {
                TypeConstructorMarker typeConstructor = typeSystemContext.typeConstructor(kotlinTypeMarker2);
                TypeVariableTypeConstructorMarker typeVariableTypeConstructorMarker = typeConstructor instanceof TypeVariableTypeConstructorMarker ? (TypeVariableTypeConstructorMarker) typeConstructor : null;
                return (typeVariableTypeConstructorMarker == null || (typeParameter = typeSystemContext.getTypeParameter(typeVariableTypeConstructorMarker)) == null || !typeSystemContext.hasRecursiveBounds(typeParameter, typeConstructorMarker)) ? false : true;
            }
            return false;
        }
        return false;
    }

    public final boolean isSubtypeForSameConstructor(TypeCheckerState typeCheckerState, TypeArgumentListMarker capturedSubArguments, SimpleTypeMarker superType) {
        int i;
        int i2;
        boolean equalTypes;
        int i3;
        Intrinsics.checkNotNullParameter(typeCheckerState, "<this>");
        Intrinsics.checkNotNullParameter(capturedSubArguments, "capturedSubArguments");
        Intrinsics.checkNotNullParameter(superType, "superType");
        TypeSystemContext typeSystemContext = typeCheckerState.getTypeSystemContext();
        TypeConstructorMarker typeConstructor = typeSystemContext.typeConstructor(superType);
        int size = typeSystemContext.size(capturedSubArguments);
        int parametersCount = typeSystemContext.parametersCount(typeConstructor);
        if (size == parametersCount) {
            SimpleTypeMarker simpleTypeMarker = superType;
            if (size == typeSystemContext.argumentsCount(simpleTypeMarker)) {
                int i4 = 0;
                while (i4 < parametersCount) {
                    int i5 = i4 + 1;
                    TypeArgumentMarker argument = typeSystemContext.getArgument(simpleTypeMarker, i4);
                    if (!typeSystemContext.isStarProjection(argument)) {
                        KotlinTypeMarker type = typeSystemContext.getType(argument);
                        TypeArgumentMarker typeArgumentMarker = typeSystemContext.get(capturedSubArguments, i4);
                        typeSystemContext.getVariance(typeArgumentMarker);
                        TypeVariance typeVariance = TypeVariance.INV;
                        KotlinTypeMarker type2 = typeSystemContext.getType(typeArgumentMarker);
                        AbstractTypeChecker abstractTypeChecker = INSTANCE;
                        TypeVariance effectiveVariance = abstractTypeChecker.effectiveVariance(typeSystemContext.getVariance(typeSystemContext.getParameter(typeConstructor, i4)), typeSystemContext.getVariance(argument));
                        if (effectiveVariance == null) {
                            return typeCheckerState.isErrorTypeEqualsToAnything();
                        }
                        if (effectiveVariance == TypeVariance.INV && (abstractTypeChecker.isTypeVariableAgainstStarProjectionForSelfType(typeSystemContext, type2, type, typeConstructor) || abstractTypeChecker.isTypeVariableAgainstStarProjectionForSelfType(typeSystemContext, type, type2, typeConstructor))) {
                            continue;
                        } else {
                            i = typeCheckerState.argumentsDepth;
                            if (i <= 100) {
                                i2 = typeCheckerState.argumentsDepth;
                                typeCheckerState.argumentsDepth = i2 + 1;
                                int i6 = WhenMappings.$EnumSwitchMapping$0[effectiveVariance.ordinal()];
                                if (i6 == 1) {
                                    equalTypes = abstractTypeChecker.equalTypes(typeCheckerState, type2, type);
                                } else if (i6 == 2) {
                                    equalTypes = isSubtypeOf$default(abstractTypeChecker, typeCheckerState, type2, type, false, 8, null);
                                } else if (i6 != 3) {
                                    throw new NoWhenBranchMatchedException();
                                } else {
                                    equalTypes = isSubtypeOf$default(abstractTypeChecker, typeCheckerState, type, type2, false, 8, null);
                                }
                                i3 = typeCheckerState.argumentsDepth;
                                typeCheckerState.argumentsDepth = i3 - 1;
                                if (!equalTypes) {
                                    return false;
                                }
                            } else {
                                throw new IllegalStateException(Intrinsics.stringPlus("Arguments depth is too high. Some related argument: ", type2).toString());
                            }
                        }
                    }
                    i4 = i5;
                }
                return true;
            }
        }
        return false;
    }

    private final boolean isCommonDenotableType(TypeSystemContext typeSystemContext, KotlinTypeMarker kotlinTypeMarker) {
        return typeSystemContext.isDenotable(typeSystemContext.typeConstructor(kotlinTypeMarker)) && !typeSystemContext.isDynamic(kotlinTypeMarker) && !typeSystemContext.isDefinitelyNotNullType(kotlinTypeMarker) && Intrinsics.areEqual(typeSystemContext.typeConstructor(typeSystemContext.lowerBoundIfFlexible(kotlinTypeMarker)), typeSystemContext.typeConstructor(typeSystemContext.upperBoundIfFlexible(kotlinTypeMarker)));
    }

    public final TypeVariance effectiveVariance(TypeVariance declared, TypeVariance useSite) {
        Intrinsics.checkNotNullParameter(declared, "declared");
        Intrinsics.checkNotNullParameter(useSite, "useSite");
        if (declared == TypeVariance.INV) {
            return useSite;
        }
        if (useSite == TypeVariance.INV || declared == useSite) {
            return declared;
        }
        return null;
    }

    private final boolean isStubTypeSubtypeOfAnother(TypeSystemContext typeSystemContext, SimpleTypeMarker simpleTypeMarker, SimpleTypeMarker simpleTypeMarker2) {
        DefinitelyNotNullTypeMarker asDefinitelyNotNullType = typeSystemContext.asDefinitelyNotNullType(simpleTypeMarker);
        SimpleTypeMarker original = asDefinitelyNotNullType == null ? simpleTypeMarker : typeSystemContext.original(asDefinitelyNotNullType);
        DefinitelyNotNullTypeMarker asDefinitelyNotNullType2 = typeSystemContext.asDefinitelyNotNullType(simpleTypeMarker2);
        if (typeSystemContext.typeConstructor(original) != typeSystemContext.typeConstructor(asDefinitelyNotNullType2 == null ? simpleTypeMarker2 : typeSystemContext.original(asDefinitelyNotNullType2))) {
            return false;
        }
        if (typeSystemContext.isDefinitelyNotNullType(simpleTypeMarker) || !typeSystemContext.isDefinitelyNotNullType(simpleTypeMarker2)) {
            return !typeSystemContext.isMarkedNullable(simpleTypeMarker) || typeSystemContext.isMarkedNullable(simpleTypeMarker2);
        }
        return false;
    }

    /* JADX WARN: Code restructure failed: missing block: B:282:0x013b, code lost:
        if (r11 != false) goto L79;
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    private final java.lang.Boolean checkSubtypeForSpecialCases(kotlin.reflect.jvm.internal.impl.types.TypeCheckerState r18, kotlin.reflect.jvm.internal.impl.types.model.SimpleTypeMarker r19, kotlin.reflect.jvm.internal.impl.types.model.SimpleTypeMarker r20) {
        /*
            Method dump skipped, instructions count: 397
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: kotlin.reflect.jvm.internal.impl.types.AbstractTypeChecker.checkSubtypeForSpecialCases(kotlin.reflect.jvm.internal.impl.types.TypeCheckerState, kotlin.reflect.jvm.internal.impl.types.model.SimpleTypeMarker, kotlin.reflect.jvm.internal.impl.types.model.SimpleTypeMarker):java.lang.Boolean");
    }

    private final TypeParameterMarker getTypeParameterForArgumentInBaseIfItEqualToTarget(TypeSystemContext typeSystemContext, KotlinTypeMarker kotlinTypeMarker, KotlinTypeMarker kotlinTypeMarker2) {
        int argumentsCount = typeSystemContext.argumentsCount(kotlinTypeMarker);
        int i = 0;
        while (true) {
            if (i >= argumentsCount) {
                return null;
            }
            int i2 = i + 1;
            TypeArgumentMarker argument = typeSystemContext.getArgument(kotlinTypeMarker, i);
            boolean z = true;
            TypeArgumentMarker typeArgumentMarker = typeSystemContext.isStarProjection(argument) ^ true ? argument : null;
            if (typeArgumentMarker != null) {
                KotlinTypeMarker type = typeSystemContext.getType(typeArgumentMarker);
                z = (typeSystemContext.isCapturedType(typeSystemContext.lowerBoundIfFlexible(type)) && typeSystemContext.isCapturedType(typeSystemContext.lowerBoundIfFlexible(kotlinTypeMarker2))) ? false : false;
                if (Intrinsics.areEqual(type, kotlinTypeMarker2) || (z && Intrinsics.areEqual(typeSystemContext.typeConstructor(type), typeSystemContext.typeConstructor(kotlinTypeMarker2)))) {
                    break;
                }
                TypeParameterMarker typeParameterForArgumentInBaseIfItEqualToTarget = getTypeParameterForArgumentInBaseIfItEqualToTarget(typeSystemContext, type, kotlinTypeMarker2);
                if (typeParameterForArgumentInBaseIfItEqualToTarget != null) {
                    return typeParameterForArgumentInBaseIfItEqualToTarget;
                }
            }
            i = i2;
        }
        return typeSystemContext.getParameter(typeSystemContext.typeConstructor(kotlinTypeMarker), i);
    }

    private final List<SimpleTypeMarker> collectAllSupertypesWithGivenTypeConstructor(TypeCheckerState typeCheckerState, SimpleTypeMarker simpleTypeMarker, TypeConstructorMarker typeConstructorMarker) {
        TypeCheckerState.SupertypesPolicy.LowerIfFlexible substitutionSupertypePolicy;
        SimpleTypeMarker simpleTypeMarker2 = simpleTypeMarker;
        TypeSystemContext typeSystemContext = typeCheckerState.getTypeSystemContext();
        SmartList fastCorrespondingSupertypes = typeSystemContext.fastCorrespondingSupertypes(simpleTypeMarker2, typeConstructorMarker);
        if (fastCorrespondingSupertypes == null) {
            if (!typeSystemContext.isClassTypeConstructor(typeConstructorMarker) && typeSystemContext.isClassType(simpleTypeMarker2)) {
                return CollectionsKt.emptyList();
            }
            if (typeSystemContext.isCommonFinalClassConstructor(typeConstructorMarker)) {
                if (typeSystemContext.areEqualTypeConstructors(typeSystemContext.typeConstructor(simpleTypeMarker2), typeConstructorMarker)) {
                    SimpleTypeMarker captureFromArguments = typeSystemContext.captureFromArguments(simpleTypeMarker2, CaptureStatus.FOR_SUBTYPING);
                    if (captureFromArguments != null) {
                        simpleTypeMarker2 = captureFromArguments;
                    }
                    return CollectionsKt.listOf(simpleTypeMarker2);
                }
                return CollectionsKt.emptyList();
            }
            fastCorrespondingSupertypes = new SmartList();
            typeCheckerState.initialize();
            ArrayDeque<SimpleTypeMarker> supertypesDeque = typeCheckerState.getSupertypesDeque();
            Intrinsics.checkNotNull(supertypesDeque);
            Set<SimpleTypeMarker> supertypesSet = typeCheckerState.getSupertypesSet();
            Intrinsics.checkNotNull(supertypesSet);
            supertypesDeque.push(simpleTypeMarker2);
            while (!supertypesDeque.isEmpty()) {
                if (supertypesSet.size() > 1000) {
                    throw new IllegalStateException(("Too many supertypes for type: " + simpleTypeMarker2 + ". Supertypes = " + CollectionsKt.joinToString$default(supertypesSet, null, null, null, 0, null, null, 63, null)).toString());
                }
                SimpleTypeMarker current = supertypesDeque.pop();
                Intrinsics.checkNotNullExpressionValue(current, "current");
                if (supertypesSet.add(current)) {
                    SimpleTypeMarker captureFromArguments2 = typeSystemContext.captureFromArguments(current, CaptureStatus.FOR_SUBTYPING);
                    if (captureFromArguments2 == null) {
                        captureFromArguments2 = current;
                    }
                    if (typeSystemContext.areEqualTypeConstructors(typeSystemContext.typeConstructor(captureFromArguments2), typeConstructorMarker)) {
                        fastCorrespondingSupertypes.add(captureFromArguments2);
                        substitutionSupertypePolicy = TypeCheckerState.SupertypesPolicy.None.INSTANCE;
                    } else if (typeSystemContext.argumentsCount(captureFromArguments2) == 0) {
                        substitutionSupertypePolicy = TypeCheckerState.SupertypesPolicy.LowerIfFlexible.INSTANCE;
                    } else {
                        substitutionSupertypePolicy = typeCheckerState.getTypeSystemContext().substitutionSupertypePolicy(captureFromArguments2);
                    }
                    if (!(!Intrinsics.areEqual(substitutionSupertypePolicy, TypeCheckerState.SupertypesPolicy.None.INSTANCE))) {
                        substitutionSupertypePolicy = null;
                    }
                    if (substitutionSupertypePolicy != null) {
                        TypeSystemContext typeSystemContext2 = typeCheckerState.getTypeSystemContext();
                        for (KotlinTypeMarker kotlinTypeMarker : typeSystemContext2.supertypes(typeSystemContext2.typeConstructor(current))) {
                            supertypesDeque.add(substitutionSupertypePolicy.mo1759transformType(typeCheckerState, kotlinTypeMarker));
                        }
                    }
                }
            }
            typeCheckerState.clear();
        }
        return fastCorrespondingSupertypes;
    }

    private final List<SimpleTypeMarker> collectAndFilter(TypeCheckerState typeCheckerState, SimpleTypeMarker simpleTypeMarker, TypeConstructorMarker typeConstructorMarker) {
        return selectOnlyPureKotlinSupertypes(typeCheckerState, collectAllSupertypesWithGivenTypeConstructor(typeCheckerState, simpleTypeMarker, typeConstructorMarker));
    }

    /* JADX WARN: Multi-variable type inference failed */
    private final List<SimpleTypeMarker> selectOnlyPureKotlinSupertypes(TypeCheckerState typeCheckerState, List<? extends SimpleTypeMarker> list) {
        TypeSystemContext typeSystemContext = typeCheckerState.getTypeSystemContext();
        if (list.size() < 2) {
            return list;
        }
        ArrayList arrayList = new ArrayList();
        Iterator it = list.iterator();
        while (true) {
            boolean z = true;
            if (!it.hasNext()) {
                break;
            }
            Object next = it.next();
            TypeArgumentListMarker asArgumentList = typeSystemContext.asArgumentList((SimpleTypeMarker) next);
            int size = typeSystemContext.size(asArgumentList);
            int i = 0;
            while (true) {
                if (i >= size) {
                    break;
                }
                int i2 = i + 1;
                if (!(typeSystemContext.asFlexibleType(typeSystemContext.getType(typeSystemContext.get(asArgumentList, i))) == null)) {
                    z = false;
                    break;
                }
                i = i2;
            }
            if (z) {
                arrayList.add(next);
            }
        }
        ArrayList arrayList2 = arrayList;
        return arrayList2.isEmpty() ^ true ? arrayList2 : list;
    }

    public final List<SimpleTypeMarker> findCorrespondingSupertypes(TypeCheckerState state, SimpleTypeMarker subType, TypeConstructorMarker superConstructor) {
        TypeCheckerState.SupertypesPolicy.LowerIfFlexible lowerIfFlexible;
        Intrinsics.checkNotNullParameter(state, "state");
        Intrinsics.checkNotNullParameter(subType, "subType");
        Intrinsics.checkNotNullParameter(superConstructor, "superConstructor");
        TypeSystemContext typeSystemContext = state.getTypeSystemContext();
        if (typeSystemContext.isClassType(subType)) {
            return INSTANCE.collectAndFilter(state, subType, superConstructor);
        }
        if (!typeSystemContext.isClassTypeConstructor(superConstructor) && !typeSystemContext.isIntegerLiteralTypeConstructor(superConstructor)) {
            return INSTANCE.collectAllSupertypesWithGivenTypeConstructor(state, subType, superConstructor);
        }
        SmartList<SimpleTypeMarker> smartList = new SmartList();
        state.initialize();
        ArrayDeque<SimpleTypeMarker> supertypesDeque = state.getSupertypesDeque();
        Intrinsics.checkNotNull(supertypesDeque);
        Set<SimpleTypeMarker> supertypesSet = state.getSupertypesSet();
        Intrinsics.checkNotNull(supertypesSet);
        supertypesDeque.push(subType);
        while (!supertypesDeque.isEmpty()) {
            if (supertypesSet.size() > 1000) {
                throw new IllegalStateException(("Too many supertypes for type: " + subType + ". Supertypes = " + CollectionsKt.joinToString$default(supertypesSet, null, null, null, 0, null, null, 63, null)).toString());
            }
            SimpleTypeMarker current = supertypesDeque.pop();
            Intrinsics.checkNotNullExpressionValue(current, "current");
            if (supertypesSet.add(current)) {
                if (typeSystemContext.isClassType(current)) {
                    smartList.add(current);
                    lowerIfFlexible = TypeCheckerState.SupertypesPolicy.None.INSTANCE;
                } else {
                    lowerIfFlexible = TypeCheckerState.SupertypesPolicy.LowerIfFlexible.INSTANCE;
                }
                if (!(!Intrinsics.areEqual(lowerIfFlexible, TypeCheckerState.SupertypesPolicy.None.INSTANCE))) {
                    lowerIfFlexible = null;
                }
                if (lowerIfFlexible != null) {
                    TypeSystemContext typeSystemContext2 = state.getTypeSystemContext();
                    for (KotlinTypeMarker kotlinTypeMarker : typeSystemContext2.supertypes(typeSystemContext2.typeConstructor(current))) {
                        supertypesDeque.add(lowerIfFlexible.mo1759transformType(state, kotlinTypeMarker));
                    }
                }
            }
        }
        state.clear();
        ArrayList arrayList = new ArrayList();
        for (SimpleTypeMarker it : smartList) {
            AbstractTypeChecker abstractTypeChecker = INSTANCE;
            Intrinsics.checkNotNullExpressionValue(it, "it");
            CollectionsKt.addAll(arrayList, abstractTypeChecker.collectAndFilter(state, it, superConstructor));
        }
        return arrayList;
    }
}
