import 'package:danmaku/index.dart';

import 'package:system_tray/system_tray.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

String getTrayImagePath(String imageName) {
  return Platform.isWindows
      ? 'assets/icon/$imageName.ico'
      : 'assets/icon/$imageName.png';
}

String getImagePath(String imageName) {
  return Platform.isWindows
      ? 'assets/icon/$imageName.bmp'
      : 'assets/icon/$imageName.png';
}

IconData getBatteryIconByLevel(int level) {
  int index = (level / 25).ceil();
  switch (index) {
    case 4:
      return Typicons.bat4;
    case 3:
      return Typicons.bat3;
    case 2:
      return Typicons.bat2;
    case 1:
      return Typicons.bat1;
  }
  return Typicons.bat4;
}

class _HomePageState extends State<HomePage> {
  final AppWindow _appWindow = AppWindow();
  final SystemTray _systemTray = SystemTray();
  final Menu _trayMenu = Menu();

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  late Widget _selectedWidget;

  static const Map<String, Widget> _widgetOptions = {
    'setting': SettingWidget(),
    'about': AboutWidget(),
  };

  Map<String, dynamic> _deviceData = <String, dynamic>{};

  Timer? _timer;

  final Battery _battery = Battery();
  late Future<int> _batteryLevel;

  @override
  void initState() {
    initSystemTray();
    initPlatformState();
    _onItemTapped('setting');
    _batteryLevel = _battery.batteryLevel;
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {
        _batteryLevel = _battery.batteryLevel;
      }),
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  void _onItemTapped(String widgetName) {
    setState(
      () {
        _selectedWidget = _widgetOptions[widgetName] ??
            Center(child: Text('无 $widgetName 组件'));
      },
    );
  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};
    try {
      if (Platform.isMacOS) {
        deviceData = _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo);
      } else if (Platform.isWindows) {
        deviceData = _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
      'kernelVersion': data.kernelVersion,
      'osRelease': data.osRelease,
      'activeCPUs': data.activeCPUs,
      'memorySize': data.memorySize,
      'cpuFrequency': data.cpuFrequency,
      'systemGUID': data.systemGUID,
    };
  }

  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
      'userName': data.userName,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'buildNumber': data.buildNumber,
      'platformId': data.platformId,
      'csdVersion': data.csdVersion,
      'servicePackMajor': data.servicePackMajor,
      'servicePackMinor': data.servicePackMinor,
      'suitMask': data.suitMask,
      'productType': data.productType,
      'reserved': data.reserved,
      'buildLab': data.buildLab,
      'buildLabEx': data.buildLabEx,
      'digitalProductId': data.digitalProductId,
      'displayVersion': data.displayVersion,
      'editionId': data.editionId,
      'installDate': data.installDate,
      'productId': data.productId,
      'productName': data.productName,
      'registeredOwner': data.registeredOwner,
      'releaseId': data.releaseId,
      'deviceId': data.deviceId,
    };
  }

  Future<void> initSystemTray() async {
    await _systemTray.initSystemTray(
      title: Constant.APP_NAME,
      toolTip: Constant.APP_NAME,
      iconPath: getTrayImagePath('app_icon'),
    );

    _systemTray.registerSystemTrayEventHandler(
      (eventName) {
        DevTools.printLog('对托盘进行一个 $eventName 的动作');
        if (eventName == kSystemTrayEventClick) {
          Platform.isWindows
              ? _appWindow.show()
              : _systemTray.popUpContextMenu();
        } else if (eventName == kSystemTrayEventRightClick) {
          Platform.isWindows
              ? _systemTray.popUpContextMenu()
              : _appWindow.show();
        }
      },
    );

    await _trayMenu.buildFrom(
      [
        MenuItemLabel(
          label: '显示',
          onClicked: (menuItem) => _appWindow.show(),
        ),
        MenuItemLabel(
          label: '隐藏',
          onClicked: (menuItem) => _appWindow.hide(),
        ),
        MenuItemLabel(
          label: '退出',
          onClicked: (menuItem) => _appWindow.close(),
        ),
      ],
    );

    _systemTray.setContextMenu(_trayMenu);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          Constant.APP_NAME,
          style: TextStyle(
            fontFamily: 'Saira',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _appWindow.hide();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 7,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).highlightColor,
                          strokeAlign: StrokeAlign.center,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: PreferenceList(
                            children: [
                              PreferenceListSection(
                                children: [
                                  PreferenceListItem(
                                    icon: const Icon(Icons.settings),
                                    title: const Text(
                                      '设置',
                                      style: TextStyle(
                                        fontFamily: 'HarmonyOS_Sans_SC',
                                      ),
                                    ),
                                    onTap: () => _onItemTapped('setting'),
                                  ),
                                  PreferenceListItem(
                                    icon: const Icon(Icons.info),
                                    title: const Text(
                                      '关于',
                                      style: TextStyle(
                                        fontFamily: 'HarmonyOS_Sans_SC',
                                      ),
                                    ),
                                    onTap: () => _onItemTapped('about'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 20,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).highlightColor,
                          strokeAlign: StrokeAlign.center,
                        ),
                      ),
                    ),
                    child: _selectedWidget,
                  ),
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).highlightColor,
                  strokeAlign: StrokeAlign.center,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Tooltip(
                          message: '',
                          child: Text(
                            '设备名：${_deviceData["computerName"]}',
                            style: TextStyle(
                              fontSize: 12,
                              color: (Theme.of(context).brightness ==
                                      Brightness.dark)
                                  ? Colors.white54
                                  : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Tooltip(
                          message: '',
                          child: Text(
                            Platform.isWindows
                                ? '用户名：${_deviceData["userName"]}'
                                : '用户名：${_deviceData["hostName"]}',
                            style: TextStyle(
                              fontSize: 12,
                              color: (Theme.of(context).brightness ==
                                      Brightness.dark)
                                  ? Colors.white54
                                  : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      FutureBuilder<int>(
                        future: _batteryLevel,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return InkWell(
                              onTap: () {},
                              child: Tooltip(
                                message: '当前电量为 ${snapshot.data!}',
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 5),
                                  child: Icon(
                                    getBatteryIconByLevel(
                                      snapshot.data!,
                                    ),
                                    color: (Theme.of(context).brightness ==
                                            Brightness.dark)
                                        ? Colors.white54
                                        : Colors.black54,
                                    size: 20,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const Icon(Typicons.bat4);
                        },
                      )
                    ],
                  ),
                ),
                const Expanded(child: Center(child: Text('|'))),
                Expanded(
                  flex: 10,
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        launchUrlString(
                          'https://github.com/Cierra-Runis',
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: Tooltip(
                        message: 'https://github.com/Cierra-Runis',
                        child: Text(
                          'Power by Cierra_Runis',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontFamily: 'Saira',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Expanded(child: Center(child: Text('|'))),
                const Expanded(
                  flex: 10,
                  child: Center(child: HiToKoToWidget()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
