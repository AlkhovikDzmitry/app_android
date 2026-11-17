package expo.modules.kotlin.functions;

import kotlin.Metadata;
import kotlin.ResultKt;
import kotlin.Unit;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.intrinsics.IntrinsicsKt;
import kotlin.coroutines.jvm.internal.DebugMetadata;
import kotlin.coroutines.jvm.internal.SuspendLambda;
import kotlin.jvm.functions.Function1;
import kotlin.jvm.functions.Function3;
import kotlin.jvm.internal.InlineMarker;
import kotlinx.coroutines.CoroutineScope;

/* compiled from: AsyncFunctionBuilder.kt */
@Metadata(m41d1 = {"\u0000\u0014\n\u0000\n\u0002\u0010\u0000\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0011\n\u0000\u0010\u0000\u001a\u0004\u0018\u00010\u0001\"\u0006\b\u0000\u0010\u0002\u0018\u0001*\u00020\u00032\u0010\u0010\u0004\u001a\f\u0012\b\b\u0001\u0012\u0004\u0018\u00010\u00010\u0005H\u008a@¨\u0006\u0006"}, m40d2 = {"<anonymous>", "", "R", "Lkotlinx/coroutines/CoroutineScope;", "it", "", "expo/modules/kotlin/functions/AsyncFunctionBuilder$SuspendBody$1"}, m39k = 3, m38mv = {1, 6, 0}, m36xi = 176)
@DebugMetadata(m32c = "expo.modules.kotlin.functions.AsyncFunctionBuilderKt$Coroutine$$inlined$SuspendBody$1", m31f = "AsyncFunctionBuilder.kt", m30i = {}, m29l = {14}, m28m = "invokeSuspend", m27n = {}, m26s = {})
/* loaded from: classes2.dex */
public final class AsyncFunctionBuilderKt$Coroutine$$inlined$SuspendBody$1 extends SuspendLambda implements Function3<CoroutineScope, Object[], Continuation<? super Object>, Object> {
    final /* synthetic */ Function1 $block;
    int label;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public AsyncFunctionBuilderKt$Coroutine$$inlined$SuspendBody$1(Function1 function1, Continuation continuation) {
        super(3, continuation);
        this.$block = function1;
    }

    @Override // kotlin.jvm.functions.Function3
    public /* bridge */ /* synthetic */ Object invoke(CoroutineScope coroutineScope, Object[] objArr, Continuation<? super Object> continuation) {
        return invoke2(coroutineScope, objArr, (Continuation<Object>) continuation);
    }

    /* renamed from: invoke */
    public final Object invoke2(CoroutineScope coroutineScope, Object[] objArr, Continuation<Object> continuation) {
        return new AsyncFunctionBuilderKt$Coroutine$$inlined$SuspendBody$1(this.$block, continuation).invokeSuspend(Unit.INSTANCE);
    }

    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    public final Object invokeSuspend(Object obj) {
        Object coroutine_suspended = IntrinsicsKt.getCOROUTINE_SUSPENDED();
        int i = this.label;
        if (i == 0) {
            ResultKt.throwOnFailure(obj);
            Function1 function1 = this.$block;
            this.label = 1;
            obj = function1.invoke(this);
            if (obj == coroutine_suspended) {
                return coroutine_suspended;
            }
        } else if (i != 1) {
            throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
        } else {
            ResultKt.throwOnFailure(obj);
        }
        return obj;
    }

    public final Object invokeSuspend$$forInline(Object obj) {
        Function1 function1 = this.$block;
        InlineMarker.mark(0);
        Object invoke = function1.invoke(this);
        InlineMarker.mark(1);
        return invoke;
    }
}
