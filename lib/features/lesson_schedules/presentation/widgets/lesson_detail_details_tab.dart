import 'package:flutter/material.dart';
import '../../domain/entities/lesson_schedule_with_package.dart';
import '../../domain/entities/lesson_schedule.dart';
import 'lesson_detail_info_card.dart';
import '../../../members/data/providers/members_providers.dart'
    as members_providers;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LessonDetailDetailsTab extends ConsumerWidget {
  final LessonScheduleWithPackage schedule;

  const LessonDetailDetailsTab({super.key, required this.schedule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Paket Bilgileri
          LessonDetailInfoCard(
            icon: Icons.school,
            title: 'Paket Bilgileri',
            children: [
              _buildInfoRow('Paket Adı:', schedule.packageName),
              _buildInfoRow(
                'Ders Sırası:',
                schedule.lessonNumber != null
                    ? '${schedule.lessonNumber}'
                    : 'Bilinmiyor',
              ),
              _buildInfoRow('Ders Sayısı:', '${schedule.packageLessonCount}'),
              _buildInfoRow(
                'Paket Başlangıç Tarihi:',
                _calculatePackageStartDate(schedule),
              ),
              _buildInfoRow(
                'Paket Durumu:',
                schedule.packageIsActive ? 'Aktif' : 'Pasif',
                valueColor: schedule.packageIsActive
                    ? Colors.green
                    : Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Ders Bilgileri
          LessonDetailInfoCard(
            icon: Icons.access_time,
            title: 'Ders Bilgileri',
            children: [
              _buildInfoRow('Ders Tarihi:', _getLessonDate(schedule)),
              _buildInfoRow('Gün:', _getDayName(schedule.dayOfWeek)),
              _buildInfoRow('Başlangıç Saati:', schedule.startTime),
              _buildInfoRow('Bitiş Saati:', schedule.endTime),
              _buildInfoRow(
                'Oluşturulma Tarihi:',
                _formatDate(schedule.createdAt),
              ),
              const Divider(height: 20),
              _buildInfoRow(
                'Ders Durumu:',
                _getStatusText(schedule.status),
                valueColor: _getStatusColor(schedule.status),
              ),
              if (schedule.actualDateDay != null &&
                  schedule.actualDateMonth != null &&
                  schedule.actualDateYear != null)
                _buildInfoRow(
                  'İşlem Tarihi:',
                  '${schedule.actualDateDay}/${schedule.actualDateMonth}/${schedule.actualDateYear}',
                ),
              // İşlemi yapan üye bilgisi - sadece completed durumunda
              _buildProcessedByInfo(ref),
            ],
          ),

          const SizedBox(height: 16),

          // Eğitmen Bilgileri
          if (schedule.instructorName != null ||
              schedule.attendeeIds.isNotEmpty) ...[
            LessonDetailInfoCard(
              icon: Icons.person,
              title: 'Eğitmen Bilgileri',
              children: [
                if (schedule.attendeeInstructors.isNotEmpty) ...[
                  _buildInfoRow(
                    'Eğitmen Sayısı:',
                    '${schedule.attendeeInstructors.length}',
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  ...schedule.attendeeInstructors.map(
                    (instructor) => _buildInstructorItem(instructor),
                  ),
                ] else if (schedule.attendeeIds.isNotEmpty) ...[
                  if (schedule.instructorName != null)
                    const SizedBox(height: 8),
                  _buildInfoRow(
                    'Katılımcı Eğitmenler:',
                    '${schedule.attendeeIds.length} eğitmen seçildi (detaylar yüklenemedi)',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Katılımcı Üyeler
          if (schedule.attendeeIds.isNotEmpty) ...[
            _buildAttendeeMembersCard(ref),
            const SizedBox(height: 16),
          ],

          // Üye Bilgileri
          if (schedule.memberName != null) ...[
            LessonDetailInfoCard(
              icon: Icons.people,
              title: 'Üye Bilgileri',
              children: [
                _buildInfoRow('Üye Adı:', schedule.memberName!),
                if (schedule.memberEmail != null)
                  _buildInfoRow('E-posta:', schedule.memberEmail!),
                if (schedule.memberPhone != null)
                  _buildInfoRow('Telefon:', schedule.memberPhone!),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Salon Bilgileri
          if (schedule.roomName != null) ...[
            LessonDetailInfoCard(
              icon: Icons.room,
              title: 'Salon Bilgileri',
              children: [
                _buildInfoRow('Salon Adı:', schedule.roomName!),
                if (schedule.roomCapacity != null)
                  _buildInfoRow('Kapasite:', '${schedule.roomCapacity}'),
                if (schedule.roomLocation != null)
                  _buildInfoRow('Konum:', schedule.roomLocation!),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  String _getStatusText(LessonStatus status) {
    switch (status) {
      case LessonStatus.scheduled:
        return 'Planlandı';
      case LessonStatus.completed:
        return 'İşlendi';
      case LessonStatus.missed:
        return 'İşlenmedi';
      case LessonStatus.rescheduled:
        return 'Yeniden Planlandı';
    }
  }

  Color _getStatusColor(LessonStatus status) {
    switch (status) {
      case LessonStatus.scheduled:
        return Colors.blue;
      case LessonStatus.completed:
        return Colors.green;
      case LessonStatus.missed:
        return Colors.red;
      case LessonStatus.rescheduled:
        return Colors.orange;
    }
  }

  Widget _buildProcessedByInfo(WidgetRef ref) {
    final currentMemberAsync = ref.watch(
      members_providers.currentMemberProvider,
    );

    return currentMemberAsync.when(
      data: (currentMember) {
        // Her durumda işlemi yapan kişiyi göster
        if (currentMember != null) {
          return _buildInfoRow(
            'İşlemi Yapan:',
            '${currentMember.firstName} ${currentMember.lastName}',
          );
        }
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calculatePackageStartDate(LessonScheduleWithPackage schedule) {
    // Actual date alanları varsa, bunları kullanarak paket başlangıç tarihini hesapla
    if (schedule.actualDateDay != null &&
        schedule.actualDateMonth != null &&
        schedule.actualDateYear != null &&
        schedule.lessonNumber != null) {
      final lessonDate = DateTime(
        schedule.actualDateYear!,
        schedule.actualDateMonth!,
        schedule.actualDateDay!,
      );

      // İlk ders (lessonNumber = 1) ise, bu tarih paket başlangıç tarihidir
      if (schedule.lessonNumber == 1) {
        return _formatDate(lessonDate);
      }

      // İlk ders değilse, geriye doğru hesapla
      // Haftalık ders günlerine göre geriye git
      final daysToSubtract =
          (schedule.lessonNumber! - 1) * 7; // Haftalık dersler için
      final packageStartDate = lessonDate.subtract(
        Duration(days: daysToSubtract),
      );

      return _formatDate(packageStartDate);
    }

    return 'Hesaplanamadı';
  }

  String _getDayName(String dayOfWeek) {
    const dayNames = {
      'monday': 'Pazartesi',
      'tuesday': 'Salı',
      'wednesday': 'Çarşamba',
      'thursday': 'Perşembe',
      'friday': 'Cuma',
      'saturday': 'Cumartesi',
      'sunday': 'Pazar',
    };
    return dayNames[dayOfWeek.toLowerCase()] ?? dayOfWeek;
  }

  String _getLessonDate(LessonScheduleWithPackage schedule) {
    // Actual date alanları varsa, bunları kullan
    if (schedule.actualDateDay != null &&
        schedule.actualDateMonth != null &&
        schedule.actualDateYear != null) {
      final lessonDate = DateTime(
        schedule.actualDateYear!,
        schedule.actualDateMonth!,
        schedule.actualDateDay!,
      );
      return _formatDate(lessonDate);
    }

    return 'Belirtilmemiş';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildAttendeeMembersCard(WidgetRef ref) {
    return LessonDetailInfoCard(
      icon: Icons.people,
      title: 'Katılımcı Üyeler',
      children: [
        _buildInfoRow('Katılımcı Sayısı:', '${schedule.attendeeIds.length}'),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        _buildAttendeeMembersList(ref),
      ],
    );
  }

  Widget _buildAttendeeMembersList(WidgetRef ref) {
    // Tüm üyeleri al
    final membersAsync = ref.watch(members_providers.membersProvider);
    final currentMemberAsync = ref.watch(
      members_providers.currentMemberProvider,
    );

    return membersAsync.when(
      data: (members) {
        // attendeeIds ile eşleşen üyeleri filtrele
        final attendeeMembers = members
            .where((member) => schedule.attendeeIds.contains(member.id))
            .toList();

        if (attendeeMembers.isEmpty) {
          return const Text(
            'Katılımcı üye bilgileri bulunamadı',
            style: TextStyle(color: Colors.grey),
          );
        }

        // Member rolü için filtreleme - sadece kendi bilgilerini göster
        final filteredMembers = currentMemberAsync.when(
          data: (currentMember) {
            if (currentMember?.roleName == 'Member') {
              // Member rolü: sadece kendi bilgilerini göster
              return attendeeMembers
                  .where((member) => member.id == currentMember?.id)
                  .toList();
            }
            // Admin/Instructor: tüm katılımcıları göster
            return attendeeMembers;
          },
          loading: () => attendeeMembers,
          error: (error, stack) => attendeeMembers,
        );

        return _AttendeeMembersList(members: filteredMembers);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Hata: $error'),
    );
  }

  Widget _buildInstructorItem(Map<String, dynamic> instructor) {
    final firstName = instructor['first_name'] as String? ?? '';
    final lastName = instructor['last_name'] as String? ?? '';
    final specialization = instructor['specialization'] as String?;
    final experience = instructor['instructor_experience'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eğitmen Adı
          Row(
            children: [
              Icon(Icons.person, size: 20, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                '$firstName $lastName',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Uzmanlık Alanı
          if (specialization != null && specialization.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.school, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Uzmanlık: $specialization',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Deneyim
          if (experience != null && experience.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.work, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Deneyim: $experience',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AttendeeMembersList extends StatefulWidget {
  final List<dynamic> members;

  const _AttendeeMembersList({required this.members});

  @override
  State<_AttendeeMembersList> createState() => _AttendeeMembersListState();
}

class _AttendeeMembersListState extends State<_AttendeeMembersList> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredMembers = [];

  @override
  void initState() {
    super.initState();
    _filteredMembers = widget.members;
    _searchController.addListener(_filterMembers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMembers() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredMembers = widget.members.where((member) {
        final firstName = member.firstName?.toLowerCase() ?? '';
        final lastName = member.lastName?.toLowerCase() ?? '';
        final email = member.email?.toLowerCase() ?? '';
        return firstName.contains(query) ||
            lastName.contains(query) ||
            email.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Arama çubuğu
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Üye ara...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Üye listesi
        if (_filteredMembers.isEmpty)
          const Text(
            'Arama kriterlerine uygun üye bulunamadı',
            style: TextStyle(color: Colors.grey),
          )
        else
          ..._filteredMembers.map((member) => _buildMemberItem(member)),
      ],
    );
  }

  Widget _buildMemberItem(dynamic member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üye Adı
          Row(
            children: [
              Icon(Icons.person, size: 20, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                '${member.firstName ?? ''} ${member.lastName ?? ''}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // E-posta
          if (member.email != null && member.email.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.email, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'E-posta: ${member.email}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Telefon
          if (member.phone != null && member.phone.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Telefon: ${member.phone}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
