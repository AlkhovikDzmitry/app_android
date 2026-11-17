package com.airbnb.android.react.maps;

import android.util.DisplayMetrics;
import android.view.WindowManager;
import androidx.core.internal.view.SupportMenu;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.ViewProps;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.google.android.material.color.MaterialColors;
import java.util.Map;

/* loaded from: classes.dex */
public class AirMapPolygonManager extends ViewGroupManager<AirMapPolygon> {
    private final DisplayMetrics metrics;

    @Override // com.facebook.react.uimanager.ViewManager, com.facebook.react.bridge.NativeModule
    public String getName() {
        return "AIRMapPolygon";
    }

    public AirMapPolygonManager(ReactApplicationContext reactApplicationContext) {
        DisplayMetrics displayMetrics = new DisplayMetrics();
        this.metrics = displayMetrics;
        ((WindowManager) reactApplicationContext.getSystemService("window")).getDefaultDisplay().getRealMetrics(displayMetrics);
    }

    @Override // com.facebook.react.uimanager.ViewManager
    public AirMapPolygon createViewInstance(ThemedReactContext themedReactContext) {
        return new AirMapPolygon(themedReactContext);
    }

    @ReactProp(name = "coordinates")
    public void setCoordinate(AirMapPolygon airMapPolygon, ReadableArray readableArray) {
        airMapPolygon.setCoordinates(readableArray);
    }

    @ReactProp(name = "holes")
    public void setHoles(AirMapPolygon airMapPolygon, ReadableArray readableArray) {
        airMapPolygon.setHoles(readableArray);
    }

    @ReactProp(defaultFloat = MaterialColors.ALPHA_FULL, name = "strokeWidth")
    public void setStrokeWidth(AirMapPolygon airMapPolygon, float f) {
        airMapPolygon.setStrokeWidth(this.metrics.density * f);
    }

    @ReactProp(customType = "Color", defaultInt = SupportMenu.CATEGORY_MASK, name = "fillColor")
    public void setFillColor(AirMapPolygon airMapPolygon, int i) {
        airMapPolygon.setFillColor(i);
    }

    @ReactProp(customType = "Color", defaultInt = SupportMenu.CATEGORY_MASK, name = "strokeColor")
    public void setStrokeColor(AirMapPolygon airMapPolygon, int i) {
        airMapPolygon.setStrokeColor(i);
    }

    @ReactProp(defaultBoolean = false, name = "tappable")
    public void setTappable(AirMapPolygon airMapPolygon, boolean z) {
        airMapPolygon.setTappable(z);
    }

    @ReactProp(defaultBoolean = false, name = "geodesic")
    public void setGeodesic(AirMapPolygon airMapPolygon, boolean z) {
        airMapPolygon.setGeodesic(z);
    }

    @Override // com.facebook.react.uimanager.BaseViewManager, com.facebook.react.uimanager.BaseViewManagerInterface
    @ReactProp(defaultFloat = MaterialColors.ALPHA_FULL, name = ViewProps.Z_INDEX)
    public void setZIndex(AirMapPolygon airMapPolygon, float f) {
        airMapPolygon.setZIndex(f);
    }

    @Override // com.facebook.react.uimanager.BaseViewManager, com.facebook.react.uimanager.ViewManager
    public Map getExportedCustomDirectEventTypeConstants() {
        return MapBuilder.m180of("onPress", MapBuilder.m180of("registrationName", "onPress"));
    }
}
