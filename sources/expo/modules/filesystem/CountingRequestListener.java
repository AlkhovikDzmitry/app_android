package expo.modules.filesystem;

import kotlin.Metadata;

/* compiled from: CountingRequestBody.kt */
@FunctionalInterface
@Metadata(m41d1 = {"\u0000\u0018\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u0002\n\u0000\n\u0002\u0010\t\n\u0002\b\u0002\bg\u0018\u00002\u00020\u0001J\u0018\u0010\u0002\u001a\u00020\u00032\u0006\u0010\u0004\u001a\u00020\u00052\u0006\u0010\u0006\u001a\u00020\u0005H&¨\u0006\u0007"}, m40d2 = {"Lexpo/modules/filesystem/CountingRequestListener;", "", "onProgress", "", "bytesWritten", "", "contentLength", "expo-file-system_release"}, m39k = 1, m38mv = {1, 6, 0}, m36xi = 48)
/* loaded from: classes2.dex */
public interface CountingRequestListener {
    void onProgress(long j, long j2);
}
