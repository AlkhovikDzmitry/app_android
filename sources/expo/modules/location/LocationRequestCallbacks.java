package expo.modules.location;

import android.location.Location;
import expo.modules.core.errors.CodedException;

/* JADX INFO: Access modifiers changed from: package-private */
/* loaded from: classes2.dex */
public abstract class LocationRequestCallbacks {
    public void onLocationChanged(Location location) {
    }

    public void onLocationError(CodedException codedException) {
    }

    public void onRequestFailed(CodedException codedException) {
    }

    public void onRequestSuccess() {
    }
}
