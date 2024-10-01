import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats/data/model/msg_model.dart';
import 'package:chats/domain/firebase_repository/firebase_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../../../../data/model/call_model.dart';
import '../../../../domain/ui_helper.dart';

class ChatsDataPage extends StatefulWidget {
  String? name;
  String? image;
  String? uId;

  ChatsDataPage({
    super.key,
    required this.name,
    required this.image,
    required this.uId,
  });

  @override
  State<ChatsDataPage> createState() => _ChatsDataPageState();
}

class _ChatsDataPageState extends State<ChatsDataPage> {
  final _scrollController = ScrollController();
  bool _emojiShowing = false;
  var msgController = TextEditingController();
  var imageMsgController = TextEditingController();
  bool msgSend = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  late CollectionReference calls;
  List<MessageModel> mList = [];
  var dt = DateFormat.Hm();
  File? actualImage;
  final pageStorageBucket = PageStorageBucket();
  var scrollController = ScrollController();
  bool isTyping = false;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        _emojiShowing = false;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    calls = fireStore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('calls');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade400,
        leading: Row(
          children: [
            mySizedBoxW2(),
            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 30,
                )),
            SizedBox(
              width: 50,
              height: 50,
              child: CircleAvatar(
                  backgroundImage: NetworkImage(widget.image!.isNotEmpty
                      ? '${widget.image}'
                      : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_kSJS4PDXmamxDis9zrjyfSj2DGKrZb_0mnIRUJJfJJfxvSDTe6Z7lTF3GtQG97aFctQ&usqp=CAU')),
            ),
            mySizedBoxW7(),
            StreamBuilder(
                stream:
                    fireStore.collection('users').doc(widget.uId).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    return data['isOnline'] == true
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              mText22align(widget.name!),
                              Text('online'),
                            ],
                          )
                        : isTyping
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  mText22align(widget.name!),
                                  Text(
                                      'lastSeen ${dt.format(DateTime.fromMillisecondsSinceEpoch(int.parse(data['lastSeen'])))}'),
                                ],
                              )
                            : data['isTyping'] == true
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      mText22align(widget.name!),
                                      Text('typing...'),
                                    ],
                                  )
                                : mText22align(widget.name!);
                  } else {
                    return Text('');
                  }
                }),
          ],
        ),
        leadingWidth: 350,
        toolbarHeight: 74,
        actions: [
          ZegoSendCallInvitationButton(
            isVideoCall: true,
            timeoutSeconds: 60,
            icon: ButtonIcon(
              icon: Icon(
                Icons.videocam_outlined,
                size: 35,
              ),
            ),
            buttonSize: Size(60, 74),
            resourceID: "zegouikit_call",
            invitees: [
              ZegoUIKitUser(
                id: '${widget.uId}',
                name: '${widget.name}',
              ),
            ],
            onPressed: (_, __, ___) {
              var data = CallModel(
                  callId: widget.uId,
                  name: widget.name,
                  image: widget.image,
                  time: DateTime.now().millisecondsSinceEpoch,
                  isVideoCall: true);
              calls.add(data.toMap());
            },
          ),
          ZegoSendCallInvitationButton(
            isVideoCall: false,
            timeoutSeconds: 60,
            icon: ButtonIcon(
              icon: Icon(
                Icons.call_rounded,
                size: 28,
              ),
            ),
            buttonSize: Size(40, 74),
            resourceID: "zegouikit_call",
            invitees: [
              ZegoUIKitUser(
                id: '${widget.uId}',
                name: widget.name!,
              ),
            ],
            onPressed: (_, __, ___) {
              var data = CallModel(
                  callId: widget.uId,
                  name: widget.name,
                  image: widget.image,
                  time: DateTime.now().millisecondsSinceEpoch,
                  isVideoCall: false);
              calls.add(data.toMap());
            },
          ),
          PopupMenuButton(
            elevation: 0,
            iconSize: 28,
            position: PopupMenuPosition.under,
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            itemBuilder: (context) {
              return [
                PopupMenuItem(child: Text('View contact')),
                PopupMenuItem(child: Text('Media, links, and docs')),
                PopupMenuItem(child: Text('Search')),
                PopupMenuItem(child: Text('Muted notification')),
                PopupMenuItem(child: Text('Disappearing message')),
                PopupMenuItem(child: Text('Wallpaper')),
                PopupMenuItem(child: Text('More')),
              ];
            },
          )
        ],
      ),
      backgroundColor: Colors.blueGrey.shade100,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FireBaseRepository.getChatStream(toId: '${widget.uId}'),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  mList = List.generate(
                      snapshot.data!.docs.length,
                      (index) => MessageModel.fromDocs(
                          snapshot.data!.docs[index].data()));
                  return PageStorage(
                    bucket: pageStorageBucket,
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: scrollController,
                      key: PageStorageKey('chat_page'),
                      itemCount: mList.length + 1,
                      itemBuilder: (context, index) {
                        if(scrollController.hasClients){
                          scrollController.animateTo(
                              scrollController.position.maxScrollExtent,
                              duration: Duration(milliseconds: 150),
                              curve: Curves.easeOut);
                        }
                        if (index == mList.length) {
                          return Container(
                            height: 40,
                          );
                        }
                        return mList.isNotEmpty?
                          mList[index].fromId ==
                                firebaseAuth.currentUser!.uid
                            ? userChat(mList[index])
                            : anotherUserChat(
                                mList[index],
                              ):Center(child: Text('No chat yet..\n start converstion now'),);
                      },
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator(),);
                }
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 5, bottom: 5, right: 5),
                  child: TextField(
                    controller: msgController,
                    focusNode: focusNode,
                    cursorColor: Colors.teal,
                    onTap: () {
                      setState(() {
                        isTyping = true;
                      });
                    },
                    onChanged: (value) {
                      if (value.length == 0) {
                        setState(() {
                          msgSend = false;
                        });
                        fireStore
                            .collection('users')
                            .doc(firebaseAuth.currentUser!.uid)
                            .update({
                          'isTyping': false,
                        });
                      } else if (value.length > 0) {
                        setState(() {
                          msgSend = true;
                          isTyping = false;
                        });
                        fireStore
                            .collection('users')
                            .doc(firebaseAuth.currentUser!.uid)
                            .update({
                          'isTyping': true,
                        });
                      }
                    },
                    style: TextStyle(
                      fontSize: 20,
                    ),
                    maxLines: 4,
                    minLines: 1,
                    autocorrect: true,
                    decoration: InputDecoration(
                        prefixIcon: GestureDetector(
                            onTap: () {
                              focusNode.unfocus();
                              focusNode.canRequestFocus = false;
                              setState(() {
                                _emojiShowing = !_emojiShowing;
                              });
                            },
                            child: Icon(
                              Icons.emoji_emotions_outlined,
                              color: Colors.blueGrey.shade700,
                              size: 30,
                            )),
                        suffixIcon: msgSend
                            ? Ink(
                                width: 20,
                                child: InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return mySheet();
                                        },
                                      );
                                    },
                                    child: Icon(
                                      Icons.link,
                                      color: Colors.blueGrey.shade700,
                                      size: 31,
                                    )),
                              )
                            : SizedBox(
                                width: 120,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    InkWell(
                                        onTap: () async {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return mySheet();
                                            },
                                          );
                                        },
                                        child: Icon(
                                          Icons.link,
                                          color: Colors.blueGrey.shade700,
                                          size: 30,
                                        )),
                                    InkWell(
                                        onTap: () async {
                                          var image = ImagePicker();
                                          XFile? pickImage =
                                              await image.pickImage(
                                                  source: ImageSource.camera);
                                          if (pickImage != null) {
                                            var cropImage =
                                                await ImageCropper().cropImage(
                                              sourcePath: pickImage.path,
                                              uiSettings: [
                                                AndroidUiSettings(
                                                  toolbarTitle: 'Cropper',
                                                  toolbarColor:
                                                      Colors.deepOrange,
                                                  toolbarWidgetColor:
                                                      Colors.white,
                                                  aspectRatioPresets: [
                                                    CropAspectRatioPreset
                                                        .original,
                                                    CropAspectRatioPreset
                                                        .square,
                                                    CropAspectRatioPreset
                                                        .ratio16x9,
                                                  ],
                                                ),
                                                IOSUiSettings(
                                                  title: 'Cropper',
                                                  aspectRatioPresets: [
                                                    CropAspectRatioPreset
                                                        .original,
                                                    CropAspectRatioPreset
                                                        .square,
                                                    // IMPORTANT: iOS supports only one custom aspect ratio in preset list
                                                  ],
                                                ),
                                                WebUiSettings(
                                                  context: context,
                                                ),
                                              ],
                                            );
                                            actualImage = File(cropImage!.path);
                                            setState(() {});
                                          }
                                          showModalBottomSheet(
                                            backgroundColor: Colors.black,
                                            isScrollControlled: true,
                                            context: context,
                                            builder: (context) {
                                              return picEdit();
                                            },
                                          );
                                        },
                                        child: Icon(
                                          Icons.camera_alt_outlined,
                                          color: Colors.blueGrey.shade700,
                                          size: 30,
                                        )),
                                  ],
                                ),
                              ),
                        contentPadding: EdgeInsets.all(11),
                        hintText: 'Message',
                        fillColor: Colors.white,
                        filled: true,
                        hintStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w400),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none)),
                  ),
                ),
              ),
              Container(
                  margin: EdgeInsets.only(right: 6, bottom: 3),
                  width: 55,
                  height: 55,
                  decoration:
                      BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
                  child: msgSend
                      ? IconButton(
                          onPressed: () {
                            FireBaseRepository.sendTextMessage(
                                toId: widget.uId!,
                                msg: msgController.text.toString());
                            msgController.clear();
                            scrollController.animateTo(
                                scrollController.position.maxScrollExtent,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeOut);
                          },
                          icon: Icon(
                            Icons.send,
                            color: Colors.white,
                          ))
                      : GestureDetector(
                          onTap: () {
                            scrollDown();
                          },
                          child: Icon(
                            Icons.mic,
                            color: Colors.white,
                          ),
                        )),
            ],
          ),
          _emojiShowing ? emojiPicker() : Container(),
        ],
      ),
    );
  }

  userChat(MessageModel messageModel) {
    var time = dt.format(DateTime.fromMillisecondsSinceEpoch(
        int.parse('${messageModel.sendAt}')));
    return Row(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.4,
        ),
        Flexible(
            child: Container(
          margin: EdgeInsets.all(7),
          padding: EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: Colors.teal.shade400,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                topLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              )),
          child: messageModel.msgType == 0
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(child: mText18W('${messageModel.msg}')),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          time,
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                        mySizedBoxW5(),
                        Icon(
                          Icons.done_all_outlined,
                          color: messageModel.isRead != ''
                              ? Colors.blue.shade900
                              : Colors.white54,
                          size: 18,
                        ),
                      ],
                    )
                  ],
                )
              : messageModel.msg != ''
                  ? Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: messageModel.imgUrl!,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Flexible(child: mText18W('${messageModel.msg}')),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              time,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white),
                            ),
                            mySizedBoxW5(),
                            Icon(
                              Icons.done_all_outlined,
                              color: messageModel.isRead != ''
                                  ? Colors.blue.shade900
                                  : Colors.white,
                              size: 18,
                            ),
                          ],
                        )
                      ],
                    )
                  : Column(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: messageModel.imgUrl!,
                            )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              time,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white),
                            ),
                            mySizedBoxW5(),
                            Icon(
                              Icons.done_all_outlined,
                              color: messageModel.isRead != ''
                                  ? Colors.blue.shade900
                                  : Colors.white54,
                              size: 18,
                            ),
                          ],
                        )
                      ],
                    ),
        )),
      ],
    );
  }

  anotherUserChat(
    MessageModel messageModel,
  ) {
    if (messageModel.isRead == '') {
      FireBaseRepository.updateReadStatus(
          toId: widget.uId!, msgId: messageModel.msgId!);
    }
    var time = dt.format(DateTime.fromMillisecondsSinceEpoch(
        int.parse('${messageModel.sendAt}')));
    return Row(
      children: [
        Flexible(
            child: Container(
          margin: EdgeInsets.all(7),
          padding: EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: Colors.teal.shade400,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
                topRight: Radius.circular(10),
              )),
          child: messageModel.msgType == 0
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(child: mText18W('${messageModel.msg}')),
                    Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          time,
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ))
                  ],
                )
              : messageModel.msg != ''
                  ? Column(
                      children: [
                        Container(
                          height: 300,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: messageModel.imgUrl!,fit: BoxFit.fill,
                              )),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Flexible(child: mText18W('${messageModel.msg}')),
                          ],
                        ),
                        Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              time,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white),
                            ))
                      ],
                    )
                  : Column(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: messageModel.imgUrl!,
                            )),
                        SizedBox(
                          height: 6,
                        ),
                        Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              time,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white),
                            ))
                      ],
                    ),
        )),
        Container(
          width: MediaQuery.of(context).size.width * 0.4,
        ),
      ],
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
                  color: Colors.grey, borderRadius: BorderRadius.circular(20)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Container(
                        margin: EdgeInsets.only(top: 15),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle),
                        child: IconButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              var image = ImagePicker();
                              XFile? pickImage = await image.pickImage(
                                  source: ImageSource.camera);
                              if (pickImage != null) {
                                var cropImage = await ImageCropper().cropImage(
                                  sourcePath: pickImage.path,
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
                                actualImage = File(cropImage!.path);
                                setState(() {});
                                showModalBottomSheet(
                                  backgroundColor: Colors.black,
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) {
                                    return picEdit();
                                  },
                                );
                              }
                            },
                            icon: Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.teal,
                              size: 30,
                            ))),
                    mText18('Camera')
                  ],
                ),
                Column(
                  children: [
                    Container(
                        margin: EdgeInsets.only(top: 15),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle),
                        child: IconButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              var image = ImagePicker();
                              XFile? pickImage = await image.pickImage(
                                  source: ImageSource.gallery);
                              if (pickImage != null) {
                                var cropImage = await ImageCropper().cropImage(
                                  sourcePath: pickImage.path,
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
                                actualImage = File(cropImage!.path);
                                setState(() {});
                                showModalBottomSheet(
                                  backgroundColor: Colors.black,
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) {
                                    return picEdit();
                                  },
                                );
                              }
                            },
                            icon: Icon(
                              Icons.image_outlined,
                              color: Colors.teal,
                              size: 30,
                            ))),
                    mText18('Gallery')
                  ],
                ),
              ],
            ),
          ],
        ));
  }

  picEdit() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    margin: EdgeInsets.only(right: 6, bottom: 3),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.blueGrey.shade900,
                        shape: BoxShape.circle),
                    child: Center(
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.cancel_outlined,
                            color: Colors.white,
                          )),
                    )),
                Container(
                    margin: EdgeInsets.only(right: 6, bottom: 3),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.blueGrey.shade900,
                        shape: BoxShape.circle),
                    child: Center(
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.white,
                          )),
                    )),
              ],
            ),
          ),
          Image.file(actualImage!),
          TextField(
            style: TextStyle(color: Colors.white, fontSize: 18),
            cursorColor: Colors.teal,
            controller: imageMsgController,
            decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.image,
                  color: Colors.white,
                ),
                filled: true,
                fillColor: Colors.blueGrey.shade900,
                hintText: 'Add a caption..',
                hintStyle: TextStyle(fontSize: 20, color: Colors.white),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none)),
          ),
          Container(
            width: double.infinity,
            height: 80,
            color: Colors.blueGrey.shade900,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.name}',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  Container(
                      margin: EdgeInsets.only(right: 6, bottom: 3),
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                          color: Colors.teal, shape: BoxShape.circle),
                      child: IconButton(
                          onPressed: () {
                            var time = DateTime.now().millisecondsSinceEpoch;
                            var image = FirebaseStorage.instance
                                .ref()
                                .child('profile_pic/IMG_$time.jpg');
                            image.putFile(actualImage!).then((value) async {
                              var imgUrl = await value.ref.getDownloadURL();
                              FireBaseRepository.sendImageMessage(
                                  toId: widget.uId!,
                                  msg: imageMsgController.text.toString(),
                                  imgUrl: imgUrl);
                              msgController.clear();
                              scrollController.animateTo(
                                  scrollController.position.maxScrollExtent,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeOut);
                            });
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.send,
                            color: Colors.white,
                          )))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void scrollDown() {
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
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

        textEditingController: msgController,
        scrollController: _scrollController,
        // onEmojiSelected: (c,emoji){
        //     setState(() {
        //       msgController.text= msgController.text+ emoji.emoji;
        //     });
        // },
        config: Config(
          emojiViewConfig: EmojiViewConfig(),
          height: MediaQuery.of(context).size.height*0.4,
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
