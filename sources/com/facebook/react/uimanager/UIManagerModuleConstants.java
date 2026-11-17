package com.facebook.react.uimanager;

import android.widget.ImageView;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.events.TouchEventType;
import com.reactnativecommunity.webview.events.TopLoadingErrorEvent;
import com.reactnativecommunity.webview.events.TopLoadingFinishEvent;
import com.reactnativecommunity.webview.events.TopLoadingStartEvent;
import com.reactnativecommunity.webview.events.TopMessageEvent;
import java.util.HashMap;
import java.util.Map;

/* loaded from: classes.dex */
class UIManagerModuleConstants {
    public static final String ACTION_DISMISSED = "dismissed";
    public static final String ACTION_ITEM_SELECTED = "itemSelected";

    UIManagerModuleConstants() {
    }

    public static Map getBubblingEventTypeConstants() {
        return MapBuilder.builder().put("topChange", MapBuilder.m180of("phasedRegistrationNames", MapBuilder.m179of("bubbled", "onChange", "captured", "onChangeCapture"))).put("topSelect", MapBuilder.m180of("phasedRegistrationNames", MapBuilder.m179of("bubbled", "onSelect", "captured", "onSelectCapture"))).put(TouchEventType.getJSEventName(TouchEventType.START), MapBuilder.m180of("phasedRegistrationNames", MapBuilder.m179of("bubbled", "onTouchStart", "captured", "onTouchStartCapture"))).put(TouchEventType.getJSEventName(TouchEventType.MOVE), MapBuilder.m180of("phasedRegistrationNames", MapBuilder.m179of("bubbled", "onTouchMove", "captured", "onTouchMoveCapture"))).put(TouchEventType.getJSEventName(TouchEventType.END), MapBuilder.m180of("phasedRegistrationNames", MapBuilder.m179of("bubbled", "onTouchEnd", "captured", "onTouchEndCapture"))).put(TouchEventType.getJSEventName(TouchEventType.CANCEL), MapBuilder.m180of("phasedRegistrationNames", MapBuilder.m179of("bubbled", "onTouchCancel", "captured", "onTouchCancelCapture"))).build();
    }

    public static Map getDirectEventTypeConstants() {
        return MapBuilder.builder().put("topContentSizeChange", MapBuilder.m180of("registrationName", "onContentSizeChange")).put("topLayout", MapBuilder.m180of("registrationName", ViewProps.ON_LAYOUT)).put(TopLoadingErrorEvent.EVENT_NAME, MapBuilder.m180of("registrationName", "onLoadingError")).put(TopLoadingFinishEvent.EVENT_NAME, MapBuilder.m180of("registrationName", "onLoadingFinish")).put(TopLoadingStartEvent.EVENT_NAME, MapBuilder.m180of("registrationName", "onLoadingStart")).put("topSelectionChange", MapBuilder.m180of("registrationName", "onSelectionChange")).put(TopMessageEvent.EVENT_NAME, MapBuilder.m180of("registrationName", "onMessage")).put("topClick", MapBuilder.m180of("registrationName", "onClick")).put("topScrollBeginDrag", MapBuilder.m180of("registrationName", "onScrollBeginDrag")).put("topScrollEndDrag", MapBuilder.m180of("registrationName", "onScrollEndDrag")).put("topScroll", MapBuilder.m180of("registrationName", "onScroll")).put("topMomentumScrollBegin", MapBuilder.m180of("registrationName", "onMomentumScrollBegin")).put("topMomentumScrollEnd", MapBuilder.m180of("registrationName", "onMomentumScrollEnd")).build();
    }

    public static Map<String, Object> getConstants() {
        HashMap newHashMap = MapBuilder.newHashMap();
        newHashMap.put("UIView", MapBuilder.m180of("ContentMode", MapBuilder.m178of("ScaleAspectFit", Integer.valueOf(ImageView.ScaleType.FIT_CENTER.ordinal()), "ScaleAspectFill", Integer.valueOf(ImageView.ScaleType.CENTER_CROP.ordinal()), "ScaleAspectCenter", Integer.valueOf(ImageView.ScaleType.CENTER_INSIDE.ordinal()))));
        newHashMap.put("StyleConstants", MapBuilder.m180of("PointerEventsValues", MapBuilder.m177of("none", Integer.valueOf(PointerEvents.NONE.ordinal()), "boxNone", Integer.valueOf(PointerEvents.BOX_NONE.ordinal()), "boxOnly", Integer.valueOf(PointerEvents.BOX_ONLY.ordinal()), "unspecified", Integer.valueOf(PointerEvents.AUTO.ordinal()))));
        newHashMap.put("PopupMenu", MapBuilder.m179of(ACTION_DISMISSED, ACTION_DISMISSED, ACTION_ITEM_SELECTED, ACTION_ITEM_SELECTED));
        newHashMap.put("AccessibilityEventTypes", MapBuilder.m178of("typeWindowStateChanged", 32, "typeViewFocused", 8, "typeViewClicked", 1));
        return newHashMap;
    }
}
