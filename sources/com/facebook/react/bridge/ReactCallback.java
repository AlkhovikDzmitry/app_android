package com.facebook.react.bridge;

/* JADX INFO: Access modifiers changed from: package-private */
/* loaded from: classes.dex */
public interface ReactCallback {
    void decrementPendingJSCalls();

    void incrementPendingJSCalls();

    void onBatchComplete();
}
