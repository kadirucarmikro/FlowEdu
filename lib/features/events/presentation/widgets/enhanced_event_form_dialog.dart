import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/event.dart';
import '../providers/events_providers.dart';
import 'rich_text_editor.dart';
import 'media_upload_widget.dart';
import 'member_selection_dialog.dart';
import 'question_form_dialog.dart';
import '../../../members/domain/entities/member.dart';

class EnhancedEventFormDialog extends ConsumerStatefulWidget {
  const EnhancedEventFormDialog({super.key, this.event, required this.onSave});

  final Event? event;
  final Function(Map<String, dynamic>) onSave;

  @override
  ConsumerState<EnhancedEventFormDialog> createState() =>
      _EnhancedEventFormDialogState();
}

class _EnhancedEventFormDialogState
    extends ConsumerState<EnhancedEventFormDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _richDescriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _maxParticipantsController = TextEditingController();

  late TabController _tabController;

  EventType _selectedType = EventType.normal;
  EventResponseType _selectedResponseType = EventResponseType.text;
  bool _isMultipleChoice = false;
  bool _isActive = true;
  DateTime? _startAt;
  DateTime? _endAt;
  DateTime? _registrationDeadline;
  int? _maxParticipants;

  final List<TextEditingController> _optionControllers = [];
  final List<EventQuestion> _questions = [];
  final List<EventOrganizer> _organizers = [];
  final List<EventInstructor> _instructors = [];
  final List<EventMedia> _media = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    // Form'u initState'de initialize et
    if (widget.event != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initializeForm();
        }
      });
    }
  }

  void _initializeForm() {
    final event = widget.event!;

    // Form'u temizle ve yeniden doldur
    _titleController.clear();
    _descriptionController.clear();
    _richDescriptionController.clear();
    _locationController.clear();
    _imageUrlController.clear();
    _maxParticipantsController.clear();

    // Event verilerini form'a doldur
    _titleController.text = event.title;
    _descriptionController.text = event.description ?? '';
    _richDescriptionController.text = event.richDescription ?? '';
    _locationController.text = event.location ?? '';
    _imageUrlController.text = event.imageUrl ?? '';

    _selectedType = event.type;
    _selectedResponseType = event.responseType;
    _isMultipleChoice = event.isMultipleChoice;
    _isActive = event.isActive;
    _startAt = event.startAt;
    _endAt = event.endAt;
    _registrationDeadline = event.registrationDeadline;
    _maxParticipants = event.maxParticipants;
    _maxParticipantsController.text = _maxParticipants?.toString() ?? '';

    // setState çağrısı ekle
    setState(() {});

    // Initialize questions
    _questions.clear();
    _questions.addAll(event.questions);

    // Initialize organizers and instructors
    _organizers.clear();
    _organizers.addAll(event.organizers);
    _instructors.clear();
    _instructors.addAll(event.instructors);

    // Initialize media
    _media.clear();
    _media.addAll(event.media);

    // Force UI update for RichTextEditor
    setState(() {});

    // Initialize option controllers
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    _optionControllers.clear();
    for (final option in event.options) {
      _optionControllers.add(TextEditingController(text: option.optionText));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _richDescriptionController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    _maxParticipantsController.dispose();
    _tabController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Form'u build'de de kontrol et
    if (widget.event != null &&
        _locationController.text.isEmpty &&
        _maxParticipantsController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeForm();
      });
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 768;

    return Dialog(
      child: Container(
        width: isMobile ? screenWidth * 0.98 : screenWidth * 0.95,
        height: isMobile ? screenHeight * 0.95 : screenHeight * 0.9,
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 1200,
          maxHeight: isMobile ? double.infinity : 800,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event,
                    color: Theme.of(context).primaryColor,
                    size: isMobile ? 20 : 24,
                  ),
                  SizedBox(width: isMobile ? 8 : 12),
                  Expanded(
                    child: Text(
                      widget.event == null
                          ? 'Yeni Etkinlik Oluştur'
                          : 'Etkinlik Düzenle',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 16 : 20,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, size: isMobile ? 20 : 24),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: isMobile,
                tabAlignment: isMobile
                    ? TabAlignment.start
                    : TabAlignment.center,
                labelPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 16,
                  vertical: isMobile ? 4 : 8,
                ),
                tabs: [
                  Tab(
                    icon: Icon(Icons.info, size: isMobile ? 16 : 20),
                    text: isMobile ? 'Genel' : 'Genel Bilgiler',
                  ),
                  Tab(
                    icon: Icon(Icons.schedule, size: isMobile ? 16 : 20),
                    text: isMobile ? 'Tarih' : 'Tarih & Saat',
                  ),
                  Tab(
                    icon: Icon(Icons.people, size: isMobile ? 16 : 20),
                    text: isMobile ? 'Organizatör' : 'Organizatörler',
                  ),
                  Tab(
                    icon: Icon(Icons.school, size: isMobile ? 16 : 20),
                    text: isMobile ? 'Eğitmen' : 'Eğitmenler',
                  ),
                  Tab(
                    icon: Icon(Icons.quiz, size: isMobile ? 16 : 20),
                    text: isMobile ? 'Soru' : 'Sorular',
                  ),
                  Tab(
                    icon: Icon(Icons.attach_file, size: isMobile ? 16 : 20),
                    text: isMobile ? 'Medya' : 'Medya',
                  ),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGeneralInfoTab(),
                    _buildDateTimeTab(),
                    _buildOrganizersTab(),
                    _buildInstructorsTab(),
                    _buildQuestionsTab(),
                    _buildMediaTab(),
                  ],
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: isMobile
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveEvent,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: Text(
                              _isSaving
                                  ? 'Kaydediliyor...'
                                  : (widget.event == null
                                        ? 'Oluştur'
                                        : 'Güncelle'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: _isSaving
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: const Text('İptal'),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _isSaving
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('İptal'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveEvent,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            _isSaving
                                ? 'Kaydediliyor...'
                                : (widget.event == null
                                      ? 'Oluştur'
                                      : 'Güncelle'),
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

  Widget _buildGeneralInfoTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Etkinlik Başlığı *',
              hintText: 'Etkinlik başlığını girin',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Etkinlik başlığı zorunludur';
              }
              return null;
            },
          ),
          SizedBox(height: isMobile ? 12 : 16),

          // Kısa Açıklama
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Kısa Açıklama *',
              hintText: 'Etkinlik hakkında kısa açıklama',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: isMobile ? 2 : 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Kısa açıklama zorunludur';
              }
              return null;
            },
          ),
          SizedBox(height: isMobile ? 12 : 16),

          // Zengin Açıklama
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detaylı Açıklama',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: isMobile ? 6 : 8),
              RichTextEditor(
                key: ValueKey(
                  'rich_description_${widget.event?.id ?? 'new'}_${_richDescriptionController.text.length}_${_richDescriptionController.text.hashCode}_${DateTime.now().millisecondsSinceEpoch}',
                ),
                initialValue: _richDescriptionController.text,
                onChanged: (value) {
                  _richDescriptionController.text = value;
                },
                height: isMobile ? 150 : 200,
                hintText: 'Etkinlik hakkında detaylı açıklama yazın...',
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),

          // Etkinlik Yeri
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Etkinlik Yeri *',
              hintText: 'Etkinlik yapılacak yer',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Etkinlik yeri zorunludur';
              }
              return null;
            },
          ),
          SizedBox(height: isMobile ? 12 : 16),

          // Resim Seçimi ve URL
          Card(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.image,
                        color: Colors.blue,
                        size: isMobile ? 18 : 20,
                      ),
                      SizedBox(width: isMobile ? 6 : 8),
                      Text(
                        'Etkinlik Resmi',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 12 : 16),

                  // Resim önizleme
                  if (_imageUrlController.text.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      height: isMobile ? 150 : 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildEventImagePreview(
                          _imageUrlController.text,
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                  ],

                  // Resim seçme butonları
                  isMobile
                      ? Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _selectImageFromDevice,
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Cihazdan Seç'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _clearImage,
                                icon: const Icon(Icons.clear),
                                label: const Text('Temizle'),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _selectImageFromDevice,
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Cihazdan Seç'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _clearImage,
                                icon: const Icon(Icons.clear),
                                label: const Text('Temizle'),
                              ),
                            ),
                          ],
                        ),
                  SizedBox(height: isMobile ? 12 : 16),

                  // URL girişi
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Resim URL (Opsiyonel)',
                      hintText: 'Manuel URL girişi',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                    onChanged: (value) {
                      setState(() {
                        // URL değiştiğinde önizlemeyi güncelle
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),

          // Aktif Durumu
          SwitchListTile(
            title: Text(
              'Aktif',
              style: TextStyle(fontSize: isMobile ? 14 : 16),
            ),
            subtitle: Text(
              'Etkinlik aktif durumda',
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlangıç Tarihi
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('Başlangıç Tarihi'),
            subtitle: Text(
              _startAt != null ? _formatDateTime(_startAt!) : 'Seçilmedi',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startAt ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(
                      _startAt ?? DateTime.now(),
                    ),
                  );
                  if (time != null) {
                    setState(() {
                      _startAt = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
            ),
          ),
          const Divider(),

          // Bitiş Tarihi
          ListTile(
            leading: const Icon(Icons.stop),
            title: const Text('Bitiş Tarihi'),
            subtitle: Text(
              _endAt != null ? _formatDateTime(_endAt!) : 'Seçilmedi',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endAt ?? (_startAt ?? DateTime.now()),
                  firstDate: _startAt ?? DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(
                      _endAt ?? DateTime.now(),
                    ),
                  );
                  if (time != null) {
                    setState(() {
                      _endAt = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
            ),
          ),
          const Divider(),

          // Kayıt Son Tarihi
          ListTile(
            leading: const Icon(Icons.event_available),
            title: const Text('Kayıt Son Tarihi'),
            subtitle: Text(
              _registrationDeadline != null
                  ? _formatDateTime(_registrationDeadline!)
                  : 'Seçilmedi',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                // Kayıt son tarihi için daha esnek tarih seçimi
                // Bugünden başlayarak yeterince ileri bir tarihe kadar seçebilsin
                final now = DateTime.now();
                final startDate = _startAt;

                // Eğer etkinlik başlangıç tarihi yoksa veya çok yakınsa, daha ileri bir tarih ver
                final lastDate =
                    startDate != null &&
                        startDate.isAfter(now.add(const Duration(days: 30)))
                    ? startDate
                    : now.add(const Duration(days: 365));

                final date = await showDatePicker(
                  context: context,
                  initialDate: _registrationDeadline ?? now,
                  firstDate: now,
                  lastDate: lastDate,
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(
                      _registrationDeadline ?? DateTime.now(),
                    ),
                  );
                  if (time != null) {
                    setState(() {
                      _registrationDeadline = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
            ),
          ),
          const Divider(),

          // Maksimum Katılımcı
          TextFormField(
            controller: _maxParticipantsController,
            decoration: const InputDecoration(
              labelText: 'Maksimum Katılımcı Sayısı',
              hintText: 'Boş bırakırsanız sınırsız olur',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.people),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _maxParticipants = int.tryParse(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizersTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Etkinlik Organizatörleri',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addOrganizer,
                        icon: const Icon(Icons.add),
                        label: const Text('Organizatör Ekle'),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Etkinlik Organizatörleri',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    ElevatedButton.icon(
                      onPressed: _addOrganizer,
                      icon: const Icon(Icons.add),
                      label: const Text('Organizatör Ekle'),
                    ),
                  ],
                ),
          SizedBox(height: isMobile ? 12 : 16),

          if (_organizers.isEmpty)
            const Center(child: Text('Henüz organizatör eklenmemiş'))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _organizers.length,
              itemBuilder: (context, index) {
                final organizer = _organizers[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(organizer.memberName ?? 'Bilinmeyen'),
                    subtitle: Text(organizer.role),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeOrganizer(index),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInstructorsTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Etkinlik Eğitmenleri',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addInstructor,
                        icon: const Icon(Icons.add),
                        label: const Text('Eğitmen Ekle'),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Etkinlik Eğitmenleri',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    ElevatedButton.icon(
                      onPressed: _addInstructor,
                      icon: const Icon(Icons.add),
                      label: const Text('Eğitmen Ekle'),
                    ),
                  ],
                ),
          SizedBox(height: isMobile ? 12 : 16),

          if (_instructors.isEmpty)
            const Center(child: Text('Henüz eğitmen eklenmemiş'))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _instructors.length,
              itemBuilder: (context, index) {
                final instructor = _instructors[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.school),
                    title: Text(instructor.memberName ?? 'Bilinmeyen'),
                    subtitle: Text(instructor.role),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeInstructor(index),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionsTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Etkinlik Soruları',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addQuestion,
                        icon: const Icon(Icons.add),
                        label: const Text('Soru Ekle'),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Etkinlik Soruları',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    ElevatedButton.icon(
                      onPressed: _addQuestion,
                      icon: const Icon(Icons.add),
                      label: const Text('Soru Ekle'),
                    ),
                  ],
                ),
          SizedBox(height: isMobile ? 12 : 16),

          if (_questions.isEmpty)
            const Center(child: Text('Henüz soru eklenmemiş'))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final question = _questions[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.quiz),
                    title: Text(question.questionText),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${question.questionType} - ${question.isRequired ? 'Zorunlu' : 'İsteğe Bağlı'}',
                        ),
                        if (question.options.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Seçenekler: ${question.options.map((o) => o.optionText).join(', ')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                    onTap: () => _editQuestion(index),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editQuestion(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeQuestion(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMediaTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mevcut medya dosyalarını göster
          if (_media.isNotEmpty) ...[
            Text(
              'Mevcut Medya Dosyaları',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: isMobile ? 18 : 20),
            ),
            SizedBox(height: isMobile ? 12 : 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _media.length,
              itemBuilder: (context, index) {
                final media = _media[index];
                return Card(
                  child: ListTile(
                    leading: _getMediaIcon(media.fileType),
                    title: Text(media.fileName),
                    subtitle: Text(
                      '${media.fileType} - ${_formatFileSize(media.fileSize ?? 0)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeMedia(index),
                    ),
                    onTap: () => _previewMedia(media),
                  ),
                );
              },
            ),
            SizedBox(height: isMobile ? 16 : 24),
          ],

          // Yeni medya dosyası ekleme
          MediaUploadWidget(
            onMediaSelected: (files) async {
              setState(() {
                _media.clear();
              });

              // Upload files to Supabase Storage
              for (final file in files) {
                try {
                  String fileUrl;

                  if (file.bytes != null) {
                    // Upload to Supabase Storage
                    final eventsRepository = ref.read(eventsRepositoryProvider);
                    fileUrl = await eventsRepository.uploadFileToStorage(
                      fileName: file.name,
                      fileBytes: file.bytes!,
                      fileType: file.type,
                    );
                  } else {
                    // Fallback to local path
                    fileUrl = file.path;
                  }

                  setState(() {
                    _media.add(
                      EventMedia(
                        id: '', // Will be generated by database
                        eventId: '', // Will be set when saving
                        fileName: file.name,
                        fileUrl: fileUrl,
                        fileType: file.type,
                        fileSize: file.size,
                        uploadedBy: null, // Will be set by current user
                        createdAt: DateTime.now(),
                      ),
                    );
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Dosya yüklenirken hata: ${file.name}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            maxFiles: 10,
            allowedTypes: const ['image', 'video', 'audio', 'document'],
          ),
        ],
      ),
    );
  }

  void _addOrganizer() {
    showDialog(
      context: context,
      builder: (context) => MemberSelectionDialog(
        title: 'Organizatör Seç',
        onMembersSelected: (members) {
          setState(() {
            for (final member in members) {
              _organizers.add(
                EventOrganizer(
                  id: '', // Will be generated by database
                  eventId: '', // Will be set when saving
                  memberId: member.id,
                  role: 'organizer',
                  createdAt: DateTime.now(),
                  memberName: '${member.firstName} ${member.lastName}',
                ),
              );
            }
          });
        },
        selectedMembers: _organizers
            .map(
              (o) => Member(
                id: o.memberId,
                userId: '',
                roleId: '',
                groupId: '',
                firstName: o.memberName?.split(' ').first ?? '',
                lastName: o.memberName?.split(' ').last ?? '',
                phone: '',
                email: '',
                birthDate: null,
                isSuspended: false,
                createdAt: DateTime.now(),
              ),
            )
            .toList(),
        multipleSelection: true,
      ),
    );
  }

  void _removeOrganizer(int index) {
    setState(() {
      _organizers.removeAt(index);
    });
  }

  void _addInstructor() {
    showDialog(
      context: context,
      builder: (context) => MemberSelectionDialog(
        title: 'Eğitmen Seç',
        onMembersSelected: (members) {
          setState(() {
            for (final member in members) {
              _instructors.add(
                EventInstructor(
                  id: '', // Will be generated by database
                  eventId: '', // Will be set when saving
                  memberId: member.id,
                  role: 'instructor',
                  createdAt: DateTime.now(),
                  memberName: '${member.firstName} ${member.lastName}',
                ),
              );
            }
          });
        },
        selectedMembers: _instructors
            .map(
              (i) => Member(
                id: i.memberId,
                userId: '',
                roleId: '',
                groupId: '',
                firstName: i.memberName?.split(' ').first ?? '',
                lastName: i.memberName?.split(' ').last ?? '',
                phone: '',
                email: '',
                birthDate: null,
                isSuspended: false,
                createdAt: DateTime.now(),
              ),
            )
            .toList(),
        multipleSelection: true,
      ),
    );
  }

  void _removeInstructor(int index) {
    setState(() {
      _instructors.removeAt(index);
    });
  }

  void _addQuestion() {
    showDialog(
      context: context,
      builder: (context) => QuestionFormDialog(
        onSave: (question) {
          setState(() {
            _questions.add(question);
          });
        },
      ),
    );
  }

  void _editQuestion(int index) {
    showDialog(
      context: context,
      builder: (context) => QuestionFormDialog(
        question: _questions[index],
        onSave: (question) {
          setState(() {
            _questions[index] = question;
          });
        },
      ),
    );
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _removeMedia(int index) {
    setState(() {
      _media.removeAt(index);
    });
  }

  Widget _getMediaIcon(String fileType) {
    switch (fileType) {
      case 'image':
        return const Icon(Icons.image, color: Colors.blue);
      case 'video':
        return const Icon(Icons.video_file, color: Colors.red);
      case 'audio':
        return const Icon(Icons.audio_file, color: Colors.green);
      case 'document':
        return const Icon(Icons.description, color: Colors.orange);
      default:
        return const Icon(Icons.attach_file, color: Colors.grey);
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Resim seçme ve yönetimi
  void _selectImageFromDevice() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Web platformunda bytes kullan
        if (file.bytes != null) {
          // Web platformunda bytes'ı base64'e çevir
          final base64String = base64Encode(file.bytes!);
          final dataUrl = 'data:image/${file.extension};base64,$base64String';

          setState(() {
            _imageUrlController.text = dataUrl;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Resim seçildi: ${file.name}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else if (file.path != null) {
          // Diğer platformlarda path kullan
          setState(() {
            _imageUrlController.text = file.path!;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Resim seçildi: ${file.name}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resim seçilirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearImage() {
    setState(() {
      _imageUrlController.clear();
    });
  }

  Widget _buildEventImagePreview(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey.shade100,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('Resim önizleme', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    // Data URL (base64) kontrolü
    if (imageUrl.startsWith('data:image/')) {
      try {
        final base64String = imageUrl.split(',')[1];
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
    }

    // Network URL kontrolü
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
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
    }

    // Local file path
    return Image.file(
      File(imageUrl),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildImageError();
      },
    );
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.grey.shade100,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 48, color: Colors.red),
            SizedBox(height: 8),
            Text('Resim yüklenemedi', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  void _previewMedia(EventMedia media) {
    if (media.fileType == 'image') {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          media.fileName,
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _buildMediaImagePreview(media)),
              ],
            ),
          ),
        ),
      );
    } else {
      // Diğer dosya türleri için bilgi göster
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(media.fileName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dosya Türü: ${media.fileType}'),
              Text('Dosya Boyutu: ${_formatFileSize(media.fileSize ?? 0)}'),
              Text('URL: ${media.fileUrl}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildMediaImagePreview(EventMedia media) {
    // Web platformunda blob URL ise bytes kullan, değilse network kullan
    if (media.fileUrl.startsWith('blob:') ||
        media.fileUrl.startsWith('web_file_') ||
        media.fileUrl.isEmpty ||
        !media.fileUrl.startsWith('http')) {
      // Bu durumda bytes kullanılamaz, sadece bilgi göster
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text('Resim: ${media.fileName}'),
            const SizedBox(height: 8),
            Text('Dosya türü: ${media.fileType}'),
            const SizedBox(height: 8),
            Text('Boyut: ${_formatFileSize(media.fileSize ?? 0)}'),
            const SizedBox(height: 8),
            Text('URL: ${media.fileUrl.isEmpty ? "Boş" : media.fileUrl}'),
            const SizedBox(height: 16),
            const Text(
              'Resim başarıyla seçildi ve kaydedilecek.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.green),
            ),
          ],
        ),
      );
    } else {
      // Network URL ise normal yükleme
      return Image.network(
        media.fileUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
                const SizedBox(height: 16),
                const Text('Resim yükleniyor...'),
              ],
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Resim yüklenemedi: $error'),
                const SizedBox(height: 8),
                Text('URL: ${media.fileUrl}'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Kapat'),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void _saveEvent() async {
    // Özel validasyon kurallarını kontrol et
    if (!_validateForm()) {
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        // Event data'yı hazırla
        final eventData = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'rich_description': _richDescriptionController.text,
          'location': _locationController.text,
          'image_url': _imageUrlController.text,
          'type': _selectedType.value,
          'response_type': _selectedResponseType.value,
          'is_multiple_choice': _isMultipleChoice,
          'is_active': _isActive,
          'start_at': _startAt?.toIso8601String(),
          'end_at': _endAt?.toIso8601String(),
          'registration_deadline': _registrationDeadline?.toIso8601String(),
          'max_participants': _maxParticipants,
          'organizers': _organizers
              .map((o) => {'member_id': o.memberId, 'role': o.role})
              .toList(),
          'instructors': _instructors
              .map((i) => {'member_id': i.memberId, 'role': i.role})
              .toList(),
          'questions': _questions
              .map(
                (q) => {
                  'question_text': q.questionText,
                  'question_type': q.questionType,
                  'is_required': q.isRequired,
                  'sort_order': q.sortOrder,
                  'options': q.options
                      .map(
                        (o) => {
                          'option_text': o.optionText,
                          'sort_order': o.sortOrder,
                        },
                      )
                      .toList(),
                },
              )
              .toList(),
          'media': _media
              .map(
                (m) => {
                  'file_name': m.fileName,
                  'file_url': m.fileUrl,
                  'file_type': m.fileType,
                  'file_size': m.fileSize,
                  'uploaded_by': m.uploadedBy,
                },
              )
              .toList(),
        };

        // Event'i kaydet
        await widget.onSave(eventData);
        // Dialog'u kapatma işlemi parent widget'ta yapılacak
      } catch (e) {
        // Hata durumunda kullanıcıya bilgi ver
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Hata: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  bool _validateForm() {
    final List<String> errors = [];

    // 1. Etkinlik başlığı kontrolü
    if (_titleController.text.trim().isEmpty) {
      errors.add('• Etkinlik başlığı zorunludur');
    }

    // 2. Kısa açıklama kontrolü
    if (_descriptionController.text.trim().isEmpty) {
      errors.add('• Kısa açıklama zorunludur');
    }

    // 3. Etkinlik yeri kontrolü
    if (_locationController.text.trim().isEmpty) {
      errors.add('• Etkinlik yeri zorunludur');
    }

    // 4. Başlangıç tarihi kontrolü
    if (_startAt == null) {
      errors.add('• Başlangıç tarihi zorunludur');
    }

    // 5. Bitiş tarihi kontrolü
    if (_endAt == null) {
      errors.add('• Bitiş tarihi zorunludur');
    }

    // 6. Kayıt son tarihi kontrolü
    if (_registrationDeadline == null) {
      errors.add('• Kayıt son tarihi zorunludur');
    }

    // 7. En az bir organizatör kontrolü
    if (_organizers.isEmpty) {
      errors.add('• En az bir organizatör eklenmelidir');
    }

    // 8. En az bir eğitmen kontrolü
    if (_instructors.isEmpty) {
      errors.add('• En az bir eğitmen eklenmelidir');
    }

    // 9. Tarih mantığı kontrolü
    if (_startAt != null && _endAt != null && _startAt!.isAfter(_endAt!)) {
      errors.add('• Başlangıç tarihi bitiş tarihinden sonra olamaz');
    }

    if (_startAt != null &&
        _registrationDeadline != null &&
        _startAt!.isAfter(_registrationDeadline!)) {
      errors.add('• Kayıt son tarihi başlangıç tarihinden sonra olmalıdır');
    }

    if (_endAt != null &&
        _registrationDeadline != null &&
        _endAt!.isBefore(_registrationDeadline!)) {
      errors.add('• Kayıt son tarihi bitiş tarihinden önce olmalıdır');
    }

    // Hata varsa kullanıcıya göster
    if (errors.isNotEmpty) {
      _showValidationErrors(errors);
      return false;
    }

    return true;
  }

  void _showValidationErrors(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Eksik Bilgiler'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lütfen aşağıdaki alanları doldurun:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ...errors.map(
              (error) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(error, style: TextStyle(color: Colors.red[700])),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
