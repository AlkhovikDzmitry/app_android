package expo.modules.core.logging;

import kotlin.Metadata;
import kotlin.ResultKt;
import kotlin.Unit;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.intrinsics.IntrinsicsKt;
import kotlin.coroutines.jvm.internal.DebugMetadata;
import kotlin.coroutines.jvm.internal.SuspendLambda;
import kotlin.jvm.functions.Function2;
import kotlin.jvm.functions.Functions;
import kotlinx.coroutines.CoroutineScope;
import kotlinx.coroutines.channels.Channel;

/* compiled from: PersistentFileLogSerialDispatchQueue.kt */
@Metadata(m41d1 = {"\u0000\n\n\u0000\n\u0002\u0010\u0002\n\u0002\u0018\u0002\u0010\u0000\u001a\u00020\u0001*\u00020\u0002H\u008a@"}, m40d2 = {"<anonymous>", "", "Lkotlinx/coroutines/CoroutineScope;"}, m39k = 3, m38mv = {1, 6, 0}, m36xi = 48)
@DebugMetadata(m32c = "expo.modules.core.logging.PersistentFileLogSerialDispatchQueue$add$1", m31f = "PersistentFileLogSerialDispatchQueue.kt", m30i = {}, m29l = {15}, m28m = "invokeSuspend", m27n = {}, m26s = {})
/* loaded from: classes2.dex */
public final class PersistentFileLogSerialDispatchQueue$add$1 extends SuspendLambda implements Function2<CoroutineScope, Continuation<? super Unit>, Object> {
    final /* synthetic */ Functions<Unit> $block;
    int label;
    final /* synthetic */ PersistentFileLogSerialDispatchQueue this$0;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public PersistentFileLogSerialDispatchQueue$add$1(PersistentFileLogSerialDispatchQueue persistentFileLogSerialDispatchQueue, Functions<Unit> functions, Continuation<? super PersistentFileLogSerialDispatchQueue$add$1> continuation) {
        super(2, continuation);
        this.this$0 = persistentFileLogSerialDispatchQueue;
        this.$block = functions;
    }

    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    public final Continuation<Unit> create(Object obj, Continuation<?> continuation) {
        return new PersistentFileLogSerialDispatchQueue$add$1(this.this$0, this.$block, continuation);
    }

    @Override // kotlin.jvm.functions.Function2
    public final Object invoke(CoroutineScope coroutineScope, Continuation<? super Unit> continuation) {
        return ((PersistentFileLogSerialDispatchQueue$add$1) create(coroutineScope, continuation)).invokeSuspend(Unit.INSTANCE);
    }

    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    public final Object invokeSuspend(Object obj) {
        Channel channel;
        Object coroutine_suspended = IntrinsicsKt.getCOROUTINE_SUSPENDED();
        int i = this.label;
        if (i == 0) {
            ResultKt.throwOnFailure(obj);
            channel = this.this$0.channel;
            this.label = 1;
            if (channel.send(this.$block, this) == coroutine_suspended) {
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
