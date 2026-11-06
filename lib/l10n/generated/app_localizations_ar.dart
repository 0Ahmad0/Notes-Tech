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

  @override
  String get untitledNote => 'بدون عنوان';

  @override
  String get noteEditorNew => 'ملاحظة جديدة';

  @override
  String get noteEditorEdit => 'تعديل الملاحظة';

  @override
  String get noteTitleHint => 'العنوان';

  @override
  String get noteBodyHint => 'ابدأ الكتابة...';

  @override
  String get saveNote => 'حفظ الملاحظة';

  @override
  String get deleteNote => 'حذف الملاحظة';

  @override
  String get deleteNoteConfirm => 'نقل هذه الملاحظة إلى سلة المهملات؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get noteSaved => 'تم حفظ الملاحظة';

  @override
  String get movedToTrash => 'تم النقل إلى سلة المهملات';

  @override
  String get undo => 'تراجع';

  @override
  String get trash => 'سلة المهملات';

  @override
  String get restore => 'استعادة';

  @override
  String get deleteForever => 'حذف نهائي';

  @override
  String get deleteForeverConfirm =>
      'حذف هذه الملاحظة نهائيًا؟ لا يمكن التراجع عن ذلك.';

  @override
  String get emptyTrash => 'سلة المهملات فارغة';

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get sortUpdatedDesc => 'الأحدث أولًا';

  @override
  String get sortUpdatedAsc => 'الأقدم أولًا';

  @override
  String get sortCreatedDesc => 'أُنشئت مؤخرًا';

  @override
  String get sortTitleAsc => 'العنوان أ-ي';

  @override
  String get viewGrid => 'عرض شبكي';

  @override
  String get viewList => 'عرض قائمة';

  @override
  String get searchNotes => 'البحث في الملاحظات';

  @override
  String get noSearchResults => 'لا توجد ملاحظات مطابقة';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterText => 'نص';

  @override
  String get filterAudio => 'صوت';

  @override
  String get filterImage => 'صور';

  @override
  String get filterFiles => 'ملفات';

  @override
  String get colorLabel => 'اللون';

  @override
  String get pin => 'تثبيت';

  @override
  String get unpin => 'إلغاء التثبيت';

  @override
  String get moreOptions => 'المزيد';

  @override
  String get discardChanges => 'تجاهل التغييرات؟';

  @override
  String get keepEditing => 'متابعة التعديل';

  @override
  String get discard => 'تجاهل';

  @override
  String get noteType => 'النوع';

  @override
  String get emptyNoteError => 'أضف عنوانًا أو نصًا أولًا.';

  @override
  String get notesDisplay => 'عرض الملاحظات';

  @override
  String get attachments => 'المرفقات';

  @override
  String get addImage => 'صورة';

  @override
  String get addAudio => 'تسجيل';

  @override
  String get addFile => 'ملف';

  @override
  String get pendingAttachmentsHint => 'ستُحفظ المرفقات مع الملاحظة.';

  @override
  String get removeAttachment => 'إزالة المرفق';

  @override
  String get attachmentTooLarge => 'هذا الملف كبير جدًا.';

  @override
  String get attachmentFailed => 'تعذر إضافة المرفق.';

  @override
  String get fileMissing => 'الملف مفقود';

  @override
  String get microphoneDenied => 'إذن الميكروفون مطلوب لتسجيل الصوت.';

  @override
  String get recordingFailed => 'فشل التسجيل. حاول مرة أخرى.';

  @override
  String get recordAudio => 'تسجيل صوتي';

  @override
  String get recording => 'جارٍ التسجيل';

  @override
  String get stopRecording => 'إيقاف';

  @override
  String get useRecording => 'استخدام التسجيل';

  @override
  String get audioPlaybackFailed => 'تعذر تشغيل هذا الصوت.';

  @override
  String get playAudio => 'تشغيل الصوت';

  @override
  String get pauseAudio => 'إيقاف الصوت مؤقتًا';

  @override
  String get colorDefault => 'افتراضي';

  @override
  String get colorYellow => 'أصفر';

  @override
  String get colorMint => 'نعناعي';

  @override
  String get colorSky => 'سماوي';

  @override
  String get colorLavender => 'لافندر';

  @override
  String get colorPeach => 'خوخي';

  @override
  String get colorRose => 'وردي';

  @override
  String get colorSlate => 'رمادي';

  @override
  String get reminders => 'تذكير';

  @override
  String get addReminder => 'إضافة تذكير';

  @override
  String get removeReminder => 'إزالة التذكير';

  @override
  String get reminderInPast => 'اختر وقتًا في المستقبل.';

  @override
  String reminderSet(String date) {
    return 'تم ضبط التذكير في $date';
  }

  @override
  String get reminderNotificationBody => 'لديك تذكير بملاحظة.';

  @override
  String get reminderFailed => 'تعذر ضبط التذكير.';

  @override
  String get notificationsDisabled => 'الإشعارات معطلة لتطبيق Notes-Tech.';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get notificationsOn => 'الإشعارات مفعّلة.';

  @override
  String get notificationsOff => 'الإشعارات متوقفة.';

  @override
  String get enableNotifications => 'تفعيل';

  @override
  String get font => 'الخط';

  @override
  String get fontSystem => 'خط النظام';

  @override
  String get fontPlexArabic => 'IBM Plex Arabic';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get localOnlyNotice =>
      'ملاحظاتك محفوظة على هذا الجهاز فقط. لا يوجد خادم حسابات أو نسخ احتياطي سحابي بعد، لذا فإن حذف التطبيق أو فقدان الجهاز يعني فقدان بياناتك.';

  @override
  String editedDate(String date) {
    return 'عُدّلت $date';
  }
}
