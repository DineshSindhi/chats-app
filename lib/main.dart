import 'package:chats/presentation/pages/chat_bot/bot_provider.dart';
import 'package:chats/presentation/splash_page/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'firebase_options.dart';
final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
  ZegoUIKit().initLog().then((value) {
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
      [ZegoUIKitSignalingPlugin()],
    );
    runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => MessageProvider(),),
          ],child: MyApp(navigatorKey: navigatorKey),));
  });
 }

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
   MyApp({super.key,required this.navigatorKey});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey:navigatorKey,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:SplashPage()
    );
  }
}

