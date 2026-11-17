package com.horcrux.svg;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import com.facebook.react.bridge.ReactContext;

/* loaded from: classes2.dex */
public class PathView extends RenderableView {
    private Path mPath;

    public PathView(ReactContext reactContext) {
        super(reactContext);
        PathParser.mScale = this.mScale;
        this.mPath = new Path();
    }

    public void setD(String str) {
        this.mPath = PathParser.parse(str);
        this.elements = PathParser.elements;
        invalidate();
    }

    @Override // com.horcrux.svg.RenderableView, com.horcrux.svg.VirtualView
    public Path getPath(Canvas canvas, Paint paint) {
        return this.mPath;
    }
}
