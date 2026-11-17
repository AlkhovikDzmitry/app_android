package androidx.lifecycle;

import android.view.View;
import kotlin.Metadata;
import kotlin.jvm.internal.Intrinsics;

@Metadata(m42bv = {1, 0, 3}, m41d1 = {"\u0000\f\n\u0000\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\u001a\f\u0010\u0000\u001a\u0004\u0018\u00010\u0001*\u00020\u0002¨\u0006\u0003"}, m40d2 = {"findViewTreeViewModelStoreOwner", "Landroidx/lifecycle/ViewModelStoreOwner;", "Landroid/view/View;", "lifecycle-viewmodel-ktx_release"}, m39k = 2, m38mv = {1, 4, 1})
/* renamed from: androidx.lifecycle.ViewTreeViewModelKt */
/* loaded from: classes.dex */
public final class ViewTreeViewModel {
    public static final ViewModelStoreOwner findViewTreeViewModelStoreOwner(View findViewTreeViewModelStoreOwner) {
        Intrinsics.checkNotNullParameter(findViewTreeViewModelStoreOwner, "$this$findViewTreeViewModelStoreOwner");
        return ViewTreeViewModelStoreOwner.get(findViewTreeViewModelStoreOwner);
    }
}
