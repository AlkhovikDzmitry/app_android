package expo.modules.kotlin.views;

import android.view.View;
import androidx.autofill.HintConstants;
import com.facebook.react.bridge.Dynamic;
import kotlin.Metadata;
import kotlin.jvm.internal.Intrinsics;

/* compiled from: AnyViewProp.kt */
@Metadata(m41d1 = {"\u0000$\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u000e\n\u0002\b\u0004\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\b&\u0018\u00002\u00020\u0001B\r\u0012\u0006\u0010\u0002\u001a\u00020\u0003¢\u0006\u0002\u0010\u0004J\u0018\u0010\u0007\u001a\u00020\b2\u0006\u0010\t\u001a\u00020\n2\u0006\u0010\u000b\u001a\u00020\fH&R\u0011\u0010\u0002\u001a\u00020\u0003¢\u0006\b\n\u0000\u001a\u0004\b\u0005\u0010\u0006¨\u0006\r"}, m40d2 = {"Lexpo/modules/kotlin/views/AnyViewProp;", "", HintConstants.AUTOFILL_HINT_NAME, "", "(Ljava/lang/String;)V", "getName", "()Ljava/lang/String;", "set", "", "prop", "Lcom/facebook/react/bridge/Dynamic;", "onView", "Landroid/view/View;", "expo-modules-core_release"}, m39k = 1, m38mv = {1, 6, 0}, m36xi = 48)
/* loaded from: classes2.dex */
public abstract class AnyViewProp {
    private final String name;

    public abstract void set(Dynamic dynamic, View view);

    public AnyViewProp(String name) {
        Intrinsics.checkNotNullParameter(name, "name");
        this.name = name;
    }

    public final String getName() {
        return this.name;
    }
}
