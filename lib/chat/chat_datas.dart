import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../my_config.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'dart:async';


FirebaseUser loggedInUser;

class User {
  String email;
  String time;
  String diary;
  Map<String, dynamic> company;

  User({this.email, this.time, this.diary});
}

String mail;
Future<List<User>> fetchUsers() async {
  final response = await http.post('http://13.124.54.4:56201/db', body: {'email': mail});

  if (response.statusCode == 200) {
    // 수신 데이터는 사전(Map)의 배열이지만, 정확한 형식은 Iterable 클래스.
    // Map의 형식은 이전 예제에 나온 것처럼 Map<String, dynamic>이 된다.
    final users = json.decode(response.body);

    // Map을 User 객체로 변환.
    // Iterable 객체로부터 전체 데이터에 대해 반복
    List<User> usersMap = [];
    for(var user in users) {        // user는 Map<String, dynamic>
      usersMap.add(User(
        email: user['email'],
        time: user['time'],
        diary: user['diary'],
      ));
    }
    return usersMap;
  }

  throw Exception('데이터 수신 실패!');
}

ChatDBState pageState;
class ChatDB extends StatefulWidget{
  @override
  ChatDBState createState() {
    pageState = ChatDBState();
    return pageState;
  }
}

class ChatDBState extends State<ChatDB> {
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    mail = loggedInUser.email;
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Center 위젯이 없으면 데이터를 가져오는 동안 인디케이터가 좌상단에 표시된다.
    return Center(
      child: FutureBuilder(
        future: fetchUsers(),                           // User 배열 반환
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<User> userArray = snapshot.data;   // 정확한 형식으로 변환
            return ListView.builder(
              itemCount: userArray.length,        // 필요한 개수만큼 아이템 생성
              itemExtent: 100.0,
              itemBuilder: (context, index) => makeRowItem(userArray[index], index),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          // 데이터를 로딩하는 동안 표시되는 인디케이터
          return CircularProgressIndicator();
        },
      ),
    );
  }

  // 리스트뷰의 항목 생성. idx는 항목의 색상을 달리 주기 위해.
  Widget makeRowItem(User user, int idx) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(user.time, style: TextStyle(fontSize: 10, color: Colors.black)),
          Text(user.diary, style: TextStyle(fontSize: 15, color: Colors.black))
        ],
      ),
      padding: EdgeInsets.only(top: 20.0),
      color: idx % 2 == 1 ? Colors.white : Colors.white,
    );
  }
}
