import 'package:flutter/material.dart';

/// Ortak hata ve uyarı mesajları için merkezi widget
class CenteredErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final bool isFullScreen;

  const CenteredErrorWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.error_outline,
    this.iconColor,
    this.onRetry,
    this.retryButtonText = 'Tekrar Dene',
    this.isFullScreen = true,
  });

  /// Erişim engellendi mesajı için özel constructor
  const CenteredErrorWidget.accessDenied({
    super.key,
    required this.message,
    this.onRetry,
    this.retryButtonText = 'Geri Dön',
    this.isFullScreen = true,
  }) : title = 'Erişim Engellendi',
       icon = Icons.lock,
       iconColor = null;

  /// Genel hata mesajı için özel constructor
  const CenteredErrorWidget.generalError({
    super.key,
    required this.message,
    this.onRetry,
    this.retryButtonText = 'Tekrar Dene',
    this.isFullScreen = true,
  }) : title = 'Bir Hata Oluştu',
       icon = Icons.error_outline,
       iconColor = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    final content = Container(
      padding: EdgeInsets.all(isMobile ? 24.0 : 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Icon(
            icon,
            size: isMobile ? 64 : 80,
            color: iconColor ?? theme.colorScheme.error,
          ),
          SizedBox(height: isMobile ? 16 : 24),

          // Title
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: iconColor ?? theme.colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 8 : 12),

          // Message
          Text(
            message,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isMobile ? 24 : 32),

          // Retry Button
          if (onRetry != null)
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryButtonText!),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: isMobile ? 12 : 16,
                ),
              ),
            ),
        ],
      ),
    );

    if (isFullScreen) {
      return Center(child: content);
    } else {
      return content;
    }
  }
}

/// Loading widget'ı için merkezi widget
class CenteredLoadingWidget extends StatelessWidget {
  final String? message;
  final bool isFullScreen;

  const CenteredLoadingWidget({
    super.key,
    this.message,
    this.isFullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: isMobile ? 32 : 40,
          height: isMobile ? 32 : 40,
          child: const CircularProgressIndicator(),
        ),
        if (message != null) ...[
          SizedBox(height: isMobile ? 16 : 24),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (isFullScreen) {
      return Center(child: content);
    } else {
      return content;
    }
  }
}

/// Boş durum widget'ı için merkezi widget
class CenteredEmptyWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const CenteredEmptyWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Center(
      child: Container(
        padding: EdgeInsets.all(isMobile ? 24.0 : 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              icon,
              size: isMobile ? 64 : 80,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            SizedBox(height: isMobile ? 16 : 24),

            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 8 : 12),

            // Message
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isMobile ? 24 : 32),

            // Action Button
            if (onAction != null && actionText != null)
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: isMobile ? 12 : 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
