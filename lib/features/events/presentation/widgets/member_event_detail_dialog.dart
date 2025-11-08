import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown/markdown.dart' as md;
import '../../domain/entities/event.dart';
import '../providers/events_providers.dart';

class MemberEventDetailDialog extends ConsumerStatefulWidget {
  const MemberEventDetailDialog({super.key, required this.event});

  final Event event;

  @override
  ConsumerState<MemberEventDetailDialog> createState() =>
      _MemberEventDetailDialogState();
}

class _MemberEventDetailDialogState
    extends ConsumerState<MemberEventDetailDialog> {
  bool _isSubmitting = false;
  bool _hasResponded = false;
  DateTime? _responseDate;
  final _textController = TextEditingController();
  String? _selectedOptionId;
  final Map<String, String> _questionResponses = {}; // questionId -> response
  final Map<String, TextEditingController> _questionControllers =
      {}; // questionId -> controller
  final Map<String, String?> _questionSelectedOptions =
      {}; // questionId -> selected option
  String? _currentMemberId;

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each question
    for (final question in widget.event.questions) {
      _questionControllers[question.id] = TextEditingController();
      _questionSelectedOptions[question.id] = null;
    }
    // Load existing responses asynchronously
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingResponses();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    for (final controller in _questionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadExistingResponses() async {
    try {
      // Get current member ID
      final eventsRepository = ref.read(eventsRepositoryProvider);
      final currentMember = await eventsRepository.getCurrentMember();

      if (currentMember != null) {
        _currentMemberId = currentMember['id'] as String;

        // Load existing question responses
        final responses = await eventsRepository.getQuestionResponses(
          eventId: widget.event.id,
          memberId: _currentMemberId!,
        );

        if (mounted) {
          setState(() {
            if (responses.isNotEmpty) {
              _hasResponded = true;
              _responseDate = responses.first.createdAt;
            } else {}

            for (final response in responses) {
              if (response.responseText != null &&
                  response.responseText!.isNotEmpty) {
                _questionResponses[response.questionId] =
                    response.responseText!;
                // Update controller text
                final controller = _questionControllers[response.questionId];
                if (controller != null) {
                  controller.text = response.responseText!;
                }
              }

              if (response.optionId != null && response.optionId!.isNotEmpty) {
                _selectedOptionId = response.optionId;

                // Set the selected option for the specific question
                _questionSelectedOptions[response.questionId] =
                    response.optionId;
                _questionResponses[response.questionId] = response.optionId!;
              }

              // Tek seçim ve çoklu seçim soruları için responseText'ten yükle
              if (response.responseText != null &&
                  response.responseText!.isNotEmpty) {
                // Bu sorunun tipini kontrol et
                EventQuestion question;
                try {
                  question = widget.event.questions.firstWhere(
                    (q) => q.id == response.questionId,
                  );
                } catch (e) {
                  // Soru bulunamadı, varsayılan soru oluştur
                  question = EventQuestion(
                    id: response.questionId,
                    eventId: widget.event.id,
                    questionText: 'Bilinmeyen Soru',
                    questionType: 'text',
                    isRequired: false,
                    sortOrder: 0,
                    createdAt: DateTime.now(),
                    options: [],
                  );
                }

                if (question.questionType == 'single_choice') {
                  // Tek seçim için responseText'i selectedOptions'a kaydet
                  _questionSelectedOptions[response.questionId] =
                      response.responseText!;
                  _questionResponses[response.questionId] =
                      response.responseText!;
                } else if (question.questionType == 'multiple_choice') {
                  // Çoklu seçim için responseText'i selectedOptions'a kaydet
                  _questionSelectedOptions[response.questionId] =
                      response.responseText!;
                  _questionResponses[response.questionId] =
                      response.responseText!;
                }
              }
            }
          });
        }
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Force reload existing responses if not loaded yet
    if (_currentMemberId != null && _questionResponses.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingResponses();
      });
    }

    // Also try to reload if member ID is available but no responses loaded
    if (_currentMemberId != null &&
        _questionResponses.isEmpty &&
        !_hasResponded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingResponses();
      });
    }

    // Check if we need to force reload
    if (_currentMemberId != null && _questionResponses.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingResponses();
      });
    }
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Dialog(
      child: Container(
        width: isMobile
            ? screenWidth * 0.98
            : isTablet
            ? screenWidth * 0.8
            : screenWidth * 0.7,
        height: isMobile ? screenHeight * 0.95 : screenHeight * 0.9,
        constraints: BoxConstraints(
          maxWidth: isMobile
              ? double.infinity
              : isTablet
              ? 700
              : 900,
          maxHeight: isMobile ? double.infinity : screenHeight * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with event details
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event title - full width
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 8 : 12,
                      horizontal: isMobile ? 4 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.event.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile
                            ? 18
                            : isTablet
                            ? 20
                            : 22,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: isMobile ? 8 : 12),

                  // Event date only (removed event type)
                  if (widget.event.startAt != null)
                    Text(
                      _formatDate(widget.event.startAt!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.7,
                        ),
                        fontSize: isMobile
                            ? 12
                            : isTablet
                            ? 14
                            : 16,
                      ),
                    ),
                ],
              ),
            ),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event image
                    if (widget.event.imageUrl != null &&
                        widget.event.imageUrl!.isNotEmpty) ...[
                      _buildSectionTitle('Etkinlik Resmi', theme, isMobile),
                      SizedBox(height: isMobile ? 8 : 12),
                      Container(
                        width: double.infinity,
                        height: isMobile
                            ? 200
                            : isTablet
                            ? 250
                            : 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade100,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildEventImage(),
                        ),
                      ),
                      SizedBox(height: isMobile ? 16 : 20),
                    ],

                    // Event description (rich description)
                    if (widget.event.richDescription != null &&
                        widget.event.richDescription!.isNotEmpty) ...[
                      _buildSectionTitle('Detaylı Açıklama', theme, isMobile),
                      SizedBox(height: isMobile ? 8 : 12),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isMobile ? 12 : 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: _buildMarkdownContent(
                          widget.event.richDescription!,
                          theme,
                          isMobile,
                        ),
                      ),
                      SizedBox(height: isMobile ? 16 : 20),
                    ],

                    // Event status
                    _buildSectionTitle('Etkinlik Durumu', theme, isMobile),
                    SizedBox(height: isMobile ? 8 : 12),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      decoration: BoxDecoration(
                        color: widget.event.isActive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: widget.event.isActive
                              ? Colors.green.withOpacity(0.3)
                              : Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.event.isActive
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: widget.event.isActive
                                ? Colors.green
                                : Colors.red,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            widget.event.isActive ? 'Aktif' : 'Pasif',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: widget.event.isActive
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 20),

                    // Event dates
                    if (widget.event.startAt != null ||
                        widget.event.endAt != null) ...[
                      _buildSectionTitle('Tarih ve Saat', theme, isMobile),
                      SizedBox(height: isMobile ? 8 : 12),
                      _buildDateInfo(theme, isMobile),
                      SizedBox(height: isMobile ? 16 : 20),
                    ],

                    // Max participants
                    if (widget.event.maxParticipants != null) ...[
                      _buildSectionTitle(
                        'Maksimum Katılımcı Sayısı',
                        theme,
                        isMobile,
                      ),
                      SizedBox(height: isMobile ? 8 : 12),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isMobile ? 12 : 16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.people, color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '${widget.event.maxParticipants} kişi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isMobile ? 16 : 20),
                    ],

                    // Location
                    if (widget.event.location != null &&
                        widget.event.location!.isNotEmpty) ...[
                      _buildSectionTitle('Etkinlik Yeri', theme, isMobile),
                      SizedBox(height: isMobile ? 8 : 12),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isMobile ? 12 : 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.blue,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.event.location!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: isMobile ? 14 : 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isMobile ? 16 : 20),
                    ],

                    // Organizers
                    if (widget.event.organizers.isNotEmpty) ...[
                      _buildSectionTitle('Organizatörler', theme, isMobile),
                      SizedBox(height: isMobile ? 8 : 12),
                      ...widget.event.organizers.map(
                        (organizer) => Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.all(isMobile ? 12 : 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: _getRoleColor(
                                  organizer.role,
                                ).withOpacity(0.1),
                                child: Icon(
                                  _getRoleIcon(organizer.role),
                                  color: _getRoleColor(organizer.role),
                                  size: 16,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      organizer.memberName ??
                                          'Organizatör ${widget.event.organizers.indexOf(organizer) + 1}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _getRoleText(organizer.role),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getRoleColor(organizer.role),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: isMobile ? 16 : 20),
                    ],

                    // Instructors
                    if (widget.event.instructors.isNotEmpty) ...[
                      _buildSectionTitle('Eğitmenler', theme, isMobile),
                      SizedBox(height: isMobile ? 8 : 12),
                      ...widget.event.instructors.map(
                        (instructor) => Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.all(isMobile ? 12 : 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: _getInstructorRoleColor(
                                  instructor.role,
                                ).withOpacity(0.1),
                                child: Icon(
                                  _getInstructorRoleIcon(instructor.role),
                                  color: _getInstructorRoleColor(
                                    instructor.role,
                                  ),
                                  size: 16,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      instructor.memberName ??
                                          'Eğitmen ${widget.event.instructors.indexOf(instructor) + 1}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _getInstructorRoleText(instructor.role),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getInstructorRoleColor(
                                          instructor.role,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: isMobile ? 16 : 20),
                    ],

                    // Questions
                    if (widget.event.questions.isNotEmpty) ...[
                      _buildSectionTitle('Sorular', theme, isMobile),
                      if (_isResponseTimeExpired())
                        Container(
                          margin: EdgeInsets.only(top: 8, bottom: 16),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Colors.red.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Son cevap zamanı geçmiş: ${_formatResponseDate(widget.event.endAt!)}',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_hasResponded && _responseDate != null)
                        Container(
                          margin: EdgeInsets.only(top: 8, bottom: 16),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            border: Border.all(color: Colors.green.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Bu etkinliğe ${_formatResponseDate(_responseDate!)} tarihinde yanıt verdiniz.',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              if (widget.event.endAt != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.blue.shade600,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Son cevap zamanı: ${_formatResponseDate(widget.event.endAt!)}',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      SizedBox(height: isMobile ? 8 : 12),
                      ...widget.event.questions.map(
                        (question) => Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(isMobile ? 12 : 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getQuestionTypeColor(
                                        question.questionType,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _getQuestionTypeText(
                                        question.questionType,
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getQuestionTypeColor(
                                          question.questionType,
                                        ),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (question.isRequired) ...[
                                    SizedBox(width: 8),
                                    Chip(
                                      label: Text('Zorunlu'),
                                      backgroundColor: Colors.redAccent,
                                      labelStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${widget.event.questions.indexOf(question) + 1}. ${question.questionText}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 12),
                              _buildAnswerField(question, theme, isMobile),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: isMobile ? 16 : 20),
                    ],

                    // Media files
                    if (widget.event.media.isNotEmpty) ...[
                      _buildSectionTitle('Medya Dosyaları', theme, isMobile),
                      SizedBox(height: isMobile ? 8 : 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isMobile ? 2 : 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: widget.event.media.length,
                        itemBuilder: (context, index) {
                          final media = widget.event.media[index];
                          return GestureDetector(
                            onTap: () => _previewMedia(context, media),
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: Column(
                                children: [
                                  Expanded(child: _buildMediaThumbnail(media)),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      media.fileName,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: isMobile ? 16 : 20),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: isMobile
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting || _isResponseTimeExpired()
                                ? null
                                : _submitResponse,
                            child: _isSubmitting
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : _isResponseTimeExpired()
                                ? Text('Süre Doldu')
                                : _hasResponded
                                ? Text('Yanıtı Güncelle')
                                : Text('Yanıt Gönder'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Kapat'),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Kapat'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSubmitting || _isResponseTimeExpired()
                                ? null
                                : _submitResponse,
                            child: _isSubmitting
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : _isResponseTimeExpired()
                                ? const Text('Süre Doldu')
                                : _hasResponded
                                ? const Text('Yanıtı Güncelle')
                                : const Text('Yanıt Gönder'),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme, bool isMobile) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: isMobile ? 16 : 18,
      ),
    );
  }

  Widget _buildEventImage() {
    if (widget.event.imageUrl!.startsWith('data:image/')) {
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
      return Image.asset(
        widget.event.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError();
        },
      );
    }
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
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

  Widget _buildDateInfo(ThemeData theme, bool isMobile) {
    return Column(
      children: [
        if (widget.event.startAt != null) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Başlangıç: ${_formatFullDateTime(widget.event.startAt!)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
        ],
        if (widget.event.endAt != null) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule_outlined, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bitiş: ${_formatFullDateTime(widget.event.endAt!)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
        ],
        if (widget.event.registrationDeadline != null) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: _getRegistrationStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getRegistrationStatusColor().withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getRegistrationStatusIcon(),
                  color: _getRegistrationStatusColor(),
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Son Kayıt: ${_formatFullDateTime(widget.event.registrationDeadline!)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: isMobile ? 14 : 16,
                      color: _getRegistrationStatusColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAnswerField(
    EventQuestion question,
    ThemeData theme,
    bool isMobile,
  ) {
    switch (question.questionType) {
      case 'text':
        return TextFormField(
          controller: _questionControllers[question.id]!,
          decoration: const InputDecoration(
            hintText: 'Cevabınızı buraya yazın...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
          maxLines: 3,
          onChanged: (value) {
            setState(() {
              _questionResponses[question.id] = value;
            });
          },
        );
      case 'single_choice':
        if (question.options.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bu soru için seçenekler henüz eklenmemiş.',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        List<EventQuestionOption> options = question.options;
        return Column(
          children: options.map((option) {
            final selectedValue = _questionSelectedOptions[question.id];

            return RadioListTile<String>(
              title: Text(option.optionText),
              value: option.id,
              groupValue: selectedValue,
              onChanged: (value) {
                setState(() {
                  _questionSelectedOptions[question.id] = value;
                  _questionResponses[question.id] = value!;
                });
              },
            );
          }).toList(),
        );
      case 'multiple_choice':
        if (question.options.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bu soru için seçenekler henüz eklenmemiş.',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        List<EventQuestionOption> options = question.options;
        return Column(
          children: options.map((option) {
            return CheckboxListTile(
              title: Text(option.optionText),
              value:
                  _questionSelectedOptions[question.id] != null &&
                  _questionSelectedOptions[question.id]!
                      .split(',')
                      .contains(option.id),
              onChanged: (bool? checked) {
                setState(() {
                  final current = _questionSelectedOptions[question.id] ?? '';
                  if (checked == true) {
                    _questionSelectedOptions[question.id] = current.isEmpty
                        ? option.id
                        : '$current,${option.id}';
                  } else {
                    _questionSelectedOptions[question.id] = current
                        .split(',')
                        .where((id) => id != option.id)
                        .join(',');
                  }
                  _questionResponses[question.id] =
                      _questionSelectedOptions[question.id] ?? '';
                });
              },
            );
          }).toList(),
        );
      default:
        return Text('Desteklenmeyen soru tipi');
    }
  }

  Widget _buildMediaThumbnail(EventMedia media) {
    if (media.fileType == 'image') {
      if (media.fileUrl.startsWith('data:image/')) {
        try {
          final base64String = media.fileUrl.split(',')[1];
          final bytes = base64Decode(base64String);
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildMediaError();
            },
          );
        } catch (e) {
          return _buildMediaError();
        }
      } else if (media.fileUrl.startsWith('http')) {
        return Image.network(
          media.fileUrl,
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
            return _buildMediaError();
          },
        );
      } else if (media.fileUrl.startsWith('blob:')) {
        // Web blob URL - show placeholder
        return Container(
          color: Colors.grey.shade200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 32, color: Colors.grey),
                SizedBox(height: 4),
                Text(
                  'Web dosyası',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }
    } else if (media.fileType == 'video') {
      return Container(
        color: Colors.grey.shade200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_outline, size: 32, color: Colors.red),
              SizedBox(height: 4),
              Text('Video', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      );
    } else if (media.fileType == 'audio') {
      return Container(
        color: Colors.grey.shade200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.audiotrack, size: 32, color: Colors.blue),
              SizedBox(height: 4),
              Text('Ses', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.grey.shade200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.insert_drive_file, size: 32, color: Colors.grey),
              SizedBox(height: 4),
              Text('Dosya', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    return _buildMediaError();
  }

  Widget _buildMediaError() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(Icons.attach_file, color: Colors.grey, size: 24),
      ),
    );
  }

  void _previewMedia(BuildContext context, EventMedia media) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              AppBar(
                title: Text(media.fileName),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              Expanded(child: _buildMediaThumbnail(media)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitResponse() async {
    if (_isSubmitting) return;

    // Son cevap zamanı kontrolü
    if (widget.event.endAt != null &&
        DateTime.now().isAfter(widget.event.endAt!)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Son cevap zamanı geçmiş: ${_formatResponseDate(widget.event.endAt!)}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Validate required questions
    for (final question in widget.event.questions) {
      if (question.isRequired) {
        if (question.questionType == 'text') {
          final controller = _questionControllers[question.id];
          if (controller == null || controller.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Lütfen "${question.questionText}" sorusunu yanıtlayın',
                ),
              ),
            );
            return;
          }
        } else if (question.questionType == 'single_choice' ||
            question.questionType == 'multiple_choice') {
          final selectedOption = _questionSelectedOptions[question.id];
          if (selectedOption == null || selectedOption.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Lütfen "${question.questionText}" sorusunu yanıtlayın',
                ),
              ),
            );
            return;
          }
        }
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final eventsRepository = ref.read(eventsRepositoryProvider);

      // Save responses for each question
      for (final question in widget.event.questions) {
        String? responseText;

        if (question.questionType == 'text') {
          final controller = _questionControllers[question.id];
          responseText = controller?.text.trim();
        } else if (question.questionType == 'single_choice' ||
            question.questionType == 'multiple_choice') {
          responseText = _questionSelectedOptions[question.id];
        }

        if (responseText != null && responseText.isNotEmpty) {
          // Determine if this is a choice question and get the optionId
          String? optionId;
          if (question.questionType == 'single_choice') {
            // For single choice, store the single option ID in optionId field
            optionId = responseText;
            responseText = null; // Don't save as responseText for single choice
          } else if (question.questionType == 'multiple_choice') {
            // For multiple choice, store the comma-separated option IDs in responseText field
            // and leave optionId as null since it can only store a single UUID
            optionId = null;
            // responseText already contains the comma-separated option IDs
          }

          try {
            await eventsRepository.createQuestionResponse(
              questionId: question.id,
              memberId: _currentMemberId!,
              optionId: optionId,
              responseText: responseText,
            );
          } catch (e) {
            // Eğer zaten cevap varsa, güncelle
            if (e.toString().contains('duplicate key')) {
              await eventsRepository.updateQuestionResponse(
                questionId: question.id,
                memberId: _currentMemberId!,
                optionId: optionId,
                responseText: responseText ?? '',
              );
            } else {
              rethrow;
            }
          }
        }
      }

      // Also save the main event response if it's interactive or poll
      if (widget.event.type == EventType.interactive ||
          widget.event.type == EventType.poll) {
        final createEventResponse = ref.read(createEventResponseProvider);
        await createEventResponse.call(
          eventId: widget.event.id,
          optionId: _selectedOptionId,
          responseText: _textController.text.trim().isEmpty
              ? null
              : _textController.text.trim(),
        );
      }

      if (mounted) {
        setState(() {
          _hasResponded = true;
          _responseDate = DateTime.now();
        });

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _hasResponded ? 'Yanıtınız güncellendi' : 'Yanıtınız gönderildi',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün sonra';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat sonra';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika sonra';
    } else {
      return 'Şimdi';
    }
  }

  String _formatResponseDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  bool _isResponseTimeExpired() {
    return widget.event.endAt != null &&
        DateTime.now().isAfter(widget.event.endAt!);
  }

  String _formatFullDateTime(DateTime dateTime) {
    final months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];

    final monthName = months[dateTime.month - 1];
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day $monthName ${dateTime.year} - $hour:$minute';
  }

  Color _getRegistrationStatusColor() {
    if (widget.event.registrationDeadline == null) return Colors.grey;

    final now = DateTime.now();
    final deadline = widget.event.registrationDeadline!;

    if (now.isAfter(deadline)) {
      return Colors.red; // Kayıt süresi dolmuş
    } else if (deadline.difference(now).inDays < 7) {
      return Colors.orange; // Son 7 gün
    } else {
      return Colors.green; // Kayıt devam ediyor
    }
  }

  IconData _getRegistrationStatusIcon() {
    if (widget.event.registrationDeadline == null) return Icons.help;

    final now = DateTime.now();
    final deadline = widget.event.registrationDeadline!;

    if (now.isAfter(deadline)) {
      return Icons.close; // Kayıt süresi dolmuş
    } else if (deadline.difference(now).inDays < 7) {
      return Icons.warning; // Son 7 gün
    } else {
      return Icons.check; // Kayıt devam ediyor
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'organizer':
        return Colors.blue;
      case 'co-organizer':
        return Colors.green;
      case 'assistant':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'organizer':
        return Icons.star;
      case 'co-organizer':
        return Icons.group;
      case 'assistant':
        return Icons.support_agent;
      default:
        return Icons.person;
    }
  }

  String _getRoleText(String role) {
    switch (role) {
      case 'organizer':
        return 'Ana Organizatör';
      case 'co-organizer':
        return 'Yardımcı Organizatör';
      case 'assistant':
        return 'Asistan';
      default:
        return role;
    }
  }

  Color _getInstructorRoleColor(String role) {
    switch (role) {
      case 'instructor':
        return Colors.purple;
      case 'co-instructor':
        return Colors.teal;
      case 'assistant':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  IconData _getInstructorRoleIcon(String role) {
    switch (role) {
      case 'instructor':
        return Icons.person_pin;
      case 'co-instructor':
        return Icons.group;
      case 'assistant':
        return Icons.support_agent;
      default:
        return Icons.person;
    }
  }

  String _getInstructorRoleText(String role) {
    switch (role) {
      case 'instructor':
        return 'Ana Eğitmen';
      case 'co-instructor':
        return 'Yardımcı Eğitmen';
      case 'assistant':
        return 'Asistan';
      default:
        return role;
    }
  }

  String _getQuestionTypeText(String type) {
    switch (type) {
      case 'text':
        return 'Metin';
      case 'single_choice':
        return 'Tek Seçim';
      case 'multiple_choice':
        return 'Çoklu Seçim';
      default:
        return 'Bilinmeyen';
    }
  }

  Color _getQuestionTypeColor(String type) {
    switch (type) {
      case 'text':
        return Colors.blue;
      case 'single_choice':
        return Colors.green;
      case 'multiple_choice':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildMarkdownContent(
    String markdown,
    ThemeData theme,
    bool isMobile,
  ) {
    // Parse markdown to HTML
    final html = md.markdownToHtml(markdown);

    // Convert HTML to Flutter widgets
    return _parseHtmlToWidgets(html, theme, isMobile);
  }

  Widget _parseHtmlToWidgets(String html, ThemeData theme, bool isMobile) {
    // Simple HTML parsing for basic markdown features
    final lines = html.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      if (line.startsWith('<h1>')) {
        widgets.add(
          Text(
            line.replaceAll(RegExp(r'<[^>]*>'), ''),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: Colors.grey[800],
              letterSpacing: 0.5,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 12));
      } else if (line.startsWith('<h2>')) {
        widgets.add(
          Text(
            line.replaceAll(RegExp(r'<[^>]*>'), ''),
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              height: 1.3,
              color: Colors.grey[700],
              letterSpacing: 0.3,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 10));
      } else if (line.startsWith('<h3>')) {
        widgets.add(
          Text(
            line.replaceAll(RegExp(r'<[^>]*>'), ''),
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: Colors.grey[700],
              letterSpacing: 0.2,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 8));
      } else if (line.startsWith('<strong>') || line.startsWith('<b>')) {
        widgets.add(
          Text(
            line.replaceAll(RegExp(r'<[^>]*>'), ''),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: isMobile ? 15 : 17,
              fontWeight: FontWeight.bold,
              height: 1.6,
              color: Colors.grey[800],
              letterSpacing: 0.2,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 6));
      } else if (line.startsWith('<em>') || line.startsWith('<i>')) {
        widgets.add(
          Text(
            line.replaceAll(RegExp(r'<[^>]*>'), ''),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: isMobile ? 15 : 17,
              fontStyle: FontStyle.italic,
              height: 1.6,
              color: Colors.grey[700],
              letterSpacing: 0.1,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 6));
      } else if (line.startsWith('<code>')) {
        widgets.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              line.replaceAll(RegExp(r'<[^>]*>'), ''),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: isMobile ? 13 : 15,
                fontFamily: 'monospace',
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
        widgets.add(const SizedBox(height: 6));
      } else {
        // Regular paragraph
        widgets.add(
          Text(
            line.replaceAll(RegExp(r'<[^>]*>'), ''),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: isMobile ? 15 : 17,
              height: 1.7,
              color: Colors.grey[700],
              letterSpacing: 0.1,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 8));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
