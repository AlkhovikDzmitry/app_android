package com.facebook.common.logging;

/* loaded from: classes.dex */
public class FLog {
    public static final int ASSERT = 7;
    public static final int DEBUG = 3;
    public static final int ERROR = 6;
    public static final int INFO = 4;
    public static final int VERBOSE = 2;
    public static final int WARN = 5;
    private static LoggingDelegate sHandler = FLogDefaultLoggingDelegate.getInstance();

    public static void setLoggingDelegate(LoggingDelegate delegate) {
        if (delegate == null) {
            throw new IllegalArgumentException();
        }
        sHandler = delegate;
    }

    public static boolean isLoggable(int level) {
        return sHandler.isLoggable(level);
    }

    public static void setMinimumLoggingLevel(int level) {
        sHandler.setMinimumLoggingLevel(level);
    }

    public static int getMinimumLoggingLevel() {
        return sHandler.getMinimumLoggingLevel();
    }

    /* renamed from: v */
    public static void m219v(String tag, String msg) {
        if (sHandler.isLoggable(2)) {
            sHandler.mo197v(tag, msg);
        }
    }

    /* renamed from: v */
    public static void m218v(String tag, String msg, Object arg1) {
        if (sHandler.isLoggable(2)) {
            sHandler.mo197v(tag, formatString(msg, arg1));
        }
    }

    /* renamed from: v */
    public static void m217v(String tag, String msg, Object arg1, Object arg2) {
        if (sHandler.isLoggable(2)) {
            sHandler.mo197v(tag, formatString(msg, arg1, arg2));
        }
    }

    /* renamed from: v */
    public static void m216v(String tag, String msg, Object arg1, Object arg2, Object arg3) {
        if (sHandler.isLoggable(2)) {
            sHandler.mo197v(tag, formatString(msg, arg1, arg2, arg3));
        }
    }

    /* renamed from: v */
    public static void m215v(String tag, String msg, Object arg1, Object arg2, Object arg3, Object arg4) {
        if (sHandler.isLoggable(2)) {
            sHandler.mo197v(tag, formatString(msg, arg1, arg2, arg3, arg4));
        }
    }

    /* renamed from: v */
    public static void m227v(Class<?> cls, String msg) {
        if (sHandler.isLoggable(2)) {
            sHandler.mo197v(getTag(cls), msg);
        }
    }

    /* renamed from: v */
    public static void m226v(Class<?> cls, String msg, Object arg1) {
        if (sHandler.isLoggable(2)) {
            sHandler.mo197v(getTag(cls), formatString(msg, arg1));
        }
    }

    /* renamed from: v */
    public static void m225v(Class<?> cls, String msg, Object arg1, Object arg2) {
        if (sHandler.isLoggable(2)) {
            sHandler.mo197v(getTag(cls), formatString(msg, arg1, arg2));
        }
    }

    /* renamed from: v */
    public static void m224v(Class<?> cls, String msg, Object arg1, Object arg2, Object arg3) {
        if (isLoggable(2)) {
            m227v(cls, formatString(msg, arg1, arg2, arg3));
        }
    }

    /* renamed from: v */
    public static void m223v(Class<?> cls, String msg, Object arg1, Object arg2, Object arg3, Object arg4) {
        if (sHandler.isLoggable(2)) {
            sHandler.mo197v(getTag(cls), formatString(msg, arg1, arg2, arg3, arg4));
        }
    }

    /* renamed from: v */
    public static void m213v(String tag, String msg, Object... args) {
        if (sHandler.isLoggable(2)) {
            sHandler.mo197v(tag, formatString(msg, args));
        }
    }

    /* renamed from: v */
    public static void m212v(String tag, Throwable tr, String msg, Object... args) {
        if (sHandler.isLoggable(2)) {
            sHandler.mo196v(tag, formatString(msg, args), tr);
        }
    }

    /* renamed from: v */
    public static void m221v(Class<?> cls, String msg, Object... args) {
        if (sHandler.isLoggable(2)) {
            sHandler.mo197v(getTag(cls), formatString(msg, args));
        }
    }

    /* renamed from: v */
    public static void m220v(Class<?> cls, Throwable tr, String msg, Object... args) {
        if (sHandler.isLoggable(2)) {
            sHandler.mo196v(getTag(cls), formatString(msg, args), tr);
        }
    }

    /* renamed from: v */
    public static void m214v(String tag, String msg, Throwable tr) {
        if (sHandler.isLoggable(2)) {
            sHandler.mo196v(tag, msg, tr);
        }
    }

    /* renamed from: v */
    public static void m222v(Class<?> cls, String msg, Throwable tr) {
        if (sHandler.isLoggable(2)) {
            sHandler.mo196v(getTag(cls), msg, tr);
        }
    }

    /* renamed from: d */
    public static void m259d(String tag, String msg) {
        if (sHandler.isLoggable(3)) {
            sHandler.mo203d(tag, msg);
        }
    }

    /* renamed from: d */
    public static void m258d(String tag, String msg, Object arg1) {
        if (sHandler.isLoggable(3)) {
            sHandler.mo203d(tag, formatString(msg, arg1));
        }
    }

    /* renamed from: d */
    public static void m257d(String tag, String msg, Object arg1, Object arg2) {
        if (sHandler.isLoggable(3)) {
            sHandler.mo203d(tag, formatString(msg, arg1, arg2));
        }
    }

    /* renamed from: d */
    public static void m256d(String tag, String msg, Object arg1, Object arg2, Object arg3) {
        if (sHandler.isLoggable(3)) {
            sHandler.mo203d(tag, formatString(msg, arg1, arg2, arg3));
        }
    }

    /* renamed from: d */
    public static void m255d(String tag, String msg, Object arg1, Object arg2, Object arg3, Object arg4) {
        if (sHandler.isLoggable(3)) {
            sHandler.mo203d(tag, formatString(msg, arg1, arg2, arg3, arg4));
        }
    }

    /* renamed from: d */
    public static void m267d(Class<?> cls, String msg) {
        if (sHandler.isLoggable(3)) {
            sHandler.mo203d(getTag(cls), msg);
        }
    }

    /* renamed from: d */
    public static void m266d(Class<?> cls, String msg, Object arg1) {
        if (sHandler.isLoggable(3)) {
            sHandler.mo203d(getTag(cls), formatString(msg, arg1));
        }
    }

    /* renamed from: d */
    public static void m265d(Class<?> cls, String msg, Object arg1, Object arg2) {
        if (sHandler.isLoggable(3)) {
            sHandler.mo203d(getTag(cls), formatString(msg, arg1, arg2));
        }
    }

    /* renamed from: d */
    public static void m264d(Class<?> cls, String msg, Object arg1, Object arg2, Object arg3) {
        if (sHandler.isLoggable(3)) {
            sHandler.mo203d(getTag(cls), formatString(msg, arg1, arg2, arg3));
        }
    }

    /* renamed from: d */
    public static void m263d(Class<?> cls, String msg, Object arg1, Object arg2, Object arg3, Object arg4) {
        if (sHandler.isLoggable(3)) {
            sHandler.mo203d(getTag(cls), formatString(msg, arg1, arg2, arg3, arg4));
        }
    }

    /* renamed from: d */
    public static void m253d(String tag, String msg, Object... args) {
        if (sHandler.isLoggable(3)) {
            m259d(tag, formatString(msg, args));
        }
    }

    /* renamed from: d */
    public static void m252d(String tag, Throwable tr, String msg, Object... args) {
        if (sHandler.isLoggable(3)) {
            m254d(tag, formatString(msg, args), tr);
        }
    }

    /* renamed from: d */
    public static void m261d(Class<?> cls, String msg, Object... args) {
        if (sHandler.isLoggable(3)) {
            sHandler.mo203d(getTag(cls), formatString(msg, args));
        }
    }

    /* renamed from: d */
    public static void m260d(Class<?> cls, Throwable tr, String msg, Object... args) {
        if (sHandler.isLoggable(3)) {
            sHandler.mo202d(getTag(cls), formatString(msg, args), tr);
        }
    }

    /* renamed from: d */
    public static void m254d(String tag, String msg, Throwable tr) {
        if (sHandler.isLoggable(3)) {
            sHandler.mo202d(tag, msg, tr);
        }
    }

    /* renamed from: d */
    public static void m262d(Class<?> cls, String msg, Throwable tr) {
        if (sHandler.isLoggable(3)) {
            sHandler.mo202d(getTag(cls), msg, tr);
        }
    }

    /* renamed from: i */
    public static void m235i(String tag, String msg) {
        if (sHandler.isLoggable(4)) {
            sHandler.mo199i(tag, msg);
        }
    }

    /* renamed from: i */
    public static void m234i(String tag, String msg, Object arg1) {
        if (sHandler.isLoggable(4)) {
            sHandler.mo199i(tag, formatString(msg, arg1));
        }
    }

    /* renamed from: i */
    public static void m233i(String tag, String msg, Object arg1, Object arg2) {
        if (sHandler.isLoggable(4)) {
            sHandler.mo199i(tag, formatString(msg, arg1, arg2));
        }
    }

    /* renamed from: i */
    public static void m232i(String tag, String msg, Object arg1, Object arg2, Object arg3) {
        if (sHandler.isLoggable(4)) {
            sHandler.mo199i(tag, formatString(msg, arg1, arg2, arg3));
        }
    }

    /* renamed from: i */
    public static void m231i(String tag, String msg, Object arg1, Object arg2, Object arg3, Object arg4) {
        if (sHandler.isLoggable(4)) {
            sHandler.mo199i(tag, formatString(msg, arg1, arg2, arg3, arg4));
        }
    }

    /* renamed from: i */
    public static void m243i(Class<?> cls, String msg) {
        if (sHandler.isLoggable(4)) {
            sHandler.mo199i(getTag(cls), msg);
        }
    }

    /* renamed from: i */
    public static void m242i(Class<?> cls, String msg, Object arg1) {
        if (sHandler.isLoggable(4)) {
            sHandler.mo199i(getTag(cls), formatString(msg, arg1));
        }
    }

    /* renamed from: i */
    public static void m241i(Class<?> cls, String msg, Object arg1, Object arg2) {
        if (sHandler.isLoggable(4)) {
            sHandler.mo199i(getTag(cls), formatString(msg, arg1, arg2));
        }
    }

    /* renamed from: i */
    public static void m240i(Class<?> cls, String msg, Object arg1, Object arg2, Object arg3) {
        if (sHandler.isLoggable(4)) {
            sHandler.mo199i(getTag(cls), formatString(msg, arg1, arg2, arg3));
        }
    }

    /* renamed from: i */
    public static void m239i(Class<?> cls, String msg, Object arg1, Object arg2, Object arg3, Object arg4) {
        if (sHandler.isLoggable(4)) {
            sHandler.mo199i(getTag(cls), formatString(msg, arg1, arg2, arg3, arg4));
        }
    }

    /* renamed from: i */
    public static void m229i(String tag, String msg, Object... args) {
        if (sHandler.isLoggable(4)) {
            sHandler.mo199i(tag, formatString(msg, args));
        }
    }

    /* renamed from: i */
    public static void m228i(String tag, Throwable tr, String msg, Object... args) {
        if (sHandler.isLoggable(4)) {
            sHandler.mo198i(tag, formatString(msg, args), tr);
        }
    }

    /* renamed from: i */
    public static void m237i(Class<?> cls, String msg, Object... args) {
        if (sHandler.isLoggable(4)) {
            sHandler.mo199i(getTag(cls), formatString(msg, args));
        }
    }

    /* renamed from: i */
    public static void m236i(Class<?> cls, Throwable tr, String msg, Object... args) {
        if (isLoggable(4)) {
            sHandler.mo198i(getTag(cls), formatString(msg, args), tr);
        }
    }

    /* renamed from: i */
    public static void m230i(String tag, String msg, Throwable tr) {
        if (sHandler.isLoggable(4)) {
            sHandler.mo198i(tag, msg, tr);
        }
    }

    /* renamed from: i */
    public static void m238i(Class<?> cls, String msg, Throwable tr) {
        if (sHandler.isLoggable(4)) {
            sHandler.mo198i(getTag(cls), msg, tr);
        }
    }

    /* renamed from: w */
    public static void m207w(String tag, String msg) {
        if (sHandler.isLoggable(5)) {
            sHandler.mo195w(tag, msg);
        }
    }

    /* renamed from: w */
    public static void m211w(Class<?> cls, String msg) {
        if (sHandler.isLoggable(5)) {
            sHandler.mo195w(getTag(cls), msg);
        }
    }

    /* renamed from: w */
    public static void m205w(String tag, String msg, Object... args) {
        if (sHandler.isLoggable(5)) {
            sHandler.mo195w(tag, formatString(msg, args));
        }
    }

    /* renamed from: w */
    public static void m204w(String tag, Throwable tr, String msg, Object... args) {
        if (sHandler.isLoggable(5)) {
            sHandler.mo194w(tag, formatString(msg, args), tr);
        }
    }

    /* renamed from: w */
    public static void m209w(Class<?> cls, String msg, Object... args) {
        if (sHandler.isLoggable(5)) {
            sHandler.mo195w(getTag(cls), formatString(msg, args));
        }
    }

    /* renamed from: w */
    public static void m208w(Class<?> cls, Throwable tr, String msg, Object... args) {
        if (isLoggable(5)) {
            m210w(cls, formatString(msg, args), tr);
        }
    }

    /* renamed from: w */
    public static void m206w(String tag, String msg, Throwable tr) {
        if (sHandler.isLoggable(5)) {
            sHandler.mo194w(tag, msg, tr);
        }
    }

    /* renamed from: w */
    public static void m210w(Class<?> cls, String msg, Throwable tr) {
        if (sHandler.isLoggable(5)) {
            sHandler.mo194w(getTag(cls), msg, tr);
        }
    }

    /* renamed from: e */
    public static void m247e(String tag, String msg) {
        if (sHandler.isLoggable(6)) {
            sHandler.mo201e(tag, msg);
        }
    }

    /* renamed from: e */
    public static void m251e(Class<?> cls, String msg) {
        if (sHandler.isLoggable(6)) {
            sHandler.mo201e(getTag(cls), msg);
        }
    }

    /* renamed from: e */
    public static void m245e(String tag, String msg, Object... args) {
        if (sHandler.isLoggable(6)) {
            sHandler.mo201e(tag, formatString(msg, args));
        }
    }

    /* renamed from: e */
    public static void m244e(String tag, Throwable tr, String msg, Object... args) {
        if (sHandler.isLoggable(6)) {
            sHandler.mo200e(tag, formatString(msg, args), tr);
        }
    }

    /* renamed from: e */
    public static void m249e(Class<?> cls, String msg, Object... args) {
        if (sHandler.isLoggable(6)) {
            sHandler.mo201e(getTag(cls), formatString(msg, args));
        }
    }

    /* renamed from: e */
    public static void m248e(Class<?> cls, Throwable tr, String msg, Object... args) {
        if (sHandler.isLoggable(6)) {
            sHandler.mo200e(getTag(cls), formatString(msg, args), tr);
        }
    }

    /* renamed from: e */
    public static void m246e(String tag, String msg, Throwable tr) {
        if (sHandler.isLoggable(6)) {
            sHandler.mo200e(tag, msg, tr);
        }
    }

    /* renamed from: e */
    public static void m250e(Class<?> cls, String msg, Throwable tr) {
        if (sHandler.isLoggable(6)) {
            sHandler.mo200e(getTag(cls), msg, tr);
        }
    }

    public static void wtf(String tag, String msg) {
        if (sHandler.isLoggable(6)) {
            sHandler.wtf(tag, msg);
        }
    }

    public static void wtf(Class<?> cls, String msg) {
        if (sHandler.isLoggable(6)) {
            sHandler.wtf(getTag(cls), msg);
        }
    }

    public static void wtf(String tag, String msg, Object... args) {
        if (sHandler.isLoggable(6)) {
            sHandler.wtf(tag, formatString(msg, args));
        }
    }

    public static void wtf(String tag, Throwable tr, String msg, Object... args) {
        if (sHandler.isLoggable(6)) {
            sHandler.wtf(tag, formatString(msg, args), tr);
        }
    }

    public static void wtf(Class<?> cls, String msg, Object... args) {
        if (sHandler.isLoggable(6)) {
            sHandler.wtf(getTag(cls), formatString(msg, args));
        }
    }

    public static void wtf(Class<?> cls, Throwable tr, String msg, Object... args) {
        if (sHandler.isLoggable(6)) {
            sHandler.wtf(getTag(cls), formatString(msg, args), tr);
        }
    }

    public static void wtf(String tag, String msg, Throwable tr) {
        if (sHandler.isLoggable(6)) {
            sHandler.wtf(tag, msg, tr);
        }
    }

    public static void wtf(Class<?> cls, String msg, Throwable tr) {
        if (sHandler.isLoggable(6)) {
            sHandler.wtf(getTag(cls), msg, tr);
        }
    }

    private static String formatString(String str, Object... args) {
        return String.format(null, str, args);
    }

    private static String getTag(Class<?> clazz) {
        return clazz.getSimpleName();
    }
}
