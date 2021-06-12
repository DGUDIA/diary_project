import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Total_list{
  int hap = 0;
  int anx = 0;
  int ang = 0;
  int neu = 0;
  int sad = 0;
  int exc = 0;
  int total = 0;
  String sender;

  Total_list({
    this.hap,
    this.anx,
    this.ang,
    this.neu,
    this.sad,
    this.exc,
    this.total,
  this.sender});
}


class xCalender {
  String diary;
  String type;
  String y;
  String m;
  String d;
  String time;
  String sender;

  xCalender({this.diary,
    this.type,
    this.y,
    this.m,
    this.d,
    this.time,
  this.sender});


  /// from json is used when reading data from firestore.
  xCalender.fromJson(Map<String, dynamic> json) {
    time = json['time'];
    diary = json['diary'];
    type = json['diary'];
    y = json['y'];
    m = json['m'];
    d = json['d'];
    time = json['time'];
    sender = json['sender'];
  }
}

Map<DateTime, List<xCalender>> generateMapOfEventsFromFirestoreDocuments(
    QuerySnapshot querySnapshot) {
  List<xCalender> tasks = List.generate(querySnapshot.documents.length,
          (index) => xCalender.fromJson(querySnapshot.documents[index].data));
  Map<DateTime, List<xCalender>> events = {};
  tasks.forEach((element) {
    DateTime date = DateTime(
        int.parse(element.y), int.parse(element.m), int.parse(element.d), 12);
    if (events[date] == null) {
      events[date] = [];
    }
    events[date].add(element);
  });
  return events;
}