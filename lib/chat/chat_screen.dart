import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../login/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary_project/chat/chat_constraint.dart';
import 'package:diary_project/my_config.dart';

final gServerIp = properties['admin']['admins'];
final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

ChatScreenState pageState;


class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  ChatScreenState createState() {
    pageState = ChatScreenState();
    return pageState;
  }
}

class ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String messageText;

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
                          messageText = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        messageTextController.clear();

                        _firestore.collection('messages').add(
                          {
                            'text': messageText,
                            'sender': loggedInUser.email,
                            'timestamp': FieldValue.serverTimestamp(),
                          },
                        );
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
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
          final messageText = message.data['text'];
          final messageSender = message.data['sender'];

          final currentUser = loggedInUser.email;

          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUser == messageSender,
          );

          messageBubbles.add(messageBubble);
        }
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
  MessageBubble({this.sender, this.text, this.isMe});

  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
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
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black54,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class SignedInPageState extends State<SignedInPage> {
//   FirebaseProvider fp;
//   TextStyle tsItem = const TextStyle(
//       color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.bold);
//   TextStyle tsContent = const TextStyle(color: Colors.blueGrey, fontSize: 12);
//   @override
//   void main() async {
//     String url = "https://eunjin3786.pythonanywhere.com/question/all/";
//     var response = await http.get(url);
//     var statusCode = response.statusCode;
//     var responseHeaders = response.headers;
//     var responseBody = response.body;
//
//     print("statusCode: ${statusCode}");
//     print("responseHeaders: ${responseHeaders}");
//     print("responseBody: ${responseBody}");
//
//     //runApp(MyApp());
//   }
//   @override
//   Widget build(BuildContext context) {
//     fp = Provider.of<FirebaseProvider>(context);
//     return Scaffold(
//         body:ListView(
//             (fp.getUser().email, style: tsContent),
//     );
//   }
// }

