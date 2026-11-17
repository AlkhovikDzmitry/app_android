package expo.modules.kotlin.functions;

import kotlin.Metadata;
import kotlin.ResultKt;
import kotlin.Unit;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.intrinsics.IntrinsicsKt;
import kotlin.coroutines.jvm.internal.DebugMetadata;
import kotlin.coroutines.jvm.internal.SuspendLambda;
import kotlin.jvm.functions.Function3;
import kotlin.jvm.functions.Function6;
import kotlin.jvm.internal.InlineMarker;
import kotlin.jvm.internal.Intrinsics;
import kotlinx.coroutines.CoroutineScope;

/* compiled from: AsyncFunctionBuilder.kt */
@Metadata(m41d1 = {"\u0000\u0016\n\u0000\n\u0002\u0010\u0000\n\u0002\b\u0006\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0011\n\u0000\u0010\u0000\u001a\u0004\u0018\u00010\u0001\"\u0006\b\u0000\u0010\u0002\u0018\u0001\"\u0006\b\u0001\u0010\u0003\u0018\u0001\"\u0006\b\u0002\u0010\u0004\u0018\u0001\"\u0006\b\u0003\u0010\u0005\u0018\u0001\"\u0006\b\u0004\u0010\u0006\u0018\u0001\"\u0006\b\u0005\u0010\u0007\u0018\u0001*\u00020\b2\u0010\u0010\t\u001a\f\u0012\b\b\u0001\u0012\u0004\u0018\u00010\u00010\nH\u008a@¨\u0006\u000b"}, m40d2 = {"<anonymous>", "", "R", "P0", "P1", "P2", "P3", "P4", "Lkotlinx/coroutines/CoroutineScope;", "it", "", "expo/modules/kotlin/functions/AsyncFunctionBuilder$SuspendBody$11"}, m39k = 3, m38mv = {1, 6, 0}, m36xi = 176)
@DebugMetadata(m32c = "expo.modules.kotlin.functions.AsyncFunctionBuilderKt$Coroutine$$inlined$SuspendBody$6", m31f = "AsyncFunctionBuilder.kt", m30i = {}, m29l = {44}, m28m = "invokeSuspend", m27n = {}, m26s = {})
/* loaded from: classes2.dex */
public final class AsyncFunctionBuilderKt$Coroutine$$inlined$SuspendBody$6 extends SuspendLambda implements Function3<CoroutineScope, Object[], Continuation<? super Object>, Object> {
    final /* synthetic */ Function6 $block;
    /* synthetic */ Object L$0;
    int label;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public AsyncFunctionBuilderKt$Coroutine$$inlined$SuspendBody$6(Function6 function6, Continuation continuation) {
        super(3, continuation);
        this.$block = function6;
    }

    @Override // kotlin.jvm.functions.Function3
    public /* bridge */ /* synthetic */ Object invoke(CoroutineScope coroutineScope, Object[] objArr, Continuation<? super Object> continuation) {
        return invoke2(coroutineScope, objArr, (Continuation<Object>) continuation);
    }

    /* renamed from: invoke */
    public final Object invoke2(CoroutineScope coroutineScope, Object[] objArr, Continuation<Object> continuation) {
        AsyncFunctionBuilderKt$Coroutine$$inlined$SuspendBody$6 asyncFunctionBuilderKt$Coroutine$$inlined$SuspendBody$6 = new AsyncFunctionBuilderKt$Coroutine$$inlined$SuspendBody$6(this.$block, continuation);
        asyncFunctionBuilderKt$Coroutine$$inlined$SuspendBody$6.L$0 = objArr;
        return asyncFunctionBuilderKt$Coroutine$$inlined$SuspendBody$6.invokeSuspend(Unit.INSTANCE);
    }

    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    public final Object invokeSuspend(Object obj) {
        Object coroutine_suspended = IntrinsicsKt.getCOROUTINE_SUSPENDED();
        int i = this.label;
        if (i == 0) {
            ResultKt.throwOnFailure(obj);
            Object[] objArr = (Object[]) this.L$0;
            Function6 function6 = this.$block;
            Object obj2 = objArr[0];
            Intrinsics.reifiedOperationMarker(1, "P0");
            Object obj3 = objArr[1];
            Intrinsics.reifiedOperationMarker(1, "P1");
            Object obj4 = objArr[2];
            Intrinsics.reifiedOperationMarker(1, "P2");
            Object obj5 = objArr[3];
            Intrinsics.reifiedOperationMarker(1, "P3");
            Object obj6 = objArr[4];
            Intrinsics.reifiedOperationMarker(1, "P4");
            this.label = 1;
            obj = function6.invoke(obj2, obj3, obj4, obj5, obj6, this);
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
        Object[] objArr = (Object[]) this.L$0;
        Function6 function6 = this.$block;
        Object obj2 = objArr[0];
        Intrinsics.reifiedOperationMarker(1, "P0");
        Object obj3 = objArr[1];
        Intrinsics.reifiedOperationMarker(1, "P1");
        Object obj4 = objArr[2];
        Intrinsics.reifiedOperationMarker(1, "P2");
        Object obj5 = objArr[3];
        Intrinsics.reifiedOperationMarker(1, "P3");
        Object obj6 = objArr[4];
        Intrinsics.reifiedOperationMarker(1, "P4");
        InlineMarker.mark(0);
        Object invoke = function6.invoke(obj2, obj3, obj4, obj5, obj6, this);
        InlineMarker.mark(1);
        return invoke;
    }
}
