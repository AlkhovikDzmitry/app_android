package com.google.android.gms.internal.p009authapi;

import android.app.PendingIntent;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.api.internal.TaskUtil;
import com.google.android.gms.tasks.TaskCompletionSource;

/* JADX INFO: Access modifiers changed from: package-private */
/* compiled from: com.google.android.gms:play-services-auth@@20.5.0 */
/* renamed from: com.google.android.gms.internal.auth-api.zbax */
/* loaded from: classes.dex */
public final class zbax extends zbaa {
    final /* synthetic */ TaskCompletionSource zba;

    public zbax(zbay zbayVar, TaskCompletionSource taskCompletionSource) {
        this.zba = taskCompletionSource;
    }

    @Override // com.google.android.gms.internal.p009authapi.zbab
    public final void zbb(Status status, PendingIntent pendingIntent) {
        TaskUtil.setResultOrApiException(status, pendingIntent, this.zba);
    }
}
