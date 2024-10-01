import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chats/presentation/pages/chat_bot/bot_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'bot_model/model.dart';

class ChatBotPage extends StatefulWidget {
  String? query;
  ChatBotPage({required this.query});
  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  List<MsgModel> mList=[];
  var dt=DateFormat.Hm();
  var mController = TextEditingController();
  FirebaseFirestore fireStore=FirebaseFirestore.instance;


   @override
   void initState() {
    super.initState();
    context.read<MessageProvider>().sendMessage(msg: '${widget.query}');
  }
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.teal,
        leading:  GestureDetector(
            onTap: (){Navigator.pop(context);},
            child: Icon(Icons.arrow_back_rounded,size: 28,)),
      ),
      backgroundColor: Colors.blueGrey.shade100,
      body: Column(
        children: [
          Expanded(
            child:Consumer<MessageProvider>(
              builder: (context, value, child) {
                mList=value.fetchAllMsg();
                return ListView.builder(
                  reverse: true,
                  itemCount: mList.length,
                  itemBuilder: (context, index) {
                    return mList[index].sendId==0?userChat(mList[index]):botChat(mList[index],index);
                  },);
              },
            )
          ),
          Padding(
            padding: const EdgeInsets.only(left: 9.0,right: 9,bottom: 9,top: 5),
            child: TextField(
              controller: mController,
              decoration: InputDecoration(
                hintText: 'Ask me a question',
                filled: true,
                fillColor: Colors.white,
                suffixIcon: Container(
                    margin: EdgeInsets.only(right: 7),
                    width: 40,height: 40,
                    decoration: BoxDecoration(color: Colors.grey.shade400,shape: BoxShape.circle),
                    child: IconButton(
                      onPressed: (){
                        if (mController.text.isNotEmpty) {
                          context.read<MessageProvider>().sendMessage(msg: mController.text.toString());
                        }
                        mController.clear();
                      },
                      icon: Icon(Icons.arrow_upward,color: Colors.black,)
                    ),
                ),

                border:
                    OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11),
                        borderSide: BorderSide.none

                    ),

              ),
            ),
          ),
        ],
      ),
    );
  }
  userChat(MsgModel msgModel){
     var time=dt.format(DateTime.fromMillisecondsSinceEpoch(int.parse('${msgModel.sendAt}')));
     return Row(
       children: [
         Container(
           width: MediaQuery.of(context).size.width*0.5,
         ),
         Flexible(child: Container(
           margin: EdgeInsets.all(7),
           padding: EdgeInsets.all(11),
           decoration: BoxDecoration(
             color: Colors.teal.shade400,
             borderRadius: BorderRadius.only(
                 bottomLeft: Radius.circular(10),
                 topLeft: Radius.circular(10),
                 bottomRight: Radius.circular(10),
             )
           ),
           child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             crossAxisAlignment: CrossAxisAlignment.end,
             children: [
               Flexible(child: Text('${msgModel.msg}')),
               Align(
                 alignment: Alignment.bottomRight,
                   child: Text(time,style: TextStyle(fontSize: 10),)),
             ],
           ),
         )),
       ],
     );
  }
  botChat(MsgModel msgModel,int index){
    var time=dt.format(DateTime.fromMillisecondsSinceEpoch(int.parse('${msgModel.sendAt}')));
    return Row(
      children: [

        Flexible(child: Container(
          margin: EdgeInsets.all(7),
          padding: EdgeInsets.all(11),
          decoration: BoxDecoration(
              color: Colors.teal.shade400,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
                topRight: Radius.circular(10),

              )
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              Expanded(
                child: msgModel.isRead?Text('${msgModel.msg}',style: TextStyle(fontSize: 16)):AnimatedTextKit(

                  repeatForever: false,
                  displayFullTextOnTap: true,
                  isRepeatingAnimation: false,
                  stopPauseOnTap: true,
                  onFinished: (){
                    context.read<MessageProvider>().msgRead(index);
                  },
                  totalRepeatCount: 0,
                  animatedTexts: [
                    TyperAnimatedText('${msgModel.msg}',speed: Duration(milliseconds: 5))],
                ),
              ),
              Align(
                  alignment: Alignment.bottomRight,
                  child: Text(time,style: TextStyle(fontSize: 10))),
            ],
          ),
        )),
        Container(
          width: MediaQuery.of(context).size.width*0.3,
        ),
      ],
    );
  }
}
