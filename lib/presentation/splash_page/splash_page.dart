import 'dart:async';
import 'package:chats/presentation/pages/navigation_bar_pages/navigation_bar_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../on_board/phone_no_verification_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    login();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
                child: Image.asset('assets/images/logo.jpeg',width: 200,height: 200,)),
        ],),
      ),
    );
  }

   login()async{

    Timer(Duration(seconds: 4), ()  {
      FirebaseAuth auth =FirebaseAuth.instance;
      var user=auth.currentUser;
      if(user != null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => NavigationBarPage(),));
      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => MobileNoPage(),));
      }
    });
   }
}
