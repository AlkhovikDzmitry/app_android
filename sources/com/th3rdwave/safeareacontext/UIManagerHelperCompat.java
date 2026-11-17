package com.th3rdwave.safeareacontext;

import android.content.Context;
import android.content.ContextWrapper;
import android.view.View;
import com.facebook.react.bridge.ReactContext;
import java.util.Objects;
import kotlin.Metadata;
import kotlin.jvm.internal.Intrinsics;

@Metadata(m41d1 = {"\u0000\u001a\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\b\n\u0000\n\u0002\u0018\u0002\n\u0000\u001a\u000e\u0010\u0000\u001a\u00020\u00012\u0006\u0010\u0002\u001a\u00020\u0003\u001a\u000e\u0010\u0004\u001a\u00020\u00052\u0006\u0010\u0006\u001a\u00020\u0007¨\u0006\b"}, m40d2 = {"getReactContext", "Lcom/facebook/react/bridge/ReactContext;", "view", "Landroid/view/View;", "getSurfaceId", "", "context", "Landroid/content/Context;", "react-native-safe-area-context_release"}, m39k = 2, m38mv = {1, 6, 0}, m36xi = 48)
/* renamed from: com.th3rdwave.safeareacontext.UIManagerHelperCompatKt */
/* loaded from: classes2.dex */
public final class UIManagerHelperCompat {
    public static final int getSurfaceId(Context context) {
        Intrinsics.checkNotNullParameter(context, "context");
        return -1;
    }

    public static final ReactContext getReactContext(View view) {
        Intrinsics.checkNotNullParameter(view, "view");
        Context context = view.getContext();
        if (!(context instanceof ReactContext) && (context instanceof ContextWrapper)) {
            context = ((ContextWrapper) context).getBaseContext();
        }
        Objects.requireNonNull(context, "null cannot be cast to non-null type com.facebook.react.bridge.ReactContext");
        return (ReactContext) context;
    }
}
