package expo.modules.kotlin.types;

import kotlin.Metadata;
import kotlin.jvm.internal.Intrinsics;
import kotlin.reflect.KType;

/* compiled from: AnyType.kt */
@Metadata(m41d1 = {"\u0000\f\n\u0000\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\u001a\n\u0010\u0000\u001a\u00020\u0001*\u00020\u0002¨\u0006\u0003"}, m40d2 = {"toAnyType", "Lexpo/modules/kotlin/types/AnyType;", "Lkotlin/reflect/KType;", "expo-modules-core_release"}, m39k = 2, m38mv = {1, 6, 0}, m36xi = 48)
/* loaded from: classes2.dex */
public final class AnyTypeKt {
    public static final AnyType toAnyType(KType kType) {
        Intrinsics.checkNotNullParameter(kType, "<this>");
        return new AnyType(kType);
    }
}
