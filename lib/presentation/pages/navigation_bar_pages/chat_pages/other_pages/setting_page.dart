import 'package:chats/presentation/on_board/phone_ver.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../../data/model/user_model.dart';
import '../../../../../domain/ui_helper.dart';
import 'user_profile_page.dart';

class SettingPage extends StatelessWidget {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  FirebaseAuth fireBaseAuth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Setting'),
      ),
      body: ListView(
        children: [
          StreamBuilder(
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
                    return InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(),));
                      },
                      child: ListTile(
                        leading: SizedBox(
                          height: 60,
                          width: 60,
                          child: CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage:eachData.image!=''? NetworkImage('${eachData.image}'):AssetImage('assets/images/avatar.jpeg')as ImageProvider
                          ),),
                        title: mText18('${eachData.name}'),
                        subtitle: Text('${eachData.about}'),
                      ),
                    );

                  },
                );
              }
              return Container();
            },
          ),
          Container(width: double.infinity,height: 1,color: Colors.blueGrey.shade200,),
          mListTile(widget: Icon(Icons.key,size: 30,), onTap: (){}, tittle: 'Account', subTittle: 'Security notification, change number'),
          mListTile(widget: Icon(Icons.lock_outlined,size: 30,), onTap: (){}, tittle: 'Privacy', subTittle: 'Bloc contacts, disappearing message'),
          mListTile(widget: Icon(Icons.face,size: 30,), onTap: (){}, tittle: 'Avatar', subTittle: 'Create, edit, profile photo'),
          mListTile(widget: Icon(Icons.favorite_border,size: 30,), onTap: (){}, tittle: 'Favorite', subTittle: 'Add, reorder,remove'),
          mListTile(widget: Icon(Icons.chat,size: 30,), onTap: (){}, tittle: 'Chats', subTittle: 'Theme, wallpaper,chat history'),
          mListTile(widget: Icon(Icons.notifications,size: 30,), onTap: (){}, tittle: 'Notification', subTittle: 'Message, group & call tones'),
          mListTile(widget: Icon(Icons.storage,size: 30,), onTap: (){}, tittle: 'Storage and data', subTittle: 'Network usage, auto-download'),
          mListTile(widget: Icon(Icons.person_add_alt_1,size: 30,), onTap: (){}, tittle: 'Invite a friend', subTittle: ''),
          Container(width: double.infinity,height: 1,color: Colors.blueGrey.shade200,),
          ListTile(title: mText20('Sign Out',),trailing: InkWell(
              onTap: () async {
                fireStore.collection('users').doc(fireBaseAuth.currentUser!.uid).update({
                  'isOnline':true,
                });
                await fireBaseAuth.signOut().then((value){ Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MobileNoPage(),
                    ));
                });

              },
              child: Icon(Icons.logout,size: 28,)),),
        ],
      ),
    );
  }


}

