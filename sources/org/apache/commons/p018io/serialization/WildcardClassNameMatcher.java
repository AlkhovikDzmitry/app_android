package org.apache.commons.p018io.serialization;

import org.apache.commons.p018io.FilenameUtils;

/* renamed from: org.apache.commons.io.serialization.WildcardClassNameMatcher */
/* loaded from: classes3.dex */
final class WildcardClassNameMatcher implements ClassNameMatcher {
    private final String pattern;

    public WildcardClassNameMatcher(String str) {
        this.pattern = str;
    }

    @Override // org.apache.commons.p018io.serialization.ClassNameMatcher
    public boolean matches(String str) {
        return FilenameUtils.wildcardMatch(str, this.pattern);
    }
}
