package com.horcrux.svg;

import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Path;
import com.facebook.common.logging.FLog;
import com.facebook.react.bridge.Dynamic;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.common.ReactConstants;

/* loaded from: classes2.dex */
public class UseView extends RenderableView {

    /* renamed from: mH */
    private SVGLength f192mH;
    private String mHref;

    /* renamed from: mW */
    private SVGLength f193mW;

    /* renamed from: mX */
    private SVGLength f194mX;

    /* renamed from: mY */
    private SVGLength f195mY;

    public UseView(ReactContext reactContext) {
        super(reactContext);
    }

    public void setHref(String str) {
        this.mHref = str;
        invalidate();
    }

    public void setX(Dynamic dynamic) {
        this.f194mX = SVGLength.from(dynamic);
        invalidate();
    }

    public void setX(String str) {
        this.f194mX = SVGLength.from(str);
        invalidate();
    }

    public void setX(Double d) {
        this.f194mX = SVGLength.from(d);
        invalidate();
    }

    public void setY(Dynamic dynamic) {
        this.f195mY = SVGLength.from(dynamic);
        invalidate();
    }

    public void setY(String str) {
        this.f195mY = SVGLength.from(str);
        invalidate();
    }

    public void setY(Double d) {
        this.f195mY = SVGLength.from(d);
        invalidate();
    }

    public void setWidth(Dynamic dynamic) {
        this.f193mW = SVGLength.from(dynamic);
        invalidate();
    }

    public void setWidth(String str) {
        this.f193mW = SVGLength.from(str);
        invalidate();
    }

    public void setWidth(Double d) {
        this.f193mW = SVGLength.from(d);
        invalidate();
    }

    public void setHeight(Dynamic dynamic) {
        this.f192mH = SVGLength.from(dynamic);
        invalidate();
    }

    public void setHeight(String str) {
        this.f192mH = SVGLength.from(str);
        invalidate();
    }

    public void setHeight(Double d) {
        this.f192mH = SVGLength.from(d);
        invalidate();
    }

    @Override // com.horcrux.svg.RenderableView, com.horcrux.svg.VirtualView
    public void draw(Canvas canvas, Paint paint, float f) {
        VirtualView definedTemplate = getSvgView().getDefinedTemplate(this.mHref);
        if (definedTemplate == null) {
            FLog.m207w(ReactConstants.TAG, "`Use` element expected a pre-defined svg template as `href` prop, template named: " + this.mHref + " is not defined.");
            return;
        }
        definedTemplate.clearCache();
        canvas.translate((float) relativeOnWidth(this.f194mX), (float) relativeOnHeight(this.f195mY));
        boolean z = definedTemplate instanceof RenderableView;
        if (z) {
            ((RenderableView) definedTemplate).mergeProperties(this);
        }
        int saveAndSetupCanvas = definedTemplate.saveAndSetupCanvas(canvas, this.mCTM);
        clip(canvas, paint);
        if (definedTemplate instanceof SymbolView) {
            ((SymbolView) definedTemplate).drawSymbol(canvas, paint, f, (float) relativeOnWidth(this.f193mW), (float) relativeOnHeight(this.f192mH));
        } else {
            definedTemplate.draw(canvas, paint, f * this.mOpacity);
        }
        setClientRect(definedTemplate.getClientRect());
        definedTemplate.restoreCanvas(canvas, saveAndSetupCanvas);
        if (z) {
            ((RenderableView) definedTemplate).resetProperties();
        }
    }

    @Override // com.horcrux.svg.RenderableView, com.horcrux.svg.VirtualView
    public int hitTest(float[] fArr) {
        if (this.mInvertible && this.mTransformInvertible) {
            float[] fArr2 = new float[2];
            this.mInvMatrix.mapPoints(fArr2, fArr);
            this.mInvTransform.mapPoints(fArr2);
            VirtualView definedTemplate = getSvgView().getDefinedTemplate(this.mHref);
            if (definedTemplate == null) {
                FLog.m207w(ReactConstants.TAG, "`Use` element expected a pre-defined svg template as `href` prop, template named: " + this.mHref + " is not defined.");
                return -1;
            }
            int hitTest = definedTemplate.hitTest(fArr2);
            if (hitTest != -1) {
                return (definedTemplate.isResponsible() || hitTest != definedTemplate.getId()) ? hitTest : getId();
            }
        }
        return -1;
    }

    @Override // com.horcrux.svg.RenderableView, com.horcrux.svg.VirtualView
    public Path getPath(Canvas canvas, Paint paint) {
        VirtualView definedTemplate = getSvgView().getDefinedTemplate(this.mHref);
        if (definedTemplate == null) {
            FLog.m207w(ReactConstants.TAG, "`Use` element expected a pre-defined svg template as `href` prop, template named: " + this.mHref + " is not defined.");
            return null;
        }
        Path path = definedTemplate.getPath(canvas, paint);
        Path path2 = new Path();
        Matrix matrix = new Matrix();
        matrix.setTranslate((float) relativeOnWidth(this.f194mX), (float) relativeOnHeight(this.f195mY));
        path.transform(matrix, path2);
        return path2;
    }
}
