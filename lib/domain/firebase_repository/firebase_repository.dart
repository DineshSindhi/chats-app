import 'package:chats/data/model/msg_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/model/call_model.dart';

class FireBaseRepository {
  static final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  static const String PREF_USER_ID = 'userId';
  static const String CHATROOM_COLLECTION = 'chatroom';
  static const String MESSAGE_COLLECTION = 'message';
  static const String CALLROOM_COLLECTION = 'callRoom';
  static const String CALLS_COLLECTION = 'calls';

  // static Future<String> getId() async {
  //   var prefs = await SharedPreferences.getInstance();
  //   return prefs.getString(PREF_USER_ID)!;
  // }

  static getChatId({required String fromId, required String toId}) {
    if (fromId.hashCode <= toId.hashCode) {
      return '${fromId}_$toId';
    } else {
      return '${toId}_$fromId';
    }
  }

  static sendTextMessage({required String toId, required String msg}) async {
    var fromId = firebaseAuth.currentUser!.uid;
    var chatId = getChatId(fromId: fromId, toId: toId);
    var currentTime = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    var msgModel = MessageModel(msgId: currentTime,
        msg: msg,
        sendAt: currentTime,
        fromId: fromId,
        toId: toId,
    );
    fireStore.collection(CHATROOM_COLLECTION).doc(chatId).collection(
        MESSAGE_COLLECTION).doc(currentTime).set(msgModel.toMap());
    fireStore.collection('chatroom').doc(chatId)
        .set({
      'ids':FieldValue.arrayUnion([fromId,toId])
    });
  }
  static sendImageMessage({required String toId,required String imgUrl,String msg=''} ) async {
    var fromId = firebaseAuth.currentUser!.uid;
    var chatId = getChatId(fromId: fromId, toId: toId);
    var currentTime = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    var msgModel = MessageModel(msgId: currentTime,
        msg: msg,
        sendAt: currentTime,
        fromId: fromId,
        toId: toId,
        msgType: 1,
        imgUrl: imgUrl
    );
    fireStore.collection(CHATROOM_COLLECTION).doc(chatId).collection(MESSAGE_COLLECTION).doc(currentTime).set(msgModel.toMap());


  }
  static Stream<QuerySnapshot<Map<String,dynamic>>>getChatStream({required String toId,}){
    var fromId = firebaseAuth.currentUser!.uid;
    var chatId = getChatId(fromId: fromId, toId: toId);
    return fireStore.collection(CHATROOM_COLLECTION).doc(chatId).collection(
        MESSAGE_COLLECTION).snapshots();
  }
  static Stream<QuerySnapshot<Map<String,dynamic>>>getLiveChatContactStream({required String fromId,}){
    return fireStore.collection(CHATROOM_COLLECTION).where('ids',arrayContains: fromId).snapshots();
  }
  static Future<DocumentSnapshot<Map<String,dynamic>>>getUserByUserId({required String userId,}){
    return fireStore.collection('users').doc(userId).get();
  }


  static updateReadStatus({required String toId,required String msgId}){
    var fromId = firebaseAuth.currentUser!.uid;
    var chatId = getChatId(fromId: fromId, toId: toId);
    var currentTime = DateTime.now()
        .millisecondsSinceEpoch
        .toString();
     fireStore.collection(CHATROOM_COLLECTION).doc(chatId).collection(MESSAGE_COLLECTION).doc(msgId).update({
      'isRead':currentTime
    });
  }

  static Stream<QuerySnapshot<Map<String,dynamic>>>getLastMsg({required String toId,}){
    var fromId = firebaseAuth.currentUser!.uid;
    var chatId = getChatId(fromId: fromId, toId: toId);
    return fireStore.collection(CHATROOM_COLLECTION).doc(chatId).collection(MESSAGE_COLLECTION).orderBy('sendAt',descending: true).limit(1).snapshots();
  }



  static Stream<QuerySnapshot<Map<String,dynamic>>>getUnreadMsgCount({required String toId,}){
    var fromId = firebaseAuth.currentUser!.uid;
    var chatId = getChatId(fromId: fromId, toId: toId);
    return fireStore.collection(CHATROOM_COLLECTION).doc(chatId).collection(MESSAGE_COLLECTION).
    where('isRead',isEqualTo: '').where('fromId',isEqualTo: toId)
        .snapshots();
  }

///calls
  static sendCallMessage({required String toId,required bool isVideoCall} ) async {
    var fromId = firebaseAuth.currentUser!.uid;
    var chatId = getChatId(fromId: fromId, toId: toId);
    var currentTime = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    var msgModel = MessageModel(msgId: currentTime,
        msg: '',
        sendAt: currentTime,
        fromId: fromId,
        toId: toId,
        msgType: 2,
      isVideoCall: isVideoCall
    );
    fireStore.collection(CHATROOM_COLLECTION).doc(chatId).collection(MESSAGE_COLLECTION).doc(currentTime).set(msgModel.toMap());


  }

}
