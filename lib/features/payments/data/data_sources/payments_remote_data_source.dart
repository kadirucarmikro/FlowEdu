import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment_model.dart';
import '../models/lesson_package_model.dart';

abstract class PaymentsRemoteDataSource {
  Future<List<PaymentModel>> getPayments();
  Future<PaymentModel> getPaymentById(String id);
  Future<List<PaymentModel>> getPaymentsByMemberId(String memberId);
  Future<PaymentModel> createPayment(PaymentModel payment);
  Future<PaymentModel> updatePayment(PaymentModel payment);
  Future<void> deletePayment(String id);

  // Lesson Packages
  Future<List<LessonPackageModel>> getLessonPackages();
  Future<LessonPackageModel> getLessonPackageById(String id);
  Future<LessonPackageModel> createLessonPackage(LessonPackageModel package);
  Future<LessonPackageModel> updateLessonPackage(LessonPackageModel package);
  Future<void> deleteLessonPackage(String id);
}

class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  final SupabaseClient _supabase;

  PaymentsRemoteDataSourceImpl(this._supabase);

  @override
  Future<List<PaymentModel>> getPayments() async {
    try {
      final response = await _supabase
          .from('payments')
          .select('*')
          .order('created_at', ascending: false);

      return response.map((json) => PaymentModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Failed to get payments: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getPaymentsWithDetails() async {
    try {
      final response = await _supabase
          .from('payments')
          .select('''
            *,
            member:members!payments_member_id_fkey(first_name, last_name),
            package:lesson_packages!payments_package_id_fkey(name, lesson_count)
          ''')
          .order('created_at', ascending: false);

      final payments = response.cast<Map<String, dynamic>>();
      
      // Her payment için schedule bilgilerini çek
      final List<Map<String, dynamic>> paymentsWithSchedules = [];
      
      for (final payment in payments) {
        final memberId = payment['member_id'] as String;
        final packageId = payment['package_id'] as String;
        
        // lesson_attendees'den bu üye ve paket için en son schedule bilgisini çek
        try {
          final scheduleResponse = await _supabase
              .from('lesson_attendees')
              .select('''
                schedule_id,
                lesson_schedules!inner(
                  id,
                  package_id,
                  actual_date_day,
                  actual_date_month,
                  actual_date_year,
                  created_at,
                  lesson_number,
                  total_lessons
                )
              ''')
              .eq('member_id', memberId)
              .eq('lesson_schedules.package_id', packageId)
              .order('assigned_at', ascending: false)
              .limit(1)
              .maybeSingle();
          
          if (scheduleResponse != null) {
            final schedule = scheduleResponse['lesson_schedules'] as Map<String, dynamic>?;
            if (schedule != null) {
              final scheduleId = scheduleResponse['schedule_id'] as String;
              final createdAt = schedule['created_at'] as String;
              final totalLessons = (schedule['total_lessons'] as int?) ?? 1;
              
              // Aynı created_at'e sahip schedule grubunu bul (aynı ders programı grubu)
              final scheduleGroupResponse = await _supabase
                  .from('lesson_schedules')
                  .select('id, actual_date_day, actual_date_month, actual_date_year, created_at, lesson_number')
                  .eq('package_id', packageId)
                  .eq('created_at', createdAt)
                  .order('lesson_number');
              
              DateTime? startDate;
              DateTime? endDate;
              
              if (scheduleGroupResponse.isNotEmpty) {
                // İlk ders tarihini bul (lesson_number = 1)
                final firstLesson = scheduleGroupResponse.firstWhere(
                  (s) => (s['lesson_number'] as int?) == 1,
                  orElse: () => scheduleGroupResponse.first,
                );
                
                final day = firstLesson['actual_date_day'] as int?;
                final month = firstLesson['actual_date_month'] as int?;
                final year = firstLesson['actual_date_year'] as int?;
                
                if (day != null && month != null && year != null) {
                  startDate = DateTime(year, month, day);
                } else {
                  startDate = DateTime.parse(firstLesson['created_at'] as String);
                }
                
                // Son ders tarihini bul (lesson_number = total_lessons)
                final lastLesson = scheduleGroupResponse.firstWhere(
                  (s) => (s['lesson_number'] as int?) == totalLessons,
                  orElse: () => scheduleGroupResponse.last,
                );
                
                final lastDay = lastLesson['actual_date_day'] as int?;
                final lastMonth = lastLesson['actual_date_month'] as int?;
                final lastYear = lastLesson['actual_date_year'] as int?;
                
                if (lastDay != null && lastMonth != null && lastYear != null) {
                  endDate = DateTime(lastYear, lastMonth, lastDay);
                } else {
                  endDate = DateTime.parse(lastLesson['created_at'] as String);
                }
              }
              
              payment['schedule_id'] = scheduleId;
              payment['schedule_start_date'] = startDate?.toIso8601String();
              payment['schedule_end_date'] = endDate?.toIso8601String();
            }
          }
        } catch (e) {
          // Schedule bilgisi çekilemezse devam et
        }
        
        paymentsWithSchedules.add(payment);
      }
      
      return paymentsWithSchedules;
    } on PostgrestException catch (e) {
      throw Exception('Failed to get payments with details: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<PaymentModel> getPaymentById(String id) async {
    try {
      final response = await _supabase
          .from('payments')
          .select('*')
          .eq('id', id)
          .single();

      return PaymentModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Failed to get payment: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<PaymentModel>> getPaymentsByMemberId(String memberId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select('*')
          .eq('member_id', memberId)
          .order('created_at', ascending: false);

      return response.map((json) => PaymentModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Failed to get payments by member: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<PaymentModel> createPayment(PaymentModel payment) async {
    try {
      final response = await _supabase
          .from('payments')
          .insert(payment.toCreateJson())
          .select()
          .single();

      return PaymentModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Failed to create payment: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<PaymentModel> updatePayment(PaymentModel payment) async {
    try {
      final response = await _supabase
          .from('payments')
          .update(payment.toJson())
          .eq('id', payment.id)
          .select()
          .single();

      return PaymentModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Failed to update payment: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePayment(String id) async {
    try {
      await _supabase.from('payments').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Failed to delete payment: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<LessonPackageModel>> getLessonPackages() async {
    try {
      final response = await _supabase
          .from('lesson_packages')
          .select('*')
          .order('created_at', ascending: false);

      return response.map((json) => LessonPackageModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Failed to get lesson packages: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<LessonPackageModel> getLessonPackageById(String id) async {
    try {
      final response = await _supabase
          .from('lesson_packages')
          .select('*')
          .eq('id', id)
          .single();

      return LessonPackageModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Failed to get lesson package: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<LessonPackageModel> createLessonPackage(
    LessonPackageModel package,
  ) async {
    try {
      final response = await _supabase
          .from('lesson_packages')
          .insert(package.toCreateJson())
          .select()
          .single();

      return LessonPackageModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Failed to create lesson package: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<LessonPackageModel> updateLessonPackage(
    LessonPackageModel package,
  ) async {
    try {
      final response = await _supabase
          .from('lesson_packages')
          .update(package.toUpdateJson())
          .eq('id', package.id)
          .select()
          .single();

      return LessonPackageModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Failed to update lesson package: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteLessonPackage(String id) async {
    try {
      await _supabase.from('lesson_packages').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Failed to delete lesson package: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  // Üye ve paket için lesson_attendees tablosundan tutar ve indirim bilgisini getir
  Future<Map<String, dynamic>?> getMemberPackagePriceAndDiscount(
    String memberId,
    String packageId, [
    String? specificScheduleId,
  ]) async {
    try {
      // Eğer specificScheduleId verilmişse, sadece o schedule'ı kullan
      List<String> scheduleIds;
      if (specificScheduleId != null) {
        scheduleIds = [specificScheduleId];
      } else {
        // Önce lesson_schedules tablosundan bu paket ile ilgili schedule ID'lerini bul
        final schedulesResponse = await _supabase
            .from('lesson_schedules')
            .select('id')
            .eq('package_id', packageId);

        if (schedulesResponse.isEmpty) {
          return null; // Bu paket için schedule bulunamadı
        }

        scheduleIds = schedulesResponse.map<String>((s) => s['id'] as String).toList();
      }

      // lesson_attendees tablosundan bu üye için bu schedule'lardan en son lesson_price değerini getir
      // Aynı zamanda schedule bilgilerini de al (tarih bilgileri için)
      final response = await _supabase
          .from('lesson_attendees')
          .select('''
            lesson_price,
            assigned_at,
            schedule_id,
            lesson_schedules!inner(
              id,
              actual_date_day,
              actual_date_month,
              actual_date_year,
              created_at,
              lesson_number,
              total_lessons
            )
          ''')
          .eq('member_id', memberId)
          .inFilter('schedule_id', scheduleIds)
          .order('assigned_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return null; // Kayıt bulunamadı
      }

      final lessonPrice = (response['lesson_price'] as num?)?.toDouble() ?? 0.0;
      final scheduleId = response['schedule_id'] as String;
      final schedule = response['lesson_schedules'] as Map<String, dynamic>;
      
      if (lessonPrice <= 0) {
        return null; // Geçerli fiyat yok
      }

      // Ders programı tarih bilgilerini hesapla
      DateTime? startDate;
      DateTime? endDate;
      
      // Bu schedule'ın total_lessons bilgisini al
      final totalLessons = (schedule['total_lessons'] as int?) ?? 1;
      
      // Bu schedule'ın created_at bilgisini al (aynı ders programı grubunu bulmak için)
      final scheduleCreatedAt = schedule['created_at'] as String?;
      
      if (scheduleCreatedAt != null) {
        // Aynı paket ve aynı zaman diliminde oluşturulan schedule'ları bul
        // (Aynı ders programı grubundan - aynı anda oluşturulan schedule'lar aynı gruba aittir)
        // created_at'e göre filtreleme yaparak aynı ders programı grubunu buluyoruz
        final scheduleGroupResponse = await _supabase
            .from('lesson_schedules')
            .select('id, actual_date_day, actual_date_month, actual_date_year, created_at, lesson_number')
            .eq('package_id', packageId)
            .eq('created_at', scheduleCreatedAt) // Aynı zaman diliminde oluşturulan schedule'lar
            .order('lesson_number');
        
        if (scheduleGroupResponse.isNotEmpty) {
          // İlk ders tarihini bul (lesson_number = 1)
          final firstLesson = scheduleGroupResponse.firstWhere(
            (s) => (s['lesson_number'] as int?) == 1,
            orElse: () => scheduleGroupResponse.first,
          );
          
          final day = firstLesson['actual_date_day'] as int?;
          final month = firstLesson['actual_date_month'] as int?;
          final year = firstLesson['actual_date_year'] as int?;
          
          if (day != null && month != null && year != null) {
            startDate = DateTime(year, month, day);
          } else {
            // Eğer actual_date yoksa created_at kullan
            startDate = DateTime.parse(firstLesson['created_at'] as String);
          }
          
          // Son ders tarihini bul (lesson_number = total_lessons)
          final lastLesson = scheduleGroupResponse.firstWhere(
            (s) => (s['lesson_number'] as int?) == totalLessons,
            orElse: () => scheduleGroupResponse.last,
          );
          
          final lastDay = lastLesson['actual_date_day'] as int?;
          final lastMonth = lastLesson['actual_date_month'] as int?;
          final lastYear = lastLesson['actual_date_year'] as int?;
          
          if (lastDay != null && lastMonth != null && lastYear != null) {
            endDate = DateTime(lastYear, lastMonth, lastDay);
          } else {
            // Eğer actual_date yoksa created_at kullan
            endDate = DateTime.parse(lastLesson['created_at'] as String);
          }
        }
      }

      // Paket bilgisini al
      final packageResponse = await _supabase
          .from('lesson_packages')
          .select('price, lesson_count')
          .eq('id', packageId)
          .maybeSingle();

      if (packageResponse == null) {
        return null; // Paket bulunamadı
      }

      final packagePrice = (packageResponse['price'] as num).toDouble();
      final lessonCount = (packageResponse['lesson_count'] as int);

      if (lessonCount <= 0 || packagePrice <= 0) {
        return null;
      }

      // Paket toplam tutarını hesapla (lesson_price * lesson_count)
      final packageTotalPrice = lessonPrice * lessonCount;

      // İndirim yüzdesini hesapla
      double discountPercent = 0.0;
      if (packagePrice > packageTotalPrice) {
        discountPercent = ((packagePrice - packageTotalPrice) / packagePrice) * 100;
      }

      // İndirim tutarını hesapla
      final discountAmount = packagePrice - packageTotalPrice;

      return {
        'amount': packageTotalPrice,
        'discountAmount': discountAmount > 0 ? discountAmount : 0.0,
        'discountPercent': discountPercent,
        'lessonPrice': lessonPrice, // Ders başına fiyat
        'scheduleId': scheduleId, // Ders programı ID'si
        'startDate': startDate?.toIso8601String(), // Başlangıç tarihi
        'endDate': endDate?.toIso8601String(), // Bitiş tarihi
      };
    } catch (e) {
      // Hata durumunda null döndür
      return null;
    }
  }

  // Aynı üye-paket-schedule için ödeme kontrolü
  Future<bool> checkExistingPaymentForSchedule(
    String memberId,
    String packageId,
    String scheduleId,
  ) async {
    try {
      // Önce bu schedule'ın hangi paket için olduğunu kontrol et
      final scheduleResponse = await _supabase
          .from('lesson_schedules')
          .select('package_id')
          .eq('id', scheduleId)
          .maybeSingle();

      if (scheduleResponse == null) {
        return false; // Schedule bulunamadı, devam et
      }

      final schedulePackageId = scheduleResponse['package_id'] as String;
      
      // Paket ID'leri eşleşmiyorsa devam et
      if (schedulePackageId != packageId) {
        return false;
      }

      // Bu schedule için lesson_attendees kaydı var mı kontrol et
      final attendeeResponse = await _supabase
          .from('lesson_attendees')
          .select('id')
          .eq('member_id', memberId)
          .eq('schedule_id', scheduleId)
          .maybeSingle();

      if (attendeeResponse == null) {
        return false; // Bu schedule için üye kaydı yok, devam edebilir
      }

      // Bu üye için bu paket ile ilgili ödemeleri kontrol et
      // Aynı üye-paket kombinasyonu için ödeme varsa, bu schedule için ödeme yapılmış olabilir
      final paymentResponse = await _supabase
          .from('payments')
          .select('id')
          .eq('member_id', memberId)
          .eq('package_id', packageId)
          .maybeSingle();

      if (paymentResponse == null) {
        return false; // Ödeme yok, devam edebilir
      }

      // Bu schedule için üye kaydı var VE ödeme de var
      // Bu durumda aynı schedule için ödeme yapılmış demektir
      return true; // Ödeme var, devam edemez
    } catch (e) {
      return false; // Hata durumunda devam et
    }
  }

  // Üye ve paket için ders programlarını getir (dropdown için)
  Future<List<Map<String, dynamic>>> getMemberPackageSchedules(
    String memberId,
    String packageId,
  ) async {
    try {
      // lesson_attendees tablosundan bu üye için bu paket ile ilgili schedule'ları getir
      final response = await _supabase
          .from('lesson_attendees')
          .select('''
            schedule_id,
            lesson_price,
            assigned_at,
            lesson_schedules!inner(
              id,
              package_id,
              actual_date_day,
              actual_date_month,
              actual_date_year,
              created_at,
              lesson_number,
              total_lessons
            )
          ''')
          .eq('member_id', memberId)
          .eq('lesson_schedules.package_id', packageId)
          .order('assigned_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      // Her schedule grubu için (aynı created_at) bir entry oluştur
      final Map<String, Map<String, dynamic>> scheduleGroups = {};

      for (final item in response) {
        final schedule = item['lesson_schedules'] as Map<String, dynamic>;
        final scheduleId = schedule['id'] as String;
        final createdAt = schedule['created_at'] as String;
        final lessonNumber = schedule['lesson_number'] as int? ?? 1;
        final totalLessons = schedule['total_lessons'] as int? ?? 1;
        final lessonPrice = (item['lesson_price'] as num?)?.toDouble() ?? 0.0;

        // Aynı created_at'e sahip schedule'ları grupla
        if (!scheduleGroups.containsKey(createdAt)) {
          scheduleGroups[createdAt] = {
            'scheduleId': scheduleId,
            'createdAt': createdAt,
            'totalLessons': totalLessons,
            'lessonPrice': lessonPrice,
            'startDate': null,
            'endDate': null,
            'firstLessonId': scheduleId,
            'lastLessonId': scheduleId,
          };
        }

        // İlk ders (lesson_number = 1)
        if (lessonNumber == 1) {
          final day = schedule['actual_date_day'] as int?;
          final month = schedule['actual_date_month'] as int?;
          final year = schedule['actual_date_year'] as int?;
          
          if (day != null && month != null && year != null) {
            scheduleGroups[createdAt]!['startDate'] = DateTime(year, month, day).toIso8601String();
          } else {
            scheduleGroups[createdAt]!['startDate'] = createdAt;
          }
          scheduleGroups[createdAt]!['firstLessonId'] = scheduleId;
        }

        // Son ders (lesson_number = total_lessons)
        if (lessonNumber == totalLessons) {
          final day = schedule['actual_date_day'] as int?;
          final month = schedule['actual_date_month'] as int?;
          final year = schedule['actual_date_year'] as int?;
          
          if (day != null && month != null && year != null) {
            scheduleGroups[createdAt]!['endDate'] = DateTime(year, month, day).toIso8601String();
          } else {
            scheduleGroups[createdAt]!['endDate'] = createdAt;
          }
          scheduleGroups[createdAt]!['lastLessonId'] = scheduleId;
        }
      }

      // Map'i listeye çevir ve tarih formatına göre sırala
      final schedules = scheduleGroups.values.toList();
      schedules.sort((a, b) {
        final aDate = a['startDate'] as String?;
        final bDate = b['startDate'] as String?;
        if (aDate == null || bDate == null) return 0;
        return DateTime.parse(bDate).compareTo(DateTime.parse(aDate)); // En yeni önce
      });

      return schedules;
    } catch (e) {
      return [];
    }
  }
}
