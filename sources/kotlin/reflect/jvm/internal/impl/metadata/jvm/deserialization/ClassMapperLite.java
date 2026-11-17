package kotlin.reflect.jvm.internal.impl.metadata.jvm.deserialization;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import kotlin.collections.CollectionsKt;
import kotlin.internal.progressionUtil;
import kotlin.jvm.JvmStatic;
import kotlin.jvm.internal.Intrinsics;
import kotlin.text.StringsKt;
import kotlin.text.Typography;
import org.apache.commons.p018io.FilenameUtils;
import org.apache.commons.p018io.IOUtils;

/* compiled from: ClassMapperLite.kt */
/* loaded from: classes2.dex */
public final class ClassMapperLite {
    public static final ClassMapperLite INSTANCE = new ClassMapperLite();

    /* renamed from: kotlin */
    private static final String f359kotlin = CollectionsKt.joinToString$default(CollectionsKt.listOf((Object[]) new Character[]{'k', 'o', 't', 'l', 'i', 'n'}), "", null, null, 0, null, null, 62, null);
    private static final Map<String, String> map;

    private ClassMapperLite() {
    }

    static {
        LinkedHashMap linkedHashMap = new LinkedHashMap();
        List listOf = CollectionsKt.listOf((Object[]) new String[]{"Boolean", "Z", "Char", "C", "Byte", "B", "Short", "S", "Int", "I", "Float", "F", "Long", "J", "Double", "D"});
        int progressionLastElement = progressionUtil.getProgressionLastElement(0, listOf.size() - 1, 2);
        if (progressionLastElement >= 0) {
            int i = 0;
            while (true) {
                int i2 = i + 2;
                StringBuilder sb = new StringBuilder();
                String str = f359kotlin;
                sb.append(str);
                sb.append(IOUtils.DIR_SEPARATOR_UNIX);
                sb.append((String) listOf.get(i));
                int i3 = i + 1;
                linkedHashMap.put(sb.toString(), listOf.get(i3));
                linkedHashMap.put(str + IOUtils.DIR_SEPARATOR_UNIX + ((String) listOf.get(i)) + "Array", Intrinsics.stringPlus("[", listOf.get(i3)));
                if (i == progressionLastElement) {
                    break;
                }
                i = i2;
            }
        }
        linkedHashMap.put(Intrinsics.stringPlus(f359kotlin, "/Unit"), "V");
        m1753map$lambda0$add(linkedHashMap, "Any", "java/lang/Object");
        m1753map$lambda0$add(linkedHashMap, "Nothing", "java/lang/Void");
        m1753map$lambda0$add(linkedHashMap, "Annotation", "java/lang/annotation/Annotation");
        for (String str2 : CollectionsKt.listOf((Object[]) new String[]{"String", "CharSequence", "Throwable", "Cloneable", "Number", "Comparable", "Enum"})) {
            m1753map$lambda0$add(linkedHashMap, str2, Intrinsics.stringPlus("java/lang/", str2));
        }
        for (String str3 : CollectionsKt.listOf((Object[]) new String[]{"Iterator", "Collection", "List", "Set", "Map", "ListIterator"})) {
            m1753map$lambda0$add(linkedHashMap, Intrinsics.stringPlus("collections/", str3), Intrinsics.stringPlus("java/util/", str3));
            m1753map$lambda0$add(linkedHashMap, Intrinsics.stringPlus("collections/Mutable", str3), Intrinsics.stringPlus("java/util/", str3));
        }
        m1753map$lambda0$add(linkedHashMap, "collections/Iterable", "java/lang/Iterable");
        m1753map$lambda0$add(linkedHashMap, "collections/MutableIterable", "java/lang/Iterable");
        m1753map$lambda0$add(linkedHashMap, "collections/Map.Entry", "java/util/Map$Entry");
        m1753map$lambda0$add(linkedHashMap, "collections/MutableMap.MutableEntry", "java/util/Map$Entry");
        for (int i4 = 0; i4 < 23; i4++) {
            String stringPlus = Intrinsics.stringPlus("Function", Integer.valueOf(i4));
            StringBuilder sb2 = new StringBuilder();
            String str4 = f359kotlin;
            sb2.append(str4);
            sb2.append("/jvm/functions/Function");
            sb2.append(i4);
            m1753map$lambda0$add(linkedHashMap, stringPlus, sb2.toString());
            m1753map$lambda0$add(linkedHashMap, Intrinsics.stringPlus("reflect/KFunction", Integer.valueOf(i4)), Intrinsics.stringPlus(str4, "/reflect/KFunction"));
        }
        for (String str5 : CollectionsKt.listOf((Object[]) new String[]{"Char", "Byte", "Short", "Int", "Float", "Long", "Double", "String", "Enum"})) {
            m1753map$lambda0$add(linkedHashMap, Intrinsics.stringPlus(str5, ".Companion"), f359kotlin + "/jvm/internal/" + str5 + "CompanionObject");
        }
        map = linkedHashMap;
    }

    /* renamed from: map$lambda-0$add */
    private static final void m1753map$lambda0$add(Map<String, String> map2, String str, String str2) {
        map2.put(f359kotlin + IOUtils.DIR_SEPARATOR_UNIX + str, 'L' + str2 + ';');
    }

    @JvmStatic
    public static final String mapClass(String classId) {
        Intrinsics.checkNotNullParameter(classId, "classId");
        String str = map.get(classId);
        if (str == null) {
            return 'L' + StringsKt.replace$default(classId, (char) FilenameUtils.EXTENSION_SEPARATOR, (char) Typography.dollar, false, 4, (Object) null) + ';';
        }
        return str;
    }
}
