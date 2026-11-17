package kotlinx.coroutines.flow;

import com.reactcommunity.rndatetimepicker.RNConstants;
import java.util.Collection;
import kotlin.Metadata;
import kotlin.Unit;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.jvm.internal.SuspendFunction;

/* JADX INFO: Access modifiers changed from: package-private */
/* compiled from: Collection.kt */
@Metadata(m41d1 = {"\u0000\u0012\n\u0000\n\u0002\u0010\u0002\n\u0002\b\u0002\n\u0002\u0010\u001f\n\u0002\b\u0003\u0010\u0000\u001a\u00020\u0001\"\u0004\b\u0000\u0010\u0002\"\u0010\b\u0001\u0010\u0003*\n\u0012\u0006\b\u0000\u0012\u0002H\u00020\u00042\u0006\u0010\u0005\u001a\u0002H\u0002H\u008a@¢\u0006\u0004\b\u0006\u0010\u0007"}, m40d2 = {"<anonymous>", "", "T", "C", "", RNConstants.ARG_VALUE, "emit", "(Ljava/lang/Object;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;"}, m39k = 3, m38mv = {1, 6, 0}, m36xi = 48)
/* loaded from: classes3.dex */
public final class FlowKt__CollectionKt$toCollection$2<T> implements FlowCollector, SuspendFunction {
    final /* synthetic */ Collection $destination;

    public FlowKt__CollectionKt$toCollection$2(Collection collection) {
        this.$destination = collection;
    }

    @Override // kotlinx.coroutines.flow.FlowCollector
    public final Object emit(T t, Continuation<? super Unit> continuation) {
        this.$destination.add(t);
        return Unit.INSTANCE;
    }
}
