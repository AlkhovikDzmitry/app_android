package com.facebook.common.logging;

/* loaded from: classes.dex */
public interface LoggingDelegate {
    /* renamed from: d */
    void mo203d(String tag, String msg);

    /* renamed from: d */
    void mo202d(String tag, String msg, Throwable tr);

    /* renamed from: e */
    void mo201e(String tag, String msg);

    /* renamed from: e */
    void mo200e(String tag, String msg, Throwable tr);

    int getMinimumLoggingLevel();

    /* renamed from: i */
    void mo199i(String tag, String msg);

    /* renamed from: i */
    void mo198i(String tag, String msg, Throwable tr);

    boolean isLoggable(int level);

    void log(int priority, String tag, String msg);

    void setMinimumLoggingLevel(int level);

    /* renamed from: v */
    void mo197v(String tag, String msg);

    /* renamed from: v */
    void mo196v(String tag, String msg, Throwable tr);

    /* renamed from: w */
    void mo195w(String tag, String msg);

    /* renamed from: w */
    void mo194w(String tag, String msg, Throwable tr);

    void wtf(String tag, String msg);

    void wtf(String tag, String msg, Throwable tr);
}
