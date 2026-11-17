package kotlin.reflect.full;

import kotlin.Metadata;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.jvm.internal.ContinuationImpl;
import kotlin.coroutines.jvm.internal.DebugMetadata;

/* compiled from: KCallables.kt */
@Metadata(m39k = 3, m38mv = {1, 6, 0}, m36xi = 48)
@DebugMetadata(m32c = "kotlin.reflect.full.KCallables", m31f = "KCallables.kt", m30i = {0, 0, 0}, m29l = {74}, m28m = "callSuspendBy", m27n = {"$this$callSuspendBy", "args", "kCallable"}, m26s = {"L$0", "L$1", "L$2"})
/* loaded from: classes2.dex */
public final class KCallables$callSuspendBy$1<R> extends ContinuationImpl {
    Object L$0;
    Object L$1;
    Object L$2;
    int label;
    /* synthetic */ Object result;

    public KCallables$callSuspendBy$1(Continuation<? super KCallables$callSuspendBy$1> continuation) {
        super(continuation);
    }

    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    public final Object invokeSuspend(Object obj) {
        this.result = obj;
        this.label |= Integer.MIN_VALUE;
        return KCallables.callSuspendBy(null, null, this);
    }
}
