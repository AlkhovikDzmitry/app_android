package com.google.android.datatransport.runtime.scheduling.persistence;

import com.google.android.datatransport.runtime.EventInternal;
import com.google.android.datatransport.runtime.TransportContext;
import java.util.Objects;

/* loaded from: classes.dex */
public final class AutoValue_PersistedEvent extends PersistedEvent {
    private final EventInternal event;

    /* renamed from: id */
    private final long f117id;
    private final TransportContext transportContext;

    public AutoValue_PersistedEvent(long j, TransportContext transportContext, EventInternal eventInternal) {
        this.f117id = j;
        Objects.requireNonNull(transportContext, "Null transportContext");
        this.transportContext = transportContext;
        Objects.requireNonNull(eventInternal, "Null event");
        this.event = eventInternal;
    }

    @Override // com.google.android.datatransport.runtime.scheduling.persistence.PersistedEvent
    public long getId() {
        return this.f117id;
    }

    @Override // com.google.android.datatransport.runtime.scheduling.persistence.PersistedEvent
    public TransportContext getTransportContext() {
        return this.transportContext;
    }

    @Override // com.google.android.datatransport.runtime.scheduling.persistence.PersistedEvent
    public EventInternal getEvent() {
        return this.event;
    }

    public String toString() {
        return "PersistedEvent{id=" + this.f117id + ", transportContext=" + this.transportContext + ", event=" + this.event + "}";
    }

    public boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (obj instanceof PersistedEvent) {
            PersistedEvent persistedEvent = (PersistedEvent) obj;
            return this.f117id == persistedEvent.getId() && this.transportContext.equals(persistedEvent.getTransportContext()) && this.event.equals(persistedEvent.getEvent());
        }
        return false;
    }

    public int hashCode() {
        long j = this.f117id;
        return this.event.hashCode() ^ ((((((int) (j ^ (j >>> 32))) ^ 1000003) * 1000003) ^ this.transportContext.hashCode()) * 1000003);
    }
}
