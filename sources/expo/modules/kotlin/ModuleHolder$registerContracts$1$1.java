package expo.modules.kotlin;

import expo.modules.kotlin.activityresult.AppContextActivityResultCaller;
import kotlin.Metadata;
import kotlin.ResultKt;
import kotlin.Unit;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.intrinsics.IntrinsicsKt;
import kotlin.coroutines.jvm.internal.DebugMetadata;
import kotlin.coroutines.jvm.internal.SuspendLambda;
import kotlin.jvm.functions.Function2;
import kotlinx.coroutines.CoroutineScope;

/* compiled from: ModuleHolder.kt */
@Metadata(m41d1 = {"\u0000\n\n\u0000\n\u0002\u0010\u0002\n\u0002\u0018\u0002\u0010\u0000\u001a\u00020\u0001*\u00020\u0002H\u008a@"}, m40d2 = {"<anonymous>", "", "Lkotlinx/coroutines/CoroutineScope;"}, m39k = 3, m38mv = {1, 6, 0}, m36xi = 48)
@DebugMetadata(m32c = "expo.modules.kotlin.ModuleHolder$registerContracts$1$1", m31f = "ModuleHolder.kt", m30i = {}, m29l = {88}, m28m = "invokeSuspend", m27n = {}, m26s = {})
/* loaded from: classes2.dex */
public final class ModuleHolder$registerContracts$1$1 extends SuspendLambda implements Function2<CoroutineScope, Continuation<? super Unit>, Object> {
    final /* synthetic */ Function2<AppContextActivityResultCaller, Continuation<? super Unit>, Object> $it;
    int label;
    final /* synthetic */ ModuleHolder this$0;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    /* JADX WARN: Multi-variable type inference failed */
    public ModuleHolder$registerContracts$1$1(Function2<? super AppContextActivityResultCaller, ? super Continuation<? super Unit>, ? extends Object> function2, ModuleHolder moduleHolder, Continuation<? super ModuleHolder$registerContracts$1$1> continuation) {
        super(2, continuation);
        this.$it = function2;
        this.this$0 = moduleHolder;
    }

    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    public final Continuation<Unit> create(Object obj, Continuation<?> continuation) {
        return new ModuleHolder$registerContracts$1$1(this.$it, this.this$0, continuation);
    }

    @Override // kotlin.jvm.functions.Function2
    public final Object invoke(CoroutineScope coroutineScope, Continuation<? super Unit> continuation) {
        return ((ModuleHolder$registerContracts$1$1) create(coroutineScope, continuation)).invokeSuspend(Unit.INSTANCE);
    }

    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    public final Object invokeSuspend(Object obj) {
        Object coroutine_suspended = IntrinsicsKt.getCOROUTINE_SUSPENDED();
        int i = this.label;
        if (i == 0) {
            ResultKt.throwOnFailure(obj);
            Function2<AppContextActivityResultCaller, Continuation<? super Unit>, Object> function2 = this.$it;
            AppContext appContext = this.this$0.getModule().getAppContext();
            this.label = 1;
            if (function2.invoke(appContext, this) == coroutine_suspended) {
                return coroutine_suspended;
            }
        } else if (i != 1) {
            throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
        } else {
            ResultKt.throwOnFailure(obj);
        }
        return Unit.INSTANCE;
    }
}
