package io.nlopez.smartlocation.p012rx;

import android.content.Context;
import android.location.Address;
import android.location.Location;
import com.google.android.gms.location.DetectedActivity;
import io.nlopez.smartlocation.OnActivityUpdatedListener;
import io.nlopez.smartlocation.OnGeocodingListener;
import io.nlopez.smartlocation.OnGeofencingTransitionListener;
import io.nlopez.smartlocation.OnLocationUpdatedListener;
import io.nlopez.smartlocation.OnReverseGeocodingListener;
import io.nlopez.smartlocation.SmartLocation;
import io.nlopez.smartlocation.geocoding.utils.LocationAddress;
import io.nlopez.smartlocation.geofencing.utils.TransitionGeofence;
import java.util.List;
import rx.Observable;
import rx.Subscriber;
import rx.functions.Action0;

/* renamed from: io.nlopez.smartlocation.rx.ObservableFactory */
/* loaded from: classes2.dex */
public class ObservableFactory {
    private ObservableFactory() {
        throw new AssertionError("This should not be instantiated");
    }

    public static Observable<Location> from(final SmartLocation.LocationControl locationControl) {
        return Observable.create(new Observable.OnSubscribe<Location>() { // from class: io.nlopez.smartlocation.rx.ObservableFactory.2
            public void call(final Subscriber<? super Location> subscriber) {
                locationControl.start(new OnLocationUpdatedListener() { // from class: io.nlopez.smartlocation.rx.ObservableFactory.2.1
                    @Override // io.nlopez.smartlocation.OnLocationUpdatedListener
                    public void onLocationUpdated(Location location) {
                        subscriber.onNext(location);
                    }
                });
            }
        }).doOnUnsubscribe(new Action0() { // from class: io.nlopez.smartlocation.rx.ObservableFactory.1
            public void call() {
                locationControl.stop();
            }
        });
    }

    public static Observable<DetectedActivity> from(final SmartLocation.ActivityRecognitionControl activityRecognitionControl) {
        return Observable.create(new Observable.OnSubscribe<DetectedActivity>() { // from class: io.nlopez.smartlocation.rx.ObservableFactory.4
            public void call(final Subscriber<? super DetectedActivity> subscriber) {
                activityRecognitionControl.start(new OnActivityUpdatedListener() { // from class: io.nlopez.smartlocation.rx.ObservableFactory.4.1
                    @Override // io.nlopez.smartlocation.OnActivityUpdatedListener
                    public void onActivityUpdated(DetectedActivity detectedActivity) {
                        subscriber.onNext(detectedActivity);
                    }
                });
            }
        }).doOnUnsubscribe(new Action0() { // from class: io.nlopez.smartlocation.rx.ObservableFactory.3
            public void call() {
                activityRecognitionControl.stop();
            }
        });
    }

    public static Observable<TransitionGeofence> from(final SmartLocation.GeofencingControl geofencingControl) {
        return Observable.create(new Observable.OnSubscribe<TransitionGeofence>() { // from class: io.nlopez.smartlocation.rx.ObservableFactory.6
            public void call(final Subscriber<? super TransitionGeofence> subscriber) {
                geofencingControl.start(new OnGeofencingTransitionListener() { // from class: io.nlopez.smartlocation.rx.ObservableFactory.6.1
                    @Override // io.nlopez.smartlocation.OnGeofencingTransitionListener
                    public void onGeofenceTransition(TransitionGeofence transitionGeofence) {
                        subscriber.onNext(transitionGeofence);
                    }
                });
            }
        }).doOnUnsubscribe(new Action0() { // from class: io.nlopez.smartlocation.rx.ObservableFactory.5
            public void call() {
                geofencingControl.stop();
            }
        });
    }

    public static Observable<List<LocationAddress>> fromAddress(final Context context, final String str, final int i) {
        return Observable.create(new Observable.OnSubscribe<List<LocationAddress>>() { // from class: io.nlopez.smartlocation.rx.ObservableFactory.7
            public void call(final Subscriber<? super List<LocationAddress>> subscriber) {
                SmartLocation.with(context).geocoding().add(str, i).start(new OnGeocodingListener() { // from class: io.nlopez.smartlocation.rx.ObservableFactory.7.1
                    @Override // io.nlopez.smartlocation.OnGeocodingListener
                    public void onLocationResolved(String str2, List<LocationAddress> list) {
                        subscriber.onNext(list);
                        subscriber.onCompleted();
                    }
                });
            }
        });
    }

    public static Observable<List<Address>> fromLocation(final Context context, final Location location, final int i) {
        return Observable.create(new Observable.OnSubscribe<List<Address>>() { // from class: io.nlopez.smartlocation.rx.ObservableFactory.8
            public void call(final Subscriber<? super List<Address>> subscriber) {
                SmartLocation.with(context).geocoding().add(location, i).start(new OnReverseGeocodingListener() { // from class: io.nlopez.smartlocation.rx.ObservableFactory.8.1
                    @Override // io.nlopez.smartlocation.OnReverseGeocodingListener
                    public void onAddressResolved(Location location2, List<Address> list) {
                        subscriber.onNext(list);
                        subscriber.onCompleted();
                    }
                });
            }
        });
    }
}
