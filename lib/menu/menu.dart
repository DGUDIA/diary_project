import 'package:diary_project/chat/calender.dart';
import 'package:diary_project/chat/kalender.dart';
import 'package:diary_project/chat/memo_board.dart';

import '../chat/client.dart';
import 'package:flutter/material.dart';
import '../chat/chat_screen.dart';
import '../login/my_page.dart';
import '../chat/server.dart';
import '../chat/chat_datas.dart';
import 'word.dart';
import 'package:http/http.dart' as http;


enum DataKind { NONE, SEND }
DataKind mKind = DataKind.NONE;
final gServerIp = 'http://52.78.162.166:50962/';
String mResult = '0';
String email;
String diary;
String mText;
var time;

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
            title: Text("일기 모아보기"),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MyCalendars()));

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


          ),
          ListTile(
            title: Text("회원 DB"),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MyMemo()));
            },


          ),
          ListTile(
            title: Text("내가 자주 쓰는 단어?"),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Word()));
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