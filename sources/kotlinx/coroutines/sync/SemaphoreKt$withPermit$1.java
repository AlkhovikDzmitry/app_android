package kotlinx.coroutines.sync;

import kotlin.Metadata;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.jvm.internal.ContinuationImpl;
import kotlin.coroutines.jvm.internal.DebugMetadata;

/* compiled from: Semaphore.kt */
@Metadata(m39k = 3, m38mv = {1, 6, 0}, m36xi = 176)
@DebugMetadata(m32c = "kotlinx.coroutines.sync.SemaphoreKt", m31f = "Semaphore.kt", m30i = {0, 0}, m29l = {85}, m28m = "withPermit", m27n = {"$this$withPermit", "action"}, m26s = {"L$0", "L$1"})
/* loaded from: classes3.dex */
public final class SemaphoreKt$withPermit$1<T> extends ContinuationImpl {
    Object L$0;
    Object L$1;
    int label;
    /* synthetic */ Object result;

    public SemaphoreKt$withPermit$1(Continuation<? super SemaphoreKt$withPermit$1> continuation) {
        super(continuation);
    }

    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    public final Object invokeSuspend(Object obj) {
        this.result = obj;
        this.label |= Integer.MIN_VALUE;
        return SemaphoreKt.withPermit(null, null, this);
    }
}
