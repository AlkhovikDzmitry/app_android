package expo.modules.device;

import android.app.UiModeManager;
import android.content.Context;
import android.content.pm.FeatureInfo;
import android.os.Build;
import android.os.SystemClock;
import android.provider.Settings;
import android.util.DisplayMetrics;
import android.view.WindowManager;
import com.facebook.device.yearclass.YearClass;
import expo.modules.core.utilities.EmulatorUtilities;
import expo.modules.device.DeviceModule;
import expo.modules.kotlin.Promise;
import expo.modules.kotlin.exception.CommonExceptions;
import expo.modules.kotlin.functions.AsyncFunctionComponent;
import expo.modules.kotlin.functions.AsyncFunctionWithPromiseComponent;
import expo.modules.kotlin.modules.Module;
import expo.modules.kotlin.modules.ModuleDefinitionBuilder;
import expo.modules.kotlin.modules.ModuleDefinitionData;
import expo.modules.kotlin.types.AnyType;
import expo.modules.kotlin.types.AnyTypeKt;
import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import kotlin.Metadata;
import kotlin.Unit;
import kotlin.collections.ArraysKt;
import kotlin.collections.CollectionsKt;
import kotlin.jvm.functions.Function1;
import kotlin.jvm.functions.Function2;
import kotlin.jvm.functions.Functions;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;
import kotlin.jvm.internal.Reflection;
import kotlin.text.StringsKt;

/* compiled from: DeviceModule.kt */
@Metadata(m41d1 = {"\u0000,\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0002\b\u0003\n\u0002\u0010\b\n\u0002\b\u0003\n\u0002\u0010\u000e\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0002\b\u0003\u0018\u0000 \u00112\u00020\u0001:\u0002\u0011\u0012B\u0005¢\u0006\u0002\u0010\u0002J\b\u0010\u000f\u001a\u00020\u0010H\u0016R\u0014\u0010\u0003\u001a\u00020\u00048BX\u0082\u0004¢\u0006\u0006\u001a\u0004\b\u0005\u0010\u0006R\u0014\u0010\u0007\u001a\u00020\b8BX\u0082\u0004¢\u0006\u0006\u001a\u0004\b\t\u0010\nR\u0014\u0010\u000b\u001a\u00020\f8BX\u0082\u0004¢\u0006\u0006\u001a\u0004\b\r\u0010\u000e¨\u0006\u0013"}, m40d2 = {"Lexpo/modules/device/DeviceModule;", "Lexpo/modules/kotlin/modules/Module;", "()V", "context", "Landroid/content/Context;", "getContext", "()Landroid/content/Context;", "deviceYearClass", "", "getDeviceYearClass", "()I", "systemName", "", "getSystemName", "()Ljava/lang/String;", "definition", "Lexpo/modules/kotlin/modules/ModuleDefinitionData;", "Companion", "DeviceType", "expo-device_release"}, m39k = 1, m38mv = {1, 6, 0}, m36xi = 48)
/* loaded from: classes2.dex */
public final class DeviceModule extends Module {
    public static final Companion Companion = new Companion(null);
    private static final String TAG = "DeviceModule";

    /* compiled from: DeviceModule.kt */
    @Metadata(m41d1 = {"\u0000\u0012\n\u0002\u0018\u0002\n\u0002\u0010\u0010\n\u0000\n\u0002\u0010\b\n\u0002\b\t\b\u0086\u0001\u0018\u00002\b\u0012\u0004\u0012\u00020\u00000\u0001B\u000f\b\u0002\u0012\u0006\u0010\u0002\u001a\u00020\u0003¢\u0006\u0002\u0010\u0004R\u0011\u0010\u0002\u001a\u00020\u0003¢\u0006\b\n\u0000\u001a\u0004\b\u0005\u0010\u0006j\u0002\b\u0007j\u0002\b\bj\u0002\b\tj\u0002\b\nj\u0002\b\u000b¨\u0006\f"}, m40d2 = {"Lexpo/modules/device/DeviceModule$DeviceType;", "", "JSValue", "", "(Ljava/lang/String;II)V", "getJSValue", "()I", "UNKNOWN", "PHONE", "TABLET", "DESKTOP", "TV", "expo-device_release"}, m39k = 1, m38mv = {1, 6, 0}, m36xi = 48)
    /* loaded from: classes2.dex */
    public enum DeviceType {
        UNKNOWN(0),
        PHONE(1),
        TABLET(2),
        DESKTOP(3),
        TV(4);
        
        private final int JSValue;

        DeviceType(int i) {
            this.JSValue = i;
        }

        public final int getJSValue() {
            return this.JSValue;
        }
    }

    public final Context getContext() {
        Context reactContext = getAppContext().getReactContext();
        if (reactContext != null) {
            return reactContext;
        }
        throw new CommonExceptions.ReactContextLost();
    }

    @Override // expo.modules.kotlin.modules.Module
    public ModuleDefinitionData definition() {
        AsyncFunctionComponent asyncFunctionComponent;
        final ModuleDefinitionBuilder moduleDefinitionBuilder = new ModuleDefinitionBuilder(this);
        moduleDefinitionBuilder.Name("ExpoDevice");
        moduleDefinitionBuilder.Constants(new Functions<Map<String, ? extends Object>>() { // from class: expo.modules.device.DeviceModule$definition$1$1
            /* JADX INFO: Access modifiers changed from: package-private */
            /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
            {
                super(0);
            }

            @Override // kotlin.jvm.functions.Functions
            /*
                Code decompiled incorrectly, please refer to instructions dump.
                To view partially-correct code enable 'Show inconsistent code' option in preferences
            */
            public final java.util.Map<java.lang.String, ? extends java.lang.Object> invoke() {
                /*
                    Method dump skipped, instructions count: 306
                    To view this dump change 'Code comments level' option to 'DEBUG'
                */
                throw new UnsupportedOperationException("Method not decompiled: expo.modules.device.DeviceModule$definition$1$1.invoke():java.util.Map");
            }
        });
        ModuleDefinitionBuilder moduleDefinitionBuilder2 = moduleDefinitionBuilder;
        moduleDefinitionBuilder2.getAsyncFunctions().put("getDeviceTypeAsync", new AsyncFunctionComponent("getDeviceTypeAsync", new AnyType[0], new Function1<Object[], Object>() { // from class: expo.modules.device.DeviceModule$definition$lambda-8$$inlined$AsyncFunctionWithoutArgs$1
            {
                super(1);
            }

            @Override // kotlin.jvm.functions.Function1
            public final Object invoke(Object[] it) {
                Context context;
                DeviceModule.DeviceType deviceType;
                Intrinsics.checkNotNullParameter(it, "it");
                DeviceModule.Companion companion = DeviceModule.Companion;
                context = DeviceModule.this.getContext();
                deviceType = companion.getDeviceType(context);
                return Integer.valueOf(deviceType.getJSValue());
            }
        }));
        moduleDefinitionBuilder2.getAsyncFunctions().put("getUptimeAsync", new AsyncFunctionComponent("getUptimeAsync", new AnyType[0], new Function1<Object[], Object>() { // from class: expo.modules.device.DeviceModule$definition$lambda-8$$inlined$AsyncFunctionWithoutArgs$2
            @Override // kotlin.jvm.functions.Function1
            public final Object invoke(Object[] it) {
                Intrinsics.checkNotNullParameter(it, "it");
                return Double.valueOf(SystemClock.uptimeMillis());
            }
        }));
        moduleDefinitionBuilder2.getAsyncFunctions().put("getMaxMemoryAsync", new AsyncFunctionComponent("getMaxMemoryAsync", new AnyType[0], new Function1<Object[], Object>() { // from class: expo.modules.device.DeviceModule$definition$lambda-8$$inlined$AsyncFunctionWithoutArgs$3
            @Override // kotlin.jvm.functions.Function1
            public final Object invoke(Object[] it) {
                Intrinsics.checkNotNullParameter(it, "it");
                long maxMemory = Runtime.getRuntime().maxMemory();
                if (maxMemory != Long.MAX_VALUE) {
                    return Double.valueOf(maxMemory);
                }
                return -1;
            }
        }));
        moduleDefinitionBuilder2.getAsyncFunctions().put("isRootedExperimentalAsync", new AsyncFunctionComponent("isRootedExperimentalAsync", new AnyType[0], new Function1<Object[], Object>() { // from class: expo.modules.device.DeviceModule$definition$lambda-8$$inlined$AsyncFunctionWithoutArgs$4
            @Override // kotlin.jvm.functions.Function1
            public final Object invoke(Object[] it) {
                boolean isRunningOnEmulator;
                Intrinsics.checkNotNullParameter(it, "it");
                isRunningOnEmulator = DeviceModule.Companion.isRunningOnEmulator();
                boolean z = true;
                boolean z2 = !isRunningOnEmulator;
                String str = Build.TAGS;
                if ((!z2 || str == null || !StringsKt.contains$default((CharSequence) str, (CharSequence) "test-keys", false, 2, (Object) null)) && !new File("/system/app/Superuser.apk").exists() && (!z2 || !new File("/system/xbin/su").exists())) {
                    z = false;
                }
                return Boolean.valueOf(z);
            }
        }));
        moduleDefinitionBuilder2.getAsyncFunctions().put("isSideLoadingEnabledAsync", new AsyncFunctionComponent("isSideLoadingEnabledAsync", new AnyType[0], new Function1<Object[], Object>() { // from class: expo.modules.device.DeviceModule$definition$lambda-8$$inlined$AsyncFunctionWithoutArgs$5
            {
                super(1);
            }

            @Override // kotlin.jvm.functions.Function1
            public final Object invoke(Object[] it) {
                Context context;
                Context context2;
                Intrinsics.checkNotNullParameter(it, "it");
                boolean z = true;
                if (Build.VERSION.SDK_INT < 26) {
                    context2 = DeviceModule.this.getContext();
                    if (Settings.Global.getInt(context2.getApplicationContext().getContentResolver(), "install_non_market_apps", 0) != 1) {
                        z = false;
                    }
                } else {
                    context = DeviceModule.this.getContext();
                    z = context.getApplicationContext().getPackageManager().canRequestPackageInstalls();
                }
                return Boolean.valueOf(z);
            }
        }));
        moduleDefinitionBuilder2.getAsyncFunctions().put("getPlatformFeaturesAsync", new AsyncFunctionComponent("getPlatformFeaturesAsync", new AnyType[0], new Function1<Object[], Object>() { // from class: expo.modules.device.DeviceModule$definition$lambda-8$$inlined$AsyncFunctionWithoutArgs$6
            {
                super(1);
            }

            @Override // kotlin.jvm.functions.Function1
            public final Object invoke(Object[] it) {
                Context context;
                Intrinsics.checkNotNullParameter(it, "it");
                context = DeviceModule.this.getContext();
                FeatureInfo[] systemAvailableFeatures = context.getApplicationContext().getPackageManager().getSystemAvailableFeatures();
                Intrinsics.checkNotNullExpressionValue(systemAvailableFeatures, "context.applicationConte…r.systemAvailableFeatures");
                List<FeatureInfo> filterNotNull = ArraysKt.filterNotNull(systemAvailableFeatures);
                ArrayList arrayList = new ArrayList(CollectionsKt.collectionSizeOrDefault(filterNotNull, 10));
                for (FeatureInfo featureInfo : filterNotNull) {
                    arrayList.add(featureInfo.name);
                }
                return arrayList;
            }
        }));
        if (Intrinsics.areEqual(Reflection.getOrCreateKotlinClass(String.class), Reflection.getOrCreateKotlinClass(Promise.class))) {
            asyncFunctionComponent = new AsyncFunctionWithPromiseComponent("hasPlatformFeatureAsync", new AnyType[0], new Function2<Object[], Promise, Unit>() { // from class: expo.modules.device.DeviceModule$definition$lambda-8$$inlined$AsyncFunction$1
                {
                    super(2);
                }

                /* renamed from: invoke  reason: avoid collision after fix types in other method */
                public final void invoke2(Object[] noName_0, Promise promise) {
                    Context context;
                    Intrinsics.checkNotNullParameter(noName_0, "$noName_0");
                    Intrinsics.checkNotNullParameter(promise, "promise");
                    context = DeviceModule.this.getContext();
                    context.getApplicationContext().getPackageManager().hasSystemFeature((String) promise);
                }

                @Override // kotlin.jvm.functions.Function2
                public /* bridge */ /* synthetic */ Unit invoke(Object[] objArr, Promise promise) {
                    invoke2(objArr, promise);
                    return Unit.INSTANCE;
                }
            });
        } else {
            asyncFunctionComponent = new AsyncFunctionComponent("hasPlatformFeatureAsync", new AnyType[]{AnyTypeKt.toAnyType(Reflection.typeOf(String.class))}, new Function1<Object[], Object>() { // from class: expo.modules.device.DeviceModule$definition$lambda-8$$inlined$AsyncFunction$2
                {
                    super(1);
                }

                @Override // kotlin.jvm.functions.Function1
                public final Object invoke(Object[] it) {
                    Context context;
                    Intrinsics.checkNotNullParameter(it, "it");
                    Object obj = it[0];
                    Objects.requireNonNull(obj, "null cannot be cast to non-null type kotlin.String");
                    context = DeviceModule.this.getContext();
                    return Boolean.valueOf(context.getApplicationContext().getPackageManager().hasSystemFeature((String) obj));
                }
            });
        }
        moduleDefinitionBuilder2.getAsyncFunctions().put("hasPlatformFeatureAsync", asyncFunctionComponent);
        return moduleDefinitionBuilder.buildModule();
    }

    public final int getDeviceYearClass() {
        return YearClass.get(getContext());
    }

    public final String getSystemName() {
        if (Build.VERSION.SDK_INT < 23) {
            return "Android";
        }
        String it = Build.VERSION.BASE_OS;
        Intrinsics.checkNotNullExpressionValue(it, "it");
        if (!(it.length() > 0)) {
            it = null;
        }
        return it == null ? "Android" : it;
    }

    /* compiled from: DeviceModule.kt */
    @Metadata(m41d1 = {"\u0000(\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0002\n\u0002\u0010\u000e\n\u0002\b\u0002\n\u0002\u0010\u000b\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\b\u0086\u0003\u0018\u00002\u00020\u0001B\u0007\b\u0002¢\u0006\u0002\u0010\u0002J\u0010\u0010\t\u001a\u00020\n2\u0006\u0010\u000b\u001a\u00020\fH\u0002R\u0016\u0010\u0003\u001a\n \u0005*\u0004\u0018\u00010\u00040\u0004X\u0082\u0004¢\u0006\u0002\n\u0000R\u0014\u0010\u0006\u001a\u00020\u00078BX\u0082\u0004¢\u0006\u0006\u001a\u0004\b\u0006\u0010\b¨\u0006\r"}, m40d2 = {"Lexpo/modules/device/DeviceModule$Companion;", "", "()V", "TAG", "", "kotlin.jvm.PlatformType", "isRunningOnEmulator", "", "()Z", "getDeviceType", "Lexpo/modules/device/DeviceModule$DeviceType;", "context", "Landroid/content/Context;", "expo-device_release"}, m39k = 1, m38mv = {1, 6, 0}, m36xi = 48)
    /* loaded from: classes2.dex */
    public static final class Companion {
        public /* synthetic */ Companion(DefaultConstructorMarker defaultConstructorMarker) {
            this();
        }

        private Companion() {
        }

        public final boolean isRunningOnEmulator() {
            return EmulatorUtilities.INSTANCE.isRunningOnEmulator();
        }

        public final DeviceType getDeviceType(Context context) {
            if (context.getApplicationContext().getPackageManager().hasSystemFeature("amazon.hardware.fire_tv")) {
                return DeviceType.TV;
            }
            UiModeManager uiModeManager = (UiModeManager) context.getSystemService("uimode");
            if (uiModeManager != null && uiModeManager.getCurrentModeType() == 4) {
                return DeviceType.TV;
            }
            WindowManager windowManager = (WindowManager) context.getSystemService("window");
            if (windowManager == null) {
                return DeviceType.UNKNOWN;
            }
            DisplayMetrics displayMetrics = new DisplayMetrics();
            windowManager.getDefaultDisplay().getMetrics(displayMetrics);
            double sqrt = Math.sqrt(Math.pow(displayMetrics.widthPixels / displayMetrics.xdpi, 2.0d) + Math.pow(displayMetrics.heightPixels / displayMetrics.ydpi, 2.0d));
            boolean z = false;
            if (3.0d <= sqrt && sqrt <= 6.9d) {
                z = true;
            }
            if (z) {
                return DeviceType.PHONE;
            }
            if (sqrt > 6.9d && sqrt <= 18.0d) {
                return DeviceType.TABLET;
            }
            return DeviceType.UNKNOWN;
        }
    }
}
