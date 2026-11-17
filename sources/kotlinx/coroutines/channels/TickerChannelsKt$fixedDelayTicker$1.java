package kotlinx.coroutines.channels;

import kotlin.Metadata;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.jvm.internal.ContinuationImpl;
import kotlin.coroutines.jvm.internal.DebugMetadata;

/* compiled from: TickerChannels.kt */
@Metadata(m39k = 3, m38mv = {1, 6, 0}, m36xi = 48)
@DebugMetadata(m32c = "kotlinx.coroutines.channels.TickerChannelsKt", m31f = "TickerChannels.kt", m30i = {0, 0, 1, 1, 2, 2}, m29l = {106, 108, 109}, m28m = "fixedDelayTicker", m27n = {"channel", "delayMillis", "channel", "delayMillis", "channel", "delayMillis"}, m26s = {"L$0", "J$0", "L$0", "J$0", "L$0", "J$0"})
/* loaded from: classes3.dex */
public final class TickerChannelsKt$fixedDelayTicker$1 extends ContinuationImpl {
    long J$0;
    Object L$0;
    int label;
    /* synthetic */ Object result;

    public TickerChannelsKt$fixedDelayTicker$1(Continuation<? super TickerChannelsKt$fixedDelayTicker$1> continuation) {
        super(continuation);
    }

    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    public final Object invokeSuspend(Object obj) {
        Object fixedDelayTicker;
        this.result = obj;
        this.label |= Integer.MIN_VALUE;
        fixedDelayTicker = TickerChannels.fixedDelayTicker(0L, 0L, null, this);
        return fixedDelayTicker;
    }
}
