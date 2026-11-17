package expo.modules.interfaces.barcodescanner;

import java.util.List;

/* loaded from: classes2.dex */
public class BarCodeScannerResult {
    private List<Integer> mCornerPoints;
    private int mReferenceImageHeight;
    private int mReferenceImageWidth;
    private int mType;
    private String mValue;

    /* loaded from: classes2.dex */
    public static class BoundingBox {
        private final int height;
        private final int width;

        /* renamed from: x */
        private final int f260x;

        /* renamed from: y */
        private final int f261y;

        public BoundingBox(int i, int i2, int i3, int i4) {
            this.f260x = i;
            this.f261y = i2;
            this.width = i3;
            this.height = i4;
        }

        public int getX() {
            return this.f260x;
        }

        public int getY() {
            return this.f261y;
        }

        public int getWidth() {
            return this.width;
        }

        public int getHeight() {
            return this.height;
        }
    }

    public BarCodeScannerResult(int i, String str, List<Integer> list, int i2, int i3) {
        this.mType = i;
        this.mValue = str;
        this.mCornerPoints = list;
        this.mReferenceImageHeight = i2;
        this.mReferenceImageWidth = i3;
    }

    public int getType() {
        return this.mType;
    }

    public String getValue() {
        return this.mValue;
    }

    public List<Integer> getCornerPoints() {
        return this.mCornerPoints;
    }

    public void setCornerPoints(List<Integer> list) {
        this.mCornerPoints = list;
    }

    public int getReferenceImageHeight() {
        return this.mReferenceImageHeight;
    }

    public void setReferenceImageHeight(int i) {
        this.mReferenceImageHeight = i;
    }

    public int getReferenceImageWidth() {
        return this.mReferenceImageWidth;
    }

    public void setReferenceImageWidth(int i) {
        this.mReferenceImageWidth = i;
    }

    public BoundingBox getBoundingBox() {
        if (this.mCornerPoints.isEmpty()) {
            return new BoundingBox(0, 0, 0, 0);
        }
        int i = Integer.MIN_VALUE;
        int i2 = Integer.MIN_VALUE;
        int i3 = Integer.MAX_VALUE;
        int i4 = Integer.MAX_VALUE;
        for (int i5 = 0; i5 < this.mCornerPoints.size(); i5 += 2) {
            int intValue = this.mCornerPoints.get(i5).intValue();
            int intValue2 = this.mCornerPoints.get(i5 + 1).intValue();
            i3 = Math.min(i3, intValue);
            i4 = Math.min(i4, intValue2);
            i = Math.max(i, intValue);
            i2 = Math.max(i2, intValue2);
        }
        return new BoundingBox(i3, i4, i - i3, i2 - i4);
    }
}
