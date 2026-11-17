package expo.modules.kotlin.exception;

import kotlin.Metadata;
import kotlin.jvm.internal.Intrinsics;
import kotlin.reflect.KClass;

/* compiled from: CodedException.kt */
@Metadata(m41d1 = {"\u0000\u0012\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0002\b\u0001\u0018\u00002\u00020\u0001B\u0011\u0012\n\u0010\u0002\u001a\u0006\u0012\u0002\b\u00030\u0003¢\u0006\u0002\u0010\u0004¨\u0006\u0005"}, m40d2 = {"Lexpo/modules/kotlin/exception/UnsupportedClass;", "Lexpo/modules/kotlin/exception/CodedException;", "clazz", "Lkotlin/reflect/KClass;", "(Lkotlin/reflect/KClass;)V", "expo-modules-core_release"}, m39k = 1, m38mv = {1, 6, 0}, m36xi = 48)
/* loaded from: classes2.dex */
public final class UnsupportedClass extends CodedException {
    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public UnsupportedClass(KClass<?> clazz) {
        super("Unsupported type: '" + clazz + "'", null, 2, null);
        Intrinsics.checkNotNullParameter(clazz, "clazz");
    }
}
