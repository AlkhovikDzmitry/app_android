package expo.modules.navigationbar;

import android.app.Activity;
import android.os.Build;
import android.util.Log;
import android.view.View;
import androidx.autofill.HintConstants;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;
import com.facebook.react.uimanager.ViewProps;
import expo.modules.core.interfaces.SingletonModule;
import kotlin.Metadata;
import kotlin.Unit;
import kotlin.jvm.JvmStatic;
import kotlin.jvm.functions.Function1;
import kotlin.jvm.functions.Functions;
import kotlin.jvm.internal.Intrinsics;

/* compiled from: NavigationBar.kt */
@Metadata(m41d1 = {"\u00008\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0010\u000e\n\u0002\b\u0002\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\b\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\b\u000e\bÆ\u0002\u0018\u00002\u00020\u0001B\u0007\b\u0002¢\u0006\u0002\u0010\u0002J\b\u0010\u0005\u001a\u00020\u0004H\u0016JG\u0010\u0006\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\t2\u0006\u0010\n\u001a\u00020\u000b2\f\u0010\f\u001a\b\u0012\u0004\u0012\u00020\u00070\r2!\u0010\u000e\u001a\u001d\u0012\u0013\u0012\u00110\u0004¢\u0006\f\b\u0010\u0012\b\b\u0011\u0012\u0004\b\b(\u0012\u0012\u0004\u0012\u00020\u00070\u000fJ\u0018\u0010\u0013\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\t2\u0006\u0010\u0014\u001a\u00020\u0004H\u0007JG\u0010\u0013\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\t2\u0006\u0010\u0014\u001a\u00020\u00042\f\u0010\f\u001a\b\u0012\u0004\u0012\u00020\u00070\r2!\u0010\u000e\u001a\u001d\u0012\u0013\u0012\u00110\u0004¢\u0006\f\b\u0010\u0012\b\b\u0011\u0012\u0004\b\b(\u0012\u0012\u0004\u0012\u00020\u00070\u000fJ\u0018\u0010\u0015\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\t2\u0006\u0010\n\u001a\u00020\u000bH\u0007JG\u0010\u0015\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\t2\u0006\u0010\n\u001a\u00020\u000b2\f\u0010\f\u001a\b\u0012\u0004\u0012\u00020\u00070\r2!\u0010\u000e\u001a\u001d\u0012\u0013\u0012\u00110\u0004¢\u0006\f\b\u0010\u0012\b\b\u0011\u0012\u0004\b\b(\u0012\u0012\u0004\u0012\u00020\u00070\u000fJG\u0010\u0016\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\t2\u0006\u0010\u0017\u001a\u00020\u00042\f\u0010\f\u001a\b\u0012\u0004\u0012\u00020\u00070\r2!\u0010\u000e\u001a\u001d\u0012\u0013\u0012\u00110\u0004¢\u0006\f\b\u0010\u0012\b\b\u0011\u0012\u0004\b\b(\u0012\u0012\u0004\u0012\u00020\u00070\u000fJ\u0018\u0010\u0018\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\t2\u0006\u0010\u0019\u001a\u00020\u0004H\u0007JG\u0010\u0018\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\t2\u0006\u0010\u0019\u001a\u00020\u00042\f\u0010\f\u001a\b\u0012\u0004\u0012\u00020\u00070\r2!\u0010\u000e\u001a\u001d\u0012\u0013\u0012\u00110\u0004¢\u0006\f\b\u0010\u0012\b\b\u0011\u0012\u0004\b\b(\u0012\u0012\u0004\u0012\u00020\u00070\u000fJ\u0018\u0010\u001a\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\t2\u0006\u0010\u001b\u001a\u00020\u0004H\u0007JG\u0010\u001a\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\t2\u0006\u0010\u001b\u001a\u00020\u00042\f\u0010\f\u001a\b\u0012\u0004\u0012\u00020\u00070\r2!\u0010\u000e\u001a\u001d\u0012\u0013\u0012\u00110\u0004¢\u0006\f\b\u0010\u0012\b\b\u0011\u0012\u0004\b\b(\u0012\u0012\u0004\u0012\u00020\u00070\u000fJ\u0018\u0010\u001c\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\t2\u0006\u0010\u001d\u001a\u00020\u0004H\u0007JG\u0010\u001c\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\t2\u0006\u0010\u001d\u001a\u00020\u00042\f\u0010\f\u001a\b\u0012\u0004\u0012\u00020\u00070\r2!\u0010\u000e\u001a\u001d\u0012\u0013\u0012\u00110\u0004¢\u0006\f\b\u0010\u0012\b\b\u0011\u0012\u0004\b\b(\u0012\u0012\u0004\u0012\u00020\u00070\u000fR\u000e\u0010\u0003\u001a\u00020\u0004X\u0082T¢\u0006\u0002\n\u0000¨\u0006\u001e"}, m40d2 = {"Lexpo/modules/navigationbar/NavigationBar;", "Lexpo/modules/core/interfaces/SingletonModule;", "()V", "TAG", "", "getName", "setBackgroundColor", "", "activity", "Landroid/app/Activity;", ViewProps.COLOR, "", "successCallback", "Lkotlin/Function0;", "failureCallback", "Lkotlin/Function1;", "Lkotlin/ParameterName;", HintConstants.AUTOFILL_HINT_NAME, "reason", "setBehavior", "behavior", "setBorderColor", "setButtonStyle", "buttonStyle", "setLegacyVisible", ViewProps.VISIBLE, "setPosition", ViewProps.POSITION, "setVisibility", "visibility", "expo-navigation-bar_release"}, m39k = 1, m38mv = {1, 6, 0}, m36xi = 48)
/* loaded from: classes2.dex */
public final class NavigationBar implements SingletonModule {
    public static final NavigationBar INSTANCE = new NavigationBar();
    private static final String TAG = "NavigationBar";

    @Override // expo.modules.core.interfaces.SingletonModule
    public String getName() {
        return TAG;
    }

    private NavigationBar() {
    }

    public final void setBackgroundColor(Activity activity, int i, Functions<Unit> successCallback, Function1<? super String, Unit> failureCallback) {
        Intrinsics.checkNotNullParameter(activity, "activity");
        Intrinsics.checkNotNullParameter(successCallback, "successCallback");
        Intrinsics.checkNotNullParameter(failureCallback, "failureCallback");
        activity.getWindow().setNavigationBarColor(i);
        successCallback.invoke();
    }

    public final void setButtonStyle(Activity activity, String buttonStyle, Functions<Unit> successCallback, Function1<? super String, Unit> failureCallback) {
        Intrinsics.checkNotNullParameter(activity, "activity");
        Intrinsics.checkNotNullParameter(buttonStyle, "buttonStyle");
        Intrinsics.checkNotNullParameter(successCallback, "successCallback");
        Intrinsics.checkNotNullParameter(failureCallback, "failureCallback");
        WindowInsetsControllerCompat windowInsetsControllerCompat = new WindowInsetsControllerCompat(activity.getWindow(), activity.getWindow().getDecorView());
        if (Intrinsics.areEqual(buttonStyle, "light")) {
            windowInsetsControllerCompat.setAppearanceLightNavigationBars(false);
        } else if (!Intrinsics.areEqual(buttonStyle, "dark")) {
            failureCallback.invoke("Invalid style: \"" + buttonStyle + "\"");
            return;
        } else {
            windowInsetsControllerCompat.setAppearanceLightNavigationBars(true);
        }
        successCallback.invoke();
    }

    public final void setBorderColor(Activity activity, int i, Functions<Unit> successCallback, Function1<? super String, Unit> failureCallback) {
        Intrinsics.checkNotNullParameter(activity, "activity");
        Intrinsics.checkNotNullParameter(successCallback, "successCallback");
        Intrinsics.checkNotNullParameter(failureCallback, "failureCallback");
        if (Build.VERSION.SDK_INT >= 28) {
            activity.getWindow().setNavigationBarDividerColor(i);
            successCallback.invoke();
            return;
        }
        failureCallback.invoke("'setBorderColorAsync' is only available on Android API 28 or higher");
    }

    @JvmStatic
    public static final void setBorderColor(Activity activity, int i) {
        Intrinsics.checkNotNullParameter(activity, "activity");
        INSTANCE.setBorderColor(activity, i, new Functions<Unit>() { // from class: expo.modules.navigationbar.NavigationBar$setBorderColor$1
            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2() {
            }

            @Override // kotlin.jvm.functions.Functions
            public /* bridge */ /* synthetic */ Unit invoke() {
                invoke2();
                return Unit.INSTANCE;
            }
        }, new Function1<String, Unit>() { // from class: expo.modules.navigationbar.NavigationBar$setBorderColor$2
            @Override // kotlin.jvm.functions.Function1
            public /* bridge */ /* synthetic */ Unit invoke(String str) {
                invoke2(str);
                return Unit.INSTANCE;
            }

            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2(String m) {
                Intrinsics.checkNotNullParameter(m, "m");
                Log.e("NavigationBar", m);
            }
        });
    }

    public final void setVisibility(Activity activity, String visibility, Functions<Unit> successCallback, Function1<? super String, Unit> failureCallback) {
        Intrinsics.checkNotNullParameter(activity, "activity");
        Intrinsics.checkNotNullParameter(visibility, "visibility");
        Intrinsics.checkNotNullParameter(successCallback, "successCallback");
        Intrinsics.checkNotNullParameter(failureCallback, "failureCallback");
        WindowInsetsControllerCompat windowInsetsControllerCompat = new WindowInsetsControllerCompat(activity.getWindow(), activity.getWindow().getDecorView());
        if (Intrinsics.areEqual(visibility, ViewProps.VISIBLE)) {
            windowInsetsControllerCompat.show(WindowInsetsCompat.Type.navigationBars());
        } else if (Intrinsics.areEqual(visibility, ViewProps.HIDDEN)) {
            windowInsetsControllerCompat.hide(WindowInsetsCompat.Type.navigationBars());
        } else {
            failureCallback.invoke("Invalid visibility: \"" + visibility + "\"");
            return;
        }
        successCallback.invoke();
    }

    @JvmStatic
    public static final void setVisibility(Activity activity, String visibility) {
        Intrinsics.checkNotNullParameter(activity, "activity");
        Intrinsics.checkNotNullParameter(visibility, "visibility");
        INSTANCE.setVisibility(activity, visibility, new Functions<Unit>() { // from class: expo.modules.navigationbar.NavigationBar$setVisibility$2
            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2() {
            }

            @Override // kotlin.jvm.functions.Functions
            public /* bridge */ /* synthetic */ Unit invoke() {
                invoke2();
                return Unit.INSTANCE;
            }
        }, new Function1<String, Unit>() { // from class: expo.modules.navigationbar.NavigationBar$setVisibility$3
            @Override // kotlin.jvm.functions.Function1
            public /* bridge */ /* synthetic */ Unit invoke(String str) {
                invoke2(str);
                return Unit.INSTANCE;
            }

            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2(String m) {
                Intrinsics.checkNotNullParameter(m, "m");
                Log.e("NavigationBar", m);
            }
        });
    }

    public final void setPosition(Activity activity, String position, Functions<Unit> successCallback, Function1<? super String, Unit> failureCallback) {
        boolean z;
        Intrinsics.checkNotNullParameter(activity, "activity");
        Intrinsics.checkNotNullParameter(position, "position");
        Intrinsics.checkNotNullParameter(successCallback, "successCallback");
        Intrinsics.checkNotNullParameter(failureCallback, "failureCallback");
        if (Intrinsics.areEqual(position, "absolute")) {
            z = false;
        } else if (!Intrinsics.areEqual(position, "relative")) {
            failureCallback.invoke("Invalid position: \"" + position + "\"");
            return;
        } else {
            z = true;
        }
        WindowCompat.setDecorFitsSystemWindows(activity.getWindow(), z);
        if (Build.VERSION.SDK_INT >= 16) {
            activity.getWindow().getDecorView().setFitsSystemWindows(z);
        }
        successCallback.invoke();
    }

    @JvmStatic
    public static final void setPosition(Activity activity, String position) {
        Intrinsics.checkNotNullParameter(activity, "activity");
        Intrinsics.checkNotNullParameter(position, "position");
        INSTANCE.setPosition(activity, position, new Functions<Unit>() { // from class: expo.modules.navigationbar.NavigationBar$setPosition$1
            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2() {
            }

            @Override // kotlin.jvm.functions.Functions
            public /* bridge */ /* synthetic */ Unit invoke() {
                invoke2();
                return Unit.INSTANCE;
            }
        }, new Function1<String, Unit>() { // from class: expo.modules.navigationbar.NavigationBar$setPosition$2
            @Override // kotlin.jvm.functions.Function1
            public /* bridge */ /* synthetic */ Unit invoke(String str) {
                invoke2(str);
                return Unit.INSTANCE;
            }

            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2(String m) {
                Intrinsics.checkNotNullParameter(m, "m");
                Log.e("NavigationBar", m);
            }
        });
    }

    public final void setBehavior(Activity activity, String behavior, Functions<Unit> successCallback, Function1<? super String, Unit> failureCallback) {
        Intrinsics.checkNotNullParameter(activity, "activity");
        Intrinsics.checkNotNullParameter(behavior, "behavior");
        Intrinsics.checkNotNullParameter(successCallback, "successCallback");
        Intrinsics.checkNotNullParameter(failureCallback, "failureCallback");
        WindowInsetsControllerCompat windowInsetsControllerCompat = new WindowInsetsControllerCompat(activity.getWindow(), activity.getWindow().getDecorView());
        int hashCode = behavior.hashCode();
        if (hashCode == -1158014083) {
            if (behavior.equals("overlay-swipe")) {
                windowInsetsControllerCompat.setSystemBarsBehavior(2);
                successCallback.invoke();
                return;
            }
            failureCallback.invoke("Invalid behavior: \"" + behavior + "\"");
        } else if (hashCode == -342250870) {
            if (behavior.equals("inset-swipe")) {
                windowInsetsControllerCompat.setSystemBarsBehavior(1);
                successCallback.invoke();
                return;
            }
            failureCallback.invoke("Invalid behavior: \"" + behavior + "\"");
        } else {
            if (hashCode == -341554545 && behavior.equals("inset-touch")) {
                windowInsetsControllerCompat.setSystemBarsBehavior(0);
                successCallback.invoke();
                return;
            }
            failureCallback.invoke("Invalid behavior: \"" + behavior + "\"");
        }
    }

    @JvmStatic
    public static final void setBehavior(Activity activity, String behavior) {
        Intrinsics.checkNotNullParameter(activity, "activity");
        Intrinsics.checkNotNullParameter(behavior, "behavior");
        INSTANCE.setBehavior(activity, behavior, new Functions<Unit>() { // from class: expo.modules.navigationbar.NavigationBar$setBehavior$2
            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2() {
            }

            @Override // kotlin.jvm.functions.Functions
            public /* bridge */ /* synthetic */ Unit invoke() {
                invoke2();
                return Unit.INSTANCE;
            }
        }, new Function1<String, Unit>() { // from class: expo.modules.navigationbar.NavigationBar$setBehavior$3
            @Override // kotlin.jvm.functions.Function1
            public /* bridge */ /* synthetic */ Unit invoke(String str) {
                invoke2(str);
                return Unit.INSTANCE;
            }

            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2(String m) {
                Intrinsics.checkNotNullParameter(m, "m");
                Log.e("NavigationBar", m);
            }
        });
    }

    public final void setLegacyVisible(Activity activity, String visible, Functions<Unit> successCallback, Function1<? super String, Unit> failureCallback) {
        int i;
        Intrinsics.checkNotNullParameter(activity, "activity");
        Intrinsics.checkNotNullParameter(visible, "visible");
        Intrinsics.checkNotNullParameter(successCallback, "successCallback");
        Intrinsics.checkNotNullParameter(failureCallback, "failureCallback");
        View decorView = activity.getWindow().getDecorView();
        Intrinsics.checkNotNullExpressionValue(decorView, "activity.window.decorView");
        int systemUiVisibility = decorView.getSystemUiVisibility();
        int hashCode = visible.hashCode();
        if (hashCode == -1197068329) {
            if (visible.equals("sticky-immersive")) {
                i = systemUiVisibility | 4102;
                decorView.setSystemUiVisibility(i);
                successCallback.invoke();
                return;
            }
            failureCallback.invoke("Invalid behavior: \"" + visible + "\"");
        } else if (hashCode != 1137617595) {
            if (hashCode == 1570144589 && visible.equals("leanback")) {
                i = systemUiVisibility | 6;
                decorView.setSystemUiVisibility(i);
                successCallback.invoke();
                return;
            }
            failureCallback.invoke("Invalid behavior: \"" + visible + "\"");
        } else {
            if (visible.equals("immersive")) {
                i = systemUiVisibility | 2054;
                decorView.setSystemUiVisibility(i);
                successCallback.invoke();
                return;
            }
            failureCallback.invoke("Invalid behavior: \"" + visible + "\"");
        }
    }

    @JvmStatic
    public static final void setLegacyVisible(Activity activity, String visible) {
        Intrinsics.checkNotNullParameter(activity, "activity");
        Intrinsics.checkNotNullParameter(visible, "visible");
        INSTANCE.setBehavior(activity, visible, new Functions<Unit>() { // from class: expo.modules.navigationbar.NavigationBar$setLegacyVisible$1
            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2() {
            }

            @Override // kotlin.jvm.functions.Functions
            public /* bridge */ /* synthetic */ Unit invoke() {
                invoke2();
                return Unit.INSTANCE;
            }
        }, new Function1<String, Unit>() { // from class: expo.modules.navigationbar.NavigationBar$setLegacyVisible$2
            @Override // kotlin.jvm.functions.Function1
            public /* bridge */ /* synthetic */ Unit invoke(String str) {
                invoke2(str);
                return Unit.INSTANCE;
            }

            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2(String m) {
                Intrinsics.checkNotNullParameter(m, "m");
                Log.e("NavigationBar", m);
            }
        });
    }
}
