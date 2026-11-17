package kotlinx.coroutines.flow;

import kotlin.Metadata;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.jvm.internal.ContinuationImpl;
import kotlin.coroutines.jvm.internal.DebugMetadata;

/* compiled from: Errors.kt */
@Metadata(m39k = 3, m38mv = {1, 6, 0}, m36xi = 48)
@DebugMetadata(m32c = "kotlinx.coroutines.flow.FlowKt__ErrorsKt", m31f = "Errors.kt", m30i = {0}, m29l = {156}, m28m = "catchImpl", m27n = {"fromDownstream"}, m26s = {"L$0"})
/* loaded from: classes3.dex */
public final class FlowKt__ErrorsKt$catchImpl$1<T> extends ContinuationImpl {
    Object L$0;
    int label;
    /* synthetic */ Object result;

    public FlowKt__ErrorsKt$catchImpl$1(Continuation<? super FlowKt__ErrorsKt$catchImpl$1> continuation) {
        super(continuation);
    }

    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    public final Object invokeSuspend(Object obj) {
        this.result = obj;
        this.label |= Integer.MIN_VALUE;
        return FlowKt.catchImpl(null, null, this);
    }
}
