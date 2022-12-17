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
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          image: const DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage('assets/icon/app_icon.png'),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 100.0,
                              spreadRadius: 1.0,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          const Text(
                            Constant.APP_NAME,
                            style: TextStyle(
                              fontFamily: 'Saira',
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Consumer<ProfileModel>(
                            builder: (context, profileModel, child) {
                              return Text(
                                profileModel.profile.currentVersion!,
                                style: const TextStyle(
                                  fontFamily: 'Saira',
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
