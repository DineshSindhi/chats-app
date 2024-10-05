import 'dart:async';
import 'package:chats/domain/ui_helper.dart';
import 'package:chats/presentation/on_board/user_info_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/model/user_model.dart';
class OtpPage extends StatefulWidget {
  String?verifyId;
  String?mobileNo;
  OtpPage({required this.verifyId,required this.mobileNo});
  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  var otpController1=TextEditingController();
  var otpController2=TextEditingController();
  var otpController3=TextEditingController();
  var otpController4=TextEditingController();
  var otpController5=TextEditingController();
  var otpController6=TextEditingController();

  FirebaseAuth firebaseAuth=FirebaseAuth.instance;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  bool isLoading=false;
  Timer? timer;
  int timerCount=59;
  @override
void initState() {
    super.initState();
    time();
  }
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.teal,
        centerTitle: true,
        leading: Icon(Icons.verified_outlined,color: Colors.white,),
        title: Text('Enter Otp for Mobile Verification',style: TextStyle(color: Colors.white),),
      ),
      body: Column(
        children: [
          SizedBox(height: 100,),
          Column(children: [
            mText20('Enter Otp for Mobile Verification'),
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Text('${widget.mobileNo}',style: TextStyle(color: Colors.teal.shade900,fontSize: 22),),
              TextButton(onPressed: (){
                Navigator.pop(context);
              }, child: mText15('Edit Number'),style: ElevatedButton.styleFrom(backgroundColor: Colors.white,),),
            ],),

            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                myTextField(controller: otpController1,first: true,last: false,mFocus: true),
                SizedBox(width: 11,),
                myTextField(controller: otpController2,first: false,last: false),
                SizedBox(width: 11,),
                myTextField(controller: otpController3,first: false,last: false),
                SizedBox(width: 11,),
                myTextField(controller: otpController4,first: false,last: false),
                SizedBox(width: 11,),
                myTextField(controller: otpController5,first: false,last: false),
                SizedBox(width: 11,),
                myTextField(controller: otpController6,first: false,last: true),
              ],),
            Container(
              margin: EdgeInsets.all(30),
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                  onPressed: ()  async {
                    List<dynamic> mList=[otpController1.text,otpController2.text,otpController3.text,otpController4.text,otpController5.text,otpController6.text];
                    if(mList.length==6){
                      String smsCode = mList.join();
                      print(mList.join());
                      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: '${widget.verifyId}', smsCode: smsCode);
                      var cred=await firebaseAuth.signInWithCredential(credential);
                      if(cred.user!.uid.isNotEmpty){
                        isLoading=true;
                        setState(() {});
                        Timer(Duration(seconds: 2), () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserInfoPage(uId: cred.user!.uid,mobileNo: widget.mobileNo!,)));
                        });
                        Timer(Duration(seconds: 2), () {
                          setState(() {
                            isLoading=false;
                          });
                        });

                      }
                    }

                  },
                  child: isLoading?Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(strokeWidth: 5,),
                      SizedBox(width: 8,),
                      Text(
                        'Verify',
                        style:
                        TextStyle(fontSize: 25, color: Colors.white),
                      )
                    ],):
                  Text(
                    'Next',
                    style:
                    TextStyle(fontSize: 25, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.teal.shade600,
                  )),
            ),
            Text(timerCount!=0? 'Didn\'t receive otp   00:${timerCount.toString()}':''),
            SizedBox(height: 5,),
            timerCount==0?
            TextButton(onPressed: (){}, child: Text('Resend Otp',style: TextStyle(color: Colors.teal,fontSize: 18),),style: ElevatedButton.styleFrom(backgroundColor: Colors.white, ),):
                Text('Resend Otp',style: TextStyle(color: Colors.grey.shade400,fontSize: 18),),
          ],),

        ],
      ),
    );
  }
  myTextField({required TextEditingController controller, bool mFocus =false,required bool first,last}){
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        cursorColor: Colors.teal,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            counterText: '',
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.teal,width: 2))
        ),

        autofocus: mFocus,
        textAlign: TextAlign.center,
        maxLength: 1,
        maxLines: 1,
        onChanged: (value){
          if(value.length==1 && last==false){
            FocusScope.of(context).nextFocus();
          }
          else if(value.length==0 && first==false){
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }
  time(){
    timer=Timer.periodic(Duration(seconds: 1), (timer) {
      if(mounted){
      setState(() {
        if(timerCount>0){
          timerCount--;
        }else{
          timer.cancel();
        }
      });}
    });
  }

}
