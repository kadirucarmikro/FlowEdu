class Validators {
  Validators._();

  // Zorunlu alan kontrolü (Türkçe mesajı döndürür)
  static String? required(String? value, {String fieldName = 'Bu alan'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName zorunludur';
    }
    return null;
  }

  // Evrensel telefon numarası formatı (ülke kodu + numara)
  static final RegExp _universalPhone = RegExp(r'^\+[1-9]\d{1,4}\d{6,14}$');

  // Telefonu normalize eder: baştaki 0, boşluk, tire, parantezleri temizler; TR için +90 ekler
  static String normalizePhone(
    String input, {
    String defaultCountryCode = '+90',
  }) {
    final String digits = input.replaceAll(RegExp(r'[^0-9+]'), '');
    String normalized = digits;
    if (normalized.startsWith('00')) {
      normalized = '+${normalized.substring(2)}';
    }
    if (!normalized.startsWith('+')) {
      if (normalized.startsWith('0')) {
        normalized = normalized.substring(1);
      }
      normalized = '$defaultCountryCode$normalized';
    }
    return normalized;
  }

  // Evrensel E.164 kontrolü (Türkçe mesaj)
  static String? phoneE164(
    String? value, {
    String fieldName = 'Telefon',
    bool requiredField = false,
    String countryCode = '+90',
  }) {
    if (value == null || value.trim().isEmpty) {
      return requiredField ? '$fieldName zorunludur' : null;
    }
    final String normalized = normalizePhone(
      value.trim(),
      defaultCountryCode: countryCode,
    );
    if (!_universalPhone.hasMatch(normalized)) {
      return '$fieldName geçerli bir telefon olmalıdır (örn. +905xxxxxxxxx)';
    }
    return null;
  }

  // Email kontrolü
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta zorunludur';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Geçerli bir e-posta adresi giriniz';
    }
    return null;
  }

  // Telefon kontrolü (basit)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Telefon opsiyonel
    }
    final phoneRegex = RegExp(r'^[\+]?[0-9\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Geçerli bir telefon numarası giriniz';
    }
    return null;
  }
}
