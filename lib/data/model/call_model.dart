class CallModel {
  String? callId;
  String? fromId;
  String? name;
  int? time;
  String? image;
  bool? isVideoCall;
  String? fromName;

  CallModel({
    required this.callId,
    required this.name,
    required this.image,
    required this.time,
    required this.isVideoCall,
    required this.fromId,
    required this.fromName,
  });

  factory CallModel.fromDocs(Map<String, dynamic>docs){
    return CallModel(
        callId: docs['callId'],
        name: docs['name'],
        image: docs['image'],
        time: docs['time'],
      isVideoCall: docs['isVideoCall'],
      fromId: docs['fromId'],
      fromName: docs['fromName'],
    );
  }
  Map<String, dynamic>toMap(){
    return {
      'callId':callId,
      'name':name,
      'image':image,
      'time':time,
      'isVideoCall':isVideoCall,
      'fromId':fromId,
      'fromName':fromName,
    };
  }
}