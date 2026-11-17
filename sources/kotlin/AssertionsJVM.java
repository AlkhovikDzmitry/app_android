package kotlin;

import com.reactcommunity.rndatetimepicker.RNConstants;
import kotlin.jvm.functions.Functions;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: Access modifiers changed from: package-private */
@Metadata(m41d1 = {"\u0000\u0018\n\u0000\n\u0002\u0010\u0002\n\u0000\n\u0002\u0010\u000b\n\u0000\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\u001a\u0011\u0010\u0000\u001a\u00020\u00012\u0006\u0010\u0002\u001a\u00020\u0003H\u0087\b\u001a\"\u0010\u0000\u001a\u00020\u00012\u0006\u0010\u0002\u001a\u00020\u00032\f\u0010\u0004\u001a\b\u0012\u0004\u0012\u00020\u00060\u0005H\u0087\bø\u0001\u0000\u0082\u0002\u0007\n\u0005\b\u009920\u0001¨\u0006\u0007"}, m40d2 = {"assert", "", RNConstants.ARG_VALUE, "", "lazyMessage", "Lkotlin/Function0;", "", "kotlin-stdlib"}, m39k = 5, m38mv = {1, 7, 1}, m36xi = 49, m35xs = "kotlin/PreconditionsKt")
/* renamed from: kotlin.PreconditionsKt__AssertionsJVMKt */
/* loaded from: classes2.dex */
public class AssertionsJVM {
    /* renamed from: assert */
    private static final void m464assert(boolean z) {
    }

    /* renamed from: assert */
    private static final void m465assert(boolean z, Functions<? extends Object> lazyMessage) {
        Intrinsics.checkNotNullParameter(lazyMessage, "lazyMessage");
    }
}
