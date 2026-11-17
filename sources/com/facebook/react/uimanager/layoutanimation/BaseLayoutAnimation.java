package com.facebook.react.uimanager.layoutanimation;

import android.view.View;
import android.view.animation.Animation;
import android.view.animation.ScaleAnimation;
import com.facebook.react.uimanager.IllegalViewOperationException;

/* loaded from: classes.dex */
abstract class BaseLayoutAnimation extends AbstractLayoutAnimation {
    abstract boolean isReverse();

    @Override // com.facebook.react.uimanager.layoutanimation.AbstractLayoutAnimation
    boolean isValid() {
        return this.mDurationMs > 0 && this.mAnimatedProperty != null;
    }

    /* renamed from: com.facebook.react.uimanager.layoutanimation.BaseLayoutAnimation$1 */
    /* loaded from: classes.dex */
    static /* synthetic */ class C13221 {

        /* renamed from: $SwitchMap$com$facebook$react$uimanager$layoutanimation$AnimatedPropertyType */
        static final /* synthetic */ int[] f113x36728427;

        static {
            int[] iArr = new int[AnimatedPropertyType.values().length];
            f113x36728427 = iArr;
            try {
                iArr[AnimatedPropertyType.OPACITY.ordinal()] = 1;
            } catch (NoSuchFieldError unused) {
            }
            try {
                f113x36728427[AnimatedPropertyType.SCALE_XY.ordinal()] = 2;
            } catch (NoSuchFieldError unused2) {
            }
            try {
                f113x36728427[AnimatedPropertyType.SCALE_X.ordinal()] = 3;
            } catch (NoSuchFieldError unused3) {
            }
            try {
                f113x36728427[AnimatedPropertyType.SCALE_Y.ordinal()] = 4;
            } catch (NoSuchFieldError unused4) {
            }
        }
    }

    @Override // com.facebook.react.uimanager.layoutanimation.AbstractLayoutAnimation
    Animation createAnimationImpl(View view, int i, int i2, int i3, int i4) {
        if (this.mAnimatedProperty != null) {
            int i5 = C13221.f113x36728427[this.mAnimatedProperty.ordinal()];
            if (i5 == 1) {
                return new OpacityAnimation(view, isReverse() ? view.getAlpha() : 0.0f, isReverse() ? 0.0f : view.getAlpha());
            } else if (i5 == 2) {
                float f = isReverse() ? 1.0f : 0.0f;
                float f2 = isReverse() ? 0.0f : 1.0f;
                return new ScaleAnimation(f, f2, f, f2, 1, 0.5f, 1, 0.5f);
            } else if (i5 == 3) {
                return new ScaleAnimation(isReverse() ? 1.0f : 0.0f, isReverse() ? 0.0f : 1.0f, 1.0f, 1.0f, 1, 0.5f, 1, 0.0f);
            } else if (i5 == 4) {
                return new ScaleAnimation(1.0f, 1.0f, isReverse() ? 1.0f : 0.0f, isReverse() ? 0.0f : 1.0f, 1, 0.0f, 1, 0.5f);
            } else {
                throw new IllegalViewOperationException("Missing animation for property : " + this.mAnimatedProperty);
            }
        }
        throw new IllegalViewOperationException("Missing animated property from animation config");
    }
}
