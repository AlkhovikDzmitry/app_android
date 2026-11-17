package kotlinx.coroutines.channels;

import kotlin.Metadata;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.jvm.internal.ContinuationImpl;
import kotlin.coroutines.jvm.internal.DebugMetadata;

/* compiled from: Deprecated.kt */
@Metadata(m39k = 3, m38mv = {1, 6, 0}, m36xi = 48)
@DebugMetadata(m32c = "kotlinx.coroutines.channels.ChannelsKt__DeprecatedKt", m31f = "Deprecated.kt", m30i = {0, 0}, m29l = {65}, m28m = "first", m27n = {"$this$consume$iv", "iterator"}, m26s = {"L$0", "L$1"})
/* loaded from: classes3.dex */
public final class ChannelsKt__DeprecatedKt$first$1<E> extends ContinuationImpl {
    Object L$0;
    Object L$1;
    int label;
    /* synthetic */ Object result;

    public ChannelsKt__DeprecatedKt$first$1(Continuation<? super ChannelsKt__DeprecatedKt$first$1> continuation) {
        super(continuation);
    }

    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    public final Object invokeSuspend(Object obj) {
        Object first;
        this.result = obj;
        this.label |= Integer.MIN_VALUE;
        first = Deprecated.first(null, this);
        return first;
    }
}
