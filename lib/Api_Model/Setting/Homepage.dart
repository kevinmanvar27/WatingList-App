class Homepage {
  bool success;
  HomepageData data;
  String message;

  Homepage({
    required this.success,
    required this.data,
    required this.message,
  });

}

class HomepageData {
  String applicationName;
  String appVersion;
  int showHomePage;
  String logo;
  String favicon;
  String appLogo;

  HomepageData({
    required this.applicationName,
    required this.appVersion,
    required this.showHomePage,
    required this.logo,
    required this.favicon,
    required this.appLogo,
  });

}
