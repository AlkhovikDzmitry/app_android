package expo.modules.core.logging;

import kotlin.Metadata;
import kotlin.jvm.internal.Intrinsics;

/* compiled from: OSLogHandler.kt */
@Metadata(m41d1 = {"\u0000\b\n\u0000\n\u0002\u0010\u000b\n\u0000\"\u000e\u0010\u0000\u001a\u00020\u0001X\u0082\u0004¢\u0006\u0002\n\u0000¨\u0006\u0002"}, m40d2 = {"isAndroid", "", "expo-modules-core_release"}, m39k = 2, m38mv = {1, 6, 0}, m36xi = 48)
/* loaded from: classes2.dex */
public final class OSLogHandlerKt {
    private static final boolean isAndroid = Intrinsics.areEqual("The Android Project", System.getProperty("java.specification.vendor"));
}
