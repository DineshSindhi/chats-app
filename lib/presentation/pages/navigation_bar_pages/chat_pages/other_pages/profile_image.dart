
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../data/model/user_model.dart';
import '../../../../../domain/ui_helper.dart';

class ProfileImage extends StatefulWidget {
  String? image;

  ProfileImage({required this.image,});

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  FirebaseFirestore fireStore=FirebaseFirestore.instance;
  FirebaseAuth firebaseAuth=FirebaseAuth.instance;
  File? actualImage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade100,
      appBar: AppBar(backgroundColor: Colors.teal,
          title: Text('Profile Picture'),
          actions:  [
            IconButton(onPressed: (){
              showModalBottomSheet(context: context, builder: (context) {
                return mySheet();
              },);
              }, icon: Icon(Icons.edit),),
            IconButton(onPressed: (){}, icon: Icon(Icons.share),),
              ]
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder(
            stream: fireStore
                .collection('users')
                .where('uId', isEqualTo: firebaseAuth.currentUser!.uid)
                .snapshots(),
            builder: (_, snapshot) {
              if(snapshot.connectionState==ConnectionState.waiting){
                return Center(child: CircularProgressIndicator(),);
              }
              else if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
              else if (snapshot.hasData) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.size,
                  itemBuilder: (context, index) {
                    var mData = snapshot.data!.docs[index].data();
                    var eachData = UserModel.fromDocs(mData);
                    return Center(
                      child: Hero(
                          tag: 'image',
                          child: eachData.image!=''?Image.network('${eachData.image}'):Image.asset('assets/images/logo.jpeg',)),
                    );
                  },
                );
              }
              return Container();
            },
          ),
        ],
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
                  fireStore.collection('users').doc(firebaseAuth.currentUser!.uid)
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
                                                  fireStore.collection('users').doc(firebaseAuth.currentUser!.uid).update({
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
                                                  fireStore.collection('users').doc(firebaseAuth.currentUser!.uid).update({
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


}