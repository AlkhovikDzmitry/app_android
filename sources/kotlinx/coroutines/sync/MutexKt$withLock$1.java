package kotlinx.coroutines.sync;

import kotlin.Metadata;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.jvm.internal.ContinuationImpl;
import kotlin.coroutines.jvm.internal.DebugMetadata;

/* compiled from: Mutex.kt */
@Metadata(m39k = 3, m38mv = {1, 6, 0}, m36xi = 176)
@DebugMetadata(m32c = "kotlinx.coroutines.sync.MutexKt", m31f = "Mutex.kt", m30i = {0, 0, 0}, m29l = {112}, m28m = "withLock", m27n = {"$this$withLock", "owner", "action"}, m26s = {"L$0", "L$1", "L$2"})
/* loaded from: classes3.dex */
public final class MutexKt$withLock$1<T> extends ContinuationImpl {
    Object L$0;
    Object L$1;
    Object L$2;
    int label;
    /* synthetic */ Object result;

    public MutexKt$withLock$1(Continuation<? super MutexKt$withLock$1> continuation) {
        super(continuation);
    }

    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    public final Object invokeSuspend(Object obj) {
        this.result = obj;
        this.label |= Integer.MIN_VALUE;
        return MutexKt.withLock(null, null, null, this);
    }
}
