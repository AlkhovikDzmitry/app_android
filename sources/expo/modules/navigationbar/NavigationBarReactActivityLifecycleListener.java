package expo.modules.navigationbar;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import expo.modules.core.interfaces.ReactActivityLifecycleListener;
import kotlin.Metadata;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;
import kotlin.text.StringsKt;

/* compiled from: NavigationBarReactActivityLifecycleListener.kt */
@Metadata(m41d1 = {"\u00006\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0010\u000e\n\u0002\b\u0002\n\u0002\u0010\b\n\u0002\b\u0005\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0002\u0018\u0000 \u00142\u00020\u0001:\u0001\u0014B\r\u0012\u0006\u0010\u0002\u001a\u00020\u0003¢\u0006\u0002\u0010\u0004J\u0010\u0010\u0005\u001a\u00020\u00062\u0006\u0010\u0007\u001a\u00020\u0003H\u0002J\u0017\u0010\b\u001a\u0004\u0018\u00010\t2\u0006\u0010\u0007\u001a\u00020\u0003H\u0002¢\u0006\u0002\u0010\nJ\u0010\u0010\u000b\u001a\u00020\u00062\u0006\u0010\u0007\u001a\u00020\u0003H\u0002J\u0010\u0010\f\u001a\u00020\u00062\u0006\u0010\u0007\u001a\u00020\u0003H\u0002J\u0010\u0010\r\u001a\u00020\u00062\u0006\u0010\u0007\u001a\u00020\u0003H\u0002J\u001a\u0010\u000e\u001a\u00020\u000f2\u0006\u0010\u0010\u001a\u00020\u00112\b\u0010\u0012\u001a\u0004\u0018\u00010\u0013H\u0016¨\u0006\u0015"}, m40d2 = {"Lexpo/modules/navigationbar/NavigationBarReactActivityLifecycleListener;", "Lexpo/modules/core/interfaces/ReactActivityLifecycleListener;", "activityContext", "Landroid/content/Context;", "(Landroid/content/Context;)V", "getBehavior", "", "context", "getBorderColor", "", "(Landroid/content/Context;)Ljava/lang/Integer;", "getLegacyVisible", "getPosition", "getVisibility", "onCreate", "", "activity", "Landroid/app/Activity;", "savedInstanceState", "Landroid/os/Bundle;", "Companion", "expo-navigation-bar_release"}, m39k = 1, m38mv = {1, 6, 0}, m36xi = 48)
/* loaded from: classes2.dex */
public final class NavigationBarReactActivityLifecycleListener implements ReactActivityLifecycleListener {
    public static final Companion Companion = new Companion(null);
    private static final String ERROR_TAG = "ERR_NAVIGATION_BAR";

    @Override // expo.modules.core.interfaces.ReactActivityLifecycleListener
    public /* synthetic */ boolean onBackPressed() {
        return ReactActivityLifecycleListener.CC.$default$onBackPressed(this);
    }

    @Override // expo.modules.core.interfaces.ReactActivityLifecycleListener
    public /* synthetic */ void onDestroy(Activity activity) {
        ReactActivityLifecycleListener.CC.$default$onDestroy(this, activity);
    }

    @Override // expo.modules.core.interfaces.ReactActivityLifecycleListener
    public /* synthetic */ boolean onNewIntent(Intent intent) {
        return ReactActivityLifecycleListener.CC.$default$onNewIntent(this, intent);
    }

    @Override // expo.modules.core.interfaces.ReactActivityLifecycleListener
    public /* synthetic */ void onPause(Activity activity) {
        ReactActivityLifecycleListener.CC.$default$onPause(this, activity);
    }

    @Override // expo.modules.core.interfaces.ReactActivityLifecycleListener
    public /* synthetic */ void onResume(Activity activity) {
        ReactActivityLifecycleListener.CC.$default$onResume(this, activity);
    }

    public NavigationBarReactActivityLifecycleListener(Context activityContext) {
        Intrinsics.checkNotNullParameter(activityContext, "activityContext");
    }

    @Override // expo.modules.core.interfaces.ReactActivityLifecycleListener
    public void onCreate(Activity activity, Bundle bundle) {
        Intrinsics.checkNotNullParameter(activity, "activity");
        Activity activity2 = activity;
        Integer borderColor = getBorderColor(activity2);
        if (borderColor != null) {
            NavigationBar.setBorderColor(activity, borderColor.intValue());
        }
        String visibility = getVisibility(activity2);
        if (!Intrinsics.areEqual(visibility, "")) {
            NavigationBar.setVisibility(activity, visibility);
        }
        String position = getPosition(activity2);
        if (!Intrinsics.areEqual(position, "")) {
            NavigationBar.setPosition(activity, position);
        }
        String behavior = getBehavior(activity2);
        if (!Intrinsics.areEqual(behavior, "")) {
            NavigationBar.setBehavior(activity, behavior);
        }
        String legacyVisible = getLegacyVisible(activity2);
        if (Intrinsics.areEqual(legacyVisible, "")) {
            return;
        }
        NavigationBar.setLegacyVisible(activity, legacyVisible);
    }

    private final Integer getBorderColor(Context context) {
        String string = context.getString(C1951R.string.expo_navigation_bar_border_color);
        Intrinsics.checkNotNullExpressionValue(string, "context.getString(R.stri…igation_bar_border_color)");
        Integer intOrNull = StringsKt.toIntOrNull(string);
        if (!Intrinsics.areEqual(string, "") && intOrNull == null) {
            Log.e(ERROR_TAG, "Invalid XML value \"" + string + "\" for string \"expo_navigation_bar_border_color\". Expected a valid color int like \"-12177173\". Ensure the value of \"borderColor\" in the \"expo-navigation-bar\" config plugin is a valid CSS color. Skipping initial border color.");
        }
        return intOrNull;
    }

    private final String getVisibility(Context context) {
        String string = context.getString(C1951R.string.expo_navigation_bar_visibility);
        Intrinsics.checkNotNullExpressionValue(string, "context.getString(R.stri…avigation_bar_visibility)");
        String lowerCase = string.toLowerCase();
        Intrinsics.checkNotNullExpressionValue(lowerCase, "this as java.lang.String).toLowerCase()");
        return lowerCase;
    }

    private final String getPosition(Context context) {
        String string = context.getString(C1951R.string.expo_navigation_bar_position);
        Intrinsics.checkNotNullExpressionValue(string, "context.getString(R.stri…_navigation_bar_position)");
        String lowerCase = string.toLowerCase();
        Intrinsics.checkNotNullExpressionValue(lowerCase, "this as java.lang.String).toLowerCase()");
        return lowerCase;
    }

    private final String getBehavior(Context context) {
        String string = context.getString(C1951R.string.expo_navigation_bar_behavior);
        Intrinsics.checkNotNullExpressionValue(string, "context.getString(R.stri…_navigation_bar_behavior)");
        String lowerCase = string.toLowerCase();
        Intrinsics.checkNotNullExpressionValue(lowerCase, "this as java.lang.String).toLowerCase()");
        return lowerCase;
    }

    private final String getLegacyVisible(Context context) {
        String string = context.getString(C1951R.string.expo_navigation_bar_legacy_visible);
        Intrinsics.checkNotNullExpressionValue(string, "context.getString(R.stri…ation_bar_legacy_visible)");
        String lowerCase = string.toLowerCase();
        Intrinsics.checkNotNullExpressionValue(lowerCase, "this as java.lang.String).toLowerCase()");
        return lowerCase;
    }

    /* compiled from: NavigationBarReactActivityLifecycleListener.kt */
    @Metadata(m41d1 = {"\u0000\u0012\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0002\n\u0002\u0010\u000e\n\u0000\b\u0086\u0003\u0018\u00002\u00020\u0001B\u0007\b\u0002¢\u0006\u0002\u0010\u0002R\u000e\u0010\u0003\u001a\u00020\u0004X\u0082T¢\u0006\u0002\n\u0000¨\u0006\u0005"}, m40d2 = {"Lexpo/modules/navigationbar/NavigationBarReactActivityLifecycleListener$Companion;", "", "()V", "ERROR_TAG", "", "expo-navigation-bar_release"}, m39k = 1, m38mv = {1, 6, 0}, m36xi = 48)
    /* loaded from: classes2.dex */
    public static final class Companion {
        public /* synthetic */ Companion(DefaultConstructorMarker defaultConstructorMarker) {
            this();
        }

        private Companion() {
        }
    }
}
