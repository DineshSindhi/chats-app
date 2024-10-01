class CallModel {
  String? callId;
  String? name;
  int? time;
  String? image;
  bool? isVideoCall;

  CallModel({
    required this.callId,
    required this.name,
    required this.image,
    required this.time,
    required this.isVideoCall,
  });

  factory CallModel.fromDocs(Map<String, dynamic>docs){
    return CallModel(
        callId: docs['uId'],
        name: docs['name'],
        image: docs['image'],
        time: docs['time'],
      isVideoCall: docs['isVideoCall'],
    );
  }
  Map<String, dynamic>toMap(){
    return {
      'callId':callId,
      'name':name,
      'image':image,
      'time':time,
      'isVideoCall':isVideoCall,
    };
  }
}