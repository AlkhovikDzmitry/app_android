import 'package:flutter/material.dart';

import '../../widgets/app_back_button.dart';
import '../../widgets/bike_bottom_nav.dart';
import '../../widgets/webview_container.dart';

class DocumentViewScreen extends StatelessWidget {
  const DocumentViewScreen({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Документ'),
        automaticallyImplyLeading: false,
        leading: const AppBackButton(),
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: bikeNavBottomInset(context)),
        child: WebViewContainer(url: url),
      ),
    );
  }
}
