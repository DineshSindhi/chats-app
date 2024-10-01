
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../../../data/model/call_model.dart';
import '../../../domain/ui_helper.dart';

class CallsPage extends StatelessWidget {
  FirebaseAuth firebaseAuth=FirebaseAuth.instance;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  var dt=DateFormat.Hm();
  var dT=DateFormat.MMMMEEEEd();
  late CollectionReference calls;

  @override
  Widget build(BuildContext context) {
    calls = fireStore.collection('users').doc(firebaseAuth.currentUser!.uid).collection('calls');
    return Scaffold(
      body: StreamBuilder(
        stream: calls.orderBy('time',descending: true).snapshots(),
        builder: (_, snapshot) {
          if(snapshot.connectionState==ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }
          else if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          }
          else if (snapshot.hasData) {
            return snapshot.data!.docs.isNotEmpty ?ListView.builder(

              itemCount: snapshot.data!.size,
              itemBuilder: (context, index) {
                Map<String,dynamic> mData = snapshot.data!.docs[index].data()as Map<String,dynamic> ;
                var eachData = CallModel.fromDocs(mData);
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          ListTile(
                            leading: eachData.image!=''?
                            CircleAvatar(
                              backgroundImage: NetworkImage('${eachData.image}'),
                            )
                                :Image.asset('assets/images/logo.jpeg',),
                            title: Text('${eachData.name}'),
                            subtitle: Text('${dt.format(DateTime.fromMillisecondsSinceEpoch(int.parse('${eachData.time}')))}, ${dT.format(DateTime.fromMillisecondsSinceEpoch(int.parse('${eachData.time}')))}'),
                          ),
                      
                        ],
                      ),
                    ),
                    Column(children: [
                      eachData.isVideoCall!?
                      ZegoSendCallInvitationButton(
                        isVideoCall: true,
                        timeoutSeconds: 60,
                        icon: ButtonIcon(
                          icon: Icon(
                            Icons.videocam_outlined,
                            size: 30,
                          ),
                        ),
                        buttonSize: Size(60, 74),
                        resourceID: "zegouikit_call",
                        invitees: [
                          ZegoUIKitUser(
                            id: '${eachData.callId}',
                            name: eachData.name!,
                          ),
                        ],
                        onPressed: (_, __, ___) {
                          var data=CallModel(callId: eachData.callId, name: eachData.name, image: eachData.image, time: DateTime.now().millisecondsSinceEpoch, isVideoCall: true);
                          calls.add(data.toMap());
                        },
                      ):
                      ZegoSendCallInvitationButton(
                        isVideoCall: false,
                        timeoutSeconds: 60,
                        icon: ButtonIcon(
                          icon: Icon(
                            Icons.call,
                            size: 28,
                          ),
                        ),
                        buttonSize: Size(60, 74),
                        resourceID: "zegouikit_call",
                        invitees: [
                          ZegoUIKitUser(
                            id: '${eachData.callId}',
                            name: eachData.name!,
                          ),
                        ],
                        onPressed: (_, __, ___) {
                          var data=CallModel(callId: eachData.callId, name: eachData.name, image: eachData.image, time: DateTime.now().millisecondsSinceEpoch, isVideoCall: false);
                          calls.add(data.toMap());
                        },
                      ),
                    ],)
                  ],
                );
              },
            ):
            Center(child: mText25('No calls yet..'),);
          }
          return Container();
        },
      ),



      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal.shade700,
        onPressed: (){
        },
        child: Icon(Icons.call,color: Colors.white,),
      ),
    );
  }
}
