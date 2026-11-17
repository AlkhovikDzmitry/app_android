package by.gto.android;

import android.app.Application;
import android.content.Context;
import android.content.res.Configuration;
import by.gto.android.newarchitecture.MainApplicationReactNativeHost;
import com.facebook.react.PackageList;
import com.facebook.react.ReactApplication;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.config.ReactFeatureFlags;
import com.facebook.soloader.SoLoader;
import expo.modules.ApplicationLifecycleDispatcher;
import expo.modules.ReactNativeHostWrapper;
import java.util.List;

/* loaded from: classes.dex */
public class MainApplication extends Application implements ReactApplication {
    private final ReactNativeHost mReactNativeHost = new ReactNativeHostWrapper(this, new ReactNativeHost(this) { // from class: by.gto.android.MainApplication.1
        @Override // com.facebook.react.ReactNativeHost
        protected String getJSMainModuleName() {
            return "index";
        }

        @Override // com.facebook.react.ReactNativeHost
        public boolean getUseDeveloperSupport() {
            return false;
        }

        @Override // com.facebook.react.ReactNativeHost
        protected List<ReactPackage> getPackages() {
            return new PackageList(this).getPackages();
        }
    });
    private final ReactNativeHost mNewArchitectureNativeHost = new ReactNativeHostWrapper(this, new MainApplicationReactNativeHost(this));

    private static void initializeFlipper(Context context, ReactInstanceManager reactInstanceManager) {
    }

    @Override // com.facebook.react.ReactApplication
    public ReactNativeHost getReactNativeHost() {
        return this.mReactNativeHost;
    }

    @Override // android.app.Application
    public void onCreate() {
        super.onCreate();
        ReactFeatureFlags.useTurboModules = false;
        SoLoader.init((Context) this, false);
        initializeFlipper(this, getReactNativeHost().getReactInstanceManager());
        ApplicationLifecycleDispatcher.onApplicationCreate(this);
    }

    @Override // android.app.Application, android.content.ComponentCallbacks
    public void onConfigurationChanged(Configuration configuration) {
        super.onConfigurationChanged(configuration);
        ApplicationLifecycleDispatcher.onConfigurationChanged(this, configuration);
    }
}
