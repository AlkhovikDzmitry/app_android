package com.google.maps.android.data.kml;

import android.graphics.Color;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.android.gms.maps.model.PolygonOptions;
import com.google.android.gms.maps.model.PolylineOptions;
import com.google.maps.android.data.Style;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Random;

/* loaded from: classes2.dex */
public class KmlStyle extends Style {
    private static final int HSV_VALUES = 3;
    private static final int HUE_VALUE = 0;
    private static final int INITIAL_SCALE = 1;
    private String mIconUrl;
    private boolean mFill = true;
    private boolean mOutline = true;
    private String mStyleId = null;
    private final HashMap<String, String> mBalloonOptions = new HashMap<>();
    private final HashSet<String> mStylesSet = new HashSet<>();
    private double mScale = 1.0d;
    private float mMarkerColor = 0.0f;
    private boolean mIconRandomColorMode = false;
    private boolean mLineRandomColorMode = false;
    private boolean mPolyRandomColorMode = false;

    public void setInfoWindowText(String str) {
        this.mBalloonOptions.put("text", str);
    }

    public String getStyleId() {
        return this.mStyleId;
    }

    public void setStyleId(String str) {
        this.mStyleId = str;
    }

    public boolean isStyleSet(String str) {
        return this.mStylesSet.contains(str);
    }

    public boolean hasFill() {
        return this.mFill;
    }

    public void setFill(boolean z) {
        this.mFill = z;
    }

    public double getIconScale() {
        return this.mScale;
    }

    public void setIconScale(double d) {
        this.mScale = d;
        this.mStylesSet.add("iconScale");
    }

    public boolean hasOutline() {
        return this.mOutline;
    }

    public boolean hasBalloonStyle() {
        return this.mBalloonOptions.size() > 0;
    }

    public void setOutline(boolean z) {
        this.mOutline = z;
        this.mStylesSet.add("outline");
    }

    public String getIconUrl() {
        return this.mIconUrl;
    }

    public void setIconUrl(String str) {
        this.mIconUrl = str;
        this.mStylesSet.add("iconUrl");
    }

    public void setFillColor(String str) {
        setPolygonFillColor(Color.parseColor("#" + convertColor(str)));
        this.mStylesSet.add("fillColor");
    }

    public void setMarkerColor(String str) {
        this.mMarkerColor = getHueValue(Color.parseColor("#" + convertColor(str)));
        this.mMarkerOptions.icon(BitmapDescriptorFactory.defaultMarker(this.mMarkerColor));
        this.mStylesSet.add("markerColor");
    }

    private static float getHueValue(int i) {
        float[] fArr = new float[3];
        Color.colorToHSV(i, fArr);
        return fArr[0];
    }

    private static String convertColor(String str) {
        String str2;
        if (str.length() > 6) {
            str2 = str.substring(0, 2) + str.substring(6, 8) + str.substring(4, 6) + str.substring(2, 4);
        } else {
            str2 = str.substring(4, 6) + str.substring(2, 4) + str.substring(0, 2);
        }
        if (str2.substring(0, 1).equals(" ")) {
            return "0" + str2.substring(1, str2.length());
        }
        return str2;
    }

    public void setHeading(float f) {
        setMarkerRotation(f);
        this.mStylesSet.add("heading");
    }

    public void setHotSpot(float f, float f2, String str, String str2) {
        setMarkerHotSpot(f, f2, str, str2);
        this.mStylesSet.add("hotSpot");
    }

    public void setIconColorMode(String str) {
        this.mIconRandomColorMode = str.equals("random");
        this.mStylesSet.add("iconColorMode");
    }

    boolean isIconRandomColorMode() {
        return this.mIconRandomColorMode;
    }

    public void setLineColorMode(String str) {
        this.mLineRandomColorMode = str.equals("random");
        this.mStylesSet.add("lineColorMode");
    }

    public boolean isLineRandomColorMode() {
        return this.mLineRandomColorMode;
    }

    public void setPolyColorMode(String str) {
        this.mPolyRandomColorMode = str.equals("random");
        this.mStylesSet.add("polyColorMode");
    }

    public boolean isPolyRandomColorMode() {
        return this.mPolyRandomColorMode;
    }

    public void setOutlineColor(String str) {
        PolylineOptions polylineOptions = this.mPolylineOptions;
        polylineOptions.color(Color.parseColor("#" + convertColor(str)));
        PolygonOptions polygonOptions = this.mPolygonOptions;
        polygonOptions.strokeColor(Color.parseColor("#" + str));
        this.mStylesSet.add("outlineColor");
    }

    public void setWidth(Float f) {
        setLineStringWidth(f.floatValue());
        setPolygonStrokeWidth(f.floatValue());
        this.mStylesSet.add("width");
    }

    public HashMap<String, String> getBalloonOptions() {
        return this.mBalloonOptions;
    }

    private static MarkerOptions createMarkerOptions(MarkerOptions markerOptions, boolean z, float f) {
        MarkerOptions markerOptions2 = new MarkerOptions();
        markerOptions2.rotation(markerOptions.getRotation());
        markerOptions2.anchor(markerOptions.getAnchorU(), markerOptions.getAnchorV());
        if (z) {
            markerOptions.icon(BitmapDescriptorFactory.defaultMarker(getHueValue(computeRandomColor((int) f))));
        }
        markerOptions2.icon(markerOptions.getIcon());
        return markerOptions2;
    }

    private static PolylineOptions createPolylineOptions(PolylineOptions polylineOptions) {
        PolylineOptions polylineOptions2 = new PolylineOptions();
        polylineOptions2.color(polylineOptions.getColor());
        polylineOptions2.width(polylineOptions.getWidth());
        return polylineOptions2;
    }

    private static PolygonOptions createPolygonOptions(PolygonOptions polygonOptions, boolean z, boolean z2) {
        PolygonOptions polygonOptions2 = new PolygonOptions();
        if (z) {
            polygonOptions2.fillColor(polygonOptions.getFillColor());
        }
        if (z2) {
            polygonOptions2.strokeColor(polygonOptions.getStrokeColor());
            polygonOptions2.strokeWidth(polygonOptions.getStrokeWidth());
        }
        return polygonOptions2;
    }

    public MarkerOptions getMarkerOptions() {
        return createMarkerOptions(this.mMarkerOptions, isIconRandomColorMode(), this.mMarkerColor);
    }

    public PolylineOptions getPolylineOptions() {
        return createPolylineOptions(this.mPolylineOptions);
    }

    public PolygonOptions getPolygonOptions() {
        return createPolygonOptions(this.mPolygonOptions, this.mFill, this.mOutline);
    }

    public static int computeRandomColor(int i) {
        Random random = new Random();
        int red = Color.red(i);
        int green = Color.green(i);
        int blue = Color.blue(i);
        if (red != 0) {
            red = random.nextInt(red);
        }
        if (blue != 0) {
            blue = random.nextInt(blue);
        }
        if (green != 0) {
            green = random.nextInt(green);
        }
        return Color.rgb(red, green, blue);
    }

    public String toString() {
        return "Style{\n balloon options=" + this.mBalloonOptions + ",\n fill=" + this.mFill + ",\n outline=" + this.mOutline + ",\n icon url=" + this.mIconUrl + ",\n scale=" + this.mScale + ",\n style id=" + this.mStyleId + "\n}\n";
    }
}
