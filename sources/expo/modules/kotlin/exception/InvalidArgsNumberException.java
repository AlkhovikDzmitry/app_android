package expo.modules.kotlin.exception;

import kotlin.Metadata;

/* compiled from: CodedException.kt */
@Metadata(m41d1 = {"\u0000\u0012\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\b\n\u0002\b\u0003\b\u0000\u0018\u00002\u00020\u0001B\u0015\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\u0006\u0010\u0004\u001a\u00020\u0003¢\u0006\u0002\u0010\u0005¨\u0006\u0006"}, m40d2 = {"Lexpo/modules/kotlin/exception/InvalidArgsNumberException;", "Lexpo/modules/kotlin/exception/CodedException;", "received", "", "expected", "(II)V", "expo-modules-core_release"}, m39k = 1, m38mv = {1, 6, 0}, m36xi = 48)
/* loaded from: classes2.dex */
public final class InvalidArgsNumberException extends CodedException {
    public InvalidArgsNumberException(int i, int i2) {
        super("Received " + i + " arguments, but " + i2 + " was expected.", null, 2, null);
    }
}
