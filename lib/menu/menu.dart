import 'package:flutter/material.dart';
import '../chat/chat_screen.dart';
import 'package:diary_project/login/my_page.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("선택해 주세요!")),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text("일기 쓰기"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ChatScreen()));
            },
          ),
          ListTile(
            title: Text("회원 정보 수정"),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => SignedInPage()));
            },
          )
        ].map((child) {
          return Card(
            child: child,
          );
        }).toList(),
      ),
    );
  }
}