package kotlin.reflect.jvm.internal.impl.descriptors.runtime.components;

import kotlin.jvm.internal.Intrinsics;
import kotlin.reflect.jvm.internal.impl.name.ClassId;
import kotlin.text.StringsKt;
import kotlin.text.Typography;
import org.apache.commons.p018io.FilenameUtils;

/* compiled from: ReflectKotlinClassFinder.kt */
/* loaded from: classes2.dex */
public final class ReflectKotlinClassFinderKt {
    public static final String toRuntimeFqName(ClassId classId) {
        String asString = classId.getRelativeClassName().asString();
        Intrinsics.checkNotNullExpressionValue(asString, "relativeClassName.asString()");
        String replace$default = StringsKt.replace$default(asString, (char) FilenameUtils.EXTENSION_SEPARATOR, (char) Typography.dollar, false, 4, (Object) null);
        if (classId.getPackageFqName().isRoot()) {
            return replace$default;
        }
        return classId.getPackageFqName() + FilenameUtils.EXTENSION_SEPARATOR + replace$default;
    }
}
