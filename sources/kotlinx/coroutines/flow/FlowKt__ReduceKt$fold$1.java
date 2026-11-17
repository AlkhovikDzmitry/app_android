package kotlinx.coroutines.flow;

import kotlin.Metadata;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.jvm.internal.ContinuationImpl;
import kotlin.coroutines.jvm.internal.DebugMetadata;

/* compiled from: Reduce.kt */
@Metadata(m39k = 3, m38mv = {1, 6, 0}, m36xi = 176)
@DebugMetadata(m32c = "kotlinx.coroutines.flow.FlowKt__ReduceKt", m31f = "Reduce.kt", m30i = {0}, m29l = {44}, m28m = "fold", m27n = {"accumulator"}, m26s = {"L$0"})
/* loaded from: classes3.dex */
public final class FlowKt__ReduceKt$fold$1<T, R> extends ContinuationImpl {
    Object L$0;
    int label;
    /* synthetic */ Object result;

    public FlowKt__ReduceKt$fold$1(Continuation<? super FlowKt__ReduceKt$fold$1> continuation) {
        super(continuation);
    }

    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    public final Object invokeSuspend(Object obj) {
        this.result = obj;
        this.label |= Integer.MIN_VALUE;
        return Reduce.fold(null, null, null, this);
    }
}
