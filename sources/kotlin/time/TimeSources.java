package kotlin.time;

import kotlin.Metadata;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;
import kotlin.time.TimeMark;

@Metadata(m41d1 = {"\u0000 \n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0004\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0006\n\u0002\b\u0002\b'\u0018\u00002\u00020\u0001:\u0001\u000bB\r\u0012\u0006\u0010\u0002\u001a\u00020\u0003¢\u0006\u0002\u0010\u0004J\b\u0010\u0007\u001a\u00020\bH\u0016J\b\u0010\t\u001a\u00020\nH$R\u0014\u0010\u0002\u001a\u00020\u0003X\u0084\u0004¢\u0006\b\n\u0000\u001a\u0004\b\u0005\u0010\u0006¨\u0006\f"}, m40d2 = {"Lkotlin/time/AbstractDoubleTimeSource;", "Lkotlin/time/TimeSource;", "unit", "Lkotlin/time/DurationUnit;", "(Lkotlin/time/DurationUnit;)V", "getUnit", "()Lkotlin/time/DurationUnit;", "markNow", "Lkotlin/time/TimeMark;", "read", "", "DoubleTimeMark", "kotlin-stdlib"}, m39k = 1, m38mv = {1, 7, 1}, m36xi = 48)
/* renamed from: kotlin.time.AbstractDoubleTimeSource */
/* loaded from: classes3.dex */
public abstract class TimeSources implements TimeSource {
    private final DurationUnitJvm unit;

    protected abstract double read();

    public TimeSources(DurationUnitJvm unit) {
        Intrinsics.checkNotNullParameter(unit, "unit");
        this.unit = unit;
    }

    protected final DurationUnitJvm getUnit() {
        return this.unit;
    }

    /* compiled from: TimeSources.kt */
    @Metadata(m41d1 = {"\u0000\u001e\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0006\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\n\b\u0002\u0018\u00002\u00020\u0001B \u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\u0006\u0010\u0004\u001a\u00020\u0005\u0012\u0006\u0010\u0006\u001a\u00020\u0007ø\u0001\u0000¢\u0006\u0002\u0010\bJ\u0015\u0010\n\u001a\u00020\u0007H\u0016ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b\u000b\u0010\fJ\u001b\u0010\r\u001a\u00020\u00012\u0006\u0010\u000e\u001a\u00020\u0007H\u0096\u0002ø\u0001\u0000¢\u0006\u0004\b\u000f\u0010\u0010R\u0016\u0010\u0006\u001a\u00020\u0007X\u0082\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\u0004\n\u0002\u0010\tR\u000e\u0010\u0002\u001a\u00020\u0003X\u0082\u0004¢\u0006\u0002\n\u0000R\u000e\u0010\u0004\u001a\u00020\u0005X\u0082\u0004¢\u0006\u0002\n\u0000\u0082\u0002\b\n\u0002\b\u0019\n\u0002\b!¨\u0006\u0011"}, m40d2 = {"Lkotlin/time/AbstractDoubleTimeSource$DoubleTimeMark;", "Lkotlin/time/TimeMark;", "startedAt", "", "timeSource", "Lkotlin/time/AbstractDoubleTimeSource;", "offset", "Lkotlin/time/Duration;", "(DLkotlin/time/AbstractDoubleTimeSource;JLkotlin/jvm/internal/DefaultConstructorMarker;)V", "J", "elapsedNow", "elapsedNow-UwyO8pc", "()J", "plus", "duration", "plus-LRDsOJo", "(J)Lkotlin/time/TimeMark;", "kotlin-stdlib"}, m39k = 1, m38mv = {1, 7, 1}, m36xi = 48)
    /* renamed from: kotlin.time.AbstractDoubleTimeSource$DoubleTimeMark */
    /* loaded from: classes3.dex */
    private static final class DoubleTimeMark implements TimeMark {
        private final long offset;
        private final double startedAt;
        private final TimeSources timeSource;

        public /* synthetic */ DoubleTimeMark(double d, TimeSources timeSources, long j, DefaultConstructorMarker defaultConstructorMarker) {
            this(d, timeSources, j);
        }

        private DoubleTimeMark(double d, TimeSources timeSources, long j) {
            this.startedAt = d;
            this.timeSource = timeSources;
            this.offset = j;
        }

        @Override // kotlin.time.TimeMark
        public boolean hasNotPassedNow() {
            return TimeMark.DefaultImpls.hasNotPassedNow(this);
        }

        @Override // kotlin.time.TimeMark
        public boolean hasPassedNow() {
            return TimeMark.DefaultImpls.hasPassedNow(this);
        }

        @Override // kotlin.time.TimeMark
        /* renamed from: minus-LRDsOJo */
        public TimeMark mo1797minusLRDsOJo(long j) {
            return TimeMark.DefaultImpls.m1939minusLRDsOJo(this, j);
        }

        @Override // kotlin.time.TimeMark
        /* renamed from: elapsedNow-UwyO8pc */
        public long mo1796elapsedNowUwyO8pc() {
            return Duration.m1839minusLRDsOJo(DurationKt.toDuration(this.timeSource.read() - this.startedAt, this.timeSource.getUnit()), this.offset);
        }

        @Override // kotlin.time.TimeMark
        /* renamed from: plus-LRDsOJo */
        public TimeMark mo1798plusLRDsOJo(long j) {
            return new DoubleTimeMark(this.startedAt, this.timeSource, Duration.m1840plusLRDsOJo(this.offset, j), null);
        }
    }

    @Override // kotlin.time.TimeSource
    public TimeMark markNow() {
        return new DoubleTimeMark(read(), this, Duration.Companion.m1906getZEROUwyO8pc(), null);
    }
}
