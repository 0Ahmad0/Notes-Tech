// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'نوتس-تك';

  @override
  String get splashTagline => 'دوّن أفكارك واحتفظ بها قريبة.';

  @override
  String get loginTitle => 'مرحبًا بعودتك';

  @override
  String get loginSubtitle => 'سجّل الدخول لفتح ملاحظاتك.';

  @override
  String get registerTitle => 'أنشئ حسابك';

  @override
  String get registerSubtitle => 'محلي وخاص. لا تحتاج إلى إنترنت.';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get haveAccount => 'لديك حساب بالفعل؟';

  @override
  String get register => 'تسجيل';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get usernameHelper =>
      'من 3 إلى 24 حرفًا: أحرف إنجليزية صغيرة أو أرقام أو شرطة سفلية.';

  @override
  String get usernameTaken => 'اسم المستخدم مستخدم بالفعل.';

  @override
  String get invalidUsername => 'أدخل اسم مستخدم صالحًا.';

  @override
  String get weakPassword => 'استخدم 8 أحرف على الأقل.';

  @override
  String get invalidCredentials => 'اسم المستخدم أو كلمة المرور غير صحيحة.';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get unexpectedError => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get homeTitle => 'نوتس-تك';

  @override
  String get emptyNotesTitle => 'لا توجد ملاحظات بعد';

  @override
  String get emptyNotesSubtitle => 'اضغط الزر أدناه لإنشاء ملاحظتك الأولى.';

  @override
  String get newNote => 'ملاحظة جديدة';

  @override
  String get comingSoon => 'قريبًا';

  @override
  String get settings => 'الإعدادات';

  @override
  String get appearance => 'المظهر';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String signedInAs(String username) {
    return 'مسجّل الدخول باسم $username';
  }

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get requiredField => 'مطلوب';

  @override
  String get changePasswordTitle => 'تغيير كلمة المرور';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get save => 'حفظ';

  @override
  String get passwordChanged => 'تم تحديث كلمة المرور بنجاح.';
}
