package com.swmansion.reanimated.keyboardObserver;

import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.widget.FrameLayout;
import androidx.core.view.OnApplyWindowInsetsListener;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsAnimationCompat;
import androidx.core.view.WindowInsetsCompat;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.PixelUtil;
import com.swmansion.reanimated.C1738R;
import com.swmansion.reanimated.NativeProxy;
import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.List;

/* loaded from: classes2.dex */
public class ReanimatedKeyboardEventListener {
    private final WeakReference<ReactApplicationContext> reactContext;
    private KeyboardState state;
    private int nextListenerId = 0;
    private final HashMap<Integer, NativeProxy.KeyboardEventDataUpdater> listeners = new HashMap<>();

    /* loaded from: classes2.dex */
    public enum KeyboardState {
        UNKNOWN(0),
        OPENING(1),
        OPEN(2),
        CLOSING(3),
        CLOSED(4);
        
        private final int value;

        KeyboardState(int i) {
            this.value = i;
        }

        public int asInt() {
            return this.value;
        }
    }

    public ReanimatedKeyboardEventListener(WeakReference<ReactApplicationContext> weakReference) {
        this.reactContext = weakReference;
    }

    private View getRootView() {
        return this.reactContext.get().getCurrentActivity().getWindow().getDecorView();
    }

    public void setupWindowInsets() {
        final View rootView = getRootView();
        WindowCompat.setDecorFitsSystemWindows(this.reactContext.get().getCurrentActivity().getWindow(), false);
        ViewCompat.setOnApplyWindowInsetsListener(rootView, new OnApplyWindowInsetsListener() { // from class: com.swmansion.reanimated.keyboardObserver.ReanimatedKeyboardEventListener$$ExternalSyntheticLambda0
            @Override // androidx.core.view.OnApplyWindowInsetsListener
            public final WindowInsetsCompat onApplyWindowInsets(View view, WindowInsetsCompat windowInsetsCompat) {
                return ReanimatedKeyboardEventListener.lambda$setupWindowInsets$0(rootView, view, windowInsetsCompat);
            }
        });
    }

    public static /* synthetic */ WindowInsetsCompat lambda$setupWindowInsets$0(View view, View view2, WindowInsetsCompat windowInsetsCompat) {
        int i = windowInsetsCompat.getInsets(WindowInsetsCompat.Type.systemBars()).top;
        View findViewById = view.getRootView().findViewById(C1738R.C1742id.action_bar_root);
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(-1, -1);
        layoutParams.setMargins(0, i, 0, 0);
        findViewById.setLayoutParams(layoutParams);
        return windowInsetsCompat;
    }

    public void updateKeyboard(int i) {
        for (NativeProxy.KeyboardEventDataUpdater keyboardEventDataUpdater : this.listeners.values()) {
            keyboardEventDataUpdater.keyboardEventDataUpdater(this.state.asInt(), i);
        }
    }

    /* loaded from: classes2.dex */
    public class WindowInsetsCallback extends WindowInsetsAnimationCompat.Callback {
        private int keyboardHeight;

        /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
        public WindowInsetsCallback() {
            super(1);
            ReanimatedKeyboardEventListener.this = r1;
            this.keyboardHeight = 0;
        }

        @Override // androidx.core.view.WindowInsetsAnimationCompat.Callback
        public WindowInsetsAnimationCompat.BoundsCompat onStart(WindowInsetsAnimationCompat windowInsetsAnimationCompat, WindowInsetsAnimationCompat.BoundsCompat boundsCompat) {
            ReanimatedKeyboardEventListener.this.state = this.keyboardHeight == 0 ? KeyboardState.OPENING : KeyboardState.CLOSING;
            ReanimatedKeyboardEventListener.this.updateKeyboard(this.keyboardHeight);
            return super.onStart(windowInsetsAnimationCompat, boundsCompat);
        }

        @Override // androidx.core.view.WindowInsetsAnimationCompat.Callback
        public WindowInsetsCompat onProgress(WindowInsetsCompat windowInsetsCompat, List<WindowInsetsAnimationCompat> list) {
            int dIPFromPixel = (int) PixelUtil.toDIPFromPixel(Math.max(0, windowInsetsCompat.getInsets(WindowInsetsCompat.Type.ime()).bottom - windowInsetsCompat.getInsets(WindowInsetsCompat.Type.systemBars()).bottom));
            this.keyboardHeight = dIPFromPixel;
            ReanimatedKeyboardEventListener.this.updateKeyboard(dIPFromPixel);
            return windowInsetsCompat;
        }

        @Override // androidx.core.view.WindowInsetsAnimationCompat.Callback
        public void onEnd(WindowInsetsAnimationCompat windowInsetsAnimationCompat) {
            ReanimatedKeyboardEventListener.this.state = this.keyboardHeight == 0 ? KeyboardState.CLOSED : KeyboardState.OPEN;
            ReanimatedKeyboardEventListener.this.updateKeyboard(this.keyboardHeight);
        }
    }

    private void setUpCallbacks() {
        View rootView = getRootView();
        new Handler(Looper.getMainLooper()).post(new Runnable() { // from class: com.swmansion.reanimated.keyboardObserver.ReanimatedKeyboardEventListener$$ExternalSyntheticLambda2
            @Override // java.lang.Runnable
            public final void run() {
                ReanimatedKeyboardEventListener.this.setupWindowInsets();
            }
        });
        ViewCompat.setWindowInsetsAnimationCallback(rootView, new WindowInsetsCallback());
    }

    public int subscribeForKeyboardEvents(NativeProxy.KeyboardEventDataUpdater keyboardEventDataUpdater) {
        int i = this.nextListenerId;
        this.nextListenerId = i + 1;
        if (this.listeners.isEmpty()) {
            setUpCallbacks();
        }
        this.listeners.put(Integer.valueOf(i), keyboardEventDataUpdater);
        return i;
    }

    public void bringBackWindowInsets() {
        WindowCompat.setDecorFitsSystemWindows(this.reactContext.get().getCurrentActivity().getWindow(), true);
        ViewCompat.setOnApplyWindowInsetsListener(getRootView(), null);
        ViewCompat.setWindowInsetsAnimationCallback(getRootView(), null);
        View findViewById = getRootView().getRootView().findViewById(C1738R.C1742id.action_bar_root);
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(-1, -1);
        layoutParams.setMargins(0, 0, 0, 0);
        findViewById.setLayoutParams(layoutParams);
    }

    private void removeCallbacks() {
        View rootView = getRootView();
        new Handler(Looper.getMainLooper()).post(new Runnable() { // from class: com.swmansion.reanimated.keyboardObserver.ReanimatedKeyboardEventListener$$ExternalSyntheticLambda1
            @Override // java.lang.Runnable
            public final void run() {
                ReanimatedKeyboardEventListener.this.bringBackWindowInsets();
            }
        });
        ViewCompat.setWindowInsetsAnimationCallback(rootView, null);
    }

    public void unsubscribeFromKeyboardEvents(int i) {
        this.listeners.remove(Integer.valueOf(i));
        if (this.listeners.isEmpty()) {
            removeCallbacks();
        }
    }
}
