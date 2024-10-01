
import 'package:flutter/material.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Container(
        margin: EdgeInsets.all(6),
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color:Colors.teal,
          ),
          child: Center(child: Text('Start Your Community'))),),
    );
  }
}
