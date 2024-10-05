
import 'package:chats/domain/ui_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../../../data/model/call_model.dart';
import '../../../domain/firebase_repository/firebase_repository.dart';
class CallsPage extends StatelessWidget {
  FirebaseAuth firebaseAuth=FirebaseAuth.instance;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  late CollectionReference calls;
  var dt=DateFormat.Hm();
  var dT=DateFormat.MMMMEEEEd();
  @override
  Widget build(BuildContext context) {
   calls= fireStore.collection('calls');
    return Scaffold(
      body:ListView(
        children: [
          StreamBuilder(
          stream: fireStore.collection('calls').where('fromId',isEqualTo: firebaseAuth.currentUser!.uid,).snapshots(),
          builder: (context, uSnapshot) {
            if(uSnapshot.hasData){
              return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: uSnapshot.data!.size,
                  itemBuilder: (context, index) {
                    var eachData=CallModel.fromDocs(uSnapshot.data!.docs[index].data());
                    return
                      Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          mText20P('Outgoing Call'),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: eachData.image!=''?
                                      CircleAvatar(
                                        backgroundImage: NetworkImage('${eachData.image}'),
                                      )
                                          :Image.asset('assets/images/avatar.jpeg',),
                                      title: Text('${eachData.name}'),
                                      subtitle: Row(
                                        children: [
                                          Icon(Icons.call_made,size: 21,),
                                          Text('${dt.format(DateTime.fromMillisecondsSinceEpoch(int.parse('${eachData.time}')))}, ${dT.format(DateTime.fromMillisecondsSinceEpoch(int.parse('${eachData.time}')))}'),
                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                              Column(children: [
                                eachData.isVideoCall==true?
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
                                      name: '${eachData.name}',
                                    ),
                                  ],
                                  onPressed: (_, __, ___) {
                                    var data=CallModel(callId: eachData.callId, name: eachData.name, image: eachData.image, time: DateTime.now().millisecondsSinceEpoch, isVideoCall: true, fromId:firebaseAuth.currentUser!.uid,fromName: eachData.fromName );
                                    calls.add(data.toMap());
                                    FireBaseRepository.sendCallMessage(toId: eachData.callId!, isVideoCall: true);

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
                                      name: '${eachData.name}',
                                    ),
                                  ],
                                  onPressed: (_, __, ___) {
                                    var data=CallModel(callId: eachData.callId, name: eachData.name, image: eachData.image, time: DateTime.now().millisecondsSinceEpoch, isVideoCall: false, fromId:firebaseAuth.currentUser!.uid ,fromName: eachData.fromName);
                                    calls.add(data.toMap());
                                    FireBaseRepository.sendCallMessage(toId: eachData.callId!, isVideoCall: false);

                                  },
                                ),
                              ],)
                            ],
                          ),
                        ],
                      );}
              );
            }else{
              return Container();
            }
          },

        ),
          StreamBuilder(
          stream: fireStore.collection('calls').where('callId',isEqualTo: firebaseAuth.currentUser!.uid).snapshots(),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.size,
                  itemBuilder: (context, index) {
                    var eachData=CallModel.fromDocs(snapshot.data!.docs[index].data());
                    return
                      Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          mText20P('Incoming Call'),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: eachData.image!=''?
                                      CircleAvatar(
                                        backgroundImage: NetworkImage('${eachData.image}'),
                                      )
                                          :Image.asset('assets/images/avatar.jpeg',),
                                      title: Text('${eachData.fromName}'),
                                      subtitle: Row(
                                        children: [
                                          Icon(Icons.call_received,size: 21,),
                                          Text('${dt.format(DateTime.fromMillisecondsSinceEpoch(int.parse('${eachData.time}')))}, ${dT.format(DateTime.fromMillisecondsSinceEpoch(int.parse('${eachData.time}')))}'),
                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                              Column(children: [
                                eachData.isVideoCall==true?
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
                                      name: '${eachData.name}',
                                    ),
                                  ],
                                  onPressed: (_, __, ___) {
                                    var data=CallModel(callId: eachData.callId, name: eachData.name, image: eachData.image, time: DateTime.now().millisecondsSinceEpoch, isVideoCall: true, fromId:firebaseAuth.currentUser!.uid,fromName: eachData.fromName);
                                    calls.add(data.toMap());
                                    FireBaseRepository.sendCallMessage(toId: eachData.callId!, isVideoCall: true);
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
                                      name: '${eachData.name}',
                                    ),
                                  ],
                                  onPressed: (_, __, ___) {
                                    var data=CallModel(callId: eachData.callId, name: eachData.name, image: eachData.image, time: DateTime.now().millisecondsSinceEpoch, isVideoCall: false, fromId:firebaseAuth.currentUser!.uid,fromName: eachData.fromName );
                                    calls.add(data.toMap());
                                    FireBaseRepository.sendCallMessage(toId: eachData.callId!, isVideoCall: false);
                                  },
                                ),
                              ],)
                            ],
                          ),
                        ],
                      );}
              );
            }else{
              return Container();
            }
          },

        ),
        ]
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