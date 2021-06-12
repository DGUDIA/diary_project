import 'dart:ui';

import 'package:diary_project/chat/memo_board.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary_project/chat/chat_data.dart';
import 'package:http/http.dart' as http;

final gServerIp = 'http://52.78.162.166:50962/';
enum DataKind { NONE, SEND }


class MyCalendars extends StatefulWidget {
  @override
  _MyCalendarsState createState() => _MyCalendarsState();
}

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;
final _auth = FirebaseAuth.instance;
var sum = 0;

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
DataKind mKind = DataKind.NONE;

String mResult = '0';
String email;
String diary;
String mText;
var time;

// post 동작의 결과를 수신할 비동기 함수
// 연산할 데이터를 전달(post)해야 하기 때문에 멤버로 만들어야 했다.


DateTime day;



class _MyCalendarsState extends State<MyCalendars>
    with TickerProviderStateMixin {


  // final dbref = FirebaseDatabase.instance.reference();
  List<Map<dynamic, dynamic>> countSch = [];
  List<Map<dynamic, dynamic>> lists = [];
  final Map<DateTime, List> _holidays = {
    DateTime(2021, 1, 1): ['New Year\'s Day'],
  };

  String dateFormat =
  DateFormat("yyyy년 M월 d일").format(DateTime.now()).replaceAll(" ", "");
  String monthDay = "";
  String yearDay = "";
  String dayDay = "";
  String yyyy =DateTime.now().year.toString();
  String mm=DateTime.now().month.toString();
  Map<DateTime, List<dynamic>> _events;
  List _selectedEvents;
  AnimationController _animationController;
  CalendarController _calendarController;
  FirebaseUser user;
  String hal = "과제";

  getUserData() async {
    FirebaseUser userData = await FirebaseAuth.instance.currentUser();
    setState(() {
      user = userData;
    });
  }


  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    final _selectedDay = DateTime.now();
    getUserData();

    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();

    super.dispose();
  }

  _onDaySelected(DateTime day, List events, List holidays)async {
    day = day;
    print('CALLBACK: _onDaySelected' + '$day');
    setState(() {
      //_selectedEvents = events;
      dateFormat = day.year.toString() +
          '년' +
          day.month.toString() +
          '월' +
          day.day.toString() +
          '일';
      monthDay = day.month.toString();
      yearDay = day.year.toString();
      dayDay = day.day.toString();

    });
    return [monthDay, yearDay, dayDay, dateFormat];
  }

  _onVisibleDaysChanged(

      DateTime month, DateTime last, CalendarFormat format) async{
    setState(() {
      yyyy = last.year.toString();
      mm = last.month.toString();
    });
    print('CALLBACK: _onVisibleDaysChanged');
    return [yyyy, mm];
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }
  var diary_num = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream:_firestore
        .collection('answers')
        .where('sender', isEqualTo: loggedInUser)
        .where('y', isEqualTo: yyyy.toString())
        .where('m', isEqualTo: mm.toString())
        .snapshots(),
    builder:(context, snapshot){
    if (snapshot.hasData) {

    int hap = 0;
    int anx = 0;
    int ang = 0;
    int neu = 0;
    int sad = 0;
    int exc = 0;
    int sum_of_emo = 0;
    final messages = snapshot.data.documents.reversed;
    for (var message in messages) {
      if (message.data['type'] == '기쁨'){
        hap+=1;
    }
      else if(message.data['type']=='슬픔'){
        sad+=1;
    }
      else if(message.data['type']=='불안'){
        anx+=1;
    }
      else if(message.data['type']=='중립'){
        neu+=1;
    }
      else if(message.data['type'] =='분노'){
        ang+=1;
    }
      else{exc+=1;}
    }
    sum_of_emo = hap+sad+anx+neu+ang+exc;

    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Row(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    // countSchedule(),

                    Text(
    sum_of_emo.toString(),
                      style: TextStyle(fontSize: 40),
                    ),

                    Text(
                      '이번달 일기 수',
                      style: TextStyle(fontSize: 15),
                    )
                  ],
                ),
                SizedBox(
                  width: 50,
                ),
                Column(
                  children: <Widget>[
                    Row(children: <Widget>[
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '😀 행복',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        hap.toString()+'번',
                        style: TextStyle(fontSize: 15),
                      )

                    ]),
                    SizedBox(
                      height: 10,
                    ),
                    Row(children: <Widget>[
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '🤔 불안',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        anx.toString()+'번',
                        style: TextStyle(fontSize: 15),
                      )
                    ]),
                    SizedBox(
                      height: 10,
                    ),
                    Row(children: <Widget>[
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '😡 분노',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        ang.toString()+'번',
                        style: TextStyle(fontSize: 15),
                      ),
                    ]),
                  ],
                ),
                SizedBox(
                  height:10,
                  width: 20,
                ),
                Column(
                  children: <Widget>[
                    Row(children: <Widget>[
                      SizedBox(
                        // height:20,
                        width: 10,
                      ),
                      Text(
                        '😐 중립',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        neu.toString()+'번',
                        style: TextStyle(fontSize: 15),
                      )
                    ]),
                    SizedBox(
                      height: 10,
                    ),
                    Row(children: <Widget>[
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '😥 슬픔',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        sad.toString()+'번',
                        style: TextStyle(fontSize: 15),
                      )
                    ]),
                    SizedBox(
                      height: 10,
                    ),
                    Row(children: <Widget>[
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '❓ 예외',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        exc.toString()+'번',
                        style: TextStyle(fontSize: 15),
                      )
                    ]),
                    SizedBox(
                      height: 10,
                    ),
                    // Row(children: <Widget>[
                    //   SizedBox(
                    //     width: 10,
                    //   ),
                    // ]),
                  ],
                ),
              ],
            ),
          ),

          _buildTableCalendar(),
          Expanded(child: dateSelect()),
        ],
      ));
  }
        }
  );
  }



  Widget _buildTableCalendar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
      StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('answers').where('sender', isEqualTo: loggedInUser).snapshots(),
        builder:(context, eventsnapshot){
          if (eventsnapshot.hasData){
    return TableCalendar(
    locale: 'ko_KO',
    calendarController: _calendarController,
    events: generateMapOfEventsFromFirestoreDocuments(eventsnapshot.data),
    holidays: _holidays,
    startingDayOfWeek: StartingDayOfWeek.sunday,
    calendarStyle: CalendarStyle(
    selectedColor: Colors.deepOrange[400],
    todayColor: Colors.deepOrange[200],
    markersColor: Colors.brown[700],
    outsideDaysVisible: false,
    ),
    headerStyle: HeaderStyle(
    formatButtonTextStyle:
    TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
    formatButtonDecoration: BoxDecoration(
    color: Colors.deepOrange[400],
    borderRadius: BorderRadius.circular(16.0),
    ),
    ),
    onDaySelected: _onDaySelected,

    onVisibleDaysChanged: _onVisibleDaysChanged,
    onCalendarCreated: _onCalendarCreated,

    );
          }
          else{
            return TableCalendar(
              locale: 'ko_KO',
              calendarController: _calendarController,
              events: _events,
              holidays: _holidays,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              calendarStyle: CalendarStyle(
                selectedColor: Colors.deepOrange[400],
                todayColor: Colors.deepOrange[200],
                markersColor: Colors.brown[700],
                outsideDaysVisible: false,
              ),
              headerStyle: HeaderStyle(
                formatButtonTextStyle:
                TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
                formatButtonDecoration: BoxDecoration(
                  color: Colors.deepOrange[400],
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              onDaySelected: _onDaySelected,

              onVisibleDaysChanged: _onVisibleDaysChanged,
              onCalendarCreated: _onCalendarCreated,

            );
          }
        }
      )
    ]


  );

  }





  Widget dateSelect(){
    return StreamBuilder<QuerySnapshot>(
        stream:_firestore
            .collection('answers')
            .where('y', isEqualTo: yearDay)
            .where('m', isEqualTo: monthDay)
            .where('d', isEqualTo: dayDay)
        .where('sender', isEqualTo: loggedInUser)
        .snapshots(),
        builder:(context, snapshot){
    if (!snapshot.hasData) {
      return ListView(children:<Widget>[Container(
        child: Center(child:Text(dayDay+'일의 일기가 없습니다!',
        style: TextStyle(color: Colors.red))
      ),
      ),
      Container(),
      ]);
    }
          else{
      final messages = snapshot.data.documents.reversed;
      List<xCalender> calender = [];
    for (var message in messages) {

    final diary = message.data['diary'];
    final time = message.data['t'];
    String type = "";

    if (message.data['type'] == '기쁨'){
    type = '😀';
    }
    else if(message.data['type']=='슬픔'){
    type = '😥';
    }
    else if(message.data['type']=='불안'){
    type = '🤔';
    }
    else if(message.data['type']=='중립'){
    type = '😐';
    }
    else if(message.data['type'] =='분노'){
    type = '😡';
    }
    else{type = '❓';}



    final x = xCalender(
      diary:diary,
        type:type,
        time:time
    );
    calender.add(x);
    }

            return ListView.builder(
              itemCount: calender.length,
              itemBuilder: (BuildContext context, int i){
                return ListTile(
                  leading:Text(calender[i].type, style: TextStyle(fontSize: 30)),
                  title: Text(calender[i].time.toString(), style:TextStyle(fontSize: 12, color:Colors.black45)
                      ),
                  subtitle: Text(calender[i].diary, style:TextStyle(fontSize:14, color:Colors.black)));

              },
            );}
        }

    );}
  }

    // else {
    // return Text(
    // dayDay+'메모를 추가해주세요!',
    // style: TextStyle(color: Colors.red),
    // );
    // }
    // );

  //           return Container(
  //             padding: EdgeInsets.only(left: 30),
  //             width: MediaQuery.of(context).size.width,
  //             height: MediaQuery.of(context).size.height * 0.55,
  //             decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.only(
  //                     topLeft: Radius.circular(50),
  //                     topRight: Radius.circular(50)),
  //                 color: Color(0xff30384c)),
  //             child: SingleChildScrollView(
  //               child: Column(
  //                 children: [
  //                   Padding(
  //                     padding: const EdgeInsets.only(top: 10),
  //                     child: Text(
  //                       dateFormat,
  //                       textAlign: TextAlign.left,
  //                       style: TextStyle(
  //                         color: Colors.white,
  //                         fontSize: 25,
  //                       ),
  //                     ),
  //                   ),
  //                   ListView.builder(
  //                       physics: ClampingScrollPhysics(),
  //                       shrinkWrap: true,
  //                       itemCount: lists.length,
  //                       itemBuilder: (BuildContext context, int index) {
  //                         return Padding(
  //                           padding: const EdgeInsets.all(4.0),
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: <Widget>[
  //                               textColor(index, values),
  //                             ],
  //                           ),
  //                         );
  //                       }),
  //                 ],
  //               ),
  //             ),
  //           );
  //         } else {
  //           return Text(
  //             '로딩중',
  //             style: TextStyle(fontSize: 25),
  //           );
  //         }
  //       });
  // }
  //
  // Widget textColor(int index, Map<dynamic, dynamic> values) {
  //   if (xCalender[index]["할일"] == '과제') {
  //     return Row(
  //       children: [
  //         Icon(
  //           Icons.menu_book_rounded,
  //           color: Colors.red,
  //           size: 27,
  //         ),
  //         SizedBox(
  //           width: 8,
  //         ),
  //         Flexible(
  //           child: Text(lists[index]["메모"],
  //               overflow: TextOverflow.ellipsis,
  //               maxLines: 5,
  //               style: TextStyle(color: Colors.red)),
  //         ),
  //         iconsButton(values, index)
  //       ],
  //     );
  //   } else if (lists[index]["할일"] == '약속') {
  //     return Row(
  //       children: [
  //         Icon(
  //           Icons.access_alarm,
  //           color: Colors.blue,
  //           size: 27,
  //         ),
  //         SizedBox(
  //           width: 8,
  //         ),
  //         Flexible(
  //             child: Text(lists[index]["메모"],
  //                 overflow: TextOverflow.ellipsis,
  //                 maxLines: 5,
  //                 style: TextStyle(color: Colors.blue))),
  //         iconsButton(values, index)
  //       ],
  //     );
  //   } else {
  //     return Row(
  //       children: [
  //         Icon(
  //           Icons.add_alert,
  //           color: Colors.teal,
  //           size: 27,
  //         ),
  //         SizedBox(
  //           width: 8,
  //         ),
  //         Flexible(
  //             child: Text(lists[index]["메모"],
  //                 overflow: TextOverflow.ellipsis,
  //                 maxLines: 5,
  //                 style: TextStyle(color: Colors.teal))),
  //         iconsButton(values, index)
  //       ],
  //     );
  //   }
  // }
  //
  // Widget iconsButton(Map<dynamic, dynamic> values, int index) {
  //   return IconButton(
  //     icon: Icon(
  //       Icons.delete,
  //       size: 25,
  //       color: Colors.white,
  //     ),
  //     onPressed: () {
  //       Alert(
  //         context: context,
  //         type: AlertType.info,
  //         title: "삭제",
  //         desc: "해당 일정을 삭제하시겠습니까?",
  //         buttons: [
  //           DialogButton(
  //             child: Text(
  //               "No",
  //               style: TextStyle(color: Colors.white, fontSize: 20),
  //             ),
  //             onPressed: () => Navigator.pop(context, false),
  //             color: Colors.teal,
  //           ),
  //           DialogButton(
  //             child: Text(
  //               "Yes",
  //               style: TextStyle(color: Colors.white, fontSize: 20),
  //             ),
  //             onPressed: () {
  //               setState(() {
  //                 dbref
  //                     .child(user.displayName)
  //                     .child(yearDay + "년")
  //                     .child(monthDay + "월")
  //                     .child(dateFormat)
  //                     .child(values.keys.elementAt(index).toString())
  //                     .remove()
  //                     .then((_) {
  //                   Navigator.pop(context, true);
  //                 });
  //               });
  //             },
  //             color: Colors.teal,
  //           )
  //         ],
  //       ).show();
  //     },
  //   );
  // }
  //
//   Widget countSchedule() {
//     return StreamBuilder<QuerySnapshot>(
//         stream: _firestore.collection('total').snapshots(),
//         builder: (context, snapshot) {
//           final students = snapshot.data.documents;
//           // snapshot은 stream에서 지정한 컬렉션을 의미하고,
//           // data.documents는 컬렉션 내 전체 문서 값들을 리턴하는 역할을 합니다.
//           // documents는 List 형식이어서 반복문 형태로 사용 가능합니다.
//           for (var student in students) {
//             var total = student.data['total'];
//             // data['field'] 를 통해 field 값에 접근할 수 있습니다.
//           // 해당 문서의 ID는 .documentID 가 리턴하는 값을 통해 얻을 수 있습니다.
//         }
//         }
//     );
// return new Text("안녕");
//   }
