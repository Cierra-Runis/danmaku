import 'package:danmaku/index.dart';

class AboutWidget extends StatefulWidget {
  const AboutWidget({super.key});

  @override
  State<AboutWidget> createState() => _AboutWidgetState();
}

class _AboutWidgetState extends State<AboutWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Text(
              '关于',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: 28,
              ),
            ),
          ),
          Expanded(
            child: Consumer<ProfileModel>(
              builder: (context, profileModel, child) {
                return Text(
                  profileModel.profile.currentVersion!,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'HarmonyOS_Sans_SC',
                    color: (Theme.of(context).brightness == Brightness.dark)
                        ? Colors.white54
                        : Colors.black54,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
