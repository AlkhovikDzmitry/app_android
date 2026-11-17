package kotlin.reflect.jvm.internal.impl.types;

import androidx.autofill.HintConstants;
import java.util.ArrayList;
import java.util.List;
import kotlin.jvm.functions.Function1;
import kotlin.reflect.jvm.internal.impl.builtins.KotlinBuiltIns;
import kotlin.reflect.jvm.internal.impl.builtins.StandardNames;
import kotlin.reflect.jvm.internal.impl.descriptors.TypeParameterDescriptor;
import kotlin.reflect.jvm.internal.impl.descriptors.annotations.Annotations;
import kotlin.reflect.jvm.internal.impl.descriptors.annotations.CompositeAnnotations;
import kotlin.reflect.jvm.internal.impl.descriptors.annotations.FilteredAnnotations;
import kotlin.reflect.jvm.internal.impl.name.FqName;
import kotlin.reflect.jvm.internal.impl.resolve.calls.inference.CapturedTypeConstructorKt;
import kotlin.reflect.jvm.internal.impl.types.checker.NewCapturedTypeConstructor;
import kotlin.reflect.jvm.internal.impl.types.typesApproximation.CapturedTypeApproximationKt;
import kotlin.reflect.jvm.internal.impl.utils.exceptionUtils;

/* loaded from: classes3.dex */
public class TypeSubstitutor {
    static final /* synthetic */ boolean $assertionsDisabled = false;
    public static final TypeSubstitutor EMPTY = create(TypeSubstitution.EMPTY);
    private final TypeSubstitution substitution;

    /* loaded from: classes3.dex */
    public enum VarianceConflictType {
        NO_CONFLICT,
        IN_IN_OUT_POSITION,
        OUT_IN_IN_POSITION
    }

    /* JADX WARN: Removed duplicated region for block: B:106:0x0030  */
    /* JADX WARN: Removed duplicated region for block: B:110:0x003b A[FALL_THROUGH] */
    /* JADX WARN: Removed duplicated region for block: B:113:0x0044  */
    /* JADX WARN: Removed duplicated region for block: B:114:0x0049  */
    /* JADX WARN: Removed duplicated region for block: B:115:0x004e  */
    /* JADX WARN: Removed duplicated region for block: B:116:0x0053  */
    /* JADX WARN: Removed duplicated region for block: B:117:0x0058  */
    /* JADX WARN: Removed duplicated region for block: B:118:0x005d  */
    /* JADX WARN: Removed duplicated region for block: B:119:0x0062  */
    /* JADX WARN: Removed duplicated region for block: B:120:0x0067  */
    /* JADX WARN: Removed duplicated region for block: B:121:0x006c  */
    /* JADX WARN: Removed duplicated region for block: B:122:0x0071  */
    /* JADX WARN: Removed duplicated region for block: B:123:0x0076  */
    /* JADX WARN: Removed duplicated region for block: B:124:0x007b  */
    /* JADX WARN: Removed duplicated region for block: B:125:0x0080  */
    /* JADX WARN: Removed duplicated region for block: B:126:0x0085  */
    /* JADX WARN: Removed duplicated region for block: B:127:0x008a  */
    /* JADX WARN: Removed duplicated region for block: B:130:0x0098  */
    /* JADX WARN: Removed duplicated region for block: B:146:0x00c8  */
    /* JADX WARN: Removed duplicated region for block: B:148:0x00cf  */
    /* JADX WARN: Removed duplicated region for block: B:149:0x00d4  */
    /* JADX WARN: Removed duplicated region for block: B:150:0x00d7  */
    /* JADX WARN: Removed duplicated region for block: B:151:0x00da  */
    /* JADX WARN: Removed duplicated region for block: B:152:0x00dd  */
    /* JADX WARN: Removed duplicated region for block: B:153:0x00e0  */
    /* JADX WARN: Removed duplicated region for block: B:154:0x00e5  */
    /* JADX WARN: Removed duplicated region for block: B:155:0x00ea  */
    /* JADX WARN: Removed duplicated region for block: B:156:0x00ed  */
    /* JADX WARN: Removed duplicated region for block: B:157:0x00f2  */
    /* JADX WARN: Removed duplicated region for block: B:160:0x00fc A[ADDED_TO_REGION] */
    /* JADX WARN: Removed duplicated region for block: B:165:0x0107  */
    /* JADX WARN: Removed duplicated region for block: B:99:0x0021 A[FALL_THROUGH] */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    private static /* synthetic */ void $$$reportNull$$$0(int r13) {
        /*
            Method dump skipped, instructions count: 660
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: kotlin.reflect.jvm.internal.impl.types.TypeSubstitutor.$$$reportNull$$$0(int):void");
    }

    /* loaded from: classes3.dex */
    public static final class SubstitutionException extends Exception {
        public SubstitutionException(String str) {
            super(str);
        }
    }

    public static TypeSubstitutor create(TypeSubstitution typeSubstitution) {
        if (typeSubstitution == null) {
            $$$reportNull$$$0(0);
        }
        return new TypeSubstitutor(typeSubstitution);
    }

    public TypeSubstitutor replaceWithNonApproximatingSubstitution() {
        TypeSubstitution typeSubstitution = this.substitution;
        return ((typeSubstitution instanceof IndexedParametersSubstitution) && typeSubstitution.approximateContravariantCapturedTypes()) ? new TypeSubstitutor(new IndexedParametersSubstitution(((IndexedParametersSubstitution) this.substitution).getParameters(), ((IndexedParametersSubstitution) this.substitution).getArguments(), false)) : this;
    }

    public static TypeSubstitutor createChainedSubstitutor(TypeSubstitution typeSubstitution, TypeSubstitution typeSubstitution2) {
        if (typeSubstitution == null) {
            $$$reportNull$$$0(3);
        }
        if (typeSubstitution2 == null) {
            $$$reportNull$$$0(4);
        }
        return create(DisjointKeysUnionTypeSubstitution.create(typeSubstitution, typeSubstitution2));
    }

    public static TypeSubstitutor create(KotlinType kotlinType) {
        if (kotlinType == null) {
            $$$reportNull$$$0(6);
        }
        return create(TypeConstructorSubstitution.create(kotlinType.getConstructor(), kotlinType.getArguments()));
    }

    protected TypeSubstitutor(TypeSubstitution typeSubstitution) {
        if (typeSubstitution == null) {
            $$$reportNull$$$0(7);
        }
        this.substitution = typeSubstitution;
    }

    public boolean isEmpty() {
        return this.substitution.isEmpty();
    }

    public TypeSubstitution getSubstitution() {
        TypeSubstitution typeSubstitution = this.substitution;
        if (typeSubstitution == null) {
            $$$reportNull$$$0(8);
        }
        return typeSubstitution;
    }

    public KotlinType safeSubstitute(KotlinType kotlinType, Variance variance) {
        if (kotlinType == null) {
            $$$reportNull$$$0(9);
        }
        if (variance == null) {
            $$$reportNull$$$0(10);
        }
        if (isEmpty()) {
            if (kotlinType == null) {
                $$$reportNull$$$0(11);
            }
            return kotlinType;
        }
        try {
            KotlinType type = unsafeSubstitute(new TypeProjectionImpl(variance, kotlinType), null, 0).getType();
            if (type == null) {
                $$$reportNull$$$0(12);
            }
            return type;
        } catch (SubstitutionException e) {
            SimpleType createErrorType = ErrorUtils.createErrorType(e.getMessage());
            if (createErrorType == null) {
                $$$reportNull$$$0(13);
            }
            return createErrorType;
        }
    }

    public KotlinType substitute(KotlinType kotlinType, Variance variance) {
        if (kotlinType == null) {
            $$$reportNull$$$0(14);
        }
        if (variance == null) {
            $$$reportNull$$$0(15);
        }
        TypeProjection substitute = substitute(new TypeProjectionImpl(variance, getSubstitution().prepareTopLevelType(kotlinType, variance)));
        if (substitute == null) {
            return null;
        }
        return substitute.getType();
    }

    public TypeProjection substitute(TypeProjection typeProjection) {
        if (typeProjection == null) {
            $$$reportNull$$$0(16);
        }
        TypeProjection substituteWithoutApproximation = substituteWithoutApproximation(typeProjection);
        return (this.substitution.approximateCapturedTypes() || this.substitution.approximateContravariantCapturedTypes()) ? CapturedTypeApproximationKt.approximateCapturedTypesIfNecessary(substituteWithoutApproximation, this.substitution.approximateContravariantCapturedTypes()) : substituteWithoutApproximation;
    }

    public TypeProjection substituteWithoutApproximation(TypeProjection typeProjection) {
        if (typeProjection == null) {
            $$$reportNull$$$0(17);
        }
        if (isEmpty()) {
            return typeProjection;
        }
        try {
            return unsafeSubstitute(typeProjection, null, 0);
        } catch (SubstitutionException unused) {
            return null;
        }
    }

    private TypeProjection unsafeSubstitute(TypeProjection typeProjection, TypeParameterDescriptor typeParameterDescriptor, int i) throws SubstitutionException {
        KotlinType makeNullableIfNeeded;
        if (typeProjection == null) {
            $$$reportNull$$$0(18);
        }
        assertRecursionDepth(i, typeProjection, this.substitution);
        if (typeProjection.isStarProjection()) {
            if (typeProjection == null) {
                $$$reportNull$$$0(19);
            }
            return typeProjection;
        }
        KotlinType type = typeProjection.getType();
        if (type instanceof TypeWithEnhancement) {
            TypeWithEnhancement typeWithEnhancement = (TypeWithEnhancement) type;
            UnwrappedType origin = typeWithEnhancement.getOrigin();
            KotlinType enhancement = typeWithEnhancement.getEnhancement();
            TypeProjection unsafeSubstitute = unsafeSubstitute(new TypeProjectionImpl(typeProjection.getProjectionKind(), origin), typeParameterDescriptor, i + 1);
            if (unsafeSubstitute.isStarProjection()) {
                if (unsafeSubstitute == null) {
                    $$$reportNull$$$0(20);
                }
                return unsafeSubstitute;
            }
            KotlinType substitute = substitute(enhancement, typeProjection.getProjectionKind());
            UnwrappedType unwrap = unsafeSubstitute.getType().unwrap();
            if (substitute instanceof TypeWithEnhancement) {
                substitute = ((TypeWithEnhancement) substitute).getEnhancement();
            }
            return new TypeProjectionImpl(unsafeSubstitute.getProjectionKind(), TypeWithEnhancementKt.wrapEnhancement(unwrap, substitute));
        } else if (DynamicTypesKt.isDynamic(type) || (type.unwrap() instanceof RawType)) {
            if (typeProjection == null) {
                $$$reportNull$$$0(21);
            }
            return typeProjection;
        } else {
            TypeProjection mo1760get = this.substitution.mo1760get(type);
            TypeProjection projectedTypeForConflictedTypeWithUnsafeVariance = mo1760get != null ? projectedTypeForConflictedTypeWithUnsafeVariance(type, mo1760get, typeParameterDescriptor, typeProjection) : null;
            Variance projectionKind = typeProjection.getProjectionKind();
            if (projectedTypeForConflictedTypeWithUnsafeVariance == null && FlexibleTypesKt.isFlexible(type) && !TypeCapabilitiesKt.isCustomTypeVariable(type)) {
                FlexibleType asFlexibleType = FlexibleTypesKt.asFlexibleType(type);
                int i2 = i + 1;
                TypeProjection unsafeSubstitute2 = unsafeSubstitute(new TypeProjectionImpl(projectionKind, asFlexibleType.getLowerBound()), typeParameterDescriptor, i2);
                TypeProjection unsafeSubstitute3 = unsafeSubstitute(new TypeProjectionImpl(projectionKind, asFlexibleType.getUpperBound()), typeParameterDescriptor, i2);
                Variance projectionKind2 = unsafeSubstitute2.getProjectionKind();
                if (unsafeSubstitute2.getType() == asFlexibleType.getLowerBound() && unsafeSubstitute3.getType() == asFlexibleType.getUpperBound()) {
                    if (typeProjection == null) {
                        $$$reportNull$$$0(22);
                    }
                    return typeProjection;
                }
                return new TypeProjectionImpl(projectionKind2, KotlinTypeFactory.flexibleType(TypeSubstitutionKt.asSimpleType(unsafeSubstitute2.getType()), TypeSubstitutionKt.asSimpleType(unsafeSubstitute3.getType())));
            } else if (KotlinBuiltIns.isNothing(type) || KotlinTypeKt.isError(type)) {
                if (typeProjection == null) {
                    $$$reportNull$$$0(23);
                }
                return typeProjection;
            } else if (projectedTypeForConflictedTypeWithUnsafeVariance != null) {
                VarianceConflictType conflictType = conflictType(projectionKind, projectedTypeForConflictedTypeWithUnsafeVariance.getProjectionKind());
                if (!CapturedTypeConstructorKt.isCaptured(type)) {
                    int i3 = C22502.f323x4790888d[conflictType.ordinal()];
                    if (i3 == 1) {
                        throw new SubstitutionException("Out-projection in in-position");
                    }
                    if (i3 == 2) {
                        return new TypeProjectionImpl(Variance.OUT_VARIANCE, type.getConstructor().getBuiltIns().getNullableAnyType());
                    }
                }
                TypeCapabilities customTypeVariable = TypeCapabilitiesKt.getCustomTypeVariable(type);
                if (projectedTypeForConflictedTypeWithUnsafeVariance.isStarProjection()) {
                    if (projectedTypeForConflictedTypeWithUnsafeVariance == null) {
                        $$$reportNull$$$0(24);
                    }
                    return projectedTypeForConflictedTypeWithUnsafeVariance;
                }
                if (customTypeVariable != null) {
                    makeNullableIfNeeded = customTypeVariable.substitutionResult(projectedTypeForConflictedTypeWithUnsafeVariance.getType());
                } else {
                    makeNullableIfNeeded = TypeUtils.makeNullableIfNeeded(projectedTypeForConflictedTypeWithUnsafeVariance.getType(), type.isMarkedNullable());
                }
                if (!type.getAnnotations().isEmpty()) {
                    makeNullableIfNeeded = kotlin.reflect.jvm.internal.impl.types.typeUtil.TypeUtils.replaceAnnotations(makeNullableIfNeeded, new CompositeAnnotations(makeNullableIfNeeded.getAnnotations(), filterOutUnsafeVariance(this.substitution.filterAnnotations(type.getAnnotations()))));
                }
                if (conflictType == VarianceConflictType.NO_CONFLICT) {
                    projectionKind = combine(projectionKind, projectedTypeForConflictedTypeWithUnsafeVariance.getProjectionKind());
                }
                return new TypeProjectionImpl(projectionKind, makeNullableIfNeeded);
            } else {
                TypeProjection substituteCompoundType = substituteCompoundType(typeProjection, i);
                if (substituteCompoundType == null) {
                    $$$reportNull$$$0(25);
                }
                return substituteCompoundType;
            }
        }
    }

    /* renamed from: kotlin.reflect.jvm.internal.impl.types.TypeSubstitutor$2 */
    /* loaded from: classes3.dex */
    public static /* synthetic */ class C22502 {

        /* renamed from: $SwitchMap$org$jetbrains$kotlin$types$TypeSubstitutor$VarianceConflictType */
        static final /* synthetic */ int[] f323x4790888d;

        static {
            int[] iArr = new int[VarianceConflictType.values().length];
            f323x4790888d = iArr;
            try {
                iArr[VarianceConflictType.OUT_IN_IN_POSITION.ordinal()] = 1;
            } catch (NoSuchFieldError unused) {
            }
            try {
                f323x4790888d[VarianceConflictType.IN_IN_OUT_POSITION.ordinal()] = 2;
            } catch (NoSuchFieldError unused2) {
            }
            try {
                f323x4790888d[VarianceConflictType.NO_CONFLICT.ordinal()] = 3;
            } catch (NoSuchFieldError unused3) {
            }
        }
    }

    private static TypeProjection projectedTypeForConflictedTypeWithUnsafeVariance(KotlinType kotlinType, TypeProjection typeProjection, TypeParameterDescriptor typeParameterDescriptor, TypeProjection typeProjection2) {
        if (kotlinType == null) {
            $$$reportNull$$$0(26);
        }
        if (typeProjection == null) {
            $$$reportNull$$$0(27);
        }
        if (typeProjection2 == null) {
            $$$reportNull$$$0(28);
        }
        if (!kotlinType.getAnnotations().hasAnnotation(StandardNames.FqNames.unsafeVariance)) {
            if (typeProjection == null) {
                $$$reportNull$$$0(29);
            }
            return typeProjection;
        }
        TypeConstructor constructor = typeProjection.getType().getConstructor();
        if (!(constructor instanceof NewCapturedTypeConstructor)) {
            if (typeProjection == null) {
                $$$reportNull$$$0(30);
            }
            return typeProjection;
        }
        TypeProjection projection = ((NewCapturedTypeConstructor) constructor).getProjection();
        Variance projectionKind = projection.getProjectionKind();
        if (conflictType(typeProjection2.getProjectionKind(), projectionKind) == VarianceConflictType.OUT_IN_IN_POSITION) {
            return new TypeProjectionImpl(projection.getType());
        }
        if (typeParameterDescriptor == null) {
            if (typeProjection == null) {
                $$$reportNull$$$0(31);
            }
            return typeProjection;
        } else if (conflictType(typeParameterDescriptor.getVariance(), projectionKind) == VarianceConflictType.OUT_IN_IN_POSITION) {
            return new TypeProjectionImpl(projection.getType());
        } else {
            if (typeProjection == null) {
                $$$reportNull$$$0(32);
            }
            return typeProjection;
        }
    }

    private static Annotations filterOutUnsafeVariance(Annotations annotations) {
        if (annotations == null) {
            $$$reportNull$$$0(33);
        }
        if (annotations.hasAnnotation(StandardNames.FqNames.unsafeVariance)) {
            return new FilteredAnnotations(annotations, new Function1<FqName, Boolean>() { // from class: kotlin.reflect.jvm.internal.impl.types.TypeSubstitutor.1
                private static /* synthetic */ void $$$reportNull$$$0(int i) {
                    throw new IllegalArgumentException(String.format("Argument for @NotNull parameter '%s' of %s.%s must not be null", HintConstants.AUTOFILL_HINT_NAME, "kotlin/reflect/jvm/internal/impl/types/TypeSubstitutor$1", "invoke"));
                }

                @Override // kotlin.jvm.functions.Function1
                public Boolean invoke(FqName fqName) {
                    if (fqName == null) {
                        $$$reportNull$$$0(0);
                    }
                    return Boolean.valueOf(!fqName.equals(StandardNames.FqNames.unsafeVariance));
                }
            });
        }
        if (annotations == null) {
            $$$reportNull$$$0(34);
        }
        return annotations;
    }

    private TypeProjection substituteCompoundType(TypeProjection typeProjection, int i) throws SubstitutionException {
        KotlinType type = typeProjection.getType();
        Variance projectionKind = typeProjection.getProjectionKind();
        if (type.getConstructor().mo1755getDeclarationDescriptor() instanceof TypeParameterDescriptor) {
            return typeProjection;
        }
        SimpleType abbreviation = SpecialTypesKt.getAbbreviation(type);
        KotlinType substitute = abbreviation != null ? replaceWithNonApproximatingSubstitution().substitute(abbreviation, Variance.INVARIANT) : null;
        KotlinType replace = TypeSubstitutionKt.replace(type, substituteTypeArguments(type.getConstructor().getParameters(), type.getArguments(), i), this.substitution.filterAnnotations(type.getAnnotations()));
        if ((replace instanceof SimpleType) && (substitute instanceof SimpleType)) {
            replace = SpecialTypesKt.withAbbreviation((SimpleType) replace, (SimpleType) substitute);
        }
        return new TypeProjectionImpl(projectionKind, replace);
    }

    private List<TypeProjection> substituteTypeArguments(List<TypeParameterDescriptor> list, List<TypeProjection> list2, int i) throws SubstitutionException {
        ArrayList arrayList = new ArrayList(list.size());
        boolean z = false;
        for (int i2 = 0; i2 < list.size(); i2++) {
            TypeParameterDescriptor typeParameterDescriptor = list.get(i2);
            TypeProjection typeProjection = list2.get(i2);
            TypeProjection unsafeSubstitute = unsafeSubstitute(typeProjection, typeParameterDescriptor, i + 1);
            int i3 = C22502.f323x4790888d[conflictType(typeParameterDescriptor.getVariance(), unsafeSubstitute.getProjectionKind()).ordinal()];
            if (i3 != 1 && i3 != 2) {
                if (i3 == 3 && typeParameterDescriptor.getVariance() != Variance.INVARIANT && !unsafeSubstitute.isStarProjection()) {
                    unsafeSubstitute = new TypeProjectionImpl(Variance.INVARIANT, unsafeSubstitute.getType());
                }
            } else {
                unsafeSubstitute = TypeUtils.makeStarProjection(typeParameterDescriptor);
            }
            if (unsafeSubstitute != typeProjection) {
                z = true;
            }
            arrayList.add(unsafeSubstitute);
        }
        return !z ? list2 : arrayList;
    }

    public static Variance combine(Variance variance, TypeProjection typeProjection) {
        if (variance == null) {
            $$$reportNull$$$0(35);
        }
        if (typeProjection == null) {
            $$$reportNull$$$0(36);
        }
        if (typeProjection.isStarProjection()) {
            Variance variance2 = Variance.OUT_VARIANCE;
            if (variance2 == null) {
                $$$reportNull$$$0(37);
            }
            return variance2;
        }
        return combine(variance, typeProjection.getProjectionKind());
    }

    public static Variance combine(Variance variance, Variance variance2) {
        if (variance == null) {
            $$$reportNull$$$0(38);
        }
        if (variance2 == null) {
            $$$reportNull$$$0(39);
        }
        if (variance == Variance.INVARIANT) {
            if (variance2 == null) {
                $$$reportNull$$$0(40);
            }
            return variance2;
        } else if (variance2 == Variance.INVARIANT) {
            if (variance == null) {
                $$$reportNull$$$0(41);
            }
            return variance;
        } else if (variance == variance2) {
            if (variance2 == null) {
                $$$reportNull$$$0(42);
            }
            return variance2;
        } else {
            throw new AssertionError("Variance conflict: type parameter variance '" + variance + "' and projection kind '" + variance2 + "' cannot be combined");
        }
    }

    private static VarianceConflictType conflictType(Variance variance, Variance variance2) {
        if (variance == Variance.IN_VARIANCE && variance2 == Variance.OUT_VARIANCE) {
            return VarianceConflictType.OUT_IN_IN_POSITION;
        }
        if (variance == Variance.OUT_VARIANCE && variance2 == Variance.IN_VARIANCE) {
            return VarianceConflictType.IN_IN_OUT_POSITION;
        }
        return VarianceConflictType.NO_CONFLICT;
    }

    private static void assertRecursionDepth(int i, TypeProjection typeProjection, TypeSubstitution typeSubstitution) {
        if (i <= 100) {
            return;
        }
        throw new IllegalStateException("Recursion too deep. Most likely infinite loop while substituting " + safeToString(typeProjection) + "; substitution: " + safeToString(typeSubstitution));
    }

    private static String safeToString(Object obj) {
        try {
            return obj.toString();
        } catch (Throwable th) {
            if (exceptionUtils.isProcessCanceledException(th)) {
                throw th;
            }
            return "[Exception while computing toString(): " + th + "]";
        }
    }
}
