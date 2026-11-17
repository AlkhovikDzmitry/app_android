package expo.modules.navigationbar;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import com.facebook.react.uimanager.ViewProps;
import expo.modules.core.Promise;
import expo.modules.core.interfaces.services.EventEmitter;
import kotlin.Metadata;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;
import kotlin.jvm.internal.Intrinsics;
import kotlin.jvm.internal.Lambda;

/* compiled from: NavigationBarModule.kt */
@Metadata(m41d1 = {"\u0000\u000e\n\u0000\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\u0010\u0000\u001a\u00020\u00012\u0006\u0010\u0002\u001a\u00020\u0003H\n¢\u0006\u0002\b\u0004"}, m40d2 = {"<anonymous>", "", "it", "Landroid/app/Activity;", "invoke"}, m39k = 3, m38mv = {1, 6, 0}, m36xi = 48)
/* loaded from: classes2.dex */
final class NavigationBarModule$startObserving$1 extends Lambda implements Function1<Activity, Unit> {
    final /* synthetic */ Promise $promise;
    final /* synthetic */ NavigationBarModule this$0;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public NavigationBarModule$startObserving$1(Promise promise, NavigationBarModule navigationBarModule) {
        super(1);
        this.$promise = promise;
        this.this$0 = navigationBarModule;
    }

    @Override // kotlin.jvm.functions.Function1
    public /* bridge */ /* synthetic */ Unit invoke(Activity activity) {
        invoke2(activity);
        return Unit.INSTANCE;
    }

    /* renamed from: invoke */
    public final void invoke2(Activity it) {
        Intrinsics.checkNotNullParameter(it, "it");
        View decorView = it.getWindow().getDecorView();
        Intrinsics.checkNotNullExpressionValue(decorView, "it.window.decorView");
        final NavigationBarModule navigationBarModule = this.this$0;
        decorView.setOnSystemUiVisibilityChangeListener(new View.OnSystemUiVisibilityChangeListener() { // from class: expo.modules.navigationbar.NavigationBarModule$startObserving$1$$ExternalSyntheticLambda0
            @Override // android.view.View.OnSystemUiVisibilityChangeListener
            public final void onSystemUiVisibilityChange(int i) {
                NavigationBarModule$startObserving$1.m446invoke$lambda1(NavigationBarModule.this, i);
            }
        });
        this.$promise.resolve(null);
    }

    /* renamed from: invoke$lambda-1 */
    public static final void m446invoke$lambda1(NavigationBarModule this$0, int i) {
        EventEmitter eventEmitter;
        Intrinsics.checkNotNullParameter(this$0, "this$0");
        String str = (i & 2) == 0 ? ViewProps.VISIBLE : ViewProps.HIDDEN;
        eventEmitter = this$0.mEventEmitter;
        if (eventEmitter == null) {
            Intrinsics.throwUninitializedPropertyAccessException("mEventEmitter");
            eventEmitter = null;
        }
        Bundle bundle = new Bundle();
        bundle.putString("visibility", str);
        bundle.putInt("rawVisibility", i);
        Unit unit = Unit.INSTANCE;
        eventEmitter.emit("ExpoNavigationBar.didChange", bundle);
    }
}
