package kotlin.ranges;

import com.facebook.react.uimanager.ViewProps;
import com.reactcommunity.rndatetimepicker.RNConstants;
import kotlin.Metadata;
import kotlin.ULong;
import kotlin.UnsignedUtils;
import kotlin.jvm.internal.DefaultConstructorMarker;

/* compiled from: ULongRange.kt */
@Metadata(m41d1 = {"\u00002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\b\u0007\n\u0002\u0010\u000b\n\u0002\b\u0005\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\b\n\u0002\b\u0002\n\u0002\u0010\u000e\n\u0002\b\u0002\b\u0007\u0018\u0000 \u00172\u00020\u00012\b\u0012\u0004\u0012\u00020\u00030\u0002:\u0001\u0017B\u0018\u0012\u0006\u0010\u0004\u001a\u00020\u0003\u0012\u0006\u0010\u0005\u001a\u00020\u0003ø\u0001\u0000¢\u0006\u0002\u0010\u0006J\u001b\u0010\n\u001a\u00020\u000b2\u0006\u0010\f\u001a\u00020\u0003H\u0096\u0002ø\u0001\u0000¢\u0006\u0004\b\r\u0010\u000eJ\u0013\u0010\u000f\u001a\u00020\u000b2\b\u0010\u0010\u001a\u0004\u0018\u00010\u0011H\u0096\u0002J\b\u0010\u0012\u001a\u00020\u0013H\u0016J\b\u0010\u0014\u001a\u00020\u000bH\u0016J\b\u0010\u0015\u001a\u00020\u0016H\u0016R\u001a\u0010\u0005\u001a\u00020\u00038VX\u0096\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\u0006\u001a\u0004\b\u0007\u0010\bR\u001a\u0010\u0004\u001a\u00020\u00038VX\u0096\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\u0006\u001a\u0004\b\t\u0010\bø\u0001\u0000\u0082\u0002\b\n\u0002\b\u0019\n\u0002\b!¨\u0006\u0018"}, m40d2 = {"Lkotlin/ranges/ULongRange;", "Lkotlin/ranges/ULongProgression;", "Lkotlin/ranges/ClosedRange;", "Lkotlin/ULong;", ViewProps.START, "endInclusive", "(JJLkotlin/jvm/internal/DefaultConstructorMarker;)V", "getEndInclusive-s-VKNKU", "()J", "getStart-s-VKNKU", "contains", "", RNConstants.ARG_VALUE, "contains-VKZWuLQ", "(J)Z", "equals", "other", "", "hashCode", "", "isEmpty", "toString", "", "Companion", "kotlin-stdlib"}, m39k = 1, m38mv = {1, 7, 1}, m36xi = 48)
/* loaded from: classes2.dex */
public final class ULongRange extends ULongProgression implements ClosedRange<ULong> {
    public static final Companion Companion = new Companion(null);
    private static final ULongRange EMPTY = new ULongRange(-1, 0, null);

    public /* synthetic */ ULongRange(long j, long j2, DefaultConstructorMarker defaultConstructorMarker) {
        this(j, j2);
    }

    @Override // kotlin.ranges.ClosedRange
    public /* bridge */ /* synthetic */ boolean contains(ULong uLong) {
        return m1707containsVKZWuLQ(uLong.m690unboximpl());
    }

    @Override // kotlin.ranges.ClosedRange
    public /* bridge */ /* synthetic */ ULong getEndInclusive() {
        return ULong.m633boximpl(m1708getEndInclusivesVKNKU());
    }

    @Override // kotlin.ranges.ClosedRange
    public /* bridge */ /* synthetic */ ULong getStart() {
        return ULong.m633boximpl(m1709getStartsVKNKU());
    }

    private ULongRange(long j, long j2) {
        super(j, j2, 1L, null);
    }

    /* renamed from: getStart-s-VKNKU */
    public long m1709getStartsVKNKU() {
        return m1703getFirstsVKNKU();
    }

    /* renamed from: getEndInclusive-s-VKNKU */
    public long m1708getEndInclusivesVKNKU() {
        return m1704getLastsVKNKU();
    }

    /* renamed from: contains-VKZWuLQ */
    public boolean m1707containsVKZWuLQ(long j) {
        return UnsignedUtils.ulongCompare(m1703getFirstsVKNKU(), j) <= 0 && UnsignedUtils.ulongCompare(j, m1704getLastsVKNKU()) <= 0;
    }

    @Override // kotlin.ranges.ULongProgression, kotlin.ranges.ClosedRange
    public boolean isEmpty() {
        return UnsignedUtils.ulongCompare(m1703getFirstsVKNKU(), m1704getLastsVKNKU()) > 0;
    }

    @Override // kotlin.ranges.ULongProgression
    public boolean equals(Object obj) {
        if (obj instanceof ULongRange) {
            if (!isEmpty() || !((ULongRange) obj).isEmpty()) {
                ULongRange uLongRange = (ULongRange) obj;
                if (m1703getFirstsVKNKU() != uLongRange.m1703getFirstsVKNKU() || m1704getLastsVKNKU() != uLongRange.m1704getLastsVKNKU()) {
                }
            }
            return true;
        }
        return false;
    }

    @Override // kotlin.ranges.ULongProgression
    public int hashCode() {
        if (isEmpty()) {
            return -1;
        }
        return ((int) ULong.m639constructorimpl(m1704getLastsVKNKU() ^ ULong.m639constructorimpl(m1704getLastsVKNKU() >>> 32))) + (((int) ULong.m639constructorimpl(m1703getFirstsVKNKU() ^ ULong.m639constructorimpl(m1703getFirstsVKNKU() >>> 32))) * 31);
    }

    @Override // kotlin.ranges.ULongProgression
    public String toString() {
        return ((Object) ULong.m684toStringimpl(m1703getFirstsVKNKU())) + ".." + ((Object) ULong.m684toStringimpl(m1704getLastsVKNKU()));
    }

    /* compiled from: ULongRange.kt */
    @Metadata(m41d1 = {"\u0000\u0014\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0002\b\u0003\b\u0086\u0003\u0018\u00002\u00020\u0001B\u0007\b\u0002¢\u0006\u0002\u0010\u0002R\u0011\u0010\u0003\u001a\u00020\u0004¢\u0006\b\n\u0000\u001a\u0004\b\u0005\u0010\u0006¨\u0006\u0007"}, m40d2 = {"Lkotlin/ranges/ULongRange$Companion;", "", "()V", "EMPTY", "Lkotlin/ranges/ULongRange;", "getEMPTY", "()Lkotlin/ranges/ULongRange;", "kotlin-stdlib"}, m39k = 1, m38mv = {1, 7, 1}, m36xi = 48)
    /* loaded from: classes2.dex */
    public static final class Companion {
        public /* synthetic */ Companion(DefaultConstructorMarker defaultConstructorMarker) {
            this();
        }

        private Companion() {
        }

        public final ULongRange getEMPTY() {
            return ULongRange.EMPTY;
        }
    }
}
