
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../../domain/ui_helper.dart';
import '../pages/navigation_bar_pages/navigation_bar_page.dart';
import 'otp_page.dart';
class MobileNoPage extends StatefulWidget {
  @override
  State<MobileNoPage> createState() => _MobileNoPageState();
}

class _MobileNoPageState extends State<MobileNoPage> {
  var phoneController=TextEditingController();

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final _FORM_KEY=GlobalKey<FormState>();
  bool isLoading =false;
  int timerCount=60;
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _FORM_KEY,
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.teal,
          centerTitle: true,
          leading: Icon(Icons.call,color: Colors.white),
          title: Text('Verify Your Mobile Number',style: TextStyle(color: Colors.white),),
        ),
        body: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            mText20('Verify Your Mobile Number'),
            Container(
              margin: EdgeInsets.all(20),
              child: TextFormField(
                style: TextStyle(fontSize: 20),
                maxLength: 10,
                controller: phoneController,
                keyboardType: TextInputType.number,
                cursorColor: Colors.teal,
                autofocus: true,
                decoration: InputDecoration(
                  focusedBorder:UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal,width: 2)
                  ),
                  contentPadding: EdgeInsets.all(10),
                  prefixIcon: SizedBox(
                    width: 85,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('+91',style: TextStyle(fontSize: 20),),
                    ),
                  ),
                  counterText:'',

                ),
                validator: (value) {
                  if(value!.isEmpty||value==''){
                    return 'Enter *Required Field';
                  }else if(value.length>10||value.length<10){
                    return 'Enter a valid Number';
                  }
                  return null;
                },
              ),
            ),

            Container(
              margin: EdgeInsets.all(10),
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                  onPressed: ()  async {

                    if(_FORM_KEY.currentState!.validate()){
                      await firebaseAuth.verifyPhoneNumber(
                        phoneNumber: '+91${phoneController.text}',
                        verificationCompleted: (PhoneAuthCredential credential) {
                        },
                        verificationFailed: (FirebaseAuthException e) {
                        },
                        codeSent: (String verificationId, int? resendToken) {
                          setState(() {
                            isLoading=true;
                          });
                          Timer(Duration(seconds: 2), () {
                            if(verificationId!=''){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => OtpPage(verifyId: verificationId,mobileNo: '+91${phoneController.text}',),));
                            }
                          });

                        },
                        codeAutoRetrievalTimeout: (String verificationId) {},
                      );

                    }

                  },
                  child: isLoading?Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 8,),
                      Text(
                        'Send Otp',
                        style:
                        TextStyle(fontSize: 25, color: Colors.white),
                      )
                    ],)
                      :Text(
                    'Next',
                    style:
                    TextStyle(fontSize: 25, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.teal.shade600,
                  )),
            )

          ],
        ),
      ),
    );

  }
  time(){
    timer=Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if(timerCount>0){
          timerCount--;
        }else{
          timer.cancel();
        }
      });
    });;
  }
}