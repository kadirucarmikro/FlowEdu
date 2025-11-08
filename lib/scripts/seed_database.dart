import 'package:supabase/supabase.dart';
import 'dart:io';

/// Veritabanına örnek veriler ekleyen script - Tango Dans Okulu
/// Kullanım: dart run lib/scripts/seed_database.dart
///
/// NOT: Bu script çalıştırılmadan önce:
/// 1. .env dosyasında SUPABASE_URL ve SUPABASE_ANON_KEY tanımlı olmalı
/// 2. delete-all-data.sql scripti Supabase SQL Editor'da çalıştırılmış olmalı
/// 3. seed-sample-data.sql scripti Supabase SQL Editor'da çalıştırılmış olmalı
///
/// Bu script auth.users gerektiren verileri (members, admins, events, vb.) ekler.

Future<void> main() async {
  // .env dosyasını yükle
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('❌ .env dosyası bulunamadı!');
    print('Lütfen proje kök dizininde .env dosyası oluşturun.');
    exit(1);
  }

  final envLines = await envFile.readAsLines();
  final env = <String, String>{};
  for (final line in envLines) {
    if (line.trim().isEmpty || line.startsWith('#')) continue;
    final parts = line.split('=');
    if (parts.length == 2) {
      env[parts[0].trim()] = parts[1].trim();
    }
  }

  final supabaseUrl = env['SUPABASE_URL'];
  final supabaseAnonKey = env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    print('❌ SUPABASE_URL veya SUPABASE_ANON_KEY .env dosyasında bulunamadı!');
    exit(1);
  }

  // Supabase client oluştur
  final supabase = SupabaseClient(supabaseUrl, supabaseAnonKey);

  try {
    print('🚀 Tango Dans Okulu veritabanı seed işlemi başlatılıyor...\n');

    // Admin kullanıcıları oluştur
    await _createAdminUsers(supabase);

    // Örnek üyeler oluştur (çoklu)
    await _createSampleMembers(supabase);

    // Örnek eğitmenler oluştur (çoklu)
    await _createSampleInstructors(supabase);

    // Örnek etkinlikler oluştur
    await _createSampleEvents(supabase);

    // Örnek bildirimler oluştur
    await _createSampleNotifications(supabase);

    // Örnek ödemeler oluştur
    await _createSamplePayments(supabase);

    // Örnek ders programları oluştur
    await _createSampleLessonSchedules(supabase);

    print('\n✅ Tüm örnek veriler başarıyla eklendi!');
  } catch (e) {
    print('\n❌ Hata oluştu: $e');
    rethrow;
  }
}

/// Admin kullanıcıları oluştur (çoklu)
Future<void> _createAdminUsers(SupabaseClient supabase) async {
  print('📝 Admin kullanıcıları oluşturuluyor...');

  final adminUsers = [
    {
      'email': 'admin@flowedu.com',
      'password': 'admin123456',
      'first_name': 'Ahmet',
      'last_name': 'Yönetim',
      'is_superadmin': true,
    },
    {
      'email': 'yonetim@flowedu.com',
      'password': 'yonetim123',
      'first_name': 'Ayşe',
      'last_name': 'Yönetici',
      'is_superadmin': false,
    },
  ];

  final adminRoleId = await _getRoleId(supabase, 'Admin');

  for (final adminData in adminUsers) {
    try {
      final authResponse = await supabase.auth.signUp(
        email: adminData['email'] as String,
        password: adminData['password'] as String,
      );

      if (authResponse.user == null) {
        // Kullanıcı zaten varsa giriş yap
        await supabase.auth.signInWithPassword(
          email: adminData['email'] as String,
          password: adminData['password'] as String,
        );
        final user = supabase.auth.currentUser;
        if (user != null) {
          await supabase.from('admins').upsert({
            'user_id': user.id,
            'is_superadmin': adminData['is_superadmin'] as bool,
          }, onConflict: 'user_id');

          if (adminRoleId != null) {
            await supabase.from('members').upsert({
              'user_id': user.id,
              'email': adminData['email'],
              'first_name': adminData['first_name'],
              'last_name': adminData['last_name'],
              'role_id': adminRoleId,
              'is_suspended': false,
            }, onConflict: 'user_id');
          }
        }
      } else {
        final user = authResponse.user!;

        await supabase.from('admins').insert({
          'user_id': user.id,
          'is_superadmin': adminData['is_superadmin'] as bool,
        });

        if (adminRoleId != null) {
          await supabase.from('members').insert({
            'user_id': user.id,
            'email': adminData['email'],
            'first_name': adminData['first_name'],
            'last_name': adminData['last_name'],
            'role_id': adminRoleId,
            'is_suspended': false,
          });
        }
      }

      print('  ✅ ${adminData['first_name']} ${adminData['last_name']} eklendi');
    } catch (e) {
      print('  ⚠️  ${adminData['email']} zaten mevcut veya hata: $e');
    }
  }
}

/// Örnek üyeler oluştur (çoklu - Tango öğrencileri)
Future<void> _createSampleMembers(SupabaseClient supabase) async {
  print('👥 Örnek üyeler oluşturuluyor...');

  final memberRoleId = await _getRoleId(supabase, 'Member');
  final groups = await supabase.from('groups').select('id, name').limit(10);

  if (memberRoleId == null || groups.isEmpty) {
    print('⚠️  Member rolü veya grup bulunamadı');
    return;
  }

  final sampleMembers = [
    // Başlangıç seviyesi öğrenciler
    {
      'email': 'ogrenci1@flowedu.com',
      'password': 'ogrenci123',
      'first_name': 'Mehmet',
      'last_name': 'Kaya',
      'phone': '05551234567',
      'group_id': groups[0]['id'], // Başlangıç Seviyesi Tango
      'birth_date': '1990-01-15',
    },
    {
      'email': 'ogrenci2@flowedu.com',
      'password': 'ogrenci123',
      'first_name': 'Zeynep',
      'last_name': 'Demir',
      'phone': '05551234568',
      'group_id': groups[0]['id'],
      'birth_date': '1992-05-20',
    },
    {
      'email': 'ogrenci3@flowedu.com',
      'password': 'ogrenci123',
      'first_name': 'Ali',
      'last_name': 'Yılmaz',
      'phone': '05551234569',
      'group_id': groups[0]['id'],
      'birth_date': '1988-08-10',
    },
    {
      'email': 'ogrenci4@flowedu.com',
      'password': 'ogrenci123',
      'first_name': 'Elif',
      'last_name': 'Şahin',
      'phone': '05551234570',
      'group_id': groups[0]['id'],
      'birth_date': '1995-03-25',
    },
    // Orta seviye öğrenciler
    {
      'email': 'ogrenci5@flowedu.com',
      'password': 'ogrenci123',
      'first_name': 'Can',
      'last_name': 'Özkan',
      'phone': '05551234571',
      'group_id': groups[1]['id'], // Orta Seviye Tango
      'birth_date': '1987-11-12',
    },
    {
      'email': 'ogrenci6@flowedu.com',
      'password': 'ogrenci123',
      'first_name': 'Selin',
      'last_name': 'Aydın',
      'phone': '05551234572',
      'group_id': groups[1]['id'],
      'birth_date': '1991-07-18',
    },
    {
      'email': 'ogrenci7@flowedu.com',
      'password': 'ogrenci123',
      'first_name': 'Burak',
      'last_name': 'Çelik',
      'phone': '05551234573',
      'group_id': groups[1]['id'],
      'birth_date': '1989-09-30',
    },
    // İleri seviye öğrenciler
    {
      'email': 'ogrenci8@flowedu.com',
      'password': 'ogrenci123',
      'first_name': 'Deniz',
      'last_name': 'Arslan',
      'phone': '05551234574',
      'group_id': groups[2]['id'], // İleri Seviye Tango
      'birth_date': '1986-04-05',
    },
    {
      'email': 'ogrenci9@flowedu.com',
      'password': 'ogrenci123',
      'first_name': 'Gizem',
      'last_name': 'Kurt',
      'phone': '05551234575',
      'group_id': groups[2]['id'],
      'birth_date': '1993-12-22',
    },
    {
      'email': 'ogrenci10@flowedu.com',
      'password': 'ogrenci123',
      'first_name': 'Emre',
      'last_name': 'Koç',
      'phone': '05551234576',
      'group_id': groups[2]['id'],
      'birth_date': '1990-06-14',
    },
    // Milonga grubu
    {
      'email': 'ogrenci11@flowedu.com',
      'password': 'ogrenci123',
      'first_name': 'Cem',
      'last_name': 'Yıldız',
      'phone': '05551234577',
      'group_id': groups[3]['id'], // Milonga
      'birth_date': '1985-02-28',
    },
    {
      'email': 'ogrenci12@flowedu.com',
      'password': 'ogrenci123',
      'first_name': 'Burcu',
      'last_name': 'Doğan',
      'phone': '05551234578',
      'group_id': groups[3]['id'],
      'birth_date': '1994-10-08',
    },
    // Yarışma hazırlık grubu
    {
      'email': 'ogrenci13@flowedu.com',
      'password': 'ogrenci123',
      'first_name': 'Kaan',
      'last_name': 'Polat',
      'phone': '05551234579',
      'group_id': groups[6]['id'], // Yarışma Hazırlık Grubu
      'birth_date': '1984-01-20',
    },
    {
      'email': 'ogrenci14@flowedu.com',
      'password': 'ogrenci123',
      'first_name': 'Derya',
      'last_name': 'Aktaş',
      'phone': '05551234580',
      'group_id': groups[6]['id'],
      'birth_date': '1992-08-15',
    },
    {
      'email': 'ogrenci15@flowedu.com',
      'password': 'ogrenci123',
      'first_name': 'Tolga',
      'last_name': 'Şen',
      'phone': '05551234581',
      'group_id': groups[6]['id'],
      'birth_date': '1987-05-03',
    },
  ];

  for (final memberData in sampleMembers) {
    try {
      final authResponse = await supabase.auth.signUp(
        email: memberData['email'] as String,
        password: memberData['password'] as String,
      );

      if (authResponse.user != null) {
        await supabase.from('members').insert({
          'user_id': authResponse.user!.id,
          'email': memberData['email'],
          'first_name': memberData['first_name'],
          'last_name': memberData['last_name'],
          'phone': memberData['phone'],
          'role_id': memberRoleId,
          'group_id': memberData['group_id'],
          'birth_date': memberData['birth_date'],
          'is_suspended': false,
        });
        print(
          '  ✅ ${memberData['first_name']} ${memberData['last_name']} eklendi',
        );
      }
    } catch (e) {
      print('  ⚠️  ${memberData['email']} zaten mevcut');
    }
  }
}

/// Örnek eğitmenler oluştur (çoklu - Tango eğitmenleri)
Future<void> _createSampleInstructors(SupabaseClient supabase) async {
  print('🎓 Örnek eğitmenler oluşturuluyor...');

  final instructorRoleId = await _getRoleId(supabase, 'Instructor');
  if (instructorRoleId == null) {
    print('⚠️  Instructor rolü bulunamadı');
    return;
  }

  final sampleInstructors = [
    {
      'email': 'egitmen1@flowedu.com',
      'password': 'egitmen123',
      'first_name': 'Carlos',
      'last_name': 'Rodriguez',
      'phone': '05551234590',
      'specialization': 'Arjantin Tango - Lider',
      'instructor_bio':
          'Arjantin doğumlu, 20 yıllık deneyime sahip tango eğitmeni. Buenos Aires'
          'te eğitim almış, uluslararası yarışmalarda jüri üyesi.',
      'instructor_experience': '20 yıl',
    },
    {
      'email': 'egitmen2@flowedu.com',
      'password': 'egitmen123',
      'first_name': 'Maria',
      'last_name': 'Garcia',
      'phone': '05551234591',
      'specialization': 'Arjantin Tango - Takipçi',
      'instructor_bio':
          'Arjantin Tango Federasyonu sertifikalı eğitmen. Milonga ve vals konusunda uzman. 15 yıllık deneyim.',
      'instructor_experience': '15 yıl',
    },
    {
      'email': 'egitmen3@flowedu.com',
      'password': 'egitmen123',
      'first_name': 'Ahmet',
      'last_name': 'Tango',
      'phone': '05551234592',
      'specialization': 'Modern Tango - Lider',
      'instructor_bio':
          'Türkiye Tango Federasyonu üyesi. Modern tango teknikleri ve yarışma hazırlığı konusunda uzman. 12 yıllık deneyim.',
      'instructor_experience': '12 yıl',
    },
    {
      'email': 'egitmen4@flowedu.com',
      'password': 'egitmen123',
      'first_name': 'Ayşe',
      'last_name': 'Dans',
      'phone': '05551234593',
      'specialization': 'Klasik Tango - Takipçi',
      'instructor_bio':
          'Klasik tango teknikleri ve geleneksel dans konusunda uzman. Başlangıç seviyesi öğrencilerle çalışma deneyimi yüksek.',
      'instructor_experience': '10 yıl',
    },
    {
      'email': 'egitmen5@flowedu.com',
      'password': 'egitmen123',
      'first_name': 'Diego',
      'last_name': 'Martinez',
      'phone': '05551234594',
      'specialization': 'Milonga ve Vals',
      'instructor_bio':
          'Milonga ve tango vals konusunda uzman eğitmen. Hızlı tango teknikleri ve pratik seansları yönetir.',
      'instructor_experience': '18 yıl',
    },
    {
      'email': 'egitmen6@flowedu.com',
      'password': 'egitmen123',
      'first_name': 'Sofia',
      'last_name': 'Lopez',
      'phone': '05551234595',
      'specialization': 'Yarışma Hazırlığı',
      'instructor_bio':
          'Yarışma hazırlığı ve performans tangosu konusunda uzman. Öğrencileri ulusal ve uluslararası yarışmalara hazırlar.',
      'instructor_experience': '14 yıl',
    },
  ];

  for (final instructorData in sampleInstructors) {
    try {
      final authResponse = await supabase.auth.signUp(
        email: instructorData['email'] as String,
        password: instructorData['password'] as String,
      );

      if (authResponse.user != null) {
        await supabase.from('members').insert({
          'user_id': authResponse.user!.id,
          'email': instructorData['email'],
          'first_name': instructorData['first_name'],
          'last_name': instructorData['last_name'],
          'phone': instructorData['phone'],
          'role_id': instructorRoleId,
          'is_instructor': true,
          'specialization': instructorData['specialization'],
          'instructor_bio': instructorData['instructor_bio'],
          'instructor_experience': instructorData['instructor_experience'],
          'is_suspended': false,
        });
        print(
          '  ✅ ${instructorData['first_name']} ${instructorData['last_name']} eklendi',
        );
      }
    } catch (e) {
      print('  ⚠️  ${instructorData['email']} zaten mevcut');
    }
  }
}

/// Örnek etkinlikler oluştur (Tango etkinlikleri)
Future<void> _createSampleEvents(SupabaseClient supabase) async {
  print('🎉 Örnek etkinlikler oluşturuluyor...');

  final admins = await supabase.from('admins').select('id').limit(1);
  if (admins.isEmpty) {
    print('⚠️  Admin bulunamadı');
    return;
  }

  final sampleEvents = [
    {
      'title': 'Milonga Gecesi - Aylık Tango Buluşması',
      'description':
          'Her ayın ilk cumartesi gecesi düzenlenen geleneksel milonga gecemize tüm tango severleri bekliyoruz. Canlı müzik, profesyonel DJ ve harika bir atmosfer!',
      'type': 'normal',
      'start_at': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      'end_at': DateTime.now()
          .add(const Duration(days: 7, hours: 4))
          .toIso8601String(),
      'created_by': admins[0]['id'],
    },
    {
      'title': 'Tango Workshop - İleri Seviye Teknikler',
      'description':
          'İleri seviye tango teknikleri workshop'
          'u. Carlos Rodriguez ve Maria Garcia eşliğinde özel teknikler öğreneceksiniz.',
      'type': 'interactive',
      'start_at': DateTime.now()
          .add(const Duration(days: 14))
          .toIso8601String(),
      'end_at': DateTime.now()
          .add(const Duration(days: 14, hours: 3))
          .toIso8601String(),
      'created_by': admins[0]['id'],
    },
    {
      'title': 'Yarışma Hazırlık Semineri',
      'description':
          'Yarışmaya hazırlanan öğrenciler için özel seminer. Jüri değerlendirme kriterleri, performans teknikleri ve sahne kullanımı.',
      'type': 'normal',
      'start_at': DateTime.now()
          .add(const Duration(days: 21))
          .toIso8601String(),
      'end_at': DateTime.now()
          .add(const Duration(days: 21, hours: 2))
          .toIso8601String(),
      'created_by': admins[0]['id'],
    },
    {
      'title': 'Başlangıç Seviyesi Tanışma Etkinliği',
      'description':
          'Yeni başlayan öğrenciler için tanışma ve bilgilendirme etkinliği. Tango hakkında merak ettiklerinizi sorabilir, eğitmenlerimizle tanışabilirsiniz.',
      'type': 'interactive',
      'start_at': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
      'end_at': DateTime.now()
          .add(const Duration(days: 5, hours: 2))
          .toIso8601String(),
      'created_by': admins[0]['id'],
    },
    {
      'title': 'Tango Vals Özel Dersi',
      'description':
          'Tango vals konusunda özel teknikler ve pratik seansı. Sınırlı kontenjan!',
      'type': 'poll',
      'start_at': DateTime.now()
          .add(const Duration(days: 10))
          .toIso8601String(),
      'end_at': DateTime.now()
          .add(const Duration(days: 10, hours: 2))
          .toIso8601String(),
      'created_by': admins[0]['id'],
    },
  ];

  for (final eventData in sampleEvents) {
    try {
      final event = await supabase
          .from('events')
          .insert(eventData)
          .select()
          .single();

      // Etkinlik seçenekleri ekle (interactive ve poll etkinlikler için)
      if (eventData['type'] == 'interactive' || eventData['type'] == 'poll') {
        await supabase.from('event_options').insert([
          {'event_id': event['id'], 'option_text': 'Katılıyorum'},
          {'event_id': event['id'], 'option_text': 'Katılamıyorum'},
          {'event_id': event['id'], 'option_text': 'Belki'},
        ]);
      }

      print('  ✅ ${eventData['title']} eklendi');
    } catch (e) {
      print('  ⚠️  Etkinlik eklenirken hata: $e');
    }
  }
}

/// Örnek bildirimler oluştur
Future<void> _createSampleNotifications(SupabaseClient supabase) async {
  print('📢 Örnek bildirimler oluşturuluyor...');

  final admins = await supabase.from('admins').select('id').limit(1);
  final groups = await supabase.from('groups').select('id').limit(3);

  if (admins.isEmpty || groups.isEmpty) {
    print('⚠️  Admin veya grup bulunamadı');
    return;
  }

  final sampleNotifications = [
    {
      'title': 'Hoş Geldiniz - FlowEdu Tango Dans Okulu',
      'body':
          'FlowEdu Tango Dans Okulu ailesine hoş geldiniz! Derslerinizden en iyi şekilde faydalanmanızı dileriz. Sorularınız için bizimle iletişime geçebilirsiniz.',
      'type': 'manual',
      'target_group_id': groups[0]['id'],
      'created_by': admins[0]['id'],
      'is_interactive': false,
    },
    {
      'title': 'Yeni Ders Programı Yayınlandı',
      'body':
          'Aralık ayı ders programı yayınlandı. Lütfen ders saatlerinizi kontrol ediniz ve değişiklikler varsa bize bildiriniz.',
      'type': 'manual',
      'target_group_id': groups[0]['id'],
      'created_by': admins[0]['id'],
      'is_interactive': true,
    },
    {
      'title': 'Milonga Gecesi Hatırlatması',
      'body':
          'Bu cumartesi akşamı milonga gecemiz var! Tüm öğrencilerimizi bekliyoruz. Canlı müzik ve harika bir atmosfer sizleri bekliyor.',
      'type': 'manual',
      'target_group_id': groups[1]['id'],
      'created_by': admins[0]['id'],
      'is_interactive': true,
    },
    {
      'title': 'Ödeme Hatırlatması',
      'body':
          'Ders paketinizin ödeme tarihi yaklaşıyor. Lütfen zamanında ödemenizi yapınız.',
      'type': 'automatic',
      'target_group_id': groups[0]['id'],
      'created_by': admins[0]['id'],
      'is_interactive': false,
    },
  ];

  for (final notificationData in sampleNotifications) {
    try {
      final notification = await supabase
          .from('notifications')
          .insert(notificationData)
          .select()
          .single();

      // Etkileşimli bildirimler için seçenekler ekle
      if (notificationData['is_interactive'] == true) {
        await supabase.from('notification_options').insert([
          {
            'notification_id': notification['id'],
            'option_text': 'Tamam',
            'option_value': 'ok',
            'sort_order': 0,
          },
          {
            'notification_id': notification['id'],
            'option_text': 'Daha Sonra',
            'option_value': 'later',
            'sort_order': 1,
          },
        ]);
      }

      print('  ✅ ${notificationData['title']} eklendi');
    } catch (e) {
      print('  ⚠️  Bildirim eklenirken hata: $e');
    }
  }
}

/// Örnek ödemeler oluştur
Future<void> _createSamplePayments(SupabaseClient supabase) async {
  print('💳 Örnek ödemeler oluşturuluyor...');

  final members = await supabase.from('members').select('id').limit(15);
  final packages = await supabase
      .from('lesson_packages')
      .select('id, name')
      .limit(10);

  if (members.isEmpty || packages.isEmpty) {
    print('⚠️  Üye veya paket bulunamadı');
    return;
  }

  // Paket fiyatları (tango dans okuluna uygun)
  final packagePrices = {
    '4 Derslik Deneme Paketi': 400.00,
    '8 Derslik Başlangıç Paketi': 750.00,
    '12 Derslik Standart Paket': 1100.00,
    '16 Derslik Yoğun Paket': 1400.00,
    'Aylık Sınırsız Paket': 1800.00,
    'Yarışma Hazırlık Paketi': 2000.00,
    'Bireysel Ders Paketi (5 Ders)': 1500.00,
    'Bireysel Ders Paketi (10 Ders)': 2800.00,
    'Haftalık Pratik Paketi': 350.00,
    'Workshop Paketi': 600.00,
  };

  for (int i = 0; i < members.length && i < packages.length; i++) {
    try {
      final package = packages[i];
      final packageName = package['name'] as String;
      final basePrice = packagePrices[packageName] ?? 500.00;
      final discount = (i % 3 == 0)
          ? basePrice * 0.1
          : 0.0; // Her 3. öğrenciye %10 indirim
      final status = (i % 4 == 0) ? 'paid' : 'pending'; // Her 4. öğrenci ödemiş

      await supabase.from('payments').insert({
        'member_id': members[i]['id'],
        'package_id': package['id'],
        'amount': basePrice,
        'discount_amount': discount,
        'status': status,
        'due_date': DateTime.now()
            .add(Duration(days: 30 + (i * 7)))
            .toIso8601String()
            .split('T')[0],
        if (status == 'paid') 'paid_at': DateTime.now().toIso8601String(),
      });
      print('  ✅ ${packageName} için ödeme eklendi (${status})');
    } catch (e) {
      print('  ⚠️  Ödeme eklenirken hata: $e');
    }
  }
}

/// Örnek ders programları oluştur
Future<void> _createSampleLessonSchedules(SupabaseClient supabase) async {
  print('📅 Örnek ders programları oluşturuluyor...');

  final packages = await supabase
      .from('lesson_packages')
      .select('id, name, lesson_count')
      .limit(5);
  final members = await supabase
      .from('members')
      .select('id')
      .eq('is_instructor', false)
      .limit(15);
  final instructors = await supabase
      .from('members')
      .select('id')
      .eq('is_instructor', true)
      .limit(6);
  final rooms = await supabase.from('rooms').select('id').limit(8);

  if (packages.isEmpty || members.isEmpty) {
    print('⚠️  Paket, üye veya oda bulunamadı');
    return;
  }

  // Her paket için ders programları oluştur
  for (int p = 0; p < packages.length; p++) {
    final package = packages[p];
    final packageId = package['id'] as String;
    final lessonCount = package['lesson_count'] as int;

    // Bu hafta için ders programları oluştur
    final now = DateTime.now();
    final nextMonday = now.add(Duration(days: (8 - now.weekday) % 7));

    // Her paket için 4-6 ders oluştur
    final lessonsToCreate = lessonCount > 6 ? 6 : lessonCount;

    for (int i = 0; i < lessonsToCreate; i++) {
      final lessonDate = nextMonday.add(
        Duration(days: i * 2),
      ); // Her 2 günde bir
      final instructorIndex = i % instructors.length;
      final roomIndex = i % rooms.length;
      final memberStartIndex = (p * 3) % members.length;
      final memberCount = (i % 5) + 3; // 3-7 arası öğrenci

      try {
        final schedule = await supabase
            .from('lesson_schedules')
            .insert({
              'package_id': packageId,
              'instructor_id': instructors.isNotEmpty
                  ? instructors[instructorIndex]['id']
                  : null,
              'room_id': rooms.isNotEmpty ? rooms[roomIndex]['id'] : null,
              'day_of_week': _getDayName(lessonDate.weekday),
              'start_time': '19:00:00',
              'end_time': '20:30:00',
              'attendee_ids': members
                  .sublist(
                    memberStartIndex,
                    (memberStartIndex + memberCount) % members.length,
                  )
                  .map((m) => m['id'])
                  .toList(),
              'lesson_number': i + 1,
              'total_lessons': lessonCount,
              'status': 'scheduled',
              'actual_date_day': lessonDate.day,
              'actual_date_month': lessonDate.month,
              'actual_date_year': lessonDate.year,
            })
            .select()
            .single();

        // Üyeleri lesson_attendees tablosuna ekle
        final selectedMembers = members.sublist(
          memberStartIndex,
          (memberStartIndex + memberCount) % members.length,
        );
        for (final member in selectedMembers) {
          await supabase.from('lesson_attendees').insert({
            'schedule_id': schedule['id'],
            'member_id': member['id'],
            'lesson_price': 50.00 + (i * 5), // Farklı fiyatlar
          });
        }

        print('  ✅ ${package['name']} - Ders ${i + 1}/$lessonCount eklendi');
      } catch (e) {
        print('  ⚠️  Ders programı eklenirken hata: $e');
      }
    }
  }
}

/// Rol ID'sini getir
Future<String?> _getRoleId(SupabaseClient supabase, String roleName) async {
  try {
    final response = await supabase
        .from('roles')
        .select('id')
        .eq('name', roleName)
        .maybeSingle();
    return response?['id'] as String?;
  } catch (e) {
    return null;
  }
}

/// Haftanın gününü string olarak döndür
String _getDayName(int weekday) {
  const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return days[weekday - 1];
}
