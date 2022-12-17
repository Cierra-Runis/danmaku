import 'package:danmaku/index.dart';

import 'dart:ui';

class DevLogDrawerWidget extends StatefulWidget {
  const DevLogDrawerWidget({super.key});

  @override
  State<DevLogDrawerWidget> createState() => _DevLogDrawerWidgetState();
}

class _DevLogDrawerWidgetState extends State<DevLogDrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        backgroundColor: Colors.transparent,
        child: Consumer<ProfileModel>(
          builder: (
            context,
            profileModel,
            child,
          ) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.25, sigmaY: 0.25),
              child: ListView(
                children: [
                  ListTile(
                    title: Text(
                      jsonEncode(profileModel.profile),
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'Saira',
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      Directory.current.path,
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'Saira',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
