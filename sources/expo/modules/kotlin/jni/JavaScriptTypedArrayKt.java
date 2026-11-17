package expo.modules.kotlin.jni;

import kotlin.Metadata;

/* compiled from: JavaScriptTypedArray.kt */
@Metadata(m41d1 = {"\u0000\b\n\u0000\n\u0002\u0010\b\n\u0000\u001a\b\u0010\u0000\u001a\u00020\u0001H\u0002\"\u000e\u0010\u0000\u001a\u00020\u0001X\u0082\u000e¢\u0006\u0002\n\u0000¨\u0006\u0002"}, m40d2 = {"nextValue", "", "expo-modules-core_release"}, m39k = 2, m38mv = {1, 6, 0}, m36xi = 48)
/* loaded from: classes2.dex */
public final class JavaScriptTypedArrayKt {
    private static int nextValue = 1;

    public static final int nextValue() {
        int i = nextValue;
        nextValue = i + 1;
        return i;
    }
}
