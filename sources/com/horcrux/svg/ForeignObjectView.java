package com.horcrux.svg;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.RectF;
import android.view.View;
import com.facebook.react.bridge.Dynamic;
import com.facebook.react.bridge.ReactContext;

/* loaded from: classes2.dex */
public class ForeignObjectView extends GroupView {
    Canvas fake;
    Bitmap fakeBitmap;

    /* renamed from: mH */
    SVGLength f155mH;

    /* renamed from: mW */
    SVGLength f156mW;

    /* renamed from: mX */
    SVGLength f157mX;

    /* renamed from: mY */
    SVGLength f158mY;

    public ForeignObjectView(ReactContext reactContext) {
        super(reactContext);
        this.fakeBitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888);
        this.fake = new Canvas(this.fakeBitmap);
    }

    @Override // com.horcrux.svg.GroupView, com.horcrux.svg.RenderableView, com.horcrux.svg.VirtualView
    public void draw(Canvas canvas, Paint paint, float f) {
        canvas.translate((float) relativeOnWidth(this.f157mX), (float) relativeOnHeight(this.f158mY));
        canvas.clipRect(0.0f, 0.0f, (float) relativeOnWidth(this.f156mW), (float) relativeOnHeight(this.f155mH));
        super.draw(canvas, paint, f);
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public void onDescendantInvalidated(View view, View view2) {
        super.onDescendantInvalidated(view, view2);
        invalidate();
    }

    public void setX(Dynamic dynamic) {
        this.f157mX = SVGLength.from(dynamic);
        invalidate();
    }

    public void setX(String str) {
        this.f157mX = SVGLength.from(str);
        invalidate();
    }

    public void setX(Double d) {
        this.f157mX = SVGLength.from(d);
        invalidate();
    }

    public void setY(Dynamic dynamic) {
        this.f158mY = SVGLength.from(dynamic);
        invalidate();
    }

    public void setY(String str) {
        this.f158mY = SVGLength.from(str);
        invalidate();
    }

    public void setY(Double d) {
        this.f158mY = SVGLength.from(d);
        invalidate();
    }

    public void setWidth(Dynamic dynamic) {
        this.f156mW = SVGLength.from(dynamic);
        invalidate();
    }

    public void setWidth(String str) {
        this.f156mW = SVGLength.from(str);
        invalidate();
    }

    public void setWidth(Double d) {
        this.f156mW = SVGLength.from(d);
        invalidate();
    }

    public void setHeight(Dynamic dynamic) {
        this.f155mH = SVGLength.from(dynamic);
        invalidate();
    }

    public void setHeight(String str) {
        this.f155mH = SVGLength.from(str);
        invalidate();
    }

    public void setHeight(Double d) {
        this.f155mH = SVGLength.from(d);
        invalidate();
    }

    @Override // com.horcrux.svg.GroupView
    public void drawGroup(Canvas canvas, Paint paint, float f) {
        pushGlyphContext();
        SvgView svgView = getSvgView();
        RectF rectF = new RectF();
        for (int i = 0; i < getChildCount(); i++) {
            View childAt = getChildAt(i);
            if (!(childAt instanceof MaskView)) {
                if (childAt instanceof VirtualView) {
                    VirtualView virtualView = (VirtualView) childAt;
                    if (!"none".equals(virtualView.mDisplay)) {
                        boolean z = virtualView instanceof RenderableView;
                        if (z) {
                            ((RenderableView) virtualView).mergeProperties(this);
                        }
                        int saveAndSetupCanvas = virtualView.saveAndSetupCanvas(canvas, this.mCTM);
                        virtualView.render(canvas, paint, this.mOpacity * f);
                        RectF clientRect = virtualView.getClientRect();
                        if (clientRect != null) {
                            rectF.union(clientRect);
                        }
                        virtualView.restoreCanvas(canvas, saveAndSetupCanvas);
                        if (z) {
                            ((RenderableView) virtualView).resetProperties();
                        }
                        if (virtualView.isResponsible()) {
                            svgView.enableTouchEvents();
                        }
                    }
                } else if (childAt instanceof SvgView) {
                    SvgView svgView2 = (SvgView) childAt;
                    svgView2.drawChildren(canvas);
                    if (svgView2.isResponsible()) {
                        svgView.enableTouchEvents();
                    }
                } else {
                    childAt.draw(canvas);
                }
            }
        }
        setClientRect(rectF);
        popGlyphContext();
    }

    @Override // com.facebook.react.views.view.ReactViewGroup, android.view.ViewGroup, android.view.View
    public void dispatchDraw(Canvas canvas) {
        super.dispatchDraw(this.fake);
    }

    @Override // com.facebook.react.views.view.ReactViewGroup, android.view.ViewGroup
    public boolean drawChild(Canvas canvas, View view, long j) {
        return super.drawChild(this.fake, view, j);
    }
}
