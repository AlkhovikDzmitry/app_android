package by.gto.android.newarchitecture.modules;

import com.facebook.jni.HybridData;
import com.facebook.react.ReactPackage;
import com.facebook.react.ReactPackageTurboModuleManagerDelegate;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.soloader.SoLoader;
import java.util.List;

/* loaded from: classes.dex */
public class MainApplicationTurboModuleManagerDelegate extends ReactPackageTurboModuleManagerDelegate {
    private static volatile boolean sIsSoLibraryLoaded;

    native boolean canCreateTurboModule(String str);

    @Override // com.facebook.react.turbomodule.core.TurboModuleManagerDelegate
    protected native HybridData initHybrid();

    protected MainApplicationTurboModuleManagerDelegate(ReactApplicationContext reactApplicationContext, List<ReactPackage> list) {
        super(reactApplicationContext, list);
    }

    /* loaded from: classes.dex */
    public static class Builder extends ReactPackageTurboModuleManagerDelegate.Builder {
        @Override // com.facebook.react.ReactPackageTurboModuleManagerDelegate.Builder
        public /* bridge */ /* synthetic */ ReactPackageTurboModuleManagerDelegate build(ReactApplicationContext reactApplicationContext, List list) {
            return build(reactApplicationContext, (List<ReactPackage>) list);
        }

        @Override // com.facebook.react.ReactPackageTurboModuleManagerDelegate.Builder
        public MainApplicationTurboModuleManagerDelegate build(ReactApplicationContext reactApplicationContext, List<ReactPackage> list) {
            return new MainApplicationTurboModuleManagerDelegate(reactApplicationContext, list);
        }
    }

    @Override // com.facebook.react.turbomodule.core.TurboModuleManagerDelegate
    protected synchronized void maybeLoadOtherSoLibraries() {
        if (!sIsSoLibraryLoaded) {
            SoLoader.loadLibrary("beltech_appmodules");
            sIsSoLibraryLoaded = true;
        }
    }
}
