import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Otomatik responsive grid/list widget
/// Her yeni sayfa bu widget'ı kullanarak otomatik responsive olur
class ResponsiveGridList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final EdgeInsets? padding;
  final double? gridSpacing;
  final double? listSpacing;
  final double? aspectRatio;
  final int? maxColumns;
  final Widget? emptyWidget;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ResponsiveGridList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.padding,
    this.gridSpacing,
    this.listSpacing,
    this.aspectRatio,
    this.maxColumns,
    this.emptyWidget,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    // Boş liste kontrolü
    if (items.isEmpty) {
      return emptyWidget ?? _buildDefaultEmptyWidget();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;

        if (isWideScreen) {
          return _buildGridView(constraints);
        } else {
          return _buildListView();
        }
      },
    );
  }

  Widget _buildGridView(BoxConstraints constraints) {
    final maxCols = maxColumns ?? 4;
    final crossAxisCount = constraints.maxWidth > 1400
        ? maxCols
        : constraints.maxWidth > 1000
        ? (maxCols - 1).clamp(1, maxCols)
        : constraints.maxWidth > 700
        ? (maxCols - 2).clamp(1, maxCols)
        : 1;

    final defaultAspectRatio =
        aspectRatio ?? (constraints.maxWidth > 1000 ? 1.2 : 1.5);

    return GridView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: defaultAspectRatio,
        crossAxisSpacing: gridSpacing ?? 12,
        mainAxisSpacing: gridSpacing ?? 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return itemBuilder(context, items[index], index);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: listSpacing ?? 12),
          child: itemBuilder(context, items[index], index),
        );
      },
    );
  }

  Widget _buildDefaultEmptyWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Henüz veri bulunmuyor'),
        ],
      ),
    );
  }
}

/// Refresh özellikli responsive widget
class RefreshableResponsiveGridList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final EdgeInsets? padding;
  final double? gridSpacing;
  final double? listSpacing;
  final double? aspectRatio;
  final int? maxColumns;
  final Widget? emptyWidget;

  const RefreshableResponsiveGridList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    this.padding,
    this.gridSpacing,
    this.listSpacing,
    this.aspectRatio,
    this.maxColumns,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ResponsiveGridList<T>(
        items: items,
        itemBuilder: itemBuilder,
        padding: padding,
        gridSpacing: gridSpacing,
        listSpacing: listSpacing,
        aspectRatio: aspectRatio,
        maxColumns: maxColumns,
        emptyWidget: emptyWidget,
      ),
    );
  }
}

/// Async data için responsive widget
class AsyncResponsiveGridList<T> extends StatelessWidget {
  final AsyncValue<List<T>> asyncData;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final EdgeInsets? padding;
  final double? gridSpacing;
  final double? listSpacing;
  final double? aspectRatio;
  final int? maxColumns;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final Widget Function(Object error)? errorWidgetBuilder;

  const AsyncResponsiveGridList({
    super.key,
    required this.asyncData,
    required this.itemBuilder,
    required this.onRefresh,
    this.padding,
    this.gridSpacing,
    this.listSpacing,
    this.aspectRatio,
    this.maxColumns,
    this.emptyWidget,
    this.loadingWidget,
    this.errorWidgetBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return asyncData.when(
      data: (items) => RefreshableResponsiveGridList<T>(
        items: items,
        itemBuilder: itemBuilder,
        onRefresh: onRefresh,
        padding: padding,
        gridSpacing: gridSpacing,
        listSpacing: listSpacing,
        aspectRatio: aspectRatio,
        maxColumns: maxColumns,
        emptyWidget: emptyWidget,
      ),
      loading: () =>
          loadingWidget ?? const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          errorWidgetBuilder?.call(error) ?? _buildDefaultErrorWidget(error),
    );
  }

  Widget _buildDefaultErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Hata: ${error.toString()}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRefresh,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }
}
