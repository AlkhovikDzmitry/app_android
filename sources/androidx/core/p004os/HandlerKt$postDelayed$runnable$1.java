package androidx.core.p004os;

import kotlin.Metadata;
import kotlin.Unit;
import kotlin.jvm.functions.Functions;

/* compiled from: Handler.kt */
@Metadata(m41d1 = {"\u0000\u0006\n\u0000\n\u0002\u0010\u0002\u0010\u0000\u001a\u00020\u0001H\n"}, m40d2 = {"<anonymous>", ""}, m39k = 3, m38mv = {1, 5, 1}, m36xi = 48)
/* renamed from: androidx.core.os.HandlerKt$postDelayed$runnable$1 */
/* loaded from: classes.dex */
public final class HandlerKt$postDelayed$runnable$1 implements Runnable {
    final /* synthetic */ Functions<Unit> $action;

    public HandlerKt$postDelayed$runnable$1(Functions<Unit> functions) {
        this.$action = functions;
    }

    @Override // java.lang.Runnable
    public final void run() {
        this.$action.invoke();
    }
}
