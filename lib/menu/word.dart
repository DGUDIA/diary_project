import 'package:diary_project/chat/calender.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart' show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../chat/chat_data.dart';
import 'package:cached_network_image/cached_network_image.dart';


class Word extends StatefulWidget {

  @override
  _WordState createState() => new _WordState();

}

final _firestore = Firestore.instance;

final _auth = FirebaseAuth.instance;




class _WordState extends State<Word> {
  // void getCurrentUser() async {
  //   try {
  //     final user = await _auth.currentUser();
  //     if (user != null) {
  //       loggedInUser = user;
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  FirebaseUser loggedInUser;

  @override
  Widget build(BuildContext context) {
    var image = 'https://github.com/DGUDIA/diary_project_server/blob/master/word/speech.png?raw=true';

    return MaterialApp(
        home: Scaffold(

            body: Center(
              // CachedNetworkImage 추가. 한번 다운로드하면 재활용 가능
              child: CachedNetworkImage(
                // placeholder: CircularProgressIndicator(),
                imageUrl: image,
              ),
            )
        )
    );
  }
}