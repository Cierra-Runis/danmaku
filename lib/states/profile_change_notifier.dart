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

    DevTools.printLog('[001] 程序初始化中');

    launchAtStartup.setup(
      appName: Constant.APP_NAME,
      appPath: Platform.resolvedExecutable,
    );

    _preferences = await SharedPreferences.getInstance();
    if (_preferences.getString('profile') == null) {
      _preferences.setString(
        'profile',
        jsonEncode(
          Profile()
            ..themeMode = ThemeMode.system
            ..userDataDir = Directory.current.path + r'\user_data'
            ..startUp = true,
        ),
      );
      await Directory(Directory.current.path + r'\user_data').create();
    }
    profile = Profile.fromJson(jsonDecode(_preferences.getString('profile')!));

    profile.themeMode ??= ThemeMode.system;
    profile.userDataDir ??= Directory.current.path + r'\user_data';
    profile.startUp ??= true;

    if (profile.startUp!) {
      await launchAtStartup.enable();
    } else {
      await launchAtStartup.disable();
    }

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
    DevTools.printLog('[002] profile 变更为 ${profile.toJson().toString()}');
    save();
    notifyListeners();
    super.notifyListeners();
  }

  void save() async {
    _preferences.setString('profile', jsonEncode(profile));
  }
}
