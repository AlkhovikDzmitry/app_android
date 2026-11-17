package expo.modules.navigationbar;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.os.Build;
import android.view.View;
import android.view.WindowInsets;
import androidx.autofill.HintConstants;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsControllerCompat;
import com.facebook.react.bridge.BaseJavaModule;
import com.facebook.react.uimanager.ViewProps;
import expo.modules.core.ExportedModule;
import expo.modules.core.ModuleRegistry;
import expo.modules.core.Promise;
import expo.modules.core.errors.CurrentActivityNotFoundException;
import expo.modules.core.interfaces.ActivityProvider;
import expo.modules.core.interfaces.ExpoMethod;
import expo.modules.core.interfaces.services.EventEmitter;
import java.util.Arrays;
import kotlin.Metadata;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;
import kotlin.jvm.functions.Functions;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;
import kotlin.jvm.internal.StringCompanionObject;

/* compiled from: NavigationBarModule.kt */
@Metadata(m41d1 = {"\u0000T\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0004\n\u0002\u0010\u000e\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\b\u0004\n\u0002\u0010\b\n\u0002\b\u000e\u0018\u0000 ,2\u00020\u0001:\u0001,B\r\u0012\u0006\u0010\u0002\u001a\u00020\u0003¢\u0006\u0002\u0010\u0004J\u0010\u0010\t\u001a\u00020\n2\u0006\u0010\u000b\u001a\u00020\fH\u0007J\u0010\u0010\r\u001a\u00020\n2\u0006\u0010\u000b\u001a\u00020\fH\u0007J\u0010\u0010\u000e\u001a\u00020\n2\u0006\u0010\u000b\u001a\u00020\fH\u0007J\u0010\u0010\u000f\u001a\u00020\n2\u0006\u0010\u000b\u001a\u00020\fH\u0007J\b\u0010\u0010\u001a\u00020\u0011H\u0016J\u0010\u0010\u0012\u001a\u00020\n2\u0006\u0010\u000b\u001a\u00020\fH\u0007J\u0010\u0010\u0013\u001a\u00020\n2\u0006\u0010\u0014\u001a\u00020\u0015H\u0016J3\u0010\u0016\u001a\u00020\n2\u0006\u0010\u000b\u001a\u00020\f2!\u0010\u0017\u001a\u001d\u0012\u0013\u0012\u00110\u0019¢\u0006\f\b\u001a\u0012\b\b\u001b\u0012\u0004\b\b(\u001c\u0012\u0004\u0012\u00020\n0\u0018H\u0002J\u0018\u0010\u001d\u001a\u00020\n2\u0006\u0010\u001e\u001a\u00020\u001f2\u0006\u0010\u000b\u001a\u00020\fH\u0007J\u0018\u0010 \u001a\u00020\n2\u0006\u0010!\u001a\u00020\u00112\u0006\u0010\u000b\u001a\u00020\fH\u0007J\u0018\u0010\"\u001a\u00020\n2\u0006\u0010\u001e\u001a\u00020\u001f2\u0006\u0010\u000b\u001a\u00020\fH\u0007J\u0018\u0010#\u001a\u00020\n2\u0006\u0010$\u001a\u00020\u00112\u0006\u0010\u000b\u001a\u00020\fH\u0007J\u0018\u0010%\u001a\u00020\n2\u0006\u0010&\u001a\u00020\u00112\u0006\u0010\u000b\u001a\u00020\fH\u0007J\u0018\u0010'\u001a\u00020\n2\u0006\u0010(\u001a\u00020\u00112\u0006\u0010\u000b\u001a\u00020\fH\u0007J\u0010\u0010)\u001a\u00020\n2\u0006\u0010\u000b\u001a\u00020\fH\u0007J\u0010\u0010*\u001a\u00020\n2\u0006\u0010\u000b\u001a\u00020\fH\u0007J\u0010\u0010+\u001a\u00020\n2\u0006\u0010\u000b\u001a\u00020\fH\u0007R\u000e\u0010\u0005\u001a\u00020\u0006X\u0082.¢\u0006\u0002\n\u0000R\u000e\u0010\u0007\u001a\u00020\bX\u0082.¢\u0006\u0002\n\u0000¨\u0006-"}, m40d2 = {"Lexpo/modules/navigationbar/NavigationBarModule;", "Lexpo/modules/core/ExportedModule;", "context", "Landroid/content/Context;", "(Landroid/content/Context;)V", "mActivityProvider", "Lexpo/modules/core/interfaces/ActivityProvider;", "mEventEmitter", "Lexpo/modules/core/interfaces/services/EventEmitter;", "getBackgroundColorAsync", "", BaseJavaModule.METHOD_TYPE_PROMISE, "Lexpo/modules/core/Promise;", "getBehaviorAsync", "getBorderColorAsync", "getButtonStyleAsync", "getName", "", "getVisibilityAsync", "onCreate", "moduleRegistry", "Lexpo/modules/core/ModuleRegistry;", "safeRunOnUiThread", "block", "Lkotlin/Function1;", "Landroid/app/Activity;", "Lkotlin/ParameterName;", HintConstants.AUTOFILL_HINT_NAME, "activity", "setBackgroundColorAsync", ViewProps.COLOR, "", "setBehaviorAsync", "behavior", "setBorderColorAsync", "setButtonStyleAsync", "buttonStyle", "setPositionAsync", ViewProps.POSITION, "setVisibilityAsync", "visibility", "startObserving", "stopObserving", "unstable_getPositionAsync", "Companion", "expo-navigation-bar_release"}, m39k = 1, m38mv = {1, 6, 0}, m36xi = 48)
/* loaded from: classes2.dex */
public final class NavigationBarModule extends ExportedModule {
    public static final Companion Companion = new Companion(null);
    private static final String ERROR_TAG = "ERR_NAVIGATION_BAR";
    private static final String NAME = "ExpoNavigationBar";
    private static final String VISIBILITY_EVENT_NAME = "ExpoNavigationBar.didChange";
    private ActivityProvider mActivityProvider;
    private EventEmitter mEventEmitter;

    @Override // expo.modules.core.ExportedModule
    public String getName() {
        return NAME;
    }

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public NavigationBarModule(Context context) {
        super(context);
        Intrinsics.checkNotNullParameter(context, "context");
    }

    @Override // expo.modules.core.ExportedModule, expo.modules.core.interfaces.RegistryLifecycleListener
    public void onCreate(ModuleRegistry moduleRegistry) {
        Intrinsics.checkNotNullParameter(moduleRegistry, "moduleRegistry");
        ActivityProvider activityProvider = (ActivityProvider) moduleRegistry.getModule(ActivityProvider.class);
        if (activityProvider == null) {
            throw new IllegalStateException("Could not find implementation for ActivityProvider.");
        }
        this.mActivityProvider = activityProvider;
        EventEmitter eventEmitter = (EventEmitter) moduleRegistry.getModule(EventEmitter.class);
        if (eventEmitter == null) {
            throw new IllegalStateException("Could not find implementation for EventEmitter.");
        }
        this.mEventEmitter = eventEmitter;
    }

    private final void safeRunOnUiThread(Promise promise, final Function1<? super Activity, Unit> function1) {
        ActivityProvider activityProvider = this.mActivityProvider;
        if (activityProvider == null) {
            Intrinsics.throwUninitializedPropertyAccessException("mActivityProvider");
            activityProvider = null;
        }
        final Activity currentActivity = activityProvider.getCurrentActivity();
        if (currentActivity == null) {
            promise.reject(new CurrentActivityNotFoundException());
        } else {
            currentActivity.runOnUiThread(new Runnable() { // from class: expo.modules.navigationbar.NavigationBarModule$$ExternalSyntheticLambda0
                @Override // java.lang.Runnable
                public final void run() {
                    NavigationBarModule.m445safeRunOnUiThread$lambda0(Function1.this, currentActivity);
                }
            });
        }
    }

    /* renamed from: safeRunOnUiThread$lambda-0 */
    public static final void m445safeRunOnUiThread$lambda0(Function1 block, Activity activity) {
        Intrinsics.checkNotNullParameter(block, "$block");
        Intrinsics.checkNotNullExpressionValue(activity, "activity");
        block.invoke(activity);
    }

    @ExpoMethod
    public final void setBackgroundColorAsync(final int i, final Promise promise) {
        Intrinsics.checkNotNullParameter(promise, "promise");
        safeRunOnUiThread(promise, new Function1<Activity, Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$setBackgroundColorAsync$1
            /* JADX INFO: Access modifiers changed from: package-private */
            /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
            {
                super(1);
            }

            @Override // kotlin.jvm.functions.Function1
            public /* bridge */ /* synthetic */ Unit invoke(Activity activity) {
                invoke2(activity);
                return Unit.INSTANCE;
            }

            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2(Activity it) {
                Intrinsics.checkNotNullParameter(it, "it");
                NavigationBar navigationBar = NavigationBar.INSTANCE;
                int i2 = i;
                final Promise promise2 = promise;
                final Promise promise3 = promise;
                navigationBar.setBackgroundColor(it, i2, new Functions<Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$setBackgroundColorAsync$1.1
                    {
                        super(0);
                    }

                    @Override // kotlin.jvm.functions.Functions
                    public /* bridge */ /* synthetic */ Unit invoke() {
                        invoke2();
                        return Unit.INSTANCE;
                    }

                    /* renamed from: invoke  reason: avoid collision after fix types in other method */
                    public final void invoke2() {
                        Promise.this.resolve(null);
                    }
                }, new Function1<String, Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$setBackgroundColorAsync$1.2
                    {
                        super(1);
                    }

                    @Override // kotlin.jvm.functions.Function1
                    public /* bridge */ /* synthetic */ Unit invoke(String str) {
                        invoke2(str);
                        return Unit.INSTANCE;
                    }

                    /* renamed from: invoke  reason: avoid collision after fix types in other method */
                    public final void invoke2(String m) {
                        Intrinsics.checkNotNullParameter(m, "m");
                        Promise.this.reject("ERR_NAVIGATION_BAR", m);
                    }
                });
            }
        });
    }

    @ExpoMethod
    public final void getBackgroundColorAsync(final Promise promise) {
        Intrinsics.checkNotNullParameter(promise, "promise");
        safeRunOnUiThread(promise, new Function1<Activity, Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$getBackgroundColorAsync$1
            /* JADX INFO: Access modifiers changed from: package-private */
            {
                super(1);
            }

            @Override // kotlin.jvm.functions.Function1
            public /* bridge */ /* synthetic */ Unit invoke(Activity activity) {
                invoke2(activity);
                return Unit.INSTANCE;
            }

            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2(Activity it) {
                Intrinsics.checkNotNullParameter(it, "it");
                Promise.this.resolve(NavigationBarModule.Companion.colorToHex(it.getWindow().getNavigationBarColor()));
            }
        });
    }

    @ExpoMethod
    public final void setBorderColorAsync(final int i, final Promise promise) {
        Intrinsics.checkNotNullParameter(promise, "promise");
        safeRunOnUiThread(promise, new Function1<Activity, Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$setBorderColorAsync$1
            /* JADX INFO: Access modifiers changed from: package-private */
            /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
            {
                super(1);
            }

            @Override // kotlin.jvm.functions.Function1
            public /* bridge */ /* synthetic */ Unit invoke(Activity activity) {
                invoke2(activity);
                return Unit.INSTANCE;
            }

            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2(Activity it) {
                Intrinsics.checkNotNullParameter(it, "it");
                NavigationBar navigationBar = NavigationBar.INSTANCE;
                int i2 = i;
                final Promise promise2 = promise;
                final Promise promise3 = promise;
                navigationBar.setBorderColor(it, i2, new Functions<Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$setBorderColorAsync$1.1
                    {
                        super(0);
                    }

                    @Override // kotlin.jvm.functions.Functions
                    public /* bridge */ /* synthetic */ Unit invoke() {
                        invoke2();
                        return Unit.INSTANCE;
                    }

                    /* renamed from: invoke  reason: avoid collision after fix types in other method */
                    public final void invoke2() {
                        Promise.this.resolve(null);
                    }
                }, new Function1<String, Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$setBorderColorAsync$1.2
                    {
                        super(1);
                    }

                    @Override // kotlin.jvm.functions.Function1
                    public /* bridge */ /* synthetic */ Unit invoke(String str) {
                        invoke2(str);
                        return Unit.INSTANCE;
                    }

                    /* renamed from: invoke  reason: avoid collision after fix types in other method */
                    public final void invoke2(String m) {
                        Intrinsics.checkNotNullParameter(m, "m");
                        Promise.this.reject("ERR_NAVIGATION_BAR", m);
                    }
                });
            }
        });
    }

    @ExpoMethod
    public final void getBorderColorAsync(final Promise promise) {
        Intrinsics.checkNotNullParameter(promise, "promise");
        safeRunOnUiThread(promise, new Function1<Activity, Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$getBorderColorAsync$1
            /* JADX INFO: Access modifiers changed from: package-private */
            {
                super(1);
            }

            @Override // kotlin.jvm.functions.Function1
            public /* bridge */ /* synthetic */ Unit invoke(Activity activity) {
                invoke2(activity);
                return Unit.INSTANCE;
            }

            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2(Activity it) {
                Intrinsics.checkNotNullParameter(it, "it");
                if (Build.VERSION.SDK_INT >= 28) {
                    Promise.this.resolve(NavigationBarModule.Companion.colorToHex(it.getWindow().getNavigationBarDividerColor()));
                    return;
                }
                Promise.this.reject("ERR_NAVIGATION_BAR", "'getBorderColorAsync' is only available on Android API 28 or higher");
            }
        });
    }

    @ExpoMethod
    public final void setButtonStyleAsync(final String buttonStyle, final Promise promise) {
        Intrinsics.checkNotNullParameter(buttonStyle, "buttonStyle");
        Intrinsics.checkNotNullParameter(promise, "promise");
        safeRunOnUiThread(promise, new Function1<Activity, Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$setButtonStyleAsync$1
            /* JADX INFO: Access modifiers changed from: package-private */
            /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
            {
                super(1);
            }

            @Override // kotlin.jvm.functions.Function1
            public /* bridge */ /* synthetic */ Unit invoke(Activity activity) {
                invoke2(activity);
                return Unit.INSTANCE;
            }

            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2(Activity it) {
                Intrinsics.checkNotNullParameter(it, "it");
                NavigationBar navigationBar = NavigationBar.INSTANCE;
                String str = buttonStyle;
                final Promise promise2 = promise;
                final Promise promise3 = promise;
                navigationBar.setButtonStyle(it, str, new Functions<Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$setButtonStyleAsync$1.1
                    {
                        super(0);
                    }

                    @Override // kotlin.jvm.functions.Functions
                    public /* bridge */ /* synthetic */ Unit invoke() {
                        invoke2();
                        return Unit.INSTANCE;
                    }

                    /* renamed from: invoke  reason: avoid collision after fix types in other method */
                    public final void invoke2() {
                        Promise.this.resolve(null);
                    }
                }, new Function1<String, Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$setButtonStyleAsync$1.2
                    {
                        super(1);
                    }

                    @Override // kotlin.jvm.functions.Function1
                    public /* bridge */ /* synthetic */ Unit invoke(String str2) {
                        invoke2(str2);
                        return Unit.INSTANCE;
                    }

                    /* renamed from: invoke  reason: avoid collision after fix types in other method */
                    public final void invoke2(String m) {
                        Intrinsics.checkNotNullParameter(m, "m");
                        Promise.this.reject("ERR_NAVIGATION_BAR", m);
                    }
                });
            }
        });
    }

    @ExpoMethod
    public final void getButtonStyleAsync(final Promise promise) {
        Intrinsics.checkNotNullParameter(promise, "promise");
        safeRunOnUiThread(promise, new Function1<Activity, Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$getButtonStyleAsync$1
            /* JADX INFO: Access modifiers changed from: package-private */
            {
                super(1);
            }

            @Override // kotlin.jvm.functions.Function1
            public /* bridge */ /* synthetic */ Unit invoke(Activity activity) {
                invoke2(activity);
                return Unit.INSTANCE;
            }

            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2(Activity it) {
                Intrinsics.checkNotNullParameter(it, "it");
                Promise.this.resolve(new WindowInsetsControllerCompat(it.getWindow(), it.getWindow().getDecorView()).isAppearanceLightNavigationBars() ? "dark" : "light");
            }
        });
    }

    @ExpoMethod
    public final void setVisibilityAsync(final String visibility, final Promise promise) {
        Intrinsics.checkNotNullParameter(visibility, "visibility");
        Intrinsics.checkNotNullParameter(promise, "promise");
        safeRunOnUiThread(promise, new Function1<Activity, Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$setVisibilityAsync$1
            /* JADX INFO: Access modifiers changed from: package-private */
            /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
            {
                super(1);
            }

            @Override // kotlin.jvm.functions.Function1
            public /* bridge */ /* synthetic */ Unit invoke(Activity activity) {
                invoke2(activity);
                return Unit.INSTANCE;
            }

            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2(Activity it) {
                Intrinsics.checkNotNullParameter(it, "it");
                NavigationBar navigationBar = NavigationBar.INSTANCE;
                String str = visibility;
                final Promise promise2 = promise;
                final Promise promise3 = promise;
                navigationBar.setVisibility(it, str, new Functions<Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$setVisibilityAsync$1.1
                    {
                        super(0);
                    }

                    @Override // kotlin.jvm.functions.Functions
                    public /* bridge */ /* synthetic */ Unit invoke() {
                        invoke2();
                        return Unit.INSTANCE;
                    }

                    /* renamed from: invoke  reason: avoid collision after fix types in other method */
                    public final void invoke2() {
                        Promise.this.resolve(null);
                    }
                }, new Function1<String, Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$setVisibilityAsync$1.2
                    {
                        super(1);
                    }

                    @Override // kotlin.jvm.functions.Function1
                    public /* bridge */ /* synthetic */ Unit invoke(String str2) {
                        invoke2(str2);
                        return Unit.INSTANCE;
                    }

                    /* renamed from: invoke  reason: avoid collision after fix types in other method */
                    public final void invoke2(String m) {
                        Intrinsics.checkNotNullParameter(m, "m");
                        Promise.this.reject("ERR_NAVIGATION_BAR", m);
                    }
                });
            }
        });
    }

    @ExpoMethod
    public final void getVisibilityAsync(final Promise promise) {
        Intrinsics.checkNotNullParameter(promise, "promise");
        safeRunOnUiThread(promise, new Function1<Activity, Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$getVisibilityAsync$1
            /* JADX INFO: Access modifiers changed from: package-private */
            {
                super(1);
            }

            @Override // kotlin.jvm.functions.Function1
            public /* bridge */ /* synthetic */ Unit invoke(Activity activity) {
                invoke2(activity);
                return Unit.INSTANCE;
            }

            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2(Activity it) {
                boolean z;
                Intrinsics.checkNotNullParameter(it, "it");
                if (Build.VERSION.SDK_INT >= 30) {
                    z = it.getWindow().getDecorView().getRootWindowInsets().isVisible(WindowInsets.Type.navigationBars());
                } else {
                    z = (it.getWindow().getDecorView().getSystemUiVisibility() & 2) == 0;
                }
                Promise.this.resolve(z ? ViewProps.VISIBLE : ViewProps.HIDDEN);
            }
        });
    }

    @ExpoMethod
    public final void setPositionAsync(final String position, final Promise promise) {
        Intrinsics.checkNotNullParameter(position, "position");
        Intrinsics.checkNotNullParameter(promise, "promise");
        safeRunOnUiThread(promise, new Function1<Activity, Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$setPositionAsync$1
            /* JADX INFO: Access modifiers changed from: package-private */
            /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
            {
                super(1);
            }

            @Override // kotlin.jvm.functions.Function1
            public /* bridge */ /* synthetic */ Unit invoke(Activity activity) {
                invoke2(activity);
                return Unit.INSTANCE;
            }

            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2(Activity it) {
                Intrinsics.checkNotNullParameter(it, "it");
                NavigationBar navigationBar = NavigationBar.INSTANCE;
                String str = position;
                final Promise promise2 = promise;
                final Promise promise3 = promise;
                navigationBar.setPosition(it, str, new Functions<Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$setPositionAsync$1.1
                    {
                        super(0);
                    }

                    @Override // kotlin.jvm.functions.Functions
                    public /* bridge */ /* synthetic */ Unit invoke() {
                        invoke2();
                        return Unit.INSTANCE;
                    }

                    /* renamed from: invoke  reason: avoid collision after fix types in other method */
                    public final void invoke2() {
                        Promise.this.resolve(null);
                    }
                }, new Function1<String, Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$setPositionAsync$1.2
                    {
                        super(1);
                    }

                    @Override // kotlin.jvm.functions.Function1
                    public /* bridge */ /* synthetic */ Unit invoke(String str2) {
                        invoke2(str2);
                        return Unit.INSTANCE;
                    }

                    /* renamed from: invoke  reason: avoid collision after fix types in other method */
                    public final void invoke2(String m) {
                        Intrinsics.checkNotNullParameter(m, "m");
                        Promise.this.reject("ERR_NAVIGATION_BAR", m);
                    }
                });
            }
        });
    }

    @ExpoMethod
    public final void unstable_getPositionAsync(final Promise promise) {
        Intrinsics.checkNotNullParameter(promise, "promise");
        safeRunOnUiThread(promise, new Function1<Activity, Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$unstable_getPositionAsync$1
            /* JADX INFO: Access modifiers changed from: package-private */
            {
                super(1);
            }

            @Override // kotlin.jvm.functions.Function1
            public /* bridge */ /* synthetic */ Unit invoke(Activity activity) {
                invoke2(activity);
                return Unit.INSTANCE;
            }

            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2(Activity it) {
                Intrinsics.checkNotNullParameter(it, "it");
                Promise.this.resolve(ViewCompat.getFitsSystemWindows(it.getWindow().getDecorView()) ? "relative" : "absolute");
            }
        });
    }

    @ExpoMethod
    public final void setBehaviorAsync(final String behavior, final Promise promise) {
        Intrinsics.checkNotNullParameter(behavior, "behavior");
        Intrinsics.checkNotNullParameter(promise, "promise");
        safeRunOnUiThread(promise, new Function1<Activity, Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$setBehaviorAsync$1
            /* JADX INFO: Access modifiers changed from: package-private */
            /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
            {
                super(1);
            }

            @Override // kotlin.jvm.functions.Function1
            public /* bridge */ /* synthetic */ Unit invoke(Activity activity) {
                invoke2(activity);
                return Unit.INSTANCE;
            }

            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2(Activity it) {
                Intrinsics.checkNotNullParameter(it, "it");
                NavigationBar navigationBar = NavigationBar.INSTANCE;
                String str = behavior;
                final Promise promise2 = promise;
                final Promise promise3 = promise;
                navigationBar.setBehavior(it, str, new Functions<Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$setBehaviorAsync$1.1
                    {
                        super(0);
                    }

                    @Override // kotlin.jvm.functions.Functions
                    public /* bridge */ /* synthetic */ Unit invoke() {
                        invoke2();
                        return Unit.INSTANCE;
                    }

                    /* renamed from: invoke  reason: avoid collision after fix types in other method */
                    public final void invoke2() {
                        Promise.this.resolve(null);
                    }
                }, new Function1<String, Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$setBehaviorAsync$1.2
                    {
                        super(1);
                    }

                    @Override // kotlin.jvm.functions.Function1
                    public /* bridge */ /* synthetic */ Unit invoke(String str2) {
                        invoke2(str2);
                        return Unit.INSTANCE;
                    }

                    /* renamed from: invoke  reason: avoid collision after fix types in other method */
                    public final void invoke2(String m) {
                        Intrinsics.checkNotNullParameter(m, "m");
                        Promise.this.reject("ERR_NAVIGATION_BAR", m);
                    }
                });
            }
        });
    }

    @ExpoMethod
    public final void getBehaviorAsync(final Promise promise) {
        Intrinsics.checkNotNullParameter(promise, "promise");
        safeRunOnUiThread(promise, new Function1<Activity, Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$getBehaviorAsync$1
            /* JADX INFO: Access modifiers changed from: package-private */
            {
                super(1);
            }

            @Override // kotlin.jvm.functions.Function1
            public /* bridge */ /* synthetic */ Unit invoke(Activity activity) {
                invoke2(activity);
                return Unit.INSTANCE;
            }

            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2(Activity it) {
                Intrinsics.checkNotNullParameter(it, "it");
                WindowInsetsControllerCompat windowInsetsControllerCompat = new WindowInsetsControllerCompat(it.getWindow(), it.getWindow().getDecorView());
                Promise promise2 = Promise.this;
                int systemBarsBehavior = windowInsetsControllerCompat.getSystemBarsBehavior();
                promise2.resolve(systemBarsBehavior != 1 ? systemBarsBehavior != 2 ? "inset-touch" : "overlay-swipe" : "inset-swipe");
            }
        });
    }

    @ExpoMethod
    public final void startObserving(Promise promise) {
        Intrinsics.checkNotNullParameter(promise, "promise");
        safeRunOnUiThread(promise, new NavigationBarModule$startObserving$1(promise, this));
    }

    @ExpoMethod
    public final void stopObserving(final Promise promise) {
        Intrinsics.checkNotNullParameter(promise, "promise");
        safeRunOnUiThread(promise, new Function1<Activity, Unit>() { // from class: expo.modules.navigationbar.NavigationBarModule$stopObserving$1
            /* JADX INFO: Access modifiers changed from: package-private */
            {
                super(1);
            }

            @Override // kotlin.jvm.functions.Function1
            public /* bridge */ /* synthetic */ Unit invoke(Activity activity) {
                invoke2(activity);
                return Unit.INSTANCE;
            }

            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2(Activity it) {
                Intrinsics.checkNotNullParameter(it, "it");
                View decorView = it.getWindow().getDecorView();
                Intrinsics.checkNotNullExpressionValue(decorView, "it.window.decorView");
                decorView.setOnSystemUiVisibilityChangeListener(null);
                Promise.this.resolve(null);
            }
        });
    }

    /* compiled from: NavigationBarModule.kt */
    @Metadata(m41d1 = {"\u0000\u001a\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0002\n\u0002\u0010\u000e\n\u0002\b\u0004\n\u0002\u0010\b\n\u0000\b\u0086\u0003\u0018\u00002\u00020\u0001B\u0007\b\u0002¢\u0006\u0002\u0010\u0002J\u000e\u0010\u0007\u001a\u00020\u00042\u0006\u0010\b\u001a\u00020\tR\u000e\u0010\u0003\u001a\u00020\u0004X\u0082T¢\u0006\u0002\n\u0000R\u000e\u0010\u0005\u001a\u00020\u0004X\u0082T¢\u0006\u0002\n\u0000R\u000e\u0010\u0006\u001a\u00020\u0004X\u0082T¢\u0006\u0002\n\u0000¨\u0006\n"}, m40d2 = {"Lexpo/modules/navigationbar/NavigationBarModule$Companion;", "", "()V", "ERROR_TAG", "", "NAME", "VISIBILITY_EVENT_NAME", "colorToHex", ViewProps.COLOR, "", "expo-navigation-bar_release"}, m39k = 1, m38mv = {1, 6, 0}, m36xi = 48)
    /* loaded from: classes2.dex */
    public static final class Companion {
        public /* synthetic */ Companion(DefaultConstructorMarker defaultConstructorMarker) {
            this();
        }

        private Companion() {
        }

        public final String colorToHex(int i) {
            StringCompanionObject stringCompanionObject = StringCompanionObject.INSTANCE;
            String format = String.format("#%02x%02x%02x", Arrays.copyOf(new Object[]{Integer.valueOf(Color.red(i)), Integer.valueOf(Color.green(i)), Integer.valueOf(Color.blue(i))}, 3));
            Intrinsics.checkNotNullExpressionValue(format, "format(format, *args)");
            return format;
        }
    }
}
