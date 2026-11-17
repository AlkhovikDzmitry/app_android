package com.horcrux.svg;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import com.facebook.react.bridge.Dynamic;
import com.facebook.react.bridge.ReactContext;

/* loaded from: classes2.dex */
public class CircleView extends RenderableView {
    private SVGLength mCx;
    private SVGLength mCy;

    /* renamed from: mR */
    private SVGLength f154mR;

    public CircleView(ReactContext reactContext) {
        super(reactContext);
    }

    public void setCx(Dynamic dynamic) {
        this.mCx = SVGLength.from(dynamic);
        invalidate();
    }

    public void setCx(String str) {
        this.mCx = SVGLength.from(str);
        invalidate();
    }

    public void setCx(Double d) {
        this.mCx = SVGLength.from(d);
        invalidate();
    }

    public void setCy(Dynamic dynamic) {
        this.mCy = SVGLength.from(dynamic);
        invalidate();
    }

    public void setCy(String str) {
        this.mCy = SVGLength.from(str);
        invalidate();
    }

    public void setCy(Double d) {
        this.mCy = SVGLength.from(d);
        invalidate();
    }

    public void setR(Dynamic dynamic) {
        this.f154mR = SVGLength.from(dynamic);
        invalidate();
    }

    public void setR(String str) {
        this.f154mR = SVGLength.from(str);
        invalidate();
    }

    public void setR(Double d) {
        this.f154mR = SVGLength.from(d);
        invalidate();
    }

    @Override // com.horcrux.svg.RenderableView, com.horcrux.svg.VirtualView
    public Path getPath(Canvas canvas, Paint paint) {
        Path path = new Path();
        path.addCircle((float) relativeOnWidth(this.mCx), (float) relativeOnHeight(this.mCy), (float) relativeOnOther(this.f154mR), Path.Direction.CW);
        return path;
    }
}
