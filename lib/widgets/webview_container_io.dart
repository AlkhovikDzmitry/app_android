import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewContainer extends StatefulWidget {
  const WebViewContainer({super.key, this.url, this.html});

  final String? url;
  final String? html;

  @override
  State<WebViewContainer> createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // Запрещаем переходы на незащищённые и локальные адреса: платёжная форма
      // и документы приходят только по https, а http/file/javascript-переходы
      // дают возможность увести пользователя на поддельную страницу или
      // прочитать локальные файлы.
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final scheme = Uri.tryParse(request.url)?.scheme.toLowerCase();
            if (scheme == 'http' ||
                scheme == 'file' ||
                scheme == 'javascript' ||
                scheme == 'content') {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    _load();
  }

  @override
  void didUpdateWidget(covariant WebViewContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url || oldWidget.html != widget.html) {
      _load();
    }
  }

  void _load() {
    if (widget.url != null) {
      _controller.loadRequest(Uri.parse(widget.url!));
    } else {
      _controller.loadHtmlString(widget.html ?? '');
    }
  }

  @override
  Widget build(BuildContext context) => WebViewWidget(controller: _controller);
}
