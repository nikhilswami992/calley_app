class AppLanguage {
  final String code;
  final String name;
  final String greeting;

  const AppLanguage(this.code, this.name, this.greeting);

  static const List<AppLanguage> all = [
    AppLanguage('en', 'English', 'Hi'),
    AppLanguage('hi', 'Hindi', 'नमस्ते'),
    AppLanguage('bn', 'Bengali', 'হ্যালো'),
    AppLanguage('kn', 'Kannada', 'ನಮಸ್ಕಾರ'),
    AppLanguage('pa', 'Punjabi', 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ'),
    AppLanguage('ta', 'Tamil', 'வணக்கம்'),
    AppLanguage('te', 'Telugu', 'హలో'),
    AppLanguage('fr', 'French', 'Bonjour'),
    AppLanguage('es', 'Spanish', 'Hola'),
  ];

  static AppLanguage byCode(String? code) =>
      all.firstWhere((l) => l.code == code, orElse: () => all.first);
}
