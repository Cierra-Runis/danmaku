import 'package:danmaku/index.dart';

class ProfileModel extends ChangeNotifier {
  static late SharedPreferences _preferences;
  Profile profile = Profile();

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();

    _preferences = await SharedPreferences.getInstance();
    if (_preferences.getString('profile') == null) {
      _preferences.setString(
          'profile', jsonEncode(Profile()..themeMode = ThemeMode.system));
    }
    profile = Profile.fromJson(jsonDecode(_preferences.getString('profile')!));

    const WindowOptions windowOptions = WindowOptions(
      size: Size(1600, 900),
      minimumSize: Size(1600, 900),
      maximumSize: Size(1600, 900),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      title: Constant.APP_NAME,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    _packageInfo = await PackageInfo.fromPlatform();
    profile.currentVersion =
        'v${_packageInfo.version}+${_packageInfo.buildNumber}';

    DevTools.init();
  }

  void changeProfile(Profile profile) async {
    this.profile = profile;
    save();
    notifyListeners();
    super.notifyListeners();
  }

  void save() async {
    _preferences.setString('profile', jsonEncode(profile));
  }
}
