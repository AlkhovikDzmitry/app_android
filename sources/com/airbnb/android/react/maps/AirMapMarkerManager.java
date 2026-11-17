package com.airbnb.android.react.maps;

import android.graphics.Bitmap;
import android.graphics.Color;
import android.view.View;
import androidx.core.internal.view.SupportMenu;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.LayoutShadowNode;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.ViewProps;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.material.color.MaterialColors;
import java.util.HashMap;
import java.util.Map;
import java.util.WeakHashMap;
import java.util.concurrent.ConcurrentHashMap;

/* loaded from: classes.dex */
public class AirMapMarkerManager extends ViewGroupManager<AirMapMarker> {
    private final Map<String, AirMapMarkerSharedIcon> sharedIcons = new ConcurrentHashMap();

    @Override // com.facebook.react.uimanager.ViewManager, com.facebook.react.bridge.NativeModule
    public String getName() {
        return "AIRMapMarker";
    }

    /* loaded from: classes.dex */
    public static class AirMapMarkerSharedIcon {
        private Bitmap bitmap;
        private BitmapDescriptor iconBitmapDescriptor;
        private final Map<AirMapMarker, Boolean> markers = new WeakHashMap();
        private boolean loadImageStarted = false;

        public synchronized boolean shouldLoadImage() {
            if (this.loadImageStarted) {
                return false;
            }
            this.loadImageStarted = true;
            return true;
        }

        public synchronized void addMarker(AirMapMarker airMapMarker) {
            this.markers.put(airMapMarker, true);
            BitmapDescriptor bitmapDescriptor = this.iconBitmapDescriptor;
            if (bitmapDescriptor != null) {
                airMapMarker.setIconBitmapDescriptor(bitmapDescriptor, this.bitmap);
            }
        }

        public synchronized void removeMarker(AirMapMarker airMapMarker) {
            this.markers.remove(airMapMarker);
        }

        public synchronized boolean hasMarker() {
            return this.markers.isEmpty();
        }

        public synchronized void updateIcon(BitmapDescriptor bitmapDescriptor, Bitmap bitmap) {
            this.iconBitmapDescriptor = bitmapDescriptor;
            this.bitmap = bitmap.copy(Bitmap.Config.ARGB_8888, true);
            if (this.markers.isEmpty()) {
                return;
            }
            for (Map.Entry<AirMapMarker, Boolean> entry : this.markers.entrySet()) {
                if (entry.getKey() != null) {
                    entry.getKey().setIconBitmapDescriptor(bitmapDescriptor, bitmap);
                }
            }
        }
    }

    public AirMapMarkerSharedIcon getSharedIcon(String str) {
        AirMapMarkerSharedIcon airMapMarkerSharedIcon = this.sharedIcons.get(str);
        if (airMapMarkerSharedIcon == null) {
            synchronized (this) {
                airMapMarkerSharedIcon = this.sharedIcons.get(str);
                if (airMapMarkerSharedIcon == null) {
                    airMapMarkerSharedIcon = new AirMapMarkerSharedIcon();
                    this.sharedIcons.put(str, airMapMarkerSharedIcon);
                }
            }
        }
        return airMapMarkerSharedIcon;
    }

    public void removeSharedIconIfEmpty(String str) {
        AirMapMarkerSharedIcon airMapMarkerSharedIcon = this.sharedIcons.get(str);
        if (airMapMarkerSharedIcon == null || airMapMarkerSharedIcon.hasMarker()) {
            return;
        }
        synchronized (this) {
            AirMapMarkerSharedIcon airMapMarkerSharedIcon2 = this.sharedIcons.get(str);
            if (airMapMarkerSharedIcon2 != null && !airMapMarkerSharedIcon2.hasMarker()) {
                this.sharedIcons.remove(str);
            }
        }
    }

    @Override // com.facebook.react.uimanager.ViewManager
    public AirMapMarker createViewInstance(ThemedReactContext themedReactContext) {
        return new AirMapMarker(themedReactContext, this);
    }

    @ReactProp(name = "coordinate")
    public void setCoordinate(AirMapMarker airMapMarker, ReadableMap readableMap) {
        airMapMarker.setCoordinate(readableMap);
    }

    @ReactProp(name = "title")
    public void setTitle(AirMapMarker airMapMarker, String str) {
        airMapMarker.setTitle(str);
    }

    @ReactProp(name = "identifier")
    public void setIdentifier(AirMapMarker airMapMarker, String str) {
        airMapMarker.setIdentifier(str);
    }

    @ReactProp(name = "description")
    public void setDescription(AirMapMarker airMapMarker, String str) {
        airMapMarker.setSnippet(str);
    }

    @ReactProp(name = "anchor")
    public void setAnchor(AirMapMarker airMapMarker, ReadableMap readableMap) {
        airMapMarker.setAnchor((readableMap == null || !readableMap.hasKey("x")) ? 0.5d : readableMap.getDouble("x"), (readableMap == null || !readableMap.hasKey("y")) ? 1.0d : readableMap.getDouble("y"));
    }

    @ReactProp(name = "calloutAnchor")
    public void setCalloutAnchor(AirMapMarker airMapMarker, ReadableMap readableMap) {
        airMapMarker.setCalloutAnchor((readableMap == null || !readableMap.hasKey("x")) ? 0.5d : readableMap.getDouble("x"), (readableMap == null || !readableMap.hasKey("y")) ? 0.0d : readableMap.getDouble("y"));
    }

    @ReactProp(name = "image")
    public void setImage(AirMapMarker airMapMarker, String str) {
        airMapMarker.setImage(str);
    }

    @ReactProp(name = "icon")
    public void setIcon(AirMapMarker airMapMarker, String str) {
        airMapMarker.setImage(str);
    }

    @ReactProp(customType = "Color", defaultInt = SupportMenu.CATEGORY_MASK, name = "pinColor")
    public void setPinColor(AirMapMarker airMapMarker, int i) {
        float[] fArr = new float[3];
        Color.colorToHSV(i, fArr);
        airMapMarker.setMarkerHue(fArr[0]);
    }

    @ReactProp(defaultFloat = 0.0f, name = ViewProps.ROTATION)
    public void setMarkerRotation(AirMapMarker airMapMarker, float f) {
        airMapMarker.setRotation(f);
    }

    @ReactProp(defaultBoolean = false, name = "flat")
    public void setFlat(AirMapMarker airMapMarker, boolean z) {
        airMapMarker.setFlat(z);
    }

    @ReactProp(defaultBoolean = false, name = "draggable")
    public void setDraggable(AirMapMarker airMapMarker, boolean z) {
        airMapMarker.setDraggable(z);
    }

    @Override // com.facebook.react.uimanager.BaseViewManager, com.facebook.react.uimanager.BaseViewManagerInterface
    @ReactProp(defaultFloat = 0.0f, name = ViewProps.Z_INDEX)
    public void setZIndex(AirMapMarker airMapMarker, float f) {
        super.setZIndex((AirMapMarkerManager) airMapMarker, f);
        airMapMarker.setZIndex(Math.round(f));
    }

    @Override // com.facebook.react.uimanager.BaseViewManager, com.facebook.react.uimanager.BaseViewManagerInterface
    @ReactProp(defaultFloat = MaterialColors.ALPHA_FULL, name = ViewProps.OPACITY)
    public void setOpacity(AirMapMarker airMapMarker, float f) {
        super.setOpacity((AirMapMarkerManager) airMapMarker, f);
        airMapMarker.setOpacity(f);
    }

    @ReactProp(defaultBoolean = com.swmansion.reanimated.BuildConfig.DEBUG, name = "tracksViewChanges")
    public void setTracksViewChanges(AirMapMarker airMapMarker, boolean z) {
        airMapMarker.setTracksViewChanges(z);
    }

    @Override // com.facebook.react.uimanager.ViewGroupManager
    public void addView(AirMapMarker airMapMarker, View view, int i) {
        if (view instanceof AirMapCallout) {
            airMapMarker.setCalloutView((AirMapCallout) view);
            return;
        }
        super.addView((AirMapMarkerManager) airMapMarker, view, i);
        airMapMarker.update(true);
    }

    @Override // com.facebook.react.uimanager.ViewGroupManager
    public void removeViewAt(AirMapMarker airMapMarker, int i) {
        super.removeViewAt((AirMapMarkerManager) airMapMarker, i);
        airMapMarker.update(true);
    }

    @Override // com.facebook.react.uimanager.ViewManager
    public void receiveCommand(AirMapMarker airMapMarker, String str, ReadableArray readableArray) {
        str.hashCode();
        char c = 65535;
        switch (str.hashCode()) {
            case -1868137362:
                if (str.equals("animateMarkerToCoordinate")) {
                    c = 0;
                    break;
                }
                break;
            case -934876681:
                if (str.equals("redraw")) {
                    c = 1;
                    break;
                }
                break;
            case 428235918:
                if (str.equals("hideCallout")) {
                    c = 2;
                    break;
                }
                break;
            case 936806003:
                if (str.equals("showCallout")) {
                    c = 3;
                    break;
                }
                break;
        }
        switch (c) {
            case 0:
                if (readableArray == null) {
                    return;
                }
                ReadableMap map = readableArray.getMap(0);
                int i = readableArray.getInt(1);
                airMapMarker.animateToCoodinate(new LatLng(map.getDouble("latitude"), map.getDouble("longitude")), Integer.valueOf(i));
                return;
            case 1:
                airMapMarker.updateMarkerIcon();
                return;
            case 2:
                ((Marker) airMapMarker.getFeature()).hideInfoWindow();
                return;
            case 3:
                ((Marker) airMapMarker.getFeature()).showInfoWindow();
                return;
            default:
                return;
        }
    }

    @Override // com.facebook.react.uimanager.BaseViewManager, com.facebook.react.uimanager.ViewManager
    public Map getExportedCustomDirectEventTypeConstants() {
        Map m176of = MapBuilder.m176of("onPress", MapBuilder.m180of("registrationName", "onPress"), "onCalloutPress", MapBuilder.m180of("registrationName", "onCalloutPress"), "onDragStart", MapBuilder.m180of("registrationName", "onDragStart"), "onDrag", MapBuilder.m180of("registrationName", "onDrag"), "onDragEnd", MapBuilder.m180of("registrationName", "onDragEnd"));
        m176of.putAll(MapBuilder.m178of("onDragStart", MapBuilder.m180of("registrationName", "onDragStart"), "onDrag", MapBuilder.m180of("registrationName", "onDrag"), "onDragEnd", MapBuilder.m180of("registrationName", "onDragEnd")));
        return m176of;
    }

    @Override // com.facebook.react.uimanager.ViewGroupManager, com.facebook.react.uimanager.ViewManager
    public LayoutShadowNode createShadowNodeInstance() {
        return new SizeReportingShadowNode();
    }

    @Override // com.facebook.react.uimanager.ViewGroupManager
    public void updateExtraData(AirMapMarker airMapMarker, Object obj) {
        HashMap hashMap = (HashMap) obj;
        airMapMarker.update((int) ((Float) hashMap.get("width")).floatValue(), (int) ((Float) hashMap.get("height")).floatValue());
    }
}
