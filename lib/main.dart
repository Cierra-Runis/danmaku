import 'package:danmaku/index.dart';

ProfileModel profileModel = ProfileModel();

void main() =>
    profileModel.init().then((e) => runApp(const DanmakuApp())).catchError(
      (err) async {
        Directory tempDir = await getTemporaryDirectory();
        File logFile = File(
          'C:\\Users\\28642\\Desktop\\'
          '${Constant.APP_NAME}-${DateTime.now().toString()}-crash-log.txt',
        );
        await logFile.writeAsString(err.toString());
        OpenAppFile.open(logFile.path);
      },
    );

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class DanmakuApp extends StatefulWidget {
  const DanmakuApp({super.key});

  @override
  State<DanmakuApp> createState() => _DanmakuAppState();
}

class _DanmakuAppState extends State<DanmakuApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => profileModel),
      ],
      child: Consumer<ProfileModel>(
        builder: (context, profileModel, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: lightColorScheme,
              fontFamily: 'HarmonyOS_Sans_SC',
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: darkColorScheme,
              fontFamily: 'HarmonyOS_Sans_SC',
            ),
            // 控制主题样式
            themeMode: profileModel.profile.themeMode,
            // 进入 SplashPage()
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
