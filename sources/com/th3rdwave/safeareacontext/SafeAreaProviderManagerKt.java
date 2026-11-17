package com.th3rdwave.safeareacontext;

import android.content.Context;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.uimanager.UIManagerHelper;
import com.facebook.react.uimanager.events.EventDispatcher;
import java.util.Objects;
import kotlin.Metadata;

/* compiled from: SafeAreaProviderManager.kt */
@Metadata(m41d1 = {"\u0000\u001a\n\u0000\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\u001a \u0010\u0000\u001a\u00020\u00012\u0006\u0010\u0002\u001a\u00020\u00032\u0006\u0010\u0004\u001a\u00020\u00052\u0006\u0010\u0006\u001a\u00020\u0007H\u0002¨\u0006\b"}, m40d2 = {"handleOnInsetsChange", "", "view", "Lcom/th3rdwave/safeareacontext/SafeAreaProvider;", "insets", "Lcom/th3rdwave/safeareacontext/EdgeInsets;", "frame", "Lcom/th3rdwave/safeareacontext/Rect;", "react-native-safe-area-context_release"}, m39k = 2, m38mv = {1, 6, 0}, m36xi = 48)
/* loaded from: classes2.dex */
public final class SafeAreaProviderManagerKt {
    public static final void handleOnInsetsChange(SafeAreaProvider safeAreaProvider, EdgeInsets edgeInsets, Rect rect) {
        Context context = safeAreaProvider.getContext();
        Objects.requireNonNull(context, "null cannot be cast to non-null type com.facebook.react.bridge.ReactContext");
        ReactContext reactContext = (ReactContext) context;
        int id = safeAreaProvider.getId();
        EventDispatcher eventDispatcherForReactTag = UIManagerHelper.getEventDispatcherForReactTag(reactContext, id);
        if (eventDispatcherForReactTag == null) {
            return;
        }
        eventDispatcherForReactTag.dispatchEvent(new InsetsChangeEvent(UIManagerHelperCompat.getSurfaceId(reactContext), id, edgeInsets, rect));
    }
}
