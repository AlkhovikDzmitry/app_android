package kotlin.reflect.jvm.internal.impl.types;

import kotlin.jvm.internal.Intrinsics;
import kotlin.reflect.jvm.internal.impl.descriptors.ClassifierDescriptor;
import kotlin.reflect.jvm.internal.impl.descriptors.DeclarationDescriptor;
import kotlin.reflect.jvm.internal.impl.descriptors.ModuleDescriptor;
import kotlin.reflect.jvm.internal.impl.descriptors.PackageFragmentDescriptor;
import kotlin.reflect.jvm.internal.impl.resolve.DescriptorUtils;

/* compiled from: ClassifierBasedTypeConstructor.kt */
/* loaded from: classes3.dex */
public abstract class ClassifierBasedTypeConstructor implements TypeConstructor {
    private int hashCode;

    @Override // kotlin.reflect.jvm.internal.impl.types.TypeConstructor
    /* renamed from: getDeclarationDescriptor */
    public abstract ClassifierDescriptor mo1755getDeclarationDescriptor();

    protected abstract boolean isSameClassifier(ClassifierDescriptor classifierDescriptor);

    public int hashCode() {
        int identityHashCode;
        int i = this.hashCode;
        if (i != 0) {
            return i;
        }
        ClassifierDescriptor mo1755getDeclarationDescriptor = mo1755getDeclarationDescriptor();
        if (hasMeaningfulFqName(mo1755getDeclarationDescriptor)) {
            identityHashCode = DescriptorUtils.getFqName(mo1755getDeclarationDescriptor).hashCode();
        } else {
            identityHashCode = System.identityHashCode(this);
        }
        this.hashCode = identityHashCode;
        return identityHashCode;
    }

    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if ((obj instanceof TypeConstructor) && obj.hashCode() == hashCode()) {
            TypeConstructor typeConstructor = (TypeConstructor) obj;
            if (typeConstructor.getParameters().size() != getParameters().size()) {
                return false;
            }
            ClassifierDescriptor mo1755getDeclarationDescriptor = mo1755getDeclarationDescriptor();
            ClassifierDescriptor mo1755getDeclarationDescriptor2 = typeConstructor.mo1755getDeclarationDescriptor();
            if (mo1755getDeclarationDescriptor2 != null && hasMeaningfulFqName(mo1755getDeclarationDescriptor) && hasMeaningfulFqName(mo1755getDeclarationDescriptor2)) {
                return isSameClassifier(mo1755getDeclarationDescriptor2);
            }
            return false;
        }
        return false;
    }

    public final boolean areFqNamesEqual(ClassifierDescriptor first, ClassifierDescriptor second) {
        Intrinsics.checkNotNullParameter(first, "first");
        Intrinsics.checkNotNullParameter(second, "second");
        if (Intrinsics.areEqual(first.getName(), second.getName())) {
            DeclarationDescriptor containingDeclaration = first.getContainingDeclaration();
            for (DeclarationDescriptor containingDeclaration2 = second.getContainingDeclaration(); containingDeclaration != null && containingDeclaration2 != null; containingDeclaration2 = containingDeclaration2.getContainingDeclaration()) {
                if (containingDeclaration instanceof ModuleDescriptor) {
                    return containingDeclaration2 instanceof ModuleDescriptor;
                }
                if (containingDeclaration2 instanceof ModuleDescriptor) {
                    return false;
                }
                if (containingDeclaration instanceof PackageFragmentDescriptor) {
                    return (containingDeclaration2 instanceof PackageFragmentDescriptor) && Intrinsics.areEqual(((PackageFragmentDescriptor) containingDeclaration).getFqName(), ((PackageFragmentDescriptor) containingDeclaration2).getFqName());
                } else if ((containingDeclaration2 instanceof PackageFragmentDescriptor) || !Intrinsics.areEqual(containingDeclaration.getName(), containingDeclaration2.getName())) {
                    return false;
                } else {
                    containingDeclaration = containingDeclaration.getContainingDeclaration();
                }
            }
            return true;
        }
        return false;
    }

    private final boolean hasMeaningfulFqName(ClassifierDescriptor classifierDescriptor) {
        ClassifierDescriptor classifierDescriptor2 = classifierDescriptor;
        return (ErrorUtils.isError(classifierDescriptor2) || DescriptorUtils.isLocal(classifierDescriptor2)) ? false : true;
    }
}
