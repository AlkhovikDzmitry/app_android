package kotlin.reflect.jvm.internal.impl.load.java;

import kotlin.reflect.jvm.internal.impl.descriptors.ClassDescriptor;
import kotlin.reflect.jvm.internal.impl.resolve.descriptorUtil.DescriptorUtils;

/* compiled from: AnnotationTypeQualifierResolver.kt */
/* loaded from: classes2.dex */
public final class AnnotationTypeQualifierResolverKt {
    public static final boolean isAnnotatedWithTypeQualifier(ClassDescriptor classDescriptor) {
        return AnnotationQualifiersFqNames.getBUILT_IN_TYPE_QUALIFIER_FQ_NAMES().contains(DescriptorUtils.getFqNameSafe(classDescriptor)) || classDescriptor.getAnnotations().hasAnnotation(AnnotationQualifiersFqNames.getTYPE_QUALIFIER_FQNAME());
    }
}
