class AppLocalizations {
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'AquaFilter',
      'login': 'Login',
    },
    'ru': {
      'title': 'Аквафильтр',
      'login': 'Войти',
    },
  };

  static String translate(String key, String locale) {
    return _localizedValues[locale]?.containsKey(key) == true
        ? _localizedValues[locale]![key]!
        : key;
  }
}
