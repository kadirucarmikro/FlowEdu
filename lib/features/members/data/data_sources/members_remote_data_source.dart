import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/member.dart';

class MembersRemoteDataSource {
  final SupabaseClient _supabase;

  MembersRemoteDataSource({required SupabaseClient supabase})
    : _supabase = supabase;

  Future<List<Member>> getMembers() async {
    try {
      final response = await _supabase
          .from('members')
          .select('''
            id,
            user_id,
            role_id,
            group_id,
            first_name,
            last_name,
            phone,
            email,
            birth_date,
            is_suspended,
            is_instructor,
            specialization,
            instructor_bio,
            instructor_experience,
            created_at
          ''')
          .order('first_name', ascending: true);

      return response.map<Member>((json) => Member.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Üyeler getirilemedi: $e');
    }
  }

  Future<Member> getMemberById(String id) async {
    try {
      final response = await _supabase
          .from('members')
          .select('''
            id,
            user_id,
            role_id,
            group_id,
            first_name,
            last_name,
            phone,
            email,
            birth_date,
            is_suspended,
            is_instructor,
            specialization,
            instructor_bio,
            instructor_experience,
            created_at
          ''')
          .eq('id', id)
          .single();

      return Member.fromJson(response);
    } catch (e) {
      throw Exception('Üye getirilemedi: $e');
    }
  }

  Future<Member> createMember(Member member) async {
    try {
      // Önce Supabase Auth ile user oluştur
      final authResponse = await _supabase.auth.signUp(
        email: member.email,
        password: member.password ?? 'password123', // Form'dan alınan şifre
      );

      if (authResponse.user == null) {
        throw Exception('Kullanıcı oluşturulamadı');
      }

      // Sonra member kaydı oluştur
      final memberData = {
        'user_id': authResponse.user!.id,
        'role_id': member.roleId,
        'group_id': member.groupId,
        'first_name': member.firstName,
        'last_name': member.lastName,
        'phone': member.phone,
        'email': member.email,
        'birth_date': member.birthDate?.toIso8601String(),
        'is_suspended': member.isSuspended,
        'is_instructor': member.isInstructor,
        'specialization': member.specialization,
        'instructor_bio': member.instructorBio,
        'instructor_experience': member.instructorExperience,
      };

      final response = await _supabase
          .from('members')
          .insert(memberData)
          .select('''
            id,
            user_id,
            role_id,
            group_id,
            first_name,
            last_name,
            phone,
            email,
            birth_date,
            is_suspended,
            is_instructor,
            specialization,
            instructor_bio,
            instructor_experience,
            created_at
          ''')
          .single();

      return Member.fromJson(response);
    } catch (e) {
      throw Exception('Üye oluşturulamadı: $e');
    }
  }

  Future<Member> updateMember(Member member) async {
    try {
      final response = await _supabase
          .from('members')
          .update(member.toJson())
          .eq('id', member.id)
          .select('''
            id,
            user_id,
            role_id,
            group_id,
            first_name,
            last_name,
            phone,
            email,
            birth_date,
            is_suspended,
            is_instructor,
            specialization,
            instructor_bio,
            instructor_experience,
            created_at
          ''')
          .single();

      return Member.fromJson(response);
    } catch (e) {
      throw Exception('Üye güncellenemedi: $e');
    }
  }

  Future<void> deleteMember(String id) async {
    try {
      await _supabase.from('members').delete().eq('id', id);
    } catch (e) {
      throw Exception('Üye silinemedi: $e');
    }
  }

  Future<List<Member>> getActiveMembers() async {
    try {
      final response = await _supabase
          .from('members')
          .select('''
            id,
            user_id,
            role_id,
            group_id,
            first_name,
            last_name,
            phone,
            email,
            birth_date,
            is_suspended,
            is_instructor,
            specialization,
            instructor_bio,
            instructor_experience,
            created_at
          ''')
          .eq('is_suspended', false)
          .order('first_name', ascending: true);

      return response.map<Member>((json) => Member.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Aktif üyeler getirilemedi: $e');
    }
  }

  // Eğitmen olan üyeleri getir
  Future<List<Member>> getInstructorMembers() async {
    try {
      final response = await _supabase
          .from('members')
          .select('''
            id,
            user_id,
            role_id,
            group_id,
            first_name,
            last_name,
            phone,
            email,
            birth_date,
            is_suspended,
            is_instructor,
            specialization,
            instructor_bio,
            instructor_experience,
            created_at
          ''')
          .eq('is_instructor', true)
          .eq('is_suspended', false)
          .order('first_name', ascending: true);

      return response.map<Member>((json) => Member.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Eğitmen üyeler getirilemedi: $e');
    }
  }

  // Çakışma kontrolü için eğitmenin belirli tarih/saatte ders programı var mı kontrol et
  Future<bool> hasInstructorConflict(
    String instructorId,
    DateTime date,
    String startTime,
    String endTime,
  ) async {
    try {
      final response = await _supabase
          .from('lesson_schedules')
          .select('id')
          .eq('instructor_id', instructorId)
          .eq('day_of_week', _getDayOfWeek(date))
          .gte('start_time', startTime)
          .lte('end_time', endTime);

      return response.isNotEmpty;
    } catch (e) {
      throw Exception('Çakışma kontrolü yapılamadı: $e');
    }
  }

  // Giriş yapan kullanıcının bilgilerini getir
  Future<Member?> getCurrentMember() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return null;
      }

      final response = await _supabase
          .from('members')
          .select('''
            id,
            user_id,
            role_id,
            group_id,
            first_name,
            last_name,
            phone,
            email,
            birth_date,
            is_suspended,
            is_instructor,
            specialization,
            instructor_bio,
            instructor_experience,
            created_at,
            roles!inner(
              name
            )
          ''')
          .eq('user_id', user.id)
          .single();

      return Member.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  String _getDayOfWeek(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }
}
