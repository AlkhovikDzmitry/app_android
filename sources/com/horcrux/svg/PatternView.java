package com.horcrux.svg;

import android.graphics.Matrix;
import android.graphics.RectF;
import com.facebook.common.logging.FLog;
import com.facebook.react.bridge.Dynamic;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.common.ReactConstants;
import com.horcrux.svg.Brush;
import javax.annotation.Nullable;

/* loaded from: classes2.dex */
public class PatternView extends GroupView {
    private static final float[] sRawMatrix = {1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f};
    String mAlign;

    /* renamed from: mH */
    private SVGLength f172mH;
    private Matrix mMatrix;
    int mMeetOrSlice;
    private float mMinX;
    private float mMinY;
    private Brush.BrushUnits mPatternContentUnits;
    private Brush.BrushUnits mPatternUnits;
    private float mVbHeight;
    private float mVbWidth;

    /* renamed from: mW */
    private SVGLength f173mW;

    /* renamed from: mX */
    private SVGLength f174mX;

    /* renamed from: mY */
    private SVGLength f175mY;

    public PatternView(ReactContext reactContext) {
        super(reactContext);
        this.mMatrix = null;
    }

    public void setX(Dynamic dynamic) {
        this.f174mX = SVGLength.from(dynamic);
        invalidate();
    }

    public void setX(String str) {
        this.f174mX = SVGLength.from(str);
        invalidate();
    }

    public void setX(Double d) {
        this.f174mX = SVGLength.from(d);
        invalidate();
    }

    public void setY(Dynamic dynamic) {
        this.f175mY = SVGLength.from(dynamic);
        invalidate();
    }

    public void setY(String str) {
        this.f175mY = SVGLength.from(str);
        invalidate();
    }

    public void setY(Double d) {
        this.f175mY = SVGLength.from(d);
        invalidate();
    }

    public void setWidth(Dynamic dynamic) {
        this.f173mW = SVGLength.from(dynamic);
        invalidate();
    }

    public void setWidth(String str) {
        this.f173mW = SVGLength.from(str);
        invalidate();
    }

    public void setWidth(Double d) {
        this.f173mW = SVGLength.from(d);
        invalidate();
    }

    public void setHeight(Dynamic dynamic) {
        this.f172mH = SVGLength.from(dynamic);
        invalidate();
    }

    public void setHeight(String str) {
        this.f172mH = SVGLength.from(str);
        invalidate();
    }

    public void setHeight(Double d) {
        this.f172mH = SVGLength.from(d);
        invalidate();
    }

    public void setPatternUnits(int i) {
        if (i == 0) {
            this.mPatternUnits = Brush.BrushUnits.OBJECT_BOUNDING_BOX;
        } else if (i == 1) {
            this.mPatternUnits = Brush.BrushUnits.USER_SPACE_ON_USE;
        }
        invalidate();
    }

    public void setPatternContentUnits(int i) {
        if (i == 0) {
            this.mPatternContentUnits = Brush.BrushUnits.OBJECT_BOUNDING_BOX;
        } else if (i == 1) {
            this.mPatternContentUnits = Brush.BrushUnits.USER_SPACE_ON_USE;
        }
        invalidate();
    }

    public void setPatternTransform(@Nullable ReadableArray readableArray) {
        if (readableArray != null) {
            float[] fArr = sRawMatrix;
            int matrixData = PropHelper.toMatrixData(readableArray, fArr, this.mScale);
            if (matrixData == 6) {
                if (this.mMatrix == null) {
                    this.mMatrix = new Matrix();
                }
                this.mMatrix.setValues(fArr);
            } else if (matrixData != -1) {
                FLog.m207w(ReactConstants.TAG, "RNSVG: Transform matrices must be of size 6");
            }
        } else {
            this.mMatrix = null;
        }
        invalidate();
    }

    public void setMinX(float f) {
        this.mMinX = f;
        invalidate();
    }

    public void setMinY(float f) {
        this.mMinY = f;
        invalidate();
    }

    public void setVbWidth(float f) {
        this.mVbWidth = f;
        invalidate();
    }

    public void setVbHeight(float f) {
        this.mVbHeight = f;
        invalidate();
    }

    public void setAlign(String str) {
        this.mAlign = str;
        invalidate();
    }

    public void setMeetOrSlice(int i) {
        this.mMeetOrSlice = i;
        invalidate();
    }

    public RectF getViewBox() {
        return new RectF(this.mMinX * this.mScale, this.mMinY * this.mScale, (this.mMinX + this.mVbWidth) * this.mScale, (this.mMinY + this.mVbHeight) * this.mScale);
    }

    @Override // com.horcrux.svg.GroupView, com.horcrux.svg.VirtualView
    public void saveDefinition() {
        if (this.mName != null) {
            Brush brush = new Brush(Brush.BrushType.PATTERN, new SVGLength[]{this.f174mX, this.f175mY, this.f173mW, this.f172mH}, this.mPatternUnits);
            brush.setContentUnits(this.mPatternContentUnits);
            brush.setPattern(this);
            Matrix matrix = this.mMatrix;
            if (matrix != null) {
                brush.setGradientTransform(matrix);
            }
            SvgView svgView = getSvgView();
            if (this.mPatternUnits == Brush.BrushUnits.USER_SPACE_ON_USE || this.mPatternContentUnits == Brush.BrushUnits.USER_SPACE_ON_USE) {
                brush.setUserSpaceBoundingBox(svgView.getCanvasBounds());
            }
            svgView.defineBrush(brush, this.mName);
        }
    }
}
