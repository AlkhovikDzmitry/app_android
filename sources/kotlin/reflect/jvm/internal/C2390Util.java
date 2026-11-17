package kotlin.reflect.jvm.internal;

/* JADX INFO: Access modifiers changed from: package-private */
/* renamed from: kotlin.reflect.jvm.internal.Util */
/* loaded from: classes2.dex */
public class C2390Util {
    public static Object getEnumConstantByName(Class<? extends Enum<?>> cls, String str) {
        return Enum.valueOf(cls, str);
    }
}
