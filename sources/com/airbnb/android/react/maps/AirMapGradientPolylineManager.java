package com.airbnb.android.react.maps;

import android.util.DisplayMetrics;
import android.view.WindowManager;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.ViewProps;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.material.color.MaterialColors;
import java.util.ArrayList;

/* loaded from: classes.dex */
public class AirMapGradientPolylineManager extends ViewGroupManager<AirMapGradientPolyline> {
    private final DisplayMetrics metrics;

    @Override // com.facebook.react.uimanager.ViewManager, com.facebook.react.bridge.NativeModule
    public String getName() {
        return "AIRMapGradientPolyline";
    }

    public AirMapGradientPolylineManager(ReactApplicationContext reactApplicationContext) {
        DisplayMetrics displayMetrics = new DisplayMetrics();
        this.metrics = displayMetrics;
        ((WindowManager) reactApplicationContext.getSystemService("window")).getDefaultDisplay().getRealMetrics(displayMetrics);
    }

    @Override // com.facebook.react.uimanager.ViewManager
    public AirMapGradientPolyline createViewInstance(ThemedReactContext themedReactContext) {
        return new AirMapGradientPolyline(themedReactContext);
    }

    @ReactProp(name = "coordinates")
    public void setCoordinates(AirMapGradientPolyline airMapGradientPolyline, ReadableArray readableArray) {
        ArrayList arrayList = new ArrayList();
        for (int i = 0; i < readableArray.size(); i++) {
            ReadableMap map = readableArray.getMap(i);
            arrayList.add(new LatLng(map.getDouble("latitude"), map.getDouble("longitude")));
        }
        airMapGradientPolyline.setCoordinates(arrayList);
    }

    @ReactProp(customType = "ColorArray", name = "strokeColors")
    public void setStrokeColors(AirMapGradientPolyline airMapGradientPolyline, ReadableArray readableArray) {
        if (readableArray != null) {
            if (readableArray.size() == 0) {
                airMapGradientPolyline.setStrokeColors(new int[]{0, 0});
                return;
            }
            if (readableArray.size() == 1) {
                airMapGradientPolyline.setStrokeColors(new int[]{readableArray.getInt(0), readableArray.getInt(0)});
                return;
            }
            int[] iArr = new int[readableArray.size()];
            for (int i = 0; i < readableArray.size(); i++) {
                iArr[i] = readableArray.getInt(i);
            }
            airMapGradientPolyline.setStrokeColors(iArr);
            return;
        }
        airMapGradientPolyline.setStrokeColors(new int[]{0, 0});
    }

    @Override // com.facebook.react.uimanager.BaseViewManager, com.facebook.react.uimanager.BaseViewManagerInterface
    @ReactProp(defaultFloat = MaterialColors.ALPHA_FULL, name = ViewProps.Z_INDEX)
    public void setZIndex(AirMapGradientPolyline airMapGradientPolyline, float f) {
        airMapGradientPolyline.setZIndex(f);
    }

    @ReactProp(defaultFloat = MaterialColors.ALPHA_FULL, name = "strokeWidth")
    public void setStrokeWidth(AirMapGradientPolyline airMapGradientPolyline, float f) {
        airMapGradientPolyline.setWidth(this.metrics.density * f);
    }
}
