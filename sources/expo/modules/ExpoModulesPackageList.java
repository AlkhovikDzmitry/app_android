package expo.modules;

import expo.modules.adapters.react.ReactAdapterPackage;
import expo.modules.application.ApplicationPackage;
import expo.modules.constants.ConstantsPackage;
import expo.modules.core.BasePackage;
import expo.modules.core.interfaces.Package;
import expo.modules.device.DeviceModule;
import expo.modules.errorrecovery.ErrorRecoveryPackage;
import expo.modules.filesystem.FileSystemPackage;
import expo.modules.font.FontLoaderPackage;
import expo.modules.keepawake.KeepAwakePackage;
import expo.modules.kotlin.ModulesProvider;
import expo.modules.kotlin.modules.Module;
import expo.modules.lineargradient.LinearGradientModule;
import expo.modules.location.LocationPackage;
import expo.modules.navigationbar.NavigationBarPackage;
import expo.modules.securestore.SecureStorePackage;
import expo.modules.splashscreen.SplashScreenPackage;
import java.util.Arrays;
import java.util.List;

/* loaded from: classes2.dex */
public class ExpoModulesPackageList implements ModulesProvider {

    /* loaded from: classes2.dex */
    private static class LazyHolder {
        static final List<Package> packagesList = Arrays.asList(new ReactAdapterPackage(), new ApplicationPackage(), new ConstantsPackage(), new BasePackage(), new ErrorRecoveryPackage(), new FileSystemPackage(), new FontLoaderPackage(), new KeepAwakePackage(), new LocationPackage(), new NavigationBarPackage(), new SecureStorePackage(), new SplashScreenPackage());
        static final List<Class<? extends Module>> modulesList = Arrays.asList(DeviceModule.class, LinearGradientModule.class);

        private LazyHolder() {
        }
    }

    public static List<Package> getPackageList() {
        return LazyHolder.packagesList;
    }

    @Override // expo.modules.kotlin.ModulesProvider
    public List<Class<? extends Module>> getModulesList() {
        return LazyHolder.modulesList;
    }
}
