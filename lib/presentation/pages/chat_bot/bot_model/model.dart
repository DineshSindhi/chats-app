class MsgModel{
  String? msg;
  int? sendId;
  String? sendAt;
  bool isRead;
  MsgModel({required this.msg,required this.sendId,required this.sendAt,this.isRead=false});
}