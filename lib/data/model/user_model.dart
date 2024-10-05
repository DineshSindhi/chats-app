class UserModel {
  String? uId;
  String? name;
  String? mobile_no;
  String? about;
  String? image;
  bool? isOnline;
  bool? isTyping;
  String? lastSeen;

  UserModel({
    required this.uId,
    this.name,
    required this.mobile_no,
    required this.about,
    required this.image,
    required this.isOnline,
     this.lastSeen='',
     this.isTyping=false,
  });

  factory UserModel.fromDocs(Map<String, dynamic>docs){
    return UserModel(
        uId: docs['uId'],
        name: docs['name'],
        mobile_no: docs['mobile_no'],
        about: docs['about'],
        image: docs['image'],
      isOnline: docs['isOnline'],
      lastSeen: docs['lastSeen'],
      isTyping: docs['isTyping'],
    );
  }
  Map<String, dynamic>toMap(){
    return {
      'uId':uId,
      'name':name,
      'mobile_no':mobile_no,
      'about':about,
      'image':image,
      'isOnline':isOnline,
      'lastSeen':lastSeen,
      'isTyping':isTyping,
    };
  }
}