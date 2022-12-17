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
                fontSize: 36,
                fontWeight: FontWeight.bold,
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
                    PreferenceListItem(
                      onTap: () async {
                        String? selectedDirectory =
                            await FilePicker.platform.getDirectoryPath();
                        if (selectedDirectory != null) {
                          profileModel.changeProfile(profileModel.profile
                            ..userDataDir = selectedDirectory);
                        }
                      },
                      title: const Text(
                        '用户文件夹',
                        style: TextStyle(
                          fontFamily: 'HarmonyOS_Sans_SC',
                        ),
                      ),
                      detailText: Consumer<ProfileModel>(
                        builder: (context, profileModel, child) {
                          return Text(
                            profileModel.profile.userDataDir!,
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
                    Consumer<ProfileModel>(
                      builder: (context, profileModel, child) {
                        return PreferenceListSwitchItem(
                          title: const Text(
                            '开机自启动',
                            style: TextStyle(
                              fontFamily: 'HarmonyOS_Sans_SC',
                            ),
                          ),
                          detailText: Text(
                            profileModel.profile.startUp! ? '开启　' : '关闭　',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'HarmonyOS_Sans_SC',
                              color: (Theme.of(context).brightness ==
                                      Brightness.dark)
                                  ? Colors.white54
                                  : Colors.black54,
                            ),
                          ),
                          value: profileModel.profile.startUp!,
                          onChanged: (value) async {
                            profileModel.changeProfile(
                              profileModel.profile..startUp = value,
                            );
                            if (value) {
                              await launchAtStartup.enable();
                            } else {
                              await launchAtStartup.disable();
                            }
                          },
                        );
                      },
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
