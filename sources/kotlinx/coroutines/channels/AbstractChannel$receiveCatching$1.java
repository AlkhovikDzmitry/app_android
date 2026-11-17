package kotlinx.coroutines.channels;

import kotlin.Metadata;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.intrinsics.IntrinsicsKt;
import kotlin.coroutines.jvm.internal.ContinuationImpl;
import kotlin.coroutines.jvm.internal.DebugMetadata;

/* compiled from: AbstractChannel.kt */
@Metadata(m39k = 3, m38mv = {1, 6, 0}, m36xi = 48)
@DebugMetadata(m32c = "kotlinx.coroutines.channels.AbstractChannel", m31f = "AbstractChannel.kt", m30i = {}, m29l = {633}, m28m = "receiveCatching-JP2dKIU", m27n = {}, m26s = {})
/* loaded from: classes3.dex */
public final class AbstractChannel$receiveCatching$1 extends ContinuationImpl {
    int label;
    /* synthetic */ Object result;
    final /* synthetic */ AbstractChannel<E> this$0;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public AbstractChannel$receiveCatching$1(AbstractChannel<E> abstractChannel, Continuation<? super AbstractChannel$receiveCatching$1> continuation) {
        super(continuation);
        this.this$0 = abstractChannel;
    }

    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    public final Object invokeSuspend(Object obj) {
        this.result = obj;
        this.label |= Integer.MIN_VALUE;
        Object mo1978receiveCatchingJP2dKIU = this.this$0.mo1978receiveCatchingJP2dKIU(this);
        return mo1978receiveCatchingJP2dKIU == IntrinsicsKt.getCOROUTINE_SUSPENDED() ? mo1978receiveCatchingJP2dKIU : ChannelResult.m1985boximpl(mo1978receiveCatchingJP2dKIU);
    }
}
