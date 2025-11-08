import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/event.dart';
import '../providers/events_providers.dart';

class MemberEventCard extends ConsumerStatefulWidget {
  const MemberEventCard({
    super.key,
    required this.event,
    required this.onRespond,
    this.onViewResponses,
  });

  final Event event;
  final VoidCallback onRespond;
  final VoidCallback? onViewResponses;

  @override
  ConsumerState<MemberEventCard> createState() => _MemberEventCardState();
}

class _MemberEventCardState extends ConsumerState<MemberEventCard> {
  bool _isRead = false;
  bool _hasResponded = false;

  @override
  void initState() {
    super.initState();
    _checkReadStatus();
    _checkResponseStatus();
  }

  void _checkReadStatus() async {
    // Check read status from provider
    final isRead = ref.read(eventReadStatusProvider).contains(widget.event.id);
    setState(() {
      _isRead = isRead;
    });
  }

  void _checkResponseStatus() async {
    setState(() {
      _hasResponded = false; // Simulate no response
    });
  }

  void _markAsRead() async {
    if (!_isRead) {
      // Mark as read in the provider
      markEventAsRead(ref, widget.event.id);

      setState(() {
        _isRead = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Card(
      margin: EdgeInsets.all(
        isMobile
            ? 8
            : isTablet
            ? 12
            : 16,
      ),
      elevation: _isRead ? 2 : 4,
      child: InkWell(
        onTap: () {
          _markAsRead();
          widget.onRespond(); // Detay dialog'unu aç
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(
            isMobile
                ? 8
                : isTablet
                ? 12
                : 16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: _isRead
                ? null
                : Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Event title and read button in header
              Row(
                children: [
                  // Event title (left side)
                  Expanded(
                    child: Text(
                      widget.event.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: _isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                        fontSize: isMobile
                            ? 16
                            : isTablet
                            ? 18
                            : 20,
                      ),
                      maxLines: isMobile ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Read button (right side)
                  GestureDetector(
                    onTap: _markAsRead,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _isRead
                            ? Colors.grey[300]
                            : theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isRead
                              ? Colors.grey[400]!
                              : theme.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isRead ? Icons.check : Icons.mark_email_unread,
                            size: 14,
                            color: _isRead
                                ? Colors.grey[600]
                                : theme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isRead ? 'Okundu' : 'Okundu',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: _isRead
                                  ? Colors.grey[600]
                                  : theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Response status indicator
                  if (_hasResponded) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                  ],
                ],
              ),

              const SizedBox(height: 6),

              // Event description
              if (widget.event.description != null &&
                  widget.event.description!.isNotEmpty)
                Text(
                  widget.event.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: isMobile
                        ? 12
                        : isTablet
                        ? 14
                        : 16,
                  ),
                  maxLines: isMobile ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 8),

              // Event image
              Container(
                height: isMobile
                    ? 60
                    : isTablet
                    ? 80
                    : 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildEventImage(),
                ),
              ),

              const SizedBox(height: 8),

              // Event dates - Always show section
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.play_arrow,
                    size: isMobile ? 12 : 14,
                    color: Colors.green[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.event.startAt != null
                        ? 'Başlangıç: ${_formatCompactDateTime(widget.event.startAt!)}'
                        : 'Başlangıç: Belirtilmemiş',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green[700],
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.stop,
                    size: isMobile ? 12 : 14,
                    color: Colors.red[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.event.endAt != null
                        ? 'Bitiş: ${_formatCompactDateTime(widget.event.endAt!)}'
                        : 'Bitiş: Belirtilmemiş',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red[700],
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: isMobile ? 12 : 14,
                    color: Colors.orange[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.event.registrationDeadline != null
                        ? 'Son Cevap: ${_formatCompactDateTime(widget.event.registrationDeadline!)}'
                        : 'Son Cevap: Belirtilmemiş',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange[700],
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Location
              if (widget.event.location != null &&
                  widget.event.location!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.event.location!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                          fontSize: isMobile ? 10 : 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Max participants
              if (widget.event.maxParticipants != null) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Max ${widget.event.maxParticipants} kişi',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                          fontSize: isMobile ? 10 : 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Action hint - Only show on mobile to save space
              if (isMobile) ...[
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: theme.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app,
                        size: 12,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Detayları görmek için tıklayın',
                        style: TextStyle(
                          fontSize: 9,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventImage() {
    if (widget.event.imageUrl == null || widget.event.imageUrl!.isEmpty) {
      return _buildPlaceholderImage();
    }

    if (widget.event.imageUrl!.startsWith('data:image/')) {
      // Base64 image
      try {
        final base64String = widget.event.imageUrl!.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageError();
          },
        );
      } catch (e) {
        return _buildImageError();
      }
    } else if (widget.event.imageUrl!.startsWith('http')) {
      // Network image
      return Image.network(
        widget.event.imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError();
        },
      );
    } else {
      // Local file
      return Image.asset(
        widget.event.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError();
        },
      );
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[100]!, Colors.purple[100]!],
        ),
      ),
      child: const Icon(Icons.event, size: 40, color: Colors.white70),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.grey.shade100,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 32, color: Colors.grey),
            SizedBox(height: 4),
            Text(
              'Resim yüklenemedi',
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCompactDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (eventDate == today) {
      return 'Bugün ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (eventDate == today.add(const Duration(days: 1))) {
      return 'Yarın ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (eventDate == today.subtract(const Duration(days: 1))) {
      return 'Dün ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
