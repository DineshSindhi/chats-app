import 'package:chats/presentation/pages/chat_bot/bot_model/ai_model.dart';
import 'package:chats/presentation/pages/chat_bot/chat_bot_api.dart';
import 'package:flutter/cupertino.dart';

import 'bot_model/model.dart';

class MessageProvider extends ChangeNotifier{
  List<MsgModel> messageList=[];
  sendMessage({required String msg}) async {
    try{
      messageList.insert(0, MsgModel(msg: msg, sendId: 0, sendAt: '${DateTime.now().millisecondsSinceEpoch}'));

      var mData=await ApiHelper().botApi(msg: msg);
      var data=AiModel.fromJson(mData);
      messageList.insert(0, MsgModel(
          msg: data.candidates![0].content!.parts![0].text,
          sendId: 1, sendAt: '${DateTime.now().millisecondsSinceEpoch}'));
      notifyListeners();
    }catch(e){
      messageList.insert(0, MsgModel(msg: msg, sendId: 1, sendAt: '${DateTime.now().millisecondsSinceEpoch}'));
      notifyListeners();
    }
  }
  fetchAllMsg(){
    return messageList;
  }
  msgRead(int index){
    messageList[index].isRead=true;
  }
}