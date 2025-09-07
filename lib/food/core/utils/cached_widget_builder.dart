import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedWidgetBuilder {
  static final Map<String, Widget> _widgetCache = {};
  
  static Widget buildCachedFoodList({
    required String cacheKey,
    required List<dynamic> items,
    required Widget Function(dynamic item, int index) itemBuilder,
  }) {
    if (_widgetCache.containsKey(cacheKey)) {
      return _widgetCache[cacheKey]!;
    }
    
    final widget = ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      itemBuilder: (context, index) => itemBuilder(items[index], index),
    );
    
    _widgetCache[cacheKey] = widget;
    return widget;
  }
  
  static Widget buildOptimizedCachedImage({
    required String imageUrl,
    required String cacheKey,
    required BoxFit fit,
    int? memCacheWidth,
    int? memCacheHeight,
    PlaceholderWidgetBuilder? placeholder,
    LoadingErrorWidgetBuilder? errorWidget,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      key: ValueKey(cacheKey),
      fit: fit,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      placeholder: placeholder,
      errorWidget: errorWidget,
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 200),
    );
  }
  
  static void clearCache([String? cacheKey]) {
    if (cacheKey != null) {
      _widgetCache.remove(cacheKey);
    } else {
      _widgetCache.clear();
    }
  }
  
  static void preWarmImageCache(List<String> imageUrls) async {
    for (String url in imageUrls) {
      try {
        // Pre-cache the image without evicting it
        await precacheImage(
          CachedNetworkImageProvider(url),
          // Use the current context from navigator
          WidgetsBinding.instance.rootElement!,
        );
      } catch (e) {
        // Silently handle any prewarming errors
        debugPrint('Failed to prewarm image: $url - $e');
      }
    }
  }
}

class CachedListView extends StatefulWidget {
  final List<Widget> children;
  final Axis scrollDirection;
  final String cacheKey;
  
  const CachedListView({
    super.key,
    required this.children,
    required this.cacheKey,
    this.scrollDirection = Axis.horizontal,
  });
  
  @override
  State<CachedListView> createState() => _CachedListViewState();
}

class _CachedListViewState extends State<CachedListView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    // For horizontal lists, use SingleChildScrollView for better performance
    if (widget.scrollDirection == Axis.horizontal) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: widget.children,
        ),
      );
    }
    
    // For vertical lists, use Column
    return Column(
      children: widget.children,
    );
  }
}