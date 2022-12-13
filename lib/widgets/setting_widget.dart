import 'package:danmaku/index.dart';

class SettingWidget extends StatefulWidget {
  const SettingWidget({super.key});

  @override
  State<SettingWidget> createState() => _SettingWidgetState();
}

class _SettingWidgetState extends State<SettingWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Text(
              '设置',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: 28,
              ),
            ),
          ),
          Expanded(
            child: PreferenceList(
              children: [
                PreferenceListSection(
                  children: [
                    PreferenceListItem(
                      onTap: () => _themeSelectorDialog(context),
                      title: const Text(
                        '深色模式',
                        style: TextStyle(
                          fontFamily: 'HarmonyOS_Sans_SC',
                        ),
                      ),
                      detailText: Consumer<ProfileModel>(
                        builder: (context, profileModel, child) {
                          return Text(
                            profileModel.profile.themeMode == ThemeMode.system
                                ? '跟随系统'
                                : profileModel.profile.themeMode ==
                                        ThemeMode.dark
                                    ? '常暗模式'
                                    : '常亮模式',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'HarmonyOS_Sans_SC',
                              color: (Theme.of(context).brightness ==
                                      Brightness.dark)
                                  ? Colors.white54
                                  : Colors.black54,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _themeSelectorDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return const ThemeSelectorWidget();
      },
    );
  }
}
