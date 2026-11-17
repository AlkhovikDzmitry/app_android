package com.facebook.fresco.animation.frame;

import com.facebook.fresco.animation.backend.AnimationInformation;

/* loaded from: classes.dex */
public class DropFramesFrameScheduler implements FrameScheduler {
    private static final int UNSET = -1;
    private final AnimationInformation mAnimationInformation;
    private long mLoopDurationMs = -1;

    public DropFramesFrameScheduler(AnimationInformation animationInformation) {
        this.mAnimationInformation = animationInformation;
    }

    @Override // com.facebook.fresco.animation.frame.FrameScheduler
    public int getFrameNumberToRender(long animationTimeMs, long lastFrameTimeMs) {
        long loopDurationMs = getLoopDurationMs();
        if (loopDurationMs == 0) {
            return getFrameNumberWithinLoop(0L);
        }
        if (isInfiniteAnimation() || animationTimeMs / loopDurationMs < this.mAnimationInformation.getLoopCount()) {
            return getFrameNumberWithinLoop(animationTimeMs % loopDurationMs);
        }
        return -1;
    }

    @Override // com.facebook.fresco.animation.frame.FrameScheduler
    public long getLoopDurationMs() {
        long j = this.mLoopDurationMs;
        if (j != -1) {
            return j;
        }
        this.mLoopDurationMs = 0L;
        int frameCount = this.mAnimationInformation.getFrameCount();
        for (int i = 0; i < frameCount; i++) {
            this.mLoopDurationMs += this.mAnimationInformation.getFrameDurationMs(i);
        }
        return this.mLoopDurationMs;
    }

    @Override // com.facebook.fresco.animation.frame.FrameScheduler
    public long getTargetRenderTimeMs(int frameNumber) {
        long j = 0;
        for (int i = 0; i < frameNumber; i++) {
            j += this.mAnimationInformation.getFrameDurationMs(frameNumber);
        }
        return j;
    }

    @Override // com.facebook.fresco.animation.frame.FrameScheduler
    public long getTargetRenderTimeForNextFrameMs(long animationTimeMs) {
        long loopDurationMs = getLoopDurationMs();
        long j = 0;
        if (loopDurationMs == 0) {
            return -1L;
        }
        if (isInfiniteAnimation() || animationTimeMs / getLoopDurationMs() < this.mAnimationInformation.getLoopCount()) {
            long j2 = animationTimeMs % loopDurationMs;
            int frameCount = this.mAnimationInformation.getFrameCount();
            for (int i = 0; i < frameCount && j <= j2; i++) {
                j += this.mAnimationInformation.getFrameDurationMs(i);
            }
            return animationTimeMs + (j - j2);
        }
        return -1L;
    }

    @Override // com.facebook.fresco.animation.frame.FrameScheduler
    public boolean isInfiniteAnimation() {
        return this.mAnimationInformation.getLoopCount() == 0;
    }

    int getFrameNumberWithinLoop(long timeInCurrentLoopMs) {
        int i = 0;
        long j = 0;
        do {
            j += this.mAnimationInformation.getFrameDurationMs(i);
            i++;
        } while (timeInCurrentLoopMs >= j);
        return i - 1;
    }
}
