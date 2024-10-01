import 'dart:io';
import 'package:chats/domain/ui_helper.dart';
import 'package:chats/presentation/pages/navigation_bar_pages/chat_pages/other_pages/profile_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../data/model/user_model.dart';

class UserProfilePage extends StatefulWidget {
  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  FirebaseAuth fireBaseAuth = FirebaseAuth.instance;
  var controller = TextEditingController();
  File? actualImage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.teal,
        title: Text('Profile'),
      ),
      body: StreamBuilder(
        stream: fireStore
            .collection('users')
            .where('uId', isEqualTo: fireBaseAuth.currentUser!.uid)
            .snapshots(),
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
                return  Column(children: [

                  SizedBox(height: 20,),
                  SizedBox(
                    height: 140,
                    width: 140,
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileImage(image: eachData.image),));
                          },
                          child: Hero(
                            tag: 'image',
                            child: SizedBox(
                              height: 155,
                              width: 155,
                              child: CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  backgroundImage:eachData.image!=''? NetworkImage('${eachData.image}'):AssetImage('assets/images/avatar.jpeg')as ImageProvider
                              ),
                            ),
                          ),
                        ),
                        Align(
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
                      ],
                    ),
                  ),
                  SizedBox(height: 15,),
                  mListTileP(widget: Icon(Icons.account_circle_outlined,color: Colors.blueGrey.shade600,size: 30,), onTap: (){
                    showModalBottomSheet(context: context, builder: (context) {
                      controller.text=eachData.name!;
                      return mySheetT('Update Name', 'Update Name', 'name', );
                    },);
                  }, tittle: 'Name', subTittle: '${eachData.name}',widgetT: Icon(Icons.edit,size: 30,color: Colors.blueGrey.shade600,)),
                  mListTileP(widget: Icon(Icons.info_outlined,color: Colors.blueGrey.shade600,size: 30,), onTap: (){
                    showModalBottomSheet(context: context, builder: (context) {
                      controller.text=eachData.about!;
                      return mySheetT('Update About you', 'Update About you', 'about',);
                    },);
                  }, tittle: 'About', subTittle: '${eachData.about}',widgetT: Icon(Icons.edit,size: 30,color: Colors.blueGrey.shade600,)),
                  mListTileP(widget: Icon(Icons.call_rounded,color: Colors.blueGrey.shade600,size: 30,), onTap: (){}, tittle: 'Phone', subTittle: '${eachData.mobile_no}',widgetT: Text('')),
                ],);

              },
            );
          }
          return Container();
        },
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
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    }, color: Colors.teal,iconSize: 30,icon: Icon(Icons.cancel_outlined)),
                Text('Profile Photo',style: TextStyle(color: Colors.teal,fontSize: 25),),
                IconButton(onPressed: () {
                  fireStore.collection('users').doc(fireBaseAuth.currentUser!.uid)
                      .update({
                   'image': '',
                  });
                  Navigator.pop(context);
                },color: Colors.teal,iconSize: 30, icon: Icon(Icons.delete)),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Container(
                        margin: EdgeInsets.only(top: 5),
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
                                showDialog(context: context, builder: (context) {
                                  return Dialog(

                                    backgroundColor: Colors.teal.shade200,
                                    child: SizedBox(
                                      height: 300,
                                      width: 350,
                                      child: Column( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            height: 150,
                                            width: 150,
                                            child: CircleAvatar(
                                              backgroundImage: FileImage(actualImage!),
                                            ),
                                          ),
                                          ElevatedButton(
                                              onPressed: () {
                                                var time=DateTime.now().millisecondsSinceEpoch;
                                                var image=FirebaseStorage.instance.ref().child('profile_pic/IMG_$time.jpg');
                                                image.putFile(actualImage!).then((value) async {
                                                  var imgUrl=await value.ref.getDownloadURL();
                                                  fireStore.collection('users').doc(fireBaseAuth.currentUser!.uid).update({
                                                    'image':imgUrl,
                                                  });

                                                });
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'Change Profile Pic',
                                                style: TextStyle(color: Colors.white, fontSize: 22),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.teal,
                                              )),
                                        ],
                                      ),
                                    ),
                                  );
                                },);
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
                        margin: EdgeInsets.only(top: 5),
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
                                showDialog(context: context, builder: (context) {
                                  return Dialog(

                                    backgroundColor: Colors.teal.shade200,
                                    child: SizedBox(
                                      height: 300,
                                      width: 350,
                                      child: Column( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            height: 150,
                                            width: 150,
                                            child: CircleAvatar(
                                              backgroundImage: FileImage(actualImage!),
                                            ),
                                          ),
                                          ElevatedButton(
                                              onPressed: () {
                                                var time=DateTime.now().millisecondsSinceEpoch;
                                                var image=FirebaseStorage.instance.ref().child('profile_pic/IMG_$time.jpg');
                                                image.putFile(actualImage!).then((value) async {
                                                  var imgUrl=await value.ref.getDownloadURL();
                                                  fireStore.collection('users').doc(fireBaseAuth.currentUser!.uid).update({
                                                    'image':imgUrl,
                                                  });

                                                });
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'Change Profile Pic',
                                                style: TextStyle(color: Colors.white, fontSize: 22),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.teal,
                                              )),
                                        ],
                                      ),
                                    ),
                                  );
                                },);
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
  Widget mySheetT(
      String titleText,
      String buttonText,
      String valueText,
      ) {
    return Container(
        height: 500,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Padding(
            padding: EdgeInsets.all(3),
            child: Column(children: [
              Text(
                titleText,
                style: TextStyle(fontSize: 30, color: Colors.teal),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: controller,
               autofocus: true,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    )),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        fireStore.collection('users').doc(fireBaseAuth.currentUser!.uid)
                            .update({
                          valueText: controller.text.toString(),
                        });
                        Navigator.pop(context);
                        controller.clear();

                      },
                      child: Text(
                        buttonText,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      )),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      )),
                ],
              )
            ])));
  }
}
