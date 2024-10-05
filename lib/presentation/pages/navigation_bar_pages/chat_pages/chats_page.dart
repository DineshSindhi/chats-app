import 'package:chats/domain/firebase_repository/firebase_repository.dart';
import 'package:chats/domain/ui_helper.dart';
import 'package:chats/presentation/pages/chat_bot/bot_model/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import '../../../../data/model/msg_model.dart';
import '../../../../data/model/user_model.dart';
import 'chats_data_page.dart';
import 'contact_page.dart';
class ChatsPage extends StatefulWidget {
  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
 @override
  void initState() {
    super.initState();
    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: 1939509096,
      appSign:'c4dbb69c88eae93262bc11695a7c283a9dda228c4f1d330a6f9d3b6f88935d2b',
      userID: firebaseAuth.currentUser!.uid,
      userName: 'you',
      plugins: [ZegoUIKitSignalingPlugin(),],
    );
  }
  var searchController=TextEditingController();
 FirebaseAuth firebaseAuth = FirebaseAuth.instance;
 FirebaseFirestore fireStore = FirebaseFirestore.instance;
 var dt=DateFormat.Hm();
 List<UserModel> mList = [];
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  SearchPage(chatUsersList: mList,),));
              },
              child: Container(width: double.infinity,height: 52,
              margin: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade100,
                borderRadius: BorderRadius.circular(22)
              ),
                child: Row(
                  children: [
                    Container(
                        margin: EdgeInsets.all(7),
                        width: 40,height: 40,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.asset('assets/images/chatbot logo.jpeg',),)),
                    Text('Ask Chats or Search',style: TextStyle(fontSize: 22,color: Colors.grey.shade700,fontWeight: FontWeight.w400),),
                  ],
                ),
              )),
          StreamBuilder(
            stream: FireBaseRepository.getLiveChatContactStream(fromId: firebaseAuth.currentUser!.uid),
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
                var listUserId= List.generate(snapshot.data!.docs.length, (index) {
                  var mData=snapshot.data!.docs[index].get('ids')as List<dynamic>;
                  mData.removeWhere((element) => element==firebaseAuth.currentUser!.uid);
                  return mData[0];
                });
                 return listUserId.isNotEmpty?ListView.builder(
                   shrinkWrap: true,
                   physics: NeverScrollableScrollPhysics(),
                   itemCount: listUserId.length,
                   itemBuilder: (context, index) {
                     return FutureBuilder(future: FireBaseRepository.getUserByUserId(userId: listUserId[index]),
                         builder: (context, uSnapshot) {
                       if(uSnapshot.hasData){
                         mList.add(UserModel.fromDocs(uSnapshot.data!.data()!));
                         var mData=UserModel.fromDocs(uSnapshot.data!.data()!);

                         return ListTile(
                           onTap: (){
                             Navigator.push(context, MaterialPageRoute(builder: (context) => ChatsDataPage(name: '${mData.name}',uId: '${mData.uId}',image: '${mData.image}'),));
                           },
                           leading: CircleAvatar(
                             backgroundColor: Colors.grey,
                               backgroundImage:mData.image!=''? NetworkImage('${mData.image}'):AssetImage('assets/images/avatar.jpeg')as ImageProvider
                           ),
                           title: Text('${mData.name}'),
                           subtitle: StreamBuilder(stream: FireBaseRepository.getLastMsg(toId: mData.uId!),
                               builder: (context, lastMsgSnapshot) {
                             if(snapshot.connectionState==ConnectionState.waiting){
                               return CircularProgressIndicator();
                             }
                             if(lastMsgSnapshot.hasData){
                               var lastMsg=MessageModel.fromDocs(lastMsgSnapshot.data!.docs[0].data());
                               return lastMsg.fromId==firebaseAuth.currentUser!.uid?
                                   lastMsg.msgType==2?
                                   Row(
                                     children: [
                                       Icon(lastMsg.isVideoCall==true?Icons.videocam_outlined:Icons.phone_rounded,color:Colors.blueGrey,size: 16,),
                                       mySizedBoxW5(),
                                       Text(lastMsg.isVideoCall==true?'Video Call':'Voice Call'),
                                     ],
                                   )
                                       :
                               lastMsg.msgType==0?
                               Row(
                                 children: [
                                   Icon(Icons.done_all_outlined,color: lastMsg.isRead!=''?Colors.blue:Colors.blueGrey,size: 16,),
                                   mySizedBoxW5(),
                                   SizedBox(
                                    width: 200,
                                     //height:30,
                                     child: Text(lastMsg.msg!,overflow: TextOverflow.ellipsis,maxLines: 1,),
                                   ),
                                 ],
                               ):lastMsg.msg!=''?
                               Row(
                                 children: [
                                   Icon(Icons.done_all_outlined,color: lastMsg.isRead!=''?Colors.blue.shade900:Colors.blueGrey,size: 16,),
                                   mySizedBoxW5(),
                                   Icon(Icons.image,color: Colors.blueGrey,size: 16,),
                                   mySizedBoxW5(),
                                   SizedBox(
                                     width: 200,
                                     //height:30,
                                     child: Text(lastMsg.msg!,overflow: TextOverflow.ellipsis,maxLines: 1,),
                                   ),
                                 ],
                               ):
                               Row(
                                 children: [
                                   Icon(Icons.done_all_outlined,color: lastMsg.isRead!=''?Colors.blue.shade900:Colors.blueGrey,size: 16,),
                                   mySizedBoxW5(),
                                   Icon(Icons.image,color:Colors.blueGrey.shade600,size: 16,),
                                   mySizedBoxW5(),
                                   Text('Photo'),
                                 ],
                               )
                                   :
                               lastMsg.msgType==2?
                               Row(
                                 children: [
                                   Icon(lastMsg.isVideoCall==true?Icons.videocam_outlined:Icons.phone_rounded,color:Colors.blueGrey,size: 16,),
                                   mySizedBoxW5(),
                                   Text(lastMsg.isVideoCall==true?'Video Call':'Voice Call'),
                                 ],
                               ):
                               lastMsg.msgType==0?
                               SizedBox(
                                 width: 200,
                                 //height:30,
                                 child: Text(lastMsg.msg!,overflow: TextOverflow.ellipsis,maxLines: 1,),
                               ):lastMsg.msg!=''?
                               Row(
                                 children: [
                                   Icon(Icons.image,color: Colors.blueGrey.shade600,size: 16,),
                                   mySizedBoxW5(),
                                   SizedBox(
                                     width: 200,
                                     //height:30,
                                     child: Text(lastMsg.msg!,overflow: TextOverflow.ellipsis,maxLines: 1,),
                                   ),
                                 ],
                               ):
                               Row(
                                 children: [
                                   Icon(Icons.image,color:Colors.blueGrey.shade600,size: 16,),
                                   mySizedBoxW5(),
                                   Text('Photo'),
                                 ],
                               );
                             }else{
                               return Text('');
                             }

                               },
                           ),
                           trailing: Padding(
                             padding: const EdgeInsets.all(4),
                             child: Column(children: [
                               StreamBuilder(stream: FireBaseRepository.getLastMsg(toId: mData.uId!),
                                 builder: (context, lastMsgSnapshot) {
                                   if(snapshot.connectionState==ConnectionState.waiting){
                                     return CircularProgressIndicator();
                                   }
                                   if(lastMsgSnapshot.hasData){
                                     var lastMsg=MessageModel.fromDocs(lastMsgSnapshot.data!.docs[0].data());
                                     return Text(dt.format(DateTime.fromMillisecondsSinceEpoch(int.parse(lastMsg.sendAt!))),style: TextStyle(fontSize: 15),);
                                   }else{
                                     return Text('');
                                   }

                                 },
                               ),
                               StreamBuilder(stream: FireBaseRepository.getUnreadMsgCount(toId: mData.uId!),
                                 builder: (context, unReadMsgCountSnapshot) {
                                   if(unReadMsgCountSnapshot.hasData&&unReadMsgCountSnapshot.data!.docs.isNotEmpty){
                                     return CircleAvatar(
                                         radius: 10,backgroundColor: Colors.teal.shade300,
                                         child: Text('${unReadMsgCountSnapshot.data!.docs.length}'));
                                   }
                                   return Text('');


                                 },
                               ),
                             ],),
                           ),

                         );
                       }else{
                         return Container();
                       }
                         },

                     );


                   },):
              Center(child: Text('No Chat Yet..'),);
            }
              return Container();
            }
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal.shade700,
        onPressed: (){
          getPermission();
        },
        child: Icon(Icons.add_comment,color: Colors.white,),
      ),
    );

  }
  getPermission()async {
    if (await Permission.contacts.isGranted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ContactPage(),));
    } else {
      await Permission.contacts.request();
    }
  }

}

