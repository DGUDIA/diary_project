import '../chat/client.dart';
import 'package:flutter/material.dart';
import '../chat/chat_screen.dart';
import '../login/my_page.dart';
import '../chat/server.dart';
import '../chat/chat_datas.dart';

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
            title: Text("마이 페이지"),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => SignedInPage()));
            },
          ),
          ListTile(
            title: Text("서버통신 TEST용"),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MyApp()));
            },
          ),
          ListTile(
            title: Text("서버통신 TEST용2"),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Client()));
            },

          ),
          ListTile(
            title: Text("회원 DB"),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => ChatDB()));
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