class MessageModel {
  String? msgId;
  String? msg;
  String? sendAt;
  String? fromId;
  String? toId;
  String? isRead;
  int? msgType;
  String? imgUrl;
  bool? isVideoCall;

  MessageModel({
    required this.msgId,
    required this.msg,
    required this.sendAt,
    required this.fromId,
    required this.toId,
     this.isRead='',
     this.msgType=0,
     this.imgUrl='',
     this.isVideoCall=false,
  });

  factory MessageModel.fromDocs(Map<String, dynamic>docs){
    return MessageModel(
      msgId: docs['msgId'],
      msg: docs['msg'],
      sendAt: docs['sendAt'],
      fromId: docs['fromId'],
      toId: docs['toId'],
      isRead: docs['isRead'],
      msgType: docs['msgType'],
      imgUrl: docs['imgUrl'],
      isVideoCall: docs['isVideoCall'],
    );
  }
  Map<String, dynamic>toMap(){
    return {
      'msgId':msgId,
      'msg':msg,
      'sendAt':sendAt,
      'fromId':fromId,
      'toId':toId,
      'isRead':isRead,
      'msgType':msgType,
      'imgUrl':imgUrl,
      'isVideoCall':isVideoCall,
    };
  }
}