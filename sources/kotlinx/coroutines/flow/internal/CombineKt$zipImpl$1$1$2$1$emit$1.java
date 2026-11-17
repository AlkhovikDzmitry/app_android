package kotlinx.coroutines.flow.internal;

import kotlin.Metadata;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.jvm.internal.ContinuationImpl;
import kotlin.coroutines.jvm.internal.DebugMetadata;
import kotlinx.coroutines.flow.internal.CombineKt$zipImpl$1$1;

/* compiled from: Combine.kt */
@Metadata(m39k = 3, m38mv = {1, 6, 0}, m36xi = 48)
@DebugMetadata(m32c = "kotlinx.coroutines.flow.internal.CombineKt$zipImpl$1$1$2$1", m31f = "Combine.kt", m30i = {}, m29l = {131}, m28m = "emit", m27n = {}, m26s = {})
/* loaded from: classes3.dex */
public final class CombineKt$zipImpl$1$1$2$1$emit$1 extends ContinuationImpl {
    int label;
    /* synthetic */ Object result;
    final /* synthetic */ CombineKt$zipImpl$1$1.C23562.C23571<T> this$0;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    /* JADX WARN: Multi-variable type inference failed */
    public CombineKt$zipImpl$1$1$2$1$emit$1(CombineKt$zipImpl$1$1.C23562.C23571<? super T> c23571, Continuation<? super CombineKt$zipImpl$1$1$2$1$emit$1> continuation) {
        super(continuation);
        this.this$0 = c23571;
    }

    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    public final Object invokeSuspend(Object obj) {
        this.result = obj;
        this.label |= Integer.MIN_VALUE;
        return this.this$0.emit(null, this);
    }
}
