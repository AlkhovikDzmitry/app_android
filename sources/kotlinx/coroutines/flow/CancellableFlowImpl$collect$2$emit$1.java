package kotlinx.coroutines.flow;

import kotlin.Metadata;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.jvm.internal.ContinuationImpl;
import kotlin.coroutines.jvm.internal.DebugMetadata;

/* compiled from: Context.kt */
@Metadata(m39k = 3, m38mv = {1, 6, 0}, m36xi = 48)
@DebugMetadata(m32c = "kotlinx.coroutines.flow.CancellableFlowImpl$collect$2", m31f = "Context.kt", m30i = {}, m29l = {275}, m28m = "emit", m27n = {}, m26s = {})
/* loaded from: classes3.dex */
public final class CancellableFlowImpl$collect$2$emit$1 extends ContinuationImpl {
    int label;
    /* synthetic */ Object result;
    final /* synthetic */ CancellableFlowImpl$collect$2<T> this$0;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    /* JADX WARN: Multi-variable type inference failed */
    public CancellableFlowImpl$collect$2$emit$1(CancellableFlowImpl$collect$2<? super T> cancellableFlowImpl$collect$2, Continuation<? super CancellableFlowImpl$collect$2$emit$1> continuation) {
        super(continuation);
        this.this$0 = cancellableFlowImpl$collect$2;
    }

    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    public final Object invokeSuspend(Object obj) {
        this.result = obj;
        this.label |= Integer.MIN_VALUE;
        return this.this$0.emit(null, this);
    }
}
