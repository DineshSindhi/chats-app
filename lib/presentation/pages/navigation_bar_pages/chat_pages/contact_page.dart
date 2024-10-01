import 'dart:async';

import 'package:chats/domain/ui_helper.dart';
import 'package:chats/presentation/pages/navigation_bar_pages/chat_pages/chats_data_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../../../data/model/user_model.dart';

class ContactPage extends StatefulWidget {
  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  bool isLoading = true;
  bool isSearch = false;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  List<UserModel> firebaseContacts = [];
  List<UserModel> phoneContacts = [];
  List<UserModel> searchList1 = [];
  List<UserModel> searchList2 = [];
  var mController = TextEditingController();
  FirebaseAuth fireBaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    searchList1 = firebaseContacts;
    searchList2 = phoneContacts;
    getContact();
  }

  getData(String value) {
    List<UserModel> result = [];
    List<UserModel> data = [];
    if (value.isEmpty) {
      result = firebaseContacts;
    } else {
      result = firebaseContacts
          .where(
              (user) => user.name!.toLowerCase().contains(value.toLowerCase()))
          .toList();
    }
    if (value.isEmpty) {
      result = data;
    } else {
      data = phoneContacts
          .where(
              (user) => user.name!.toLowerCase().contains(value.toLowerCase()))
          .toList();
    }
    setState(() {
      searchList1 = result;
      searchList2 = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    var conLength = firebaseContacts.length + phoneContacts.length;
    return Scaffold(
        appBar: isSearch
            ? AppBar(
                leading: Padding(
                  padding: EdgeInsets.only(left: 8, right: 8),
                  child: PopScope(
                    canPop: false,
                    onPopInvoked: (didPop) {
                      if(isSearch){
                        setState(() {
                          isSearch=false;
                        });
                      }else{
                        Navigator.pop(context);
                      }
                    },
                    child: TextField(
                      controller: mController,
                      autofocus: true,
                      onChanged: (value) => getData(value),
                      decoration: InputDecoration(
                        hintText: 'Search Your Contacts',
                        hintStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w400),
                        prefixIcon: GestureDetector(
                            onTap: () {
                              searchList1 = firebaseContacts;
                              searchList2 = phoneContacts;
                              setState(() {
                                isSearch = false;
                              });
                              mController.clear();
                            },
                            child: Icon(
                              Icons.arrow_back_sharp,
                              size: 28,
                            )),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(50)),
                        fillColor: Colors.blueGrey.shade100,
                        filled: true,
                        contentPadding: EdgeInsets.all(5),
                      ),
                    ),
                  ),
                ),
                leadingWidth: double.infinity,
              )
            : AppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    mText15('Select Contact'),
                    isLoading ? mText15('') : mText15('$conLength Contacts'),
                  ],
                ),
                actions: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          isSearch = true;
                        });
                      },
                      icon: Icon(Icons.search)),
                  PopupMenuButton(
                    iconSize: 28,
                    position: PopupMenuPosition.under,
                    color: Colors.white,
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: Text('Invite Friend'),
                        ),
                        PopupMenuItem(
                          child: Text('Refresh'),
                          onTap: () {
                            // setState(() {
                            //   isLoading = true;
                            // });

                          },
                        ),
                      ];
                    },
                  )
                ],
                backgroundColor: Colors.teal,
                leadingWidth: 28,
              ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : firebaseContacts.isNotEmpty || phoneContacts.isNotEmpty
                ? searchList1.isNotEmpty || searchList2.isNotEmpty
                    ? ListView(
                        children: [
                          mText20P(searchList1.isNotEmpty
                              ? 'Contacts on Chats'
                              : ''),
                          ListTile(
                            leading: CircleAvatar(backgroundColor: Colors.teal,
                            child: Center(child: Icon(Icons.group_add,color: Colors.white,),),
                            ),
                            title: Text('New group',style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          ListTile(
                            leading: CircleAvatar(backgroundColor: Colors.teal,
                            child: Center(child: Icon(Icons.person_add_alt_1,color: Colors.white,),),
                            ),
                            title: Text('New contact',style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          ListTile(
                            leading: CircleAvatar(backgroundColor: Colors.teal,
                            child: Center(child: Icon(Icons.groups,color: Colors.white,),),
                            ),
                            title: Text('New community',style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: isSearch
                                ? searchList1.length
                                : firebaseContacts.length,
                            itemBuilder: (context, index) {
                              var mData = isSearch
                                  ? searchList1[index]
                                  : firebaseContacts[index];
                              return ListTile(
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatsDataPage(
                                          name: mData.name,
                                          image: mData.image,
                                          uId: mData.uId,
                                        ),
                                      ));
                                },
                                leading: CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    backgroundImage: mData.image != ''
                                        ? NetworkImage('${mData.image}')
                                        : AssetImage(
                                                'assets/images/avatar.jpeg')
                                            as ImageProvider),
                                title: Text(
                                  '${mData.name}',
                                ),
                                subtitle: Text(
                                  '${mData.about}',
                                ),
                              );
                            },
                          ),
                          mText20P(
                              searchList2.isNotEmpty ? 'Invite to Chats' : ''),
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: isSearch
                                ? searchList2.length
                                : phoneContacts.length,
                            itemBuilder: (context, index) {
                              var mData = isSearch
                                  ? searchList2[index]
                                  : phoneContacts[index];
                              return ListTile(
                                leading: CircleAvatar(
                                    backgroundImage: AssetImage(mData.image!)),
                                title: mText18(
                                  '${mData.name}',
                                ),
                                trailing: Text('Invite',
                                    style: TextStyle(
                                        color: Colors.teal, fontSize: 18)),
                              );
                            },
                          )
                        ],
                      )
                    : mController.text.isNotEmpty
                        ? Center(
                            child: Text('No Result Found'),
                          )
                        : ListView(
                            children: [
                              mText20P('Contacts on Chats'),
                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: firebaseContacts.length,
                                itemBuilder: (context, index) {
                                  var mData = firebaseContacts[index];
                                  return ListTile(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatsDataPage(
                                              name: mData.name,
                                              image: mData.image,
                                              uId: mData.uId,
                                            ),
                                          ));
                                    },
                                    leading: CircleAvatar(
                                        backgroundColor: Colors.grey,
                                        backgroundImage: mData.image != ''
                                            ? NetworkImage('${mData.image}')
                                            : AssetImage(
                                                    'assets/images/avatar.jpeg')
                                                as ImageProvider),
                                    title: Text(
                                      '${mData.name}',
                                    ),
                                    subtitle: Text(
                                      '${mData.about}',
                                    ),
                                  );
                                },
                              ),
                              mText20P('Invite to Chats'),
                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: phoneContacts.length,
                                itemBuilder: (context, index) {
                                  var mData = phoneContacts[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                        backgroundImage:
                                            AssetImage(mData.image!)),
                                    title: mText18(
                                      '${mData.name}',
                                    ),
                                    trailing: Text('Invite',
                                        style: TextStyle(
                                            color: Colors.teal, fontSize: 18)),
                                  );
                                },
                              )
                            ],
                          )
                : Center(
                    child: Text('No Contact Found in your Phone'),
                  ));
  }

  getContact() async {
    if (await FlutterContacts.requestPermission()) {
      final userCollection = await fireStore.collection('users').get();
      final allContactsInThePhone = await FlutterContacts.getContacts(
        withProperties: true,
      );

      bool isContactFound = false;

      for (var contact in allContactsInThePhone) {
        for (var firebaseContactData in userCollection.docs) {
          var firebaseContact = UserModel.fromDocs(firebaseContactData.data());
          if (contact.phones[0].number.replaceAll(' ', '') ==
              firebaseContact.mobile_no) {
            firebaseContacts.add(UserModel(
                uId: firebaseContact.uId,
                name: contact.displayName,
                mobile_no: firebaseContact.mobile_no,
                about: 'Hey Chats',
                image: firebaseContact.image,
                isOnline: firebaseContact.isOnline));
            isContactFound = true;
            break;
          }
          if(firebaseContact.uId==fireBaseAuth.currentUser!.uid){
            firebaseContacts.insert(0,UserModel(
                uId: firebaseContact.uId,
                name: '${firebaseContact.name}(you)',
                mobile_no: firebaseContact.mobile_no,
                about: 'Hey Chats',
                image: firebaseContact.image,
                isOnline: firebaseContact.isOnline) );
          }
        }
        if (!isContactFound) {
          phoneContacts.add(UserModel(
              uId: '',
              name: contact.displayName,
              mobile_no: contact.phones[0].number.replaceAll('', ''),
              about: '',
              image: 'assets/images/avatar.jpeg',
              isOnline: false));
        }

        isContactFound = false;
        Timer(Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        });
      }
      if (allContactsInThePhone.isEmpty) {
        print('No Contact in your Phone');
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
