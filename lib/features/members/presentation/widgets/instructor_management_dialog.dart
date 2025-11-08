import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/member.dart';
import '../../data/providers/members_providers.dart';

class InstructorManagementDialog extends ConsumerStatefulWidget {
  const InstructorManagementDialog({super.key});

  @override
  ConsumerState<InstructorManagementDialog> createState() =>
      _InstructorManagementDialogState();
}

class _InstructorManagementDialogState
    extends ConsumerState<InstructorManagementDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          children: [
            // Başlık ve kapatma butonu
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.school, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Eğitmen Yönetimi',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Ana içerik
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Üst butonlar
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showAddInstructorDialog(context),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Yeni Eğitmen Ekle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Eğitmenleri yönetin, ekleyin, düzenleyin veya silin',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Eğitmen listesi
                    Consumer(
                      builder: (context, ref, child) {
                        final instructorsAsync = ref.watch(
                          instructorMembersProvider,
                        );

                        return instructorsAsync.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, stack) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error,
                                  size: 48,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Hata: $error',
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () =>
                                      ref.invalidate(instructorMembersProvider),
                                  child: const Text('Tekrar Dene'),
                                ),
                              ],
                            ),
                          ),
                          data: (instructors) {
                            if (instructors.isEmpty) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.school,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Henüz eğitmen eklenmemiş',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return RefreshIndicator(
                              onRefresh: () async {
                                ref.invalidate(instructorMembersProvider);
                              },
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: instructors.length,
                                itemBuilder: (context, index) {
                                  final instructor = instructors[index];
                                  return _buildInstructorListItem(
                                    context,
                                    instructor,
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructorListItem(BuildContext context, Member instructor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Text(
            instructor.firstName[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          instructor.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(instructor.email),
            if (instructor.specialization != null)
              Text(
                'Uzmanlık: ${instructor.specialization}',
                style: TextStyle(color: Colors.green[700], fontSize: 12),
              ),
            if (instructor.instructorBio != null)
              Text(
                instructor.instructorBio!,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditInstructorDialog(context, instructor);
                break;
              case 'delete':
                _showDeleteInstructorDialog(context, instructor);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Düzenle'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Sil', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddInstructorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _InstructorFormDialog(
        title: 'Yeni Eğitmen Ekle',
        onSave: (instructor) async {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Eğitmen eklendi!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _showEditInstructorDialog(BuildContext context, Member instructor) {
    showDialog(
      context: context,
      builder: (context) => _InstructorFormDialog(
        title: 'Eğitmen Düzenle',
        instructor: instructor,
        onSave: (updatedInstructor) async {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Eğitmen güncellendi!'),
              backgroundColor: Colors.blue,
            ),
          );
        },
      ),
    );
  }

  void _showDeleteInstructorDialog(BuildContext context, Member instructor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eğitmeni Sil'),
        content: Text(
          '${instructor.fullName} eğitmenini silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Eğitmen silindi!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

class _InstructorFormDialog extends ConsumerStatefulWidget {
  final String title;
  final Member? instructor;
  final Function(Member) onSave;

  const _InstructorFormDialog({
    required this.title,
    this.instructor,
    required this.onSave,
  });

  @override
  ConsumerState<_InstructorFormDialog> createState() =>
      _InstructorFormDialogState();
}

class _InstructorFormDialogState extends ConsumerState<_InstructorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specializationController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.instructor != null) {
      _firstNameController.text = widget.instructor!.firstName;
      _lastNameController.text = widget.instructor!.lastName;
      _emailController.text = widget.instructor!.email;
      _phoneController.text = widget.instructor!.phone ?? '';
      _specializationController.text = widget.instructor!.specialization ?? '';
      _bioController.text = widget.instructor!.instructorBio ?? '';
      _experienceController.text =
          widget.instructor!.instructorExperience ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Başlık
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.school, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Form içeriği
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kişisel Bilgiler
                      _buildSectionTitle('Kişisel Bilgiler'),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'Ad *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ad gereklidir';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Soyad *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Soyad gereklidir';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'E-posta *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'E-posta gereklidir';
                          }
                          if (!value.contains('@')) {
                            return 'Geçerli bir e-posta adresi giriniz';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telefon',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 24),

                      // Eğitmen Bilgileri
                      _buildSectionTitle('Eğitmen Bilgileri'),
                      TextFormField(
                        controller: _specializationController,
                        decoration: const InputDecoration(
                          labelText: 'Uzmanlık Alanı *',
                          border: OutlineInputBorder(),
                          hintText: 'Örn: Tango Dansı, Matematik, Fizik',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Uzmanlık alanı gereklidir';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(
                          labelText: 'Biyografi',
                          border: OutlineInputBorder(),
                          hintText: 'Eğitmen hakkında kısa bilgi',
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _experienceController,
                        decoration: const InputDecoration(
                          labelText: 'Deneyim',
                          border: OutlineInputBorder(),
                          hintText: 'Eğitmen deneyimi ve başarıları',
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Alt butonlar
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('İptal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _saveInstructor,
                      child: const Text('Kaydet'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  void _saveInstructor() {
    if (_formKey.currentState!.validate()) {
      final instructor = Member(
        id: widget.instructor?.id ?? '',
        userId: widget.instructor?.userId ?? '',
        roleId: widget.instructor?.roleId ?? '',
        groupId: widget.instructor?.groupId,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        birthDate: widget.instructor?.birthDate,
        isSuspended: false,
        isInstructor: true,
        specialization: _specializationController.text,
        instructorBio: _bioController.text.isEmpty ? null : _bioController.text,
        instructorExperience: _experienceController.text.isEmpty
            ? null
            : _experienceController.text,
        createdAt: widget.instructor?.createdAt ?? DateTime.now(),
      );

      widget.onSave(instructor);
    }
  }
}
