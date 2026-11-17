package io.nlopez.smartlocation.location;

import io.nlopez.smartlocation.utils.ServiceConnectionListener;

/* loaded from: classes2.dex */
public interface ServiceLocationProvider extends LocationProvider {
    ServiceConnectionListener getServiceListener();

    void setServiceListener(ServiceConnectionListener serviceConnectionListener);
}
