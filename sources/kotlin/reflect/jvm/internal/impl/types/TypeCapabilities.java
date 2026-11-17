package kotlin.reflect.jvm.internal.impl.types;

/* renamed from: kotlin.reflect.jvm.internal.impl.types.CustomTypeVariable */
/* loaded from: classes3.dex */
public interface TypeCapabilities {
    boolean isTypeVariable();

    KotlinType substitutionResult(KotlinType kotlinType);
}
