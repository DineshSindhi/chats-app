import 'package:animated_hint_textfield/animated_hint_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../data/model/msg_model.dart';
import '../../../../data/model/user_model.dart';
import '../../../../domain/firebase_repository/firebase_repository.dart';
import '../../../../domain/ui_helper.dart';
import '../../navigation_bar_pages/chat_pages/chats_data_page.dart';
import '../../theme/theme_provider.dart';
import '../chat_bot_page.dart';

class SearchPage extends StatefulWidget {
  List<UserModel> chatUsersList = [];
  SearchPage({super.key,required this.chatUsersList});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  var mController = TextEditingController();

  List<UserModel> searchList = [];
  var dt=DateFormat.Hm();
  FirebaseAuth firebaseAuth =FirebaseAuth.instance;
  bool isDark =false;
  @override
  void initState() {
    super.initState();
    searchList=widget.chatUsersList;
  }
  getData(String value){
    List<UserModel> result = [];
    if(value.isEmpty){
      result=widget.chatUsersList;
    }else{
      result= widget.chatUsersList.where((user) =>
          user.name!.toLowerCase().contains(value.toLowerCase())
      ).toList();
    }

    setState(() {
      searchList=result;
    });

  }
  @override
  Widget build(BuildContext context) {
    isDark=context.watch<ThemeProvider>().isDark;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 5, right: 5, top: 2,bottom: 10),
              child: AnimatedTextField(
                autofocus: true,
                controller: mController,
                cursorColor: Colors.teal,
                animationType: Animationtype.slide,
                onChanged: (value)=>getData(value),
                decoration: InputDecoration(
                  prefixIconColor: isDark?Colors.white:Colors.black,
                  fillColor:isDark?Colors.blueGrey.shade300:Colors.blueGrey.shade100,
                  filled: true,

                  suffixIcon: Container(
                      margin: EdgeInsets.only(right: 7),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.teal, shape: BoxShape.circle),
                      child: IconButton(
                          onPressed: () {
                            if(mController.text.isNotEmpty){
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatBotPage(
                                      query: mController.text.toString(),
                                    ),
                                  ),
                              );
                            }

                          },
                          icon: Icon(
                            Icons.send,
                            color:    Colors.white,
                          ))),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none

                  ),

                  prefixIcon:  SizedBox(
                    width:90,
                    child: Row(
                      children: [
                        mySizedBoxW5(),
                        GestureDetector(
                            onTap: (){
                              Navigator.pop(context);},
                            child: Icon(Icons.arrow_back_sharp,size: 28,)),
                        Container(
                            margin: EdgeInsets.all(7),
                            width: 40,height: 40,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Image.asset('assets/images/chatbot logo.jpeg',),)),
                      ],
                    ),
                  ),
                  contentPadding: EdgeInsets.all(12),
                ),
                hintTextStyle: TextStyle(color: isDark?Colors.black54:Colors.grey.shade700,),
                hintTexts: const [
                  'Ask me AnyThing',
                  'Ask me a question',
                  'Ask me about Flutter',
                  'Search Chat',
                ],
              ),
            ),
            searchList.isNotEmpty?
            Expanded(
              child:ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: searchList.length,
                itemBuilder: (context, index) {
                  var mData=searchList[index];
                  // searchList.clear();
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
                        if(lastMsgSnapshot.connectionState==ConnectionState.waiting){
                          return Text('');
                        }
                        if(lastMsgSnapshot.hasData){
                          var lastMsg=MessageModel.fromDocs(lastMsgSnapshot.data!.docs[0].data());
                          return lastMsg.fromId==firebaseAuth.currentUser!.uid?
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
                              :lastMsg.msgType==0?
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


                },)
            ):
            Center(child: Text('No chat found'),)
          ],
        ),

      ),
    );
  }
}