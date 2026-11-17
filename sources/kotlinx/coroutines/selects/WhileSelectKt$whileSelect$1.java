package kotlinx.coroutines.selects;

import kotlin.Metadata;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.jvm.internal.ContinuationImpl;
import kotlin.coroutines.jvm.internal.DebugMetadata;

/* compiled from: WhileSelect.kt */
@Metadata(m39k = 3, m38mv = {1, 6, 0}, m36xi = 176)
@DebugMetadata(m32c = "kotlinx.coroutines.selects.WhileSelectKt", m31f = "WhileSelect.kt", m30i = {0}, m29l = {37}, m28m = "whileSelect", m27n = {"builder"}, m26s = {"L$0"})
/* loaded from: classes3.dex */
public final class WhileSelectKt$whileSelect$1 extends ContinuationImpl {
    Object L$0;
    int label;
    /* synthetic */ Object result;

    public WhileSelectKt$whileSelect$1(Continuation<? super WhileSelectKt$whileSelect$1> continuation) {
        super(continuation);
    }

    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    public final Object invokeSuspend(Object obj) {
        this.result = obj;
        this.label |= Integer.MIN_VALUE;
        return WhileSelect.whileSelect(null, this);
    }
}
