package expo.modules.constants;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.util.Log;
import com.facebook.device.yearclass.YearClass;
import expo.modules.core.ModuleRegistry;
import expo.modules.core.interfaces.InternalModule;
import expo.modules.core.interfaces.RegistryLifecycleListener;
import expo.modules.core.utilities.EmulatorUtilities;
import expo.modules.interfaces.constants.ConstantsInterface;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import kotlin.Metadata;
import kotlin.TuplesKt;
import kotlin.collections.CollectionsKt;
import kotlin.collections.MapsKt;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;
import kotlin.p013io.Closeable;
import org.apache.commons.p018io.IOUtils;

/* compiled from: ConstantsService.kt */
@Metadata(m41d1 = {"\u0000L\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0010\u000e\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0010\b\n\u0002\b\u0007\n\u0002\u0010$\n\u0002\u0010\u0000\n\u0002\b\u0003\n\u0002\u0010 \n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u000b\n\u0002\b\u0007\b\u0016\u0018\u0000 #2\u00020\u00012\u00020\u0002:\u0002#$B\r\u0012\u0006\u0010\u0003\u001a\u00020\u0004¢\u0006\u0002\u0010\u0005J\b\u0010\u0013\u001a\u00020\u0007H\u0016J\n\u0010\u0014\u001a\u0004\u0018\u00010\u0007H\u0016J\u0016\u0010\u0015\u001a\u0010\u0012\u0004\u0012\u00020\u0007\u0012\u0006\u0012\u0004\u0018\u00010\u00170\u0016H\u0016J\b\u0010\u0018\u001a\u00020\u0007H\u0016J\b\u0010\u0019\u001a\u00020\u000eH\u0016J\u0012\u0010\u001a\u001a\f\u0012\b\u0012\u0006\u0012\u0002\b\u00030\u001c0\u001bH\u0016J\b\u0010\u001d\u001a\u00020\u001eH\u0016J\b\u0010\u001f\u001a\u00020\u0007H\u0016J\b\u0010 \u001a\u00020\u000eH\u0016J\u000e\u0010!\u001a\b\u0012\u0004\u0012\u00020\u00070\u001bH\u0016J\b\u0010\"\u001a\u00020\u0007H\u0016R\u0016\u0010\u0006\u001a\u0004\u0018\u00010\u00078BX\u0082\u0004¢\u0006\u0006\u001a\u0004\b\b\u0010\tR\u000e\u0010\u0003\u001a\u00020\u0004X\u0082\u0004¢\u0006\u0002\n\u0000R\u000e\u0010\n\u001a\u00020\u000bX\u0082\u0004¢\u0006\u0002\n\u0000R\u000e\u0010\f\u001a\u00020\u0007X\u0082\u0004¢\u0006\u0002\n\u0000R\u001a\u0010\r\u001a\u00020\u000eX\u0086\u000e¢\u0006\u000e\n\u0000\u001a\u0004\b\u000f\u0010\u0010\"\u0004\b\u0011\u0010\u0012¨\u0006%"}, m40d2 = {"Lexpo/modules/constants/ConstantsService;", "Lexpo/modules/core/interfaces/InternalModule;", "Lexpo/modules/interfaces/constants/ConstantsInterface;", "context", "Landroid/content/Context;", "(Landroid/content/Context;)V", "appConfig", "", "getAppConfig", "()Ljava/lang/String;", "exponentInstallationId", "Lexpo/modules/constants/ExponentInstallationId;", "sessionId", "statusBarHeightInternal", "", "getStatusBarHeightInternal", "()I", "setStatusBarHeightInternal", "(I)V", "getAppOwnership", "getAppScopeKey", "getConstants", "", "", "getDeviceName", "getDeviceYearClass", "getExportedInterfaces", "", "Ljava/lang/Class;", "getIsDevice", "", "getOrCreateInstallationId", "getStatusBarHeight", "getSystemFonts", "getSystemVersion", "Companion", "ExecutionEnvironment", "expo-constants_release"}, m39k = 1, m38mv = {1, 6, 0}, m36xi = 48)
/* loaded from: classes2.dex */
public class ConstantsService implements InternalModule, ConstantsInterface {
    public static final Companion Companion = new Companion(null);
    private final Context context;
    private final ExponentInstallationId exponentInstallationId;
    private final String sessionId;
    private int statusBarHeightInternal;

    @Override // expo.modules.interfaces.constants.ConstantsInterface
    public String getAppOwnership() {
        return "guest";
    }

    @Override // expo.modules.core.interfaces.RegistryLifecycleListener
    public /* synthetic */ void onCreate(ModuleRegistry moduleRegistry) {
        RegistryLifecycleListener.CC.$default$onCreate(this, moduleRegistry);
    }

    @Override // expo.modules.core.interfaces.RegistryLifecycleListener
    public /* synthetic */ void onDestroy() {
        RegistryLifecycleListener.CC.$default$onDestroy(this);
    }

    public ConstantsService(Context context) {
        Intrinsics.checkNotNullParameter(context, "context");
        this.context = context;
        Integer valueOf = Integer.valueOf(context.getResources().getIdentifier("status_bar_height", "dimen", "android"));
        valueOf = valueOf.intValue() > 0 ? valueOf : null;
        this.statusBarHeightInternal = valueOf != null ? Companion.convertPixelsToDp(Integer.valueOf(context.getResources().getDimensionPixelSize(valueOf.intValue())).intValue(), context) : 0;
        String uuid = UUID.randomUUID().toString();
        Intrinsics.checkNotNullExpressionValue(uuid, "randomUUID().toString()");
        this.sessionId = uuid;
        this.exponentInstallationId = new ExponentInstallationId(context);
    }

    public final int getStatusBarHeightInternal() {
        return this.statusBarHeightInternal;
    }

    public final void setStatusBarHeightInternal(int i) {
        this.statusBarHeightInternal = i;
    }

    /* compiled from: ConstantsService.kt */
    @Metadata(m41d1 = {"\u0000\u0012\n\u0002\u0018\u0002\n\u0002\u0010\u0010\n\u0000\n\u0002\u0010\u000e\n\u0002\b\u0007\b\u0086\u0001\u0018\u00002\b\u0012\u0004\u0012\u00020\u00000\u0001B\u000f\b\u0002\u0012\u0006\u0010\u0002\u001a\u00020\u0003¢\u0006\u0002\u0010\u0004R\u0011\u0010\u0002\u001a\u00020\u0003¢\u0006\b\n\u0000\u001a\u0004\b\u0005\u0010\u0006j\u0002\b\u0007j\u0002\b\bj\u0002\b\t¨\u0006\n"}, m40d2 = {"Lexpo/modules/constants/ConstantsService$ExecutionEnvironment;", "", "string", "", "(Ljava/lang/String;ILjava/lang/String;)V", "getString", "()Ljava/lang/String;", "BARE", "STANDALONE", "STORE_CLIENT", "expo-constants_release"}, m39k = 1, m38mv = {1, 6, 0}, m36xi = 48)
    /* loaded from: classes2.dex */
    public enum ExecutionEnvironment {
        BARE("bare"),
        STANDALONE("standalone"),
        STORE_CLIENT("storeClient");
        
        private final String string;

        ExecutionEnvironment(String str) {
            this.string = str;
        }

        public final String getString() {
            return this.string;
        }
    }

    @Override // expo.modules.core.interfaces.InternalModule
    public List<Class<?>> getExportedInterfaces() {
        return CollectionsKt.listOf(ConstantsInterface.class);
    }

    @Override // expo.modules.interfaces.constants.ConstantsInterface
    public Map<String, Object> getConstants() {
        String str;
        Map<String, Object> mutableMapOf = MapsKt.mutableMapOf(TuplesKt.m33to("sessionId", this.sessionId), TuplesKt.m33to("executionEnvironment", ExecutionEnvironment.BARE.getString()), TuplesKt.m33to("statusBarHeight", Integer.valueOf(this.statusBarHeightInternal)), TuplesKt.m33to("deviceYearClass", Integer.valueOf(getDeviceYearClass())), TuplesKt.m33to("deviceName", getDeviceName()), TuplesKt.m33to("isDevice", Boolean.valueOf(getIsDevice())), TuplesKt.m33to("systemFonts", getSystemFonts()), TuplesKt.m33to("systemVersion", getSystemVersion()), TuplesKt.m33to("installationId", getOrCreateInstallationId()), TuplesKt.m33to("manifest", getAppConfig()), TuplesKt.m33to("platform", MapsKt.mapOf(TuplesKt.m33to("android", MapsKt.emptyMap()))));
        try {
            PackageInfo pInfo = this.context.getPackageManager().getPackageInfo(this.context.getPackageName(), 0);
            mutableMapOf.put("nativeAppVersion", pInfo.versionName);
            Companion companion = Companion;
            Intrinsics.checkNotNullExpressionValue(pInfo, "pInfo");
            mutableMapOf.put("nativeBuildVersion", String.valueOf((int) companion.getLongVersionCode(pInfo)));
        } catch (PackageManager.NameNotFoundException e) {
            str = ConstantsServiceKt.TAG;
            Log.e(str, "Exception: ", e);
        }
        return mutableMapOf;
    }

    @Override // expo.modules.interfaces.constants.ConstantsInterface
    public String getAppScopeKey() {
        return this.context.getPackageName();
    }

    @Override // expo.modules.interfaces.constants.ConstantsInterface
    public String getDeviceName() {
        String MODEL = Build.MODEL;
        Intrinsics.checkNotNullExpressionValue(MODEL, "MODEL");
        return MODEL;
    }

    @Override // expo.modules.interfaces.constants.ConstantsInterface
    public int getDeviceYearClass() {
        return YearClass.get(this.context);
    }

    @Override // expo.modules.interfaces.constants.ConstantsInterface
    public boolean getIsDevice() {
        return !EmulatorUtilities.INSTANCE.isRunningOnEmulator();
    }

    @Override // expo.modules.interfaces.constants.ConstantsInterface
    public int getStatusBarHeight() {
        return this.statusBarHeightInternal;
    }

    @Override // expo.modules.interfaces.constants.ConstantsInterface
    public String getSystemVersion() {
        String RELEASE = Build.VERSION.RELEASE;
        Intrinsics.checkNotNullExpressionValue(RELEASE, "RELEASE");
        return RELEASE;
    }

    public String getOrCreateInstallationId() {
        return this.exponentInstallationId.getOrCreateUUID();
    }

    @Override // expo.modules.interfaces.constants.ConstantsInterface
    public List<String> getSystemFonts() {
        return CollectionsKt.listOf((Object[]) new String[]{"normal", "notoserif", "sans-serif", "sans-serif-light", "sans-serif-thin", "sans-serif-condensed", "sans-serif-medium", "serif", "Roboto", "monospace"});
    }

    private final String getAppConfig() {
        String str;
        try {
            InputStream open = this.context.getAssets().open("app.config");
            try {
                String iOUtils = IOUtils.toString(open, StandardCharsets.UTF_8);
                Closeable.closeFinally(open, null);
                return iOUtils;
            } finally {
            }
        } catch (FileNotFoundException unused) {
            return null;
        } catch (Exception e) {
            str = ConstantsServiceKt.TAG;
            Log.e(str, "Error reading embedded app config", e);
            return null;
        }
    }

    /* compiled from: ConstantsService.kt */
    @Metadata(m41d1 = {"\u00002\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0002\n\u0002\u0010\u000b\n\u0002\b\u0002\n\u0002\u0010\b\n\u0000\n\u0002\u0010\u0007\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\t\n\u0000\n\u0002\u0018\u0002\n\u0000\b\u0086\u0003\u0018\u00002\u00020\u0001B\u0007\b\u0002¢\u0006\u0002\u0010\u0002J\u0018\u0010\u0006\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\t2\u0006\u0010\n\u001a\u00020\u000bH\u0002J\u0010\u0010\f\u001a\u00020\r2\u0006\u0010\u000e\u001a\u00020\u000fH\u0002R\u0014\u0010\u0003\u001a\u00020\u00048BX\u0082\u0004¢\u0006\u0006\u001a\u0004\b\u0003\u0010\u0005¨\u0006\u0010"}, m40d2 = {"Lexpo/modules/constants/ConstantsService$Companion;", "", "()V", "isRunningOnEmulator", "", "()Z", "convertPixelsToDp", "", "px", "", "context", "Landroid/content/Context;", "getLongVersionCode", "", "info", "Landroid/content/pm/PackageInfo;", "expo-constants_release"}, m39k = 1, m38mv = {1, 6, 0}, m36xi = 48)
    /* loaded from: classes2.dex */
    public static final class Companion {
        public /* synthetic */ Companion(DefaultConstructorMarker defaultConstructorMarker) {
            this();
        }

        private Companion() {
        }

        public final int convertPixelsToDp(float f, Context context) {
            return (int) (f / (context.getResources().getDisplayMetrics().densityDpi / 160.0f));
        }

        private final boolean isRunningOnEmulator() {
            return EmulatorUtilities.INSTANCE.isRunningOnEmulator();
        }

        public final long getLongVersionCode(PackageInfo packageInfo) {
            return Build.VERSION.SDK_INT >= 28 ? packageInfo.getLongVersionCode() : packageInfo.versionCode;
        }
    }
}
