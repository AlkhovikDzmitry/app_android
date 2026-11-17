package com.google.android.gms.internal.p009authapi;

import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.api.internal.BaseImplementation;

/* compiled from: com.google.android.gms:play-services-auth@@20.5.0 */
/* renamed from: com.google.android.gms.internal.auth-api.zbk */
/* loaded from: classes.dex */
final class zbk extends zbd {
    private final BaseImplementation.ResultHolder zba;

    public zbk(BaseImplementation.ResultHolder resultHolder) {
        this.zba = resultHolder;
    }

    @Override // com.google.android.gms.internal.p009authapi.zbd, com.google.android.gms.internal.p009authapi.zbs
    public final void zbc(Status status) {
        this.zba.setResult(status);
    }
}
