import 'dart:io';
import 'package:chats/data/model/user_model.dart';
import 'package:chats/domain/ui_helper.dart';
import 'package:chats/presentation/pages/navigation_bar_pages/navigation_bar_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class UserInfoPage extends StatefulWidget {
  String uId;
  String mobile_no;
   UserInfoPage({required this.uId,required this.mobile_no});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final _scrollController = ScrollController();
  bool _emojiShowing = false;
   var mController=TextEditingController();
   FirebaseFirestore fireStore = FirebaseFirestore.instance;
   FirebaseAuth firebaseAuth=FirebaseAuth.instance;
  File? actualImage;
  bool isProfile=false;
  late CollectionReference userInfo;
   final _FORM_KEY=GlobalKey<FormState>();
  FocusNode focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    userInfo = fireStore.collection('users');
    return Form(
      key: _FORM_KEY,
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.teal,
        centerTitle: true,
          title: Text('Profile Info',style: TextStyle(color: Colors.white),),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: fireStore.collection('users').where('uId', isEqualTo: firebaseAuth.currentUser!.uid).snapshots(),
                builder: (_, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('${snapshot.error}'),
                    );
                  } else if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.size,
                      itemBuilder: (context, index) {
                        var mData = snapshot.data!.docs[index].data();
                        var eachData = UserModel.fromDocs(mData);
                        mController.text='${eachData.name}';
                        return  Column(
                          children: [
                            SizedBox(height: 15,),
                            mText20('Please provider your name and profile'),
                            mText20('photo'),
                            SizedBox(height: 15,),
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blueGrey,
                                image: actualImage!=null?
                                DecorationImage(
                                    image: FileImage(actualImage!),fit: BoxFit.fill
                                ):eachData.image!=null?
                                DecorationImage(
                                    image: NetworkImage(eachData.image!),fit: BoxFit.fill
                                ):
                                DecorationImage(
                                  image: AssetImage('assets/images/avatar.jpeg',),
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                    margin: EdgeInsets.only(right: 7),
                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                        color: Colors.teal, shape: BoxShape.circle),
                                    child: IconButton(
                                        onPressed: () {
                                          showModalBottomSheet(context: context, builder: (context) {
                                            return mySheet();
                                          },);
                                        },
                                        icon: Icon(
                                          Icons.camera_alt_outlined,
                                          color: Colors.white,
                                        ))),
                              ),
                            ),
                            SizedBox(height: 20,),
                            Padding(
                              padding:  EdgeInsets.only(left: 15,right: 10,),
                              child: Row(children: [
                                Expanded(child: TextFormField(
                                  controller: mController,
                                  validator: (value) {
                                    if(value!.isEmpty||value==''){
                                      return 'Enter *Required Field';
                                    }
                                    return null;
                                  },
                                  cursorColor: Colors.teal,
                                  decoration: InputDecoration(
                                                    hintText: 'Type your name here',
                                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.teal,width: 2))
                                  ),
                                )),
                                IconButton(onPressed: (){
                                  focusNode.unfocus();
                                  focusNode.canRequestFocus = false;
                                  setState(() {
                                    _emojiShowing = !_emojiShowing;
                                  });
                                }, icon: Icon(Icons.emoji_emotions_outlined,size: 30,color: Colors.blueGrey.shade600,)),
                              ],),
                            ),

                          ],);

                      },
                    );
                  }
                  return Container();
                },
              ),
            ),
            Container(
              margin: EdgeInsets.all(30),
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                  onPressed: ()   {
                    if(_FORM_KEY.currentState!.validate()){
                     if(isProfile){
                       var time=DateTime.now().millisecondsSinceEpoch;
                       var image=FirebaseStorage.instance.ref().child('profile_pic/IMG_$time.jpg');
                       image.putFile(actualImage!).then((value) async {
                         var imgUrl=await value.ref.getDownloadURL();
                         print('imgUri:$imgUrl');
                         var data= UserModel(uId: widget.uId, name: mController.text.toString(), mobile_no: widget.mobile_no, about: 'Hey Chats', image: imgUrl,isOnline: false);
                         userInfo.doc(widget.uId).set(data.toMap());
                         userInfo.doc(widget.uId).update({
                           'name':mController.text.toString(),
                           'image': imgUrl,
                         });
                       });
                       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NavigationBarPage(),));
                     }else{
                       userInfo.doc(widget.uId).update({
                         'name':mController.text.toString(),
                       });
                       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NavigationBarPage(),));
                     }
                    }
                  },
                  child: Text(
                    'Next',
                    style:
                    TextStyle(fontSize: 25, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.teal.shade600,
                  )),
            ),
            _emojiShowing ? emojiPicker() : Container(),
          ],
        ),

      ),
    );
  }
   Widget mySheet() {
     return Container(
         height: 200,
         decoration: BoxDecoration(
             borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
         child: Column(
           children: [
             Container(
                 margin: EdgeInsets.all(10),
                 width: 50,
                 height: 6,
                 decoration: BoxDecoration(
                     color: Colors.grey,
                   borderRadius: BorderRadius.circular(20)
                 ),
                 ),
             mText25('Profile Photo'),
             Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
               children: [
                 Column(
                   children: [
                     Container(
                         margin: EdgeInsets.only(top: 10),
                         width: 60,
                         height: 60,
                         decoration: BoxDecoration(
                             color: Colors.grey.shade300, shape: BoxShape.circle),
                         child: IconButton(
                             onPressed: () async {
                               Navigator.pop(context);
                               var image= ImagePicker();
                               XFile? pickImage=await image.pickImage(source: ImageSource.camera);
                               if(pickImage!=null){
                                 var  cropImage=await ImageCropper().cropImage(sourcePath: pickImage.path,
                                   uiSettings: [
                                     AndroidUiSettings(
                                       toolbarTitle: 'Cropper',
                                       toolbarColor: Colors.deepOrange,
                                       toolbarWidgetColor: Colors.white,
                                       aspectRatioPresets: [
                                         CropAspectRatioPreset.original,
                                         CropAspectRatioPreset.square,
                                         CropAspectRatioPreset.ratio16x9,

                                       ],
                                     ),
                                     IOSUiSettings(
                                       title: 'Cropper',
                                       aspectRatioPresets: [
                                         CropAspectRatioPreset.original,
                                         CropAspectRatioPreset.square,
                                         // IMPORTANT: iOS supports only one custom aspect ratio in preset list
                                       ],
                                     ),
                                     WebUiSettings(
                                       context: context,
                                     ),
                                   ],
                                 );
                                 actualImage=File(cropImage!.path);
                                 setState(() {

                                 });
                                 isProfile=true;
                               }

                             },
                             icon: Icon(
                               Icons.camera_alt_outlined,
                               color: Colors.teal,size: 30,
                             ))),
                     mText18('Camera')
                   ],
                 ),
                 Column(
                   children: [
                     Container(
                         margin: EdgeInsets.only(top: 10),
                         width: 60,
                         height: 60,
                         decoration: BoxDecoration(
                             color: Colors.grey.shade300, shape: BoxShape.circle),
                         child: IconButton(
                             onPressed: () async {
                               Navigator.pop(context);
                               var image= ImagePicker();
                               XFile? pickImage=await image.pickImage(source: ImageSource.gallery);
                               if(pickImage!=null){
                                 var  cropImage=await ImageCropper().cropImage(sourcePath: pickImage.path,
                                   uiSettings: [
                                     AndroidUiSettings(
                                       toolbarTitle: 'Cropper',
                                       toolbarColor: Colors.deepOrange,
                                       toolbarWidgetColor: Colors.white,
                                       aspectRatioPresets: [
                                         CropAspectRatioPreset.original,
                                         CropAspectRatioPreset.square,
                                         CropAspectRatioPreset.ratio16x9,

                                       ],
                                     ),
                                     IOSUiSettings(
                                       title: 'Cropper',
                                       aspectRatioPresets: [
                                         CropAspectRatioPreset.original,
                                         CropAspectRatioPreset.square,
                                         // IMPORTANT: iOS supports only one custom aspect ratio in preset list
                                       ],
                                     ),
                                     WebUiSettings(
                                       context: context,
                                     ),
                                   ],
                                 );
                                 actualImage=File(cropImage!.path);
                                 setState(() {

                                 });
                                 isProfile=true;
                               }

                             },
                             icon: Icon(
                               Icons.image_outlined,
                               color: Colors.teal,size: 30,
                             ))),
                     mText18('Gallery')
                   ],
                 ),
               ],
             ),
           ],
         )

     );
   }
   emojiPicker() {
     return PopScope(
       canPop: false,
       onPopInvoked: (didPop) {
         if(_emojiShowing){
           setState(() {
             _emojiShowing=false;
           });
         }else{
           Navigator.pop(context);
         }
       },
       child: EmojiPicker(

         textEditingController: mController,
         scrollController: _scrollController,
         config: Config(
           emojiViewConfig: EmojiViewConfig(),
           height: 256,
           checkPlatformCompatibility: true,
           categoryViewConfig: const CategoryViewConfig(
             showBackspaceButton: true,
             backspaceColor: Colors.teal,
           ),
           bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
         ),
       ),
     );
   }
   }
