package kotlinx.coroutines.channels;

import kotlin.Metadata;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.jvm.internal.ContinuationImpl;
import kotlin.coroutines.jvm.internal.DebugMetadata;

/* compiled from: Deprecated.kt */
@Metadata(m39k = 3, m38mv = {1, 6, 0}, m36xi = 48)
@DebugMetadata(m32c = "kotlinx.coroutines.channels.ChannelsKt__DeprecatedKt", m31f = "Deprecated.kt", m30i = {0, 0}, m29l = {487}, m28m = "count", m27n = {"count", "$this$consume$iv$iv"}, m26s = {"L$0", "L$1"})
/* loaded from: classes3.dex */
public final class ChannelsKt__DeprecatedKt$count$1<E> extends ContinuationImpl {
    Object L$0;
    Object L$1;
    Object L$2;
    int label;
    /* synthetic */ Object result;

    public ChannelsKt__DeprecatedKt$count$1(Continuation<? super ChannelsKt__DeprecatedKt$count$1> continuation) {
        super(continuation);
    }

    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    public final Object invokeSuspend(Object obj) {
        Object count;
        this.result = obj;
        this.label |= Integer.MIN_VALUE;
        count = Deprecated.count(null, this);
        return count;
    }
}
