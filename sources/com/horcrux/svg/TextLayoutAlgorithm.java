package com.horcrux.svg;

import android.view.View;
import com.horcrux.svg.TextProperties;
import java.util.ArrayList;

/* JADX INFO: Access modifiers changed from: package-private */
/* loaded from: classes2.dex */
public class TextLayoutAlgorithm {
    TextLayoutAlgorithm() {
    }

    /* loaded from: classes2.dex */
    public class CharacterInformation {
        double advance;
        char character;
        TextView element;
        int index;

        /* renamed from: x */
        double f190x = 0.0d;

        /* renamed from: y */
        double f191y = 0.0d;
        double rotate = 0.0d;
        boolean hidden = false;
        boolean middle = false;
        boolean resolved = false;
        boolean xSpecified = false;
        boolean ySpecified = false;
        boolean addressable = true;
        boolean anchoredChunk = false;
        boolean rotateSpecified = false;
        boolean firstCharacterInResolvedDescendant = false;

        CharacterInformation(int i, char c) {
            TextLayoutAlgorithm.this = r3;
            this.index = i;
            this.character = c;
        }
    }

    /* loaded from: classes2.dex */
    class LayoutInput {
        boolean horizontal;
        TextView text;

        LayoutInput() {
            TextLayoutAlgorithm.this = r1;
        }
    }

    private void getSubTreeTypographicCharacterPositions(ArrayList<TextPathView> arrayList, ArrayList<TextView> arrayList2, StringBuilder sb, View view, TextPathView textPathView) {
        int i = 0;
        if (view instanceof TSpanView) {
            TSpanView tSpanView = (TSpanView) view;
            String str = tSpanView.mContent;
            if (str == null) {
                while (i < tSpanView.getChildCount()) {
                    getSubTreeTypographicCharacterPositions(arrayList, arrayList2, sb, tSpanView.getChildAt(i), textPathView);
                    i++;
                }
                return;
            }
            while (i < str.length()) {
                arrayList2.add(tSpanView);
                arrayList.add(textPathView);
                i++;
            }
            sb.append(str);
            return;
        }
        if (view instanceof TextPathView) {
            textPathView = (TextPathView) view;
        }
        while (i < textPathView.getChildCount()) {
            getSubTreeTypographicCharacterPositions(arrayList, arrayList2, sb, textPathView.getChildAt(i), textPathView);
            i++;
        }
    }

    /* JADX WARN: Code restructure failed: missing block: B:262:0x019a, code lost:
        if (r18 == Double.POSITIVE_INFINITY) goto L105;
     */
    /* JADX WARN: Code restructure failed: missing block: B:266:0x01a1, code lost:
        if (r4 == (r10 - 1)) goto L78;
     */
    /* JADX WARN: Code restructure failed: missing block: B:267:0x01a3, code lost:
        r12 = com.horcrux.svg.TextProperties.TextAnchor.start;
        r13 = com.horcrux.svg.TextProperties.Direction.ltr;
        r14 = r10 - 1;
     */
    /* JADX WARN: Code restructure failed: missing block: B:268:0x01a9, code lost:
        if (r4 != r14) goto L81;
     */
    /* JADX WARN: Code restructure failed: missing block: B:269:0x01ab, code lost:
        r16 = r0;
        r18 = r5;
     */
    /* JADX WARN: Code restructure failed: missing block: B:270:0x01af, code lost:
        r2 = r11[r8].f190x;
        r12 = com.horcrux.svg.TextLayoutAlgorithm.C16641.$SwitchMap$com$horcrux$svg$TextProperties$TextAnchor[r12.ordinal()];
     */
    /* JADX WARN: Code restructure failed: missing block: B:271:0x01bc, code lost:
        if (r12 == 1) goto L103;
     */
    /* JADX WARN: Code restructure failed: missing block: B:273:0x01bf, code lost:
        if (r12 == 2) goto L102;
     */
    /* JADX WARN: Code restructure failed: missing block: B:275:0x01c2, code lost:
        if (r12 == 3) goto L87;
     */
    /* JADX WARN: Code restructure failed: missing block: B:278:0x01c7, code lost:
        if (r13 != com.horcrux.svg.TextProperties.Direction.ltr) goto L89;
     */
    /* JADX WARN: Code restructure failed: missing block: B:280:0x01ca, code lost:
        r12 = com.horcrux.svg.TextProperties.Direction.ltr;
        r2 = r2 - ((r18 + r16) / 2.0d);
     */
    /* JADX WARN: Code restructure failed: missing block: B:282:0x01d4, code lost:
        if (r13 != com.horcrux.svg.TextProperties.Direction.ltr) goto L90;
     */
    /* JADX WARN: Code restructure failed: missing block: B:283:0x01d6, code lost:
        r2 = r2 - r18;
     */
    /* JADX WARN: Code restructure failed: missing block: B:284:0x01d9, code lost:
        r2 = r2 - r16;
     */
    /* JADX WARN: Code restructure failed: missing block: B:285:0x01db, code lost:
        if (r4 != r14) goto L101;
     */
    /* JADX WARN: Code restructure failed: missing block: B:286:0x01dd, code lost:
        r12 = r4;
     */
    /* JADX WARN: Code restructure failed: missing block: B:287:0x01df, code lost:
        r12 = r4 - 1;
     */
    /* JADX WARN: Code restructure failed: missing block: B:288:0x01e1, code lost:
        if (r8 > r12) goto L96;
     */
    /* JADX WARN: Code restructure failed: missing block: B:289:0x01e3, code lost:
        r11[r8].f190x += r2;
        r8 = r8 + 1;
     */
    /* JADX WARN: Code restructure failed: missing block: B:290:0x01ed, code lost:
        r8 = r4;
     */
    /* JADX WARN: Code restructure failed: missing block: B:291:0x01ee, code lost:
        r20 = r16;
        r16 = r0;
     */
    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:349:0x02e7  */
    /* JADX WARN: Removed duplicated region for block: B:350:0x0318  */
    /* JADX WARN: Type inference failed for: r1v6, types: [com.horcrux.svg.TextLayoutAlgorithm$1TextLengthResolver] */
    /* JADX WARN: Type inference failed for: r3v3 */
    /* JADX WARN: Type inference failed for: r3v4, types: [android.graphics.Canvas, android.graphics.Paint] */
    /* JADX WARN: Type inference failed for: r3v5 */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    com.horcrux.svg.TextLayoutAlgorithm.CharacterInformation[] layoutText(com.horcrux.svg.TextLayoutAlgorithm.LayoutInput r27) {
        /*
            Method dump skipped, instructions count: 931
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: com.horcrux.svg.TextLayoutAlgorithm.layoutText(com.horcrux.svg.TextLayoutAlgorithm$LayoutInput):com.horcrux.svg.TextLayoutAlgorithm$CharacterInformation[]");
    }

    /* renamed from: com.horcrux.svg.TextLayoutAlgorithm$1 */
    /* loaded from: classes2.dex */
    static /* synthetic */ class C16641 {
        static final /* synthetic */ int[] $SwitchMap$com$horcrux$svg$TextProperties$TextAnchor;

        static {
            int[] iArr = new int[TextProperties.TextAnchor.values().length];
            $SwitchMap$com$horcrux$svg$TextProperties$TextAnchor = iArr;
            try {
                iArr[TextProperties.TextAnchor.start.ordinal()] = 1;
            } catch (NoSuchFieldError unused) {
            }
            try {
                $SwitchMap$com$horcrux$svg$TextProperties$TextAnchor[TextProperties.TextAnchor.middle.ordinal()] = 2;
            } catch (NoSuchFieldError unused2) {
            }
            try {
                $SwitchMap$com$horcrux$svg$TextProperties$TextAnchor[TextProperties.TextAnchor.end.ordinal()] = 3;
            } catch (NoSuchFieldError unused3) {
            }
        }
    }
}
