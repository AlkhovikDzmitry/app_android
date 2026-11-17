package kotlin.reflect.jvm.internal.impl.descriptors.runtime.components;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import kotlin.jvm.internal.Intrinsics;
import kotlin.reflect.jvm.internal.impl.descriptors.runtime.structure.reflectClassUtil;

/* JADX INFO: Access modifiers changed from: package-private */
/* compiled from: ReflectKotlinClass.kt */
/* loaded from: classes2.dex */
public final class SignatureSerializer {
    public static final SignatureSerializer INSTANCE = new SignatureSerializer();

    private SignatureSerializer() {
    }

    public final String methodDesc(Method method) {
        Intrinsics.checkNotNullParameter(method, "method");
        StringBuilder sb = new StringBuilder();
        sb.append("(");
        Class<?>[] parameterTypes = method.getParameterTypes();
        Intrinsics.checkNotNullExpressionValue(parameterTypes, "method.parameterTypes");
        int length = parameterTypes.length;
        int i = 0;
        while (i < length) {
            Class<?> parameterType = parameterTypes[i];
            i++;
            Intrinsics.checkNotNullExpressionValue(parameterType, "parameterType");
            sb.append(reflectClassUtil.getDesc(parameterType));
        }
        sb.append(")");
        Class<?> returnType = method.getReturnType();
        Intrinsics.checkNotNullExpressionValue(returnType, "method.returnType");
        sb.append(reflectClassUtil.getDesc(returnType));
        String sb2 = sb.toString();
        Intrinsics.checkNotNullExpressionValue(sb2, "sb.toString()");
        return sb2;
    }

    public final String constructorDesc(Constructor<?> constructor) {
        Intrinsics.checkNotNullParameter(constructor, "constructor");
        StringBuilder sb = new StringBuilder();
        sb.append("(");
        Class<?>[] parameterTypes = constructor.getParameterTypes();
        Intrinsics.checkNotNullExpressionValue(parameterTypes, "constructor.parameterTypes");
        int length = parameterTypes.length;
        int i = 0;
        while (i < length) {
            Class<?> parameterType = parameterTypes[i];
            i++;
            Intrinsics.checkNotNullExpressionValue(parameterType, "parameterType");
            sb.append(reflectClassUtil.getDesc(parameterType));
        }
        sb.append(")V");
        String sb2 = sb.toString();
        Intrinsics.checkNotNullExpressionValue(sb2, "sb.toString()");
        return sb2;
    }

    public final String fieldDesc(Field field) {
        Intrinsics.checkNotNullParameter(field, "field");
        Class<?> type = field.getType();
        Intrinsics.checkNotNullExpressionValue(type, "field.type");
        return reflectClassUtil.getDesc(type);
    }
}
