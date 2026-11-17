package androidx.fragment.app;

import androidx.lifecycle.ViewModelStore;
import androidx.lifecycle.ViewModelStoreOwner;
import kotlin.Metadata;
import kotlin.jvm.functions.Functions;
import kotlin.jvm.internal.Intrinsics;
import kotlin.jvm.internal.Lambda;

/* compiled from: FragmentViewModelLazy.kt */
@Metadata(m41d1 = {"\u0000\f\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\u0010\u0000\u001a\u00020\u0001\"\n\b\u0000\u0010\u0002\u0018\u0001*\u00020\u0003H\n"}, m40d2 = {"<anonymous>", "Landroidx/lifecycle/ViewModelStore;", "VM", "Landroidx/lifecycle/ViewModel;"}, m39k = 3, m38mv = {1, 5, 1}, m36xi = 48)
/* loaded from: classes.dex */
public final class FragmentViewModelLazyKt$viewModels$2 extends Lambda implements Functions<ViewModelStore> {
    final /* synthetic */ Functions<ViewModelStoreOwner> $ownerProducer;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    /* JADX WARN: Multi-variable type inference failed */
    public FragmentViewModelLazyKt$viewModels$2(Functions<? extends ViewModelStoreOwner> functions) {
        super(0);
        this.$ownerProducer = functions;
    }

    @Override // kotlin.jvm.functions.Functions
    public final ViewModelStore invoke() {
        ViewModelStore viewModelStore = this.$ownerProducer.invoke().getViewModelStore();
        Intrinsics.checkNotNullExpressionValue(viewModelStore, "ownerProducer().viewModelStore");
        return viewModelStore;
    }
}
