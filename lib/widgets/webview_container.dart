import 'package:flutter/material.dart';

import 'webview_container_io.dart'
    if (dart.library.js_interop) 'webview_container_web.dart'
    as impl;

class WebViewContainer extends StatelessWidget {
  const WebViewContainer({super.key, this.url, this.html});

  final String? url;
  final String? html;

  @override
  Widget build(BuildContext context) {
    return impl.WebViewContainer(url: url, html: html);
  }
}
