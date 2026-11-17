package kotlinx.coroutines.debug.internal;

import kotlin.Metadata;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.jvm.internal.ContinuationImpl;
import kotlin.coroutines.jvm.internal.DebugMetadata;

/* compiled from: DebugCoroutineInfoImpl.kt */
@Metadata(m39k = 3, m38mv = {1, 6, 0}, m36xi = 48)
@DebugMetadata(m32c = "kotlinx.coroutines.debug.internal.DebugCoroutineInfoImpl", m31f = "DebugCoroutineInfoImpl.kt", m30i = {}, m29l = {80}, m28m = "yieldFrames", m27n = {}, m26s = {})
/* loaded from: classes3.dex */
public final class DebugCoroutineInfoImpl$yieldFrames$1 extends ContinuationImpl {
    Object L$0;
    Object L$1;
    Object L$2;
    int label;
    /* synthetic */ Object result;
    final /* synthetic */ DebugCoroutineInfoImpl this$0;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public DebugCoroutineInfoImpl$yieldFrames$1(DebugCoroutineInfoImpl debugCoroutineInfoImpl, Continuation<? super DebugCoroutineInfoImpl$yieldFrames$1> continuation) {
        super(continuation);
        this.this$0 = debugCoroutineInfoImpl;
    }

    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    public final Object invokeSuspend(Object obj) {
        Object yieldFrames;
        this.result = obj;
        this.label |= Integer.MIN_VALUE;
        yieldFrames = this.this$0.yieldFrames(null, null, this);
        return yieldFrames;
    }
}
