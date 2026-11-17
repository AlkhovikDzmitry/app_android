package com.facebook.react.viewmanagers;

import android.view.View;
import com.facebook.react.bridge.ColorPropConverter;
import com.facebook.react.uimanager.BaseViewManagerDelegate;
import com.facebook.react.uimanager.BaseViewManagerInterface;
import com.facebook.react.uimanager.ViewProps;
import com.facebook.react.viewmanagers.RNSVGSvgViewManagerInterface;

/* loaded from: classes.dex */
public class RNSVGSvgViewManagerDelegate<T extends View, U extends BaseViewManagerInterface<T> & RNSVGSvgViewManagerInterface<T>> extends BaseViewManagerDelegate<T, U> {
    public RNSVGSvgViewManagerDelegate(BaseViewManagerInterface baseViewManagerInterface) {
        super(baseViewManagerInterface);
    }

    @Override // com.facebook.react.uimanager.BaseViewManagerDelegate, com.facebook.react.uimanager.ViewManagerDelegate
    public void setProperty(T t, String str, Object obj) {
        str.hashCode();
        char c = 65535;
        switch (str.hashCode()) {
            case -2064426617:
                if (str.equals("bbHeight")) {
                    c = 0;
                    break;
                }
                break;
            case -1567958285:
                if (str.equals("vbHeight")) {
                    c = 1;
                    break;
                }
                break;
            case -329721498:
                if (str.equals("bbWidth")) {
                    c = 2;
                    break;
                }
                break;
            case -293492298:
                if (str.equals(ViewProps.POINTER_EVENTS)) {
                    c = 3;
                    break;
                }
                break;
            case 3351622:
                if (str.equals("minX")) {
                    c = 4;
                    break;
                }
                break;
            case 3351623:
                if (str.equals("minY")) {
                    c = 5;
                    break;
                }
                break;
            case 92903173:
                if (str.equals("align")) {
                    c = 6;
                    break;
                }
                break;
            case 94842723:
                if (str.equals(ViewProps.COLOR)) {
                    c = 7;
                    break;
                }
                break;
            case 240482938:
                if (str.equals("vbWidth")) {
                    c = '\b';
                    break;
                }
                break;
            case 1327599912:
                if (str.equals("tintColor")) {
                    c = '\t';
                    break;
                }
                break;
            case 1908075304:
                if (str.equals("meetOrSlice")) {
                    c = '\n';
                    break;
                }
                break;
        }
        switch (c) {
            case 0:
                if (obj instanceof String) {
                    ((RNSVGSvgViewManagerInterface) this.mViewManager).setBbHeight((RNSVGSvgViewManagerInterface) t, (String) obj);
                    return;
                } else if (obj instanceof Double) {
                    ((RNSVGSvgViewManagerInterface) this.mViewManager).setBbHeight((RNSVGSvgViewManagerInterface) t, (Double) obj);
                    return;
                } else {
                    ((RNSVGSvgViewManagerInterface) this.mViewManager).setBbHeight((RNSVGSvgViewManagerInterface) t, (Double) null);
                    return;
                }
            case 1:
                ((RNSVGSvgViewManagerInterface) this.mViewManager).setVbHeight(t, obj != null ? ((Double) obj).floatValue() : Float.NaN);
                return;
            case 2:
                if (obj instanceof String) {
                    ((RNSVGSvgViewManagerInterface) this.mViewManager).setBbWidth((RNSVGSvgViewManagerInterface) t, (String) obj);
                    return;
                } else if (obj instanceof Double) {
                    ((RNSVGSvgViewManagerInterface) this.mViewManager).setBbWidth((RNSVGSvgViewManagerInterface) t, (Double) obj);
                    return;
                } else {
                    ((RNSVGSvgViewManagerInterface) this.mViewManager).setBbWidth((RNSVGSvgViewManagerInterface) t, (Double) null);
                    return;
                }
            case 3:
                ((RNSVGSvgViewManagerInterface) this.mViewManager).setPointerEvents(t, obj != null ? (String) obj : null);
                return;
            case 4:
                ((RNSVGSvgViewManagerInterface) this.mViewManager).setMinX(t, obj != null ? ((Double) obj).floatValue() : Float.NaN);
                return;
            case 5:
                ((RNSVGSvgViewManagerInterface) this.mViewManager).setMinY(t, obj != null ? ((Double) obj).floatValue() : Float.NaN);
                return;
            case 6:
                ((RNSVGSvgViewManagerInterface) this.mViewManager).setAlign(t, obj != null ? (String) obj : null);
                return;
            case 7:
                ((RNSVGSvgViewManagerInterface) this.mViewManager).setColor(t, ColorPropConverter.getColor(obj, t.getContext()));
                return;
            case '\b':
                ((RNSVGSvgViewManagerInterface) this.mViewManager).setVbWidth(t, obj != null ? ((Double) obj).floatValue() : Float.NaN);
                return;
            case '\t':
                ((RNSVGSvgViewManagerInterface) this.mViewManager).setTintColor(t, ColorPropConverter.getColor(obj, t.getContext()));
                return;
            case '\n':
                ((RNSVGSvgViewManagerInterface) this.mViewManager).setMeetOrSlice(t, obj != null ? ((Double) obj).intValue() : 0);
                return;
            default:
                super.setProperty(t, str, obj);
                return;
        }
    }
}
