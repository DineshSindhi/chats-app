
import 'package:chats/presentation/pages/chat_bot/bot_provider.dart';
import 'package:chats/presentation/pages/theme/theme_provider.dart';
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
            ChangeNotifierProvider(create: (context) => ThemeProvider()..init(),),
          ],child: MyApp(navigatorKey: navigatorKey,),));
  });

 }

class MyApp extends StatelessWidget {

  final GlobalKey<NavigatorState> navigatorKey;

   MyApp({super.key,required this.navigatorKey,});
  @override
  Widget build(BuildContext context) {
    final theme=Provider.of<ThemeProvider>(context);
    return MaterialApp(
      navigatorKey:navigatorKey,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
        themeMode:  ThemeMode.dark,
        darkTheme: theme.isDark?  ThemeData.dark(): ThemeData.light(),
      home:const SplashPage()
    );
  }
}

//themeMode: notifier.isDark? ThemeMode.dark : ThemeMode.light,
//darkTheme: notifier.isDark? notifier.darkTheme : notifier.lightTheme,