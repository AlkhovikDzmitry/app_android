package com.horcrux.svg;

import android.graphics.Matrix;
import com.facebook.common.logging.FLog;
import com.facebook.react.bridge.Dynamic;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.common.ReactConstants;
import com.horcrux.svg.Brush;
import javax.annotation.Nullable;

/* JADX INFO: Access modifiers changed from: package-private */
/* loaded from: classes2.dex */
public class MaskView extends GroupView {
    private static final float[] sRawMatrix = {1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f};

    /* renamed from: mH */
    SVGLength f165mH;
    private Brush.BrushUnits mMaskContentUnits;
    private Brush.BrushUnits mMaskUnits;
    private Matrix mMatrix;

    /* renamed from: mW */
    SVGLength f166mW;

    /* renamed from: mX */
    SVGLength f167mX;

    /* renamed from: mY */
    SVGLength f168mY;

    public MaskView(ReactContext reactContext) {
        super(reactContext);
        this.mMatrix = null;
    }

    public void setX(Dynamic dynamic) {
        this.f167mX = SVGLength.from(dynamic);
        invalidate();
    }

    public void setX(String str) {
        this.f167mX = SVGLength.from(str);
        invalidate();
    }

    public void setX(Double d) {
        this.f167mX = SVGLength.from(d);
        invalidate();
    }

    public void setY(Dynamic dynamic) {
        this.f168mY = SVGLength.from(dynamic);
        invalidate();
    }

    public void setY(String str) {
        this.f168mY = SVGLength.from(str);
        invalidate();
    }

    public void setY(Double d) {
        this.f168mY = SVGLength.from(d);
        invalidate();
    }

    public void setWidth(Dynamic dynamic) {
        this.f166mW = SVGLength.from(dynamic);
        invalidate();
    }

    public void setWidth(String str) {
        this.f166mW = SVGLength.from(str);
        invalidate();
    }

    public void setWidth(Double d) {
        this.f166mW = SVGLength.from(d);
        invalidate();
    }

    public void setHeight(Dynamic dynamic) {
        this.f165mH = SVGLength.from(dynamic);
        invalidate();
    }

    public void setHeight(String str) {
        this.f165mH = SVGLength.from(str);
        invalidate();
    }

    public void setHeight(Double d) {
        this.f165mH = SVGLength.from(d);
        invalidate();
    }

    public void setMaskUnits(int i) {
        if (i == 0) {
            this.mMaskUnits = Brush.BrushUnits.OBJECT_BOUNDING_BOX;
        } else if (i == 1) {
            this.mMaskUnits = Brush.BrushUnits.USER_SPACE_ON_USE;
        }
        invalidate();
    }

    public void setMaskContentUnits(int i) {
        if (i == 0) {
            this.mMaskContentUnits = Brush.BrushUnits.OBJECT_BOUNDING_BOX;
        } else if (i == 1) {
            this.mMaskContentUnits = Brush.BrushUnits.USER_SPACE_ON_USE;
        }
        invalidate();
    }

    public void setMaskTransform(@Nullable ReadableArray readableArray) {
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

    /* JADX INFO: Access modifiers changed from: package-private */
    @Override // com.horcrux.svg.GroupView, com.horcrux.svg.VirtualView
    public void saveDefinition() {
        if (this.mName != null) {
            getSvgView().defineMask(this, this.mName);
        }
    }
}
