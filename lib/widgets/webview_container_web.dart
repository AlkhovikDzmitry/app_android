import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class WebViewContainer extends StatefulWidget {
  const WebViewContainer({super.key, this.url, this.html});

  final String? url;
  final String? html;

  @override
  State<WebViewContainer> createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> {
  late final String _viewId;
  String? _url;
  String? _html;

  @override
  void initState() {
    super.initState();
    _url = widget.url;
    _html = widget.html;
    _viewId = 'webview-${identityHashCode(this)}';
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final iframe =
          web.document.createElement('iframe') as web.HTMLIFrameElement;
      iframe.style.border = 'none';
      iframe.style.width = '100%';
      iframe.style.height = '100%';
      if (_url != null) {
        iframe.src = _url!;
      } else {
        iframe.setAttribute('srcdoc', _html ?? '');
      }
      return iframe;
    });
  }

  @override
  void didUpdateWidget(covariant WebViewContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url || oldWidget.html != widget.html) {
      setState(() {
        _url = widget.url;
        _html = widget.html;
      });
    }
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _viewId);
}
