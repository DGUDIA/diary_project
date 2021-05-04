import 'dart:convert';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../login/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'chat_constraint.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timer_builder/timer_builder.dart';
import '../my_config.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';


FirebaseUser loggedInUser;

ChatScreenState pageState;
enum DataKind { NONE, SEND }
final gServerIp = 'http://13.124.54.4:56201/';
final _firestore = Firestore.instance;

String getTime() {
  DateFormat df = DateFormat("yyyy/MM/dd hh:mm");
  return df.format(DateTime.now());
}

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  ChatScreenState createState() {
    pageState = ChatScreenState();
    return pageState;
  }
}



  DataKind mKind = DataKind.NONE;

  String mResult = '0';
  String email;
  String mText;
  var time;


  // post 동작의 결과를 수신할 비동기 함수
  // 연산할 데이터를 전달(post)해야 하기 때문에 멤버로 만들어야 했다.
  Future<String> postReply() async {
    if(mText == null)
      return '';

    // 문자열 이름은 서버에 정의된 add와 multiply 서비스
    var addr = gServerIp + ((mKind == DataKind.SEND) ? 'chat':'none');
    var response = await http.post(addr, body: {'email': email, 'time':time, 'diary':mText});

    // 200 ok. 정상 동작임을 알려준다.
    if (response.statusCode == 200)
      return response.body;

    throw Exception('데이터 수신 실패!');
  }

class ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

    @override
    void initState() {
      super.initState();
      getCurrentUser();
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
      return Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MessagesStream(),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageTextController,
                        onChanged: (value) {
                          mText = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    TextButton(

                      onPressed: () {
                        if(mText != null) {
                          messageTextController.clear();
                          _firestore.collection('messages').add(
                              {
                                'sender': loggedInUser.email,
                                'timestamp': getTime(),
                                'diary': mText,
                              },);
                        // try {
                        //   mKind = DataKind.SEND;
                        //   email = loggedInUser.email;
                        //   time = getTime();
                        // postReply()
                        //     .then((recvd) => mResult = recvd)
                        //     .whenComplete(() {
                        // if(mResult.isEmpty == false)
                        // setState(() {});
                        // });
                        // } catch (e, s) {
                        // print(s);
                      //   }
                      //
                      //
                      }
                      },
                      child:Text(
                        'Record',
                        style: kSendButtonTextStyle,
                      )
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }


class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
      _firestore.collection('messages').orderBy('timestamp').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.documents.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final diary = message.data['diary'];
          final sender = message.data['sender'];
          final time = message.data['timestamp'];

          final currentUser = loggedInUser.email;

          final messageBubble = MessageBubble(
            sender: sender,
            diary: diary,
            time:time,
            isMe: true,
          );

          messageBubbles.add(messageBubble);
        }
        for (var message in messages) {
          final diary = message.data['diary'];
          final sender = message.data['sender'];
          final time = message.data['timestamp'];

          final currentUser = loggedInUser.email;

          final messageBubble = MessageBubble(
            sender: sender,
            diary: diary,
            time:time,
            isMe: false,
          );

          messageBubbles.add(messageBubble);}

    //메시지 시간순 정렬
        messageBubbles.sort((a, b) {
          if (b.isMe) {
            return -1;
          }
          return 1;
        });
        messageBubbles.sort((a, b) => a.time.compareTo(b.time));




  return Expanded(
  child: ListView(
  reverse: true,
  padding: EdgeInsets.symmetric(
  horizontal: 10.0,
  vertical: 20.0,
  ),
  children: messageBubbles,
  ),
  );
  },
    );
    }
  }

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.time, this.diary, this.isMe});

  final String sender;
  final time;
  final String diary;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
      return Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: <Widget>[
                  isMe ? Text(
                    time,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.black54,
                    ),
                  )
                      :Text('  💎다이아리',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.black54,
                        fontWeight: FontWeight.bold,
                    ),
                  ),
                  Material(
                    borderRadius: isMe
                        ? BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                    )
                        : BorderRadius.only(
                      topRight: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                    ),
                    elevation: 5.0,
                    color: isMe ? Colors.lightBlueAccent : Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Text(
                    diary,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black54,
                      fontSize: 15.0,
                    ),
                  ),
                ),

              ),
                  if(isMe ==false)
                    Container(margin:EdgeInsets.only(top:10)),
                  if(isMe ==false)
                    Text('  💎다이아리',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if(isMe ==false)
                    Container(
                    decoration:BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.only(
                      topRight: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                    ),
                    boxShadow:[
                      BoxShadow(
    color:Colors.grey.withOpacity(0.5),
    blurRadius:5,
    offset: Offset(0,3)
    )
    ]),


                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                      child: new InkWell(
                        child : new Text('🎁\n'
                            '여기를 눌러주세요!'),
                        onTap:()=>launch('https://www.naver.com/',forceWebView: true)
                      )

                    ),

                  ),

        ],

              ),

                  );
  }
}
