package com.facebook.react.viewmanagers;

import android.view.View;

/* loaded from: classes.dex */
public interface RNSVGSvgViewManagerInterface<T extends View> {
    void setAlign(T t, String str);

    void setBbHeight(T t, Double d);

    void setBbHeight(T t, String str);

    void setBbWidth(T t, Double d);

    void setBbWidth(T t, String str);

    void setColor(T t, Integer num);

    void setMeetOrSlice(T t, int i);

    void setMinX(T t, float f);

    void setMinY(T t, float f);

    void setPointerEvents(T t, String str);

    void setTintColor(T t, Integer num);

    void setVbHeight(T t, float f);

    void setVbWidth(T t, float f);
}
