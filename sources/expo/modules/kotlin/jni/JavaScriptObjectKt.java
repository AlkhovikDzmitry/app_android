package expo.modules.kotlin.jni;

import expo.modules.kotlin.jni.JavaScriptObject;
import java.util.List;
import kotlin.Metadata;

/* compiled from: JavaScriptObject.kt */
@Metadata(m41d1 = {"\u0000\u0010\n\u0000\n\u0002\u0010\b\n\u0002\u0010 \n\u0002\u0018\u0002\n\u0000\u001a\u0012\u0010\u0000\u001a\u00020\u0001*\b\u0012\u0004\u0012\u00020\u00030\u0002H\u0002¨\u0006\u0004"}, m40d2 = {"toCppOptions", "", "", "Lexpo/modules/kotlin/jni/JavaScriptObject$PropertyDescriptor;", "expo-modules-core_release"}, m39k = 2, m38mv = {1, 6, 0}, m36xi = 48)
/* loaded from: classes2.dex */
public final class JavaScriptObjectKt {
    public static final int toCppOptions(List<? extends JavaScriptObject.PropertyDescriptor> list) {
        int i = 0;
        for (JavaScriptObject.PropertyDescriptor propertyDescriptor : list) {
            i |= propertyDescriptor.getValue();
        }
        return i;
    }
}
