import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../models/news.dart';
import '../../services/news_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/bike_bottom_nav.dart';
import '../../widgets/empty_data.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<(List<NewsGroup>, int)> _future;
  bool _loadingAll = false;

  @override
  void initState() {
    super.initState();
    _future = NewsService.instance.getNews();
  }

  void _reload() {
    setState(() {
      _loadingAll = false;
      _future = NewsService.instance.getNews();
    });
  }

  Future<void> _loadAll() async {
    setState(() => _loadingAll = true);
    try {
      final groups = await NewsService.instance.getAllNews();
      if (!mounted) return;
      setState(() {
        _future = Future.value((
          groups,
          groups.fold<int>(0, (sum, g) => sum + g.posts.length),
        ));
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось загрузить все новости')),
      );
    } finally {
      if (mounted) setState(() => _loadingAll = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новости')),
      body: FutureBuilder<(List<NewsGroup>, int)>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final message = snapshot.error is ApiException
                ? (snapshot.error as ApiException).message
                : 'Не удалось загрузить новости';
            return _ErrorView(message: message, onRetry: _reload);
          }
          final groups = snapshot.data?.$1 ?? [];
          final total = snapshot.data?.$2 ?? 0;
          if (groups.isEmpty) return const EmptyData(text: 'Новостей пока нет');
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                24 + bikeNavBottomInset(context),
              ),
              itemCount: groups.length + 1,
              itemBuilder: (context, i) {
                if (i == groups.length) {
                  return _LoadMoreButton(
                    visible: total > 20 && !_loadingAll,
                    loading: _loadingAll,
                    onTap: _loadAll,
                  );
                }
                return _NewsGroupView(group: groups[i]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({
    required this.visible,
    required this.loading,
    required this.onTap,
  });

  final bool visible;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (!visible && !loading) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.6),
              )
            : OutlinedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.expand_more_rounded),
                label: const Text('Показать все новости'),
              ),
      ),
    );
  }
}

class _NewsGroupView extends StatelessWidget {
  const _NewsGroupView({required this.group});

  final NewsGroup group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: group.monthName),
        ...group.posts.map((p) => _NewsCard(post: p)),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.post});

  final NewsPost post;

  @override
  Widget build(BuildContext context) {
    final hasImage = post.titlePicture != null && post.titlePicture!.isNotEmpty;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.zero,
      onTap: () => context.push('/news-detail', extra: post),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: post.titlePicture!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  memCacheWidth: 600,
                  placeholder: (context, url) => Container(
                    height: 140,
                    width: double.infinity,
                    color: AppColors.cardBackground,
                  ),
                  errorWidget: (_, _, _) => const SizedBox.shrink(),
                ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _formatDate(post.datePublished),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hasImage) ...[
                  Text(
                    _formatDate(post.datePublished),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  post.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (post.preview != null && post.preview!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    post.preview!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Читать далее',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
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
