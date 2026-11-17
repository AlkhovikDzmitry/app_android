package kotlin.reflect.jvm.internal.impl.load.java.typeEnhancement;

import kotlin.reflect.jvm.internal.impl.types.FlexibleType;
import kotlin.reflect.jvm.internal.impl.types.KotlinType;
import kotlin.reflect.jvm.internal.impl.types.UnwrappedType;

/* compiled from: signatureEnhancement.kt */
/* loaded from: classes2.dex */
public final class SignatureEnhancementKt {
    public static final boolean isNullabilityFlexible(KotlinType kotlinType) {
        UnwrappedType unwrap = kotlinType.unwrap();
        FlexibleType flexibleType = unwrap instanceof FlexibleType ? (FlexibleType) unwrap : null;
        return (flexibleType == null || flexibleType.getLowerBound().isMarkedNullable() == flexibleType.getUpperBound().isMarkedNullable()) ? false : true;
    }
}
