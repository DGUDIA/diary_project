import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:diary_project/my_config.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

void main() => runApp(MaterialApp(
    home:Scaffold(
      body:Client()))
);

class Client extends StatefulWidget {
  @override
  _ClientState createState() => _ClientState();
}

enum DataKind { NONE, SEND }
final gServerIp = 'http://13.124.54.4:56201/';


class _ClientState extends State<Client> {
  DataKind mKind = DataKind.NONE;

  String mResult = '0';               // 서버로부터 수신한 덧셈 또는 곱셈 결과
  String mText;        // 사용자가 입력한 연산의 왼쪽과 오른쪽 항의 값

  // post 동작의 결과를 수신할 비동기 함수
  // 연산할 데이터를 전달(post)해야 하기 때문에 멤버로 만들어야 했다.
  Future<String> postReply() async {
    if(mText == null)
      return '';

    // 문자열 이름은 서버에 정의된 add와 multiply 서비스
    var addr = gServerIp + ((mKind == DataKind.SEND) ? 'send':'none');
    var response = await http.post(addr, body: {'text': mText});

    // 200 ok. 정상 동작임을 알려준다.
    if (response.statusCode == 200)
      return response.body;

    // 데이터 수신을 하지 못했다고 예외를 일으키는 것은 틀렸다.
    // 여기서는 코드를 간단하게 처리하기 위해.
    throw Exception('데이터 수신 실패!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Padding(
                  // TextField 위젯은 사용자 입력을 받는다.
                  // Expanded 또는 Flexible 등의 위젯의 자식이어야 한다.
                  child: TextField(
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25),
                    onChanged: (text) => mText = text,  // 입력할 때마다 호출
                  ),
                  padding: EdgeInsets.all(3.0),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                child: Text('보내기'),
                onPressed: () {
                  if(mText != null) {
                    mKind = DataKind.SEND;
                    // postReply 함수는 비동기 함수여서 지연 처리
                    // then : 수신 결과를 멤버변수에 저장
                    // whenComplete : // 비동기 연산 완료되면 상태 변경
                    try {
                      postReply()
                          .then((recvd) => mResult = recvd)
                          .whenComplete(() {
                        if(mResult.isEmpty == false)
                          setState(() {});
                      });
                    } catch (e, s) {
                      print(s);
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}