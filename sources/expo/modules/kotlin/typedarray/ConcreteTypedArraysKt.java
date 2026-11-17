package expo.modules.kotlin.typedarray;

import kotlin.Metadata;

/* compiled from: ConcreteTypedArrays.kt */
@Metadata(m41d1 = {"\u0000\u0012\n\u0000\n\u0002\u0010\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\b\n\u0000\u001a\u0015\u0010\u0000\u001a\u00020\u0001*\u00020\u00022\u0006\u0010\u0003\u001a\u00020\u0004H\u0082\b¨\u0006\u0005"}, m40d2 = {"checkIfInRange", "", "Lexpo/modules/kotlin/typedarray/TypedArray;", "index", "", "expo-modules-core_release"}, m39k = 2, m38mv = {1, 6, 0}, m36xi = 48)
/* loaded from: classes2.dex */
public final class ConcreteTypedArraysKt {
    private static final void checkIfInRange(TypedArray typedArray, int i) {
        if (i < 0 || i >= typedArray.getLength()) {
            throw new IndexOutOfBoundsException();
        }
    }
}
