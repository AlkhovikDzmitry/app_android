package kotlinx.coroutines.channels;

import kotlin.Metadata;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.jvm.internal.ContinuationImpl;
import kotlin.coroutines.jvm.internal.DebugMetadata;

/* compiled from: Deprecated.kt */
@Metadata(m39k = 3, m38mv = {1, 6, 0}, m36xi = 48)
@DebugMetadata(m32c = "kotlinx.coroutines.channels.ChannelsKt__DeprecatedKt", m31f = "Deprecated.kt", m30i = {0, 0, 1, 1, 1}, m29l = {97, 100}, m28m = "last", m27n = {"$this$consume$iv", "iterator", "$this$consume$iv", "iterator", "last"}, m26s = {"L$0", "L$1", "L$0", "L$1", "L$2"})
/* loaded from: classes3.dex */
public final class ChannelsKt__DeprecatedKt$last$1<E> extends ContinuationImpl {
    Object L$0;
    Object L$1;
    Object L$2;
    int label;
    /* synthetic */ Object result;

    public ChannelsKt__DeprecatedKt$last$1(Continuation<? super ChannelsKt__DeprecatedKt$last$1> continuation) {
        super(continuation);
    }

    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    public final Object invokeSuspend(Object obj) {
        Object last;
        this.result = obj;
        this.label |= Integer.MIN_VALUE;
        last = Deprecated.last(null, this);
        return last;
    }
}
