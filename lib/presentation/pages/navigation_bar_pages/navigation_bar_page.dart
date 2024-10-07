import 'package:chats/presentation/pages/navigation_bar_pages/calls_page.dart';
import 'package:chats/presentation/pages/navigation_bar_pages/chat_pages/chats_page.dart';
import 'package:chats/presentation/pages/navigation_bar_pages/chat_pages/other_pages/setting_page.dart';
import 'package:chats/presentation/pages/navigation_bar_pages/community_page.dart';
import 'package:chats/presentation/pages/navigation_bar_pages/updates_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

class NavigationBarPage extends StatefulWidget {
  const NavigationBarPage({super.key});

  @override
  State<NavigationBarPage> createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage>
    with WidgetsBindingObserver {
  int selectedIndex = 0;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  bool isDark=false;
  List<Widget> mPage = [
    ChatsPage(),
    UpdatesPage(),
    CommunityPage(),
    CallsPage()
  ];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    if(state==AppLifecycleState.resumed){
      fireStore.collection('users').doc(firebaseAuth.currentUser!.uid).update({
        'isOnline':true,
        'lastSeen':DateTime.now().millisecondsSinceEpoch.toString()
      });
    }else{

      fireStore.collection('users').doc(firebaseAuth.currentUser!.uid).update({
        'isOnline':false,
        'lastSeen':DateTime.now().millisecondsSinceEpoch.toString()
      });
    }
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  Widget build(BuildContext context) {
    isDark=context.watch<ThemeProvider>().isDark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade500,
        title: const Text('Chats',),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.qr_code_scanner_outlined,
                size: 28,
                color: isDark?Colors.white:Colors.black54,
              )),
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.camera_alt_outlined,
                size: 28,
                color: isDark?Colors.white:Colors.black54,
              )),
          selectedIndex == 1 || selectedIndex == 3
              ? IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.search,
                size: 28,
                color: isDark?Colors.white:Colors.black54,
              ))
              : Container(),
          selectedIndex == 0
              ? PopupMenuButton(
            iconColor: isDark?Colors.white:Colors.black54,
            iconSize: 28,
            position: PopupMenuPosition.under,
            color: isDark?Colors.black:Colors.white,
            itemBuilder: (context) {
              return [
                PopupMenuItem(child: Text('New Group')),
                PopupMenuItem(child: Text('Linked devices')),
                PopupMenuItem(child: Text('Setting'),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingPage(),));
                  },
                ),
              ];
            },
          )
              : selectedIndex == 1
              ? PopupMenuButton(
            iconSize: 28,
            position: PopupMenuPosition.under,
            iconColor: isDark?Colors.white:Colors.black54,
            itemBuilder: (context) {
              return [
                PopupMenuItem(child: Text('Status privacy')),

                PopupMenuItem(child: Text('Setting'),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingPage(),));
                  },
                ),
              ];
            },
          )
              : selectedIndex == 2
              ? PopupMenuButton(
            iconSize: 28,
            position: PopupMenuPosition.under,
            iconColor: isDark?Colors.white:Colors.black54,
            itemBuilder: (context) {
              return [
                PopupMenuItem(child: Text('Setting'),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingPage(),));
                  },
                ),
              ];
            },
          )
              : PopupMenuButton(
            iconSize: 28,
            position: PopupMenuPosition.under,
            iconColor: isDark?Colors.white:Colors.black54,
            itemBuilder: (context) {
              return [
                PopupMenuItem(child: Text('Clear call log')),
                PopupMenuItem(child: Text('Setting'),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingPage(),));
                  },
                ),
              ];
            },
          )
        ],
      ),
      bottomNavigationBar: NavigationBar(
        indicatorColor: Colors.teal.shade400,
        onDestinationSelected: (value) {
          selectedIndex = value;
          setState(() {});
        },
        selectedIndex: selectedIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_sharp),
            label: 'Chats',
          ),
          NavigationDestination(
              icon: Icon(Icons.update_rounded), label: 'Updates'),
          NavigationDestination(
            icon: Icon(Icons.person_add_alt_sharp),
            label: 'Communities',
          ),
          NavigationDestination(icon: Icon(Icons.call), label: 'Calls'),
        ],
      ),
      body: mPage[selectedIndex],
    );
  }
}
