import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../models/news.dart';
import '../../services/news_service.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/bike_bottom_nav.dart';

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key, required this.post});

  final NewsPost post;

  @override
  Widget build(BuildContext context) {
    final hasImage = post.titlePicture != null && post.titlePicture!.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новость'),
        automaticallyImplyLeading: false,
        leading: const AppBackButton(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          32 + bikeNavBottomInset(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: post.titlePicture!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  memCacheWidth: 800,
                  placeholder: (context, url) =>
                      Container(height: 180, color: AppColors.cardBackground),
                  errorWidget: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              _formatDate(post.datePublished),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              post.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<String>(
              future: _loadContent(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    'Не удалось загрузить текст новости',
                    style: TextStyle(color: AppColors.textSecondary),
                  );
                }
                return HtmlWidget(
                  snapshot.data ?? '',
                  textStyle: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                  onTapUrl: (url) {
                    final uri = Uri.tryParse(url);
                    if (uri != null) {
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                    return true;
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _loadContent() async {
    return NewsService.instance.getNewsFullPost(post.id);
  }
}

String _formatDate(String? value) {
  if (value == null || value.isEmpty) return '';
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    final parts = value.split('.');
    if (parts.length == 3) {
      final d = DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
      if (d != null) return DateFormat('dd.MM.yyyy').format(d);
    }
    return value;
  }
  return DateFormat('dd.MM.yyyy').format(parsed);
}
