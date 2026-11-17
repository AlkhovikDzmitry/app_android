package by.gto.android;

import android.os.Build;
import android.os.Bundle;
import com.facebook.react.ReactActivity;
import com.facebook.react.ReactActivityDelegate;
import com.facebook.react.ReactRootView;
import expo.modules.ReactActivityDelegateWrapper;

/* loaded from: classes.dex */
public class MainActivity extends ReactActivity {
    @Override // com.facebook.react.ReactActivity
    protected String getMainComponentName() {
        return "main";
    }

    @Override // com.facebook.react.ReactActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    public void onCreate(Bundle bundle) {
        setTheme(C0773R.style.AppTheme);
        super.onCreate(null);
    }

    @Override // com.facebook.react.ReactActivity
    protected ReactActivityDelegate createReactActivityDelegate() {
        return new ReactActivityDelegateWrapper(this, false, new MainActivityDelegate(this, getMainComponentName()));
    }

    @Override // com.facebook.react.ReactActivity, com.facebook.react.modules.core.DefaultHardwareBackBtnHandler
    public void invokeDefaultOnBackPressed() {
        if (Build.VERSION.SDK_INT <= 30) {
            if (moveTaskToBack(false)) {
                return;
            }
            super.invokeDefaultOnBackPressed();
            return;
        }
        super.invokeDefaultOnBackPressed();
    }

    /* loaded from: classes.dex */
    public static class MainActivityDelegate extends ReactActivityDelegate {
        @Override // com.facebook.react.ReactActivityDelegate
        protected boolean isConcurrentRootEnabled() {
            return false;
        }

        public MainActivityDelegate(ReactActivity reactActivity, String str) {
            super(reactActivity, str);
        }

        @Override // com.facebook.react.ReactActivityDelegate
        protected ReactRootView createRootView() {
            ReactRootView reactRootView = new ReactRootView(getContext());
            reactRootView.setIsFabric(false);
            return reactRootView;
        }
    }
}
