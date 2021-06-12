import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart' show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'chat_data.dart';



class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => new _MyHomePageState();

}

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;
final _auth = FirebaseAuth.instance;
String _CurrentMonth = DateFormat("yyyy년 M월").format(DateTime.now());
String dateFormat = DateFormat("yyyy년 M월 d일")
    .format(DateTime.now())
    .replaceAll(" ", "");
String monthDay = "";
String yearDay = "";
String dayDay = "";
List<xCalender> calender = [];

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

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('answers')
            .where('y', isEqualTo: yearDay)
            .where('m', isEqualTo: monthDay)
            // .where('d', isEqualTo: dayDay)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text(
              dayDay + '일기가 없습니다!',
              style: TextStyle(color: Colors.red),
            );
          }
          final messages = snapshot.data.documents.reversed;


          for (var message in messages) {
            // diary_num+=1;
            final diary = message.data['diary'];
            final type = message.data['type'];
            final y = message.data['y'];
            final d = message.data['d'];
            final m = message.data['m'];
            final time = message.data['time'];
            final x = xCalender(
                diary: diary,
                type: type,
              y:y,
              d:d,
              m:m,
              time:time,
            );
            calender.add(x);
          }
          return ListView.builder(
              itemCount: calender.length,
              itemBuilder: (BuildContext context, int i){
                return ListTile(
                  title: Text(calender[i].diary+calender[i].type),
                );
              },
            );}

    );

  }
}

class _MyHomePageState extends State<MyHomePage> {

  DateTime _currentDate = DateTime(DateTime
      .now()
      .year, DateTime
      .now()
      .month, DateTime
      .now()
      .day);
  DateTime _currentDate2 = DateTime(DateTime
      .now()
      .year, DateTime
      .now()
      .month, DateTime
      .now()
      .day);

  // String _currentMonth = DateFormat.yMMM().format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
  DateTime _targetDateTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  static Widget _eventIcon = new Container(
    decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(1000)),
        border: Border.all(color: Colors.blue, width: 2.0)),
    child: new Icon(
      Icons.person,
      color: Colors.amber,
    ),
  );


  EventList<Event> _markedDateMap = new EventList<Event>(
    events: {

      new DateTime(2020, 8, 5): [
        new Event(
          date: new DateTime(2020, 8, 5),
          title: 'Event 1',
          icon: _eventIcon,
          dot: Container(
            margin: EdgeInsets.symmetric(horizontal: 1.0),
            color: Colors.green,
            height: 5.0,
            width: 5.0,
          ),
        ),
        new Event(
          date: new DateTime(2020, 8, 5),
          title: 'Event 2',
          icon: _eventIcon,
        ),
      ],
    },
  );

  CalendarCarousel _calendarCarousel, _calendarCarouselNoHeader;

//             .collection('answers')
//             // .where('y', isEqualTo: yearDay)
//             // .where('m', isEqualTo: monthDay)
//         // .where('d', isEqualTo: dayDay)
//             .snapshots(),
  @override
  void initState() {
    Stream collectionStream = _firestore.collection('answers').where('y', isEqualTo: yearDay).where('m', isEqualTo: monthDay).snapshots();
    Stream dayStream = _firestore.collection('answers').where('y', isEqualTo: yearDay).where('m', isEqualTo: monthDay).where('d', isEqualTo: dayDay).snapshots();
    _markedDateMap.addAll(new DateTime(2020, 8, 13), [
      new Event(
        date: new DateTime(2020, 8, 13),
        title: 'Event 1',
        icon: _eventIcon,
      ),
      new Event(
        date: new DateTime(2020, 8, 13),
        title: 'Event 2',
        icon: _eventIcon,
      ),
      new Event(
        date: new DateTime(2020, 8, 13),
        title: 'Event 3',
        icon: _eventIcon,
      ),
      new Event(
        date: new DateTime(2020, 8, 13),
        title: 'Event 3',
        icon: _eventIcon,
      ),
    ]);
    super.initState();
  }



  @override
  Widget build(BuildContext context) {

    _calendarCarouselNoHeader = CalendarCarousel<Event>(
      todayBorderColor: Colors.green,
      onDayPressed: (DateTime date, List<Event> events) {
        this.setState(() => _currentDate2 = date);
        events.forEach((event) => print(event.title));
      },
      daysHaveCircularBorder: true,
      showOnlyCurrentMonthDate: true,
      weekendTextStyle: TextStyle(
        // color: Colors.black,
      ),
      thisMonthDayBorderColor: Colors.grey,
      weekFormat: false,
//      firstDayOfWeek: 4,
      markedDatesMap: _markedDateMap,
      height: 500.0,
      selectedDateTime: _currentDate2,
      targetDateTime: _targetDateTime,
      customGridViewPhysics: NeverScrollableScrollPhysics(),

      minSelectedDate: _currentDate.subtract(Duration(days: 360)),
      maxSelectedDate: _currentDate.add(Duration(days: 360)),

      inactiveDaysTextStyle: TextStyle(
        color: Colors.tealAccent,
        fontSize: 16,
      ),
      onCalendarChanged: (DateTime date) {
        this.setState(() {
          _targetDateTime = date;
          _CurrentMonth = DateFormat("yyyy년 M월").format(_targetDateTime);
          yearDay = _targetDateTime.year.toString();
          monthDay = _targetDateTime.month.toString();
          Expanded(child: MessagesStream());
          for (var x in calender){
            Event e = new Event(date: new DateTime(int.parse(x.y),int.parse(x.m),int.parse(x.d)),
              title: x.type,
              icon: _eventIcon,
            );
            print(x.type);
            _markedDateMap.add(new DateTime(int.parse(x.y),int.parse(x.m),int.parse(x.d)), e);
          }
        });
      },
      onDayLongPressed: (DateTime date) {
        print('long pressed date $date');
      },
    );

    return new Scaffold(
      // appBar: new AppBar(
      //   title: new Text(widget.title),
      // ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                child: _calendarCarousel,
              ),
              // This trailing comma makes auto-formatting nicer for build methods.
              // custom icon without header
              Container(
                margin: EdgeInsets.only(
                  top: 30.0,
                  bottom: 16.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: new Row(
                  children: <Widget>[
                    Expanded(
                        child: Text(
                          _CurrentMonth,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0,
                          ),
                        )),
                    FlatButton(
                      child: Text('PREV'),
                      onPressed: () {
                        setState(() {
                          _targetDateTime = DateTime(_targetDateTime.year,
                              _targetDateTime.month - 1);
                          _CurrentMonth = DateFormat("yyyy년 M월").format(
                              _targetDateTime);
                        });
                      },
                    ),
                    FlatButton(
                      child: Text('NEXT'),
                      onPressed: () {
                        setState(() {
                          _targetDateTime = DateTime(_targetDateTime.year,
                              _targetDateTime.month + 1);
                          _CurrentMonth = DateFormat("yyyy년 M월").format(
                              _targetDateTime);
                        });
                      },
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                child: _calendarCarouselNoHeader,
              ),
            ],
          ),
        ));
  }
}