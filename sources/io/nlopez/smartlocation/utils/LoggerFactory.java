package io.nlopez.smartlocation.utils;

import android.util.Log;

/* loaded from: classes2.dex */
public class LoggerFactory {
    public static Logger buildLogger(boolean z) {
        return z ? new Blabber() : new Sssht();
    }

    /* JADX INFO: Access modifiers changed from: private */
    /* loaded from: classes2.dex */
    public static class Sssht implements Logger {
        @Override // io.nlopez.smartlocation.utils.Logger
        /* renamed from: d */
        public void mo52d(String str, Object... objArr) {
        }

        @Override // io.nlopez.smartlocation.utils.Logger
        /* renamed from: d */
        public void mo51d(Throwable th, String str, Object... objArr) {
        }

        @Override // io.nlopez.smartlocation.utils.Logger
        /* renamed from: e */
        public void mo50e(String str, Object... objArr) {
        }

        @Override // io.nlopez.smartlocation.utils.Logger
        /* renamed from: e */
        public void mo49e(Throwable th, String str, Object... objArr) {
        }

        @Override // io.nlopez.smartlocation.utils.Logger
        /* renamed from: i */
        public void mo48i(String str, Object... objArr) {
        }

        @Override // io.nlopez.smartlocation.utils.Logger
        /* renamed from: i */
        public void mo47i(Throwable th, String str, Object... objArr) {
        }

        @Override // io.nlopez.smartlocation.utils.Logger
        /* renamed from: v */
        public void mo46v(String str, Object... objArr) {
        }

        @Override // io.nlopez.smartlocation.utils.Logger
        /* renamed from: v */
        public void mo45v(Throwable th, String str, Object... objArr) {
        }

        @Override // io.nlopez.smartlocation.utils.Logger
        /* renamed from: w */
        public void mo44w(String str, Object... objArr) {
        }

        @Override // io.nlopez.smartlocation.utils.Logger
        /* renamed from: w */
        public void mo43w(Throwable th, String str, Object... objArr) {
        }

        private Sssht() {
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    /* loaded from: classes2.dex */
    public static class Blabber implements Logger {
        private Blabber() {
        }

        private String getTag() {
            return new Exception().getStackTrace()[3].getMethodName();
        }

        private String formatMessage(String str, Object... objArr) {
            return objArr.length == 0 ? str : String.format(str, objArr);
        }

        @Override // io.nlopez.smartlocation.utils.Logger
        /* renamed from: v */
        public void mo46v(String str, Object... objArr) {
            Log.v(getTag(), formatMessage(str, objArr));
        }

        @Override // io.nlopez.smartlocation.utils.Logger
        /* renamed from: v */
        public void mo45v(Throwable th, String str, Object... objArr) {
            Log.v(getTag(), formatMessage(str, objArr), th);
        }

        @Override // io.nlopez.smartlocation.utils.Logger
        /* renamed from: d */
        public void mo52d(String str, Object... objArr) {
            Log.d(getTag(), formatMessage(str, objArr));
        }

        @Override // io.nlopez.smartlocation.utils.Logger
        /* renamed from: d */
        public void mo51d(Throwable th, String str, Object... objArr) {
            Log.d(getTag(), formatMessage(str, objArr), th);
        }

        @Override // io.nlopez.smartlocation.utils.Logger
        /* renamed from: i */
        public void mo48i(String str, Object... objArr) {
            Log.i(getTag(), formatMessage(str, objArr));
        }

        @Override // io.nlopez.smartlocation.utils.Logger
        /* renamed from: i */
        public void mo47i(Throwable th, String str, Object... objArr) {
            Log.i(getTag(), formatMessage(str, objArr), th);
        }

        @Override // io.nlopez.smartlocation.utils.Logger
        /* renamed from: w */
        public void mo44w(String str, Object... objArr) {
            Log.w(getTag(), formatMessage(str, objArr));
        }

        @Override // io.nlopez.smartlocation.utils.Logger
        /* renamed from: w */
        public void mo43w(Throwable th, String str, Object... objArr) {
            Log.w(getTag(), formatMessage(str, objArr), th);
        }

        @Override // io.nlopez.smartlocation.utils.Logger
        /* renamed from: e */
        public void mo50e(String str, Object... objArr) {
            Log.e(getTag(), formatMessage(str, objArr));
        }

        @Override // io.nlopez.smartlocation.utils.Logger
        /* renamed from: e */
        public void mo49e(Throwable th, String str, Object... objArr) {
            Log.e(getTag(), formatMessage(str, objArr), th);
        }
    }
}
