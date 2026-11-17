package com.swmansion.reanimated.nodes;

import android.graphics.PointF;
import com.facebook.react.bridge.ReadableMap;
import com.swmansion.reanimated.MapUtils;
import com.swmansion.reanimated.NodesManager;

/* loaded from: classes2.dex */
public class BezierNode extends Node {
    private final int mInputID;
    private final CubicBezierInterpolator mInterpolator;

    /* loaded from: classes2.dex */
    public static class CubicBezierInterpolator {

        /* renamed from: a */
        protected PointF f215a;

        /* renamed from: b */
        protected PointF f216b;

        /* renamed from: c */
        protected PointF f217c;
        protected PointF end;
        protected PointF start;

        public CubicBezierInterpolator(PointF pointF, PointF pointF2) {
            this.f215a = new PointF();
            this.f216b = new PointF();
            this.f217c = new PointF();
            this.start = pointF;
            this.end = pointF2;
        }

        public CubicBezierInterpolator(float f, float f2, float f3, float f4) {
            this(new PointF(f, f2), new PointF(f3, f4));
        }

        public float getInterpolation(float f) {
            return getBezierCoordinateY(getXForTime(f));
        }

        protected float getBezierCoordinateY(float f) {
            this.f217c.y = this.start.y * 3.0f;
            this.f216b.y = ((this.end.y - this.start.y) * 3.0f) - this.f217c.y;
            this.f215a.y = (1.0f - this.f217c.y) - this.f216b.y;
            return f * (this.f217c.y + ((this.f216b.y + (this.f215a.y * f)) * f));
        }

        protected float getXForTime(float f) {
            float f2 = f;
            for (int i = 1; i < 14; i++) {
                float bezierCoordinateX = getBezierCoordinateX(f2) - f;
                if (Math.abs(bezierCoordinateX) < 0.001d) {
                    break;
                }
                f2 -= bezierCoordinateX / getXDerivate(f2);
            }
            return f2;
        }

        private float getXDerivate(float f) {
            return this.f217c.x + (f * ((this.f216b.x * 2.0f) + (this.f215a.x * 3.0f * f)));
        }

        private float getBezierCoordinateX(float f) {
            this.f217c.x = this.start.x * 3.0f;
            this.f216b.x = ((this.end.x - this.start.x) * 3.0f) - this.f217c.x;
            this.f215a.x = (1.0f - this.f217c.x) - this.f216b.x;
            return f * (this.f217c.x + ((this.f216b.x + (this.f215a.x * f)) * f));
        }
    }

    public BezierNode(int i, ReadableMap readableMap, NodesManager nodesManager) {
        super(i, readableMap, nodesManager);
        this.mInputID = MapUtils.getInt(readableMap, "input", "Reanimated: Argument passed to bezier node is either of wrong type or is missing.");
        this.mInterpolator = new CubicBezierInterpolator((float) readableMap.getDouble("mX1"), (float) readableMap.getDouble("mY1"), (float) readableMap.getDouble("mX2"), (float) readableMap.getDouble("mY2"));
    }

    @Override // com.swmansion.reanimated.nodes.Node
    public Double evaluate() {
        return Double.valueOf(this.mInterpolator.getInterpolation(((Double) this.mNodesManager.getNodeValue(this.mInputID)).floatValue()));
    }
}
