package expo.modules.core.logging;

import com.google.firebase.messaging.Constants;
import com.swmansion.reanimated.BuildConfig;
import kotlin.Metadata;
import kotlin.NoWhenBranchMatchedException;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;

/* compiled from: LogType.kt */
@Metadata(m41d1 = {"\u0000\u0012\n\u0002\u0018\u0002\n\u0002\u0010\u0010\n\u0000\n\u0002\u0010\u000e\n\u0002\b\r\b\u0086\u0001\u0018\u0000 \u000f2\b\u0012\u0004\u0012\u00020\u00000\u0001:\u0001\u000fB\u000f\b\u0002\u0012\u0006\u0010\u0002\u001a\u00020\u0003¢\u0006\u0002\u0010\u0004R\u0011\u0010\u0002\u001a\u00020\u0003¢\u0006\b\n\u0000\u001a\u0004\b\u0005\u0010\u0006j\u0002\b\u0007j\u0002\b\bj\u0002\b\tj\u0002\b\nj\u0002\b\u000bj\u0002\b\fj\u0002\b\rj\u0002\b\u000e¨\u0006\u0010"}, m40d2 = {"Lexpo/modules/core/logging/LogType;", "", "type", "", "(Ljava/lang/String;ILjava/lang/String;)V", "getType", "()Ljava/lang/String;", "Trace", "Timer", "Stacktrace", "Debug", "Info", "Warn", "Error", "Fatal", "Companion", "expo-modules-core_release"}, m39k = 1, m38mv = {1, 6, 0}, m36xi = 48)
/* loaded from: classes2.dex */
public enum LogType {
    Trace("trace"),
    Timer("timer"),
    Stacktrace("stacktrace"),
    Debug(BuildConfig.BUILD_TYPE),
    Info("info"),
    Warn("warn"),
    Error(Constants.IPC_BUNDLE_KEY_SEND_ERROR),
    Fatal("fatal");
    
    public static final Companion Companion = new Companion(null);
    private final String type;

    LogType(String str) {
        this.type = str;
    }

    public final String getType() {
        return this.type;
    }

    /* compiled from: LogType.kt */
    @Metadata(m41d1 = {"\u0000\u0018\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0002\n\u0002\u0010\b\n\u0000\n\u0002\u0018\u0002\n\u0000\b\u0086\u0003\u0018\u00002\u00020\u0001B\u0007\b\u0002¢\u0006\u0002\u0010\u0002J\u000e\u0010\u0003\u001a\u00020\u00042\u0006\u0010\u0005\u001a\u00020\u0006¨\u0006\u0007"}, m40d2 = {"Lexpo/modules/core/logging/LogType$Companion;", "", "()V", "toOSLogType", "", "type", "Lexpo/modules/core/logging/LogType;", "expo-modules-core_release"}, m39k = 1, m38mv = {1, 6, 0}, m36xi = 48)
    /* loaded from: classes2.dex */
    public static final class Companion {

        /* compiled from: LogType.kt */
        @Metadata(m39k = 3, m38mv = {1, 6, 0}, m36xi = 48)
        /* loaded from: classes2.dex */
        public /* synthetic */ class WhenMappings {
            public static final /* synthetic */ int[] $EnumSwitchMapping$0;

            static {
                int[] iArr = new int[LogType.values().length];
                iArr[LogType.Trace.ordinal()] = 1;
                iArr[LogType.Timer.ordinal()] = 2;
                iArr[LogType.Stacktrace.ordinal()] = 3;
                iArr[LogType.Debug.ordinal()] = 4;
                iArr[LogType.Info.ordinal()] = 5;
                iArr[LogType.Warn.ordinal()] = 6;
                iArr[LogType.Error.ordinal()] = 7;
                iArr[LogType.Fatal.ordinal()] = 8;
                $EnumSwitchMapping$0 = iArr;
            }
        }

        public /* synthetic */ Companion(DefaultConstructorMarker defaultConstructorMarker) {
            this();
        }

        private Companion() {
        }

        public final int toOSLogType(LogType type) {
            Intrinsics.checkNotNullParameter(type, "type");
            switch (WhenMappings.$EnumSwitchMapping$0[type.ordinal()]) {
                case 1:
                case 2:
                case 3:
                case 4:
                    return 3;
                case 5:
                    return 4;
                case 6:
                    return 5;
                case 7:
                    return 6;
                case 8:
                    return 7;
                default:
                    throw new NoWhenBranchMatchedException();
            }
        }
    }
}
