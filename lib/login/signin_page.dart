import '../chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'firebase_provider.dart';
import 'signup_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forgot_pw.dart';

SignInPageState pageState;

class SignInPage extends StatefulWidget {
  @override
  SignInPageState createState() {
    pageState = SignInPageState();
    return pageState;
  }
}

class SignInPageState extends State<SignInPage> {
  TextEditingController _mailCon = TextEditingController();
  TextEditingController _pwCon = TextEditingController();
  bool doRemember = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseProvider fp;

  @override
  void initState() {
    super.initState();
    getRememberInfo();
  }

  @override
  void dispose() {
    setRememberInfo();
    _mailCon.dispose();
    _pwCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);

    logger.d(fp.getUser());
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(child:Text("💎",
            style:TextStyle(fontSize: 30),
          )),
          Container(child:Text("다이\n아리",
            style:TextStyle(fontSize: 50),
          )),
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Column(
              children: <Widget>[

                // Input Area
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: _mailCon,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.mail),
                          hintText: "Email",
                        ),
                      ),
                      TextField(
                        controller: _pwCon,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          hintText: "Password",
                        ),
                        obscureText: true,
                      ),
                    ].map((c) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        child: c,
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          ),
          // Remember Me
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: <Widget>[
                Checkbox(
                  value: doRemember,
                  onChanged: (newValue) {
                    setState(() {
                      doRemember = newValue;
                    });
                  },
                ),
                Text("Remember Me")
              ],
            ),
          ),

          // Alert Box
          (fp.getUser() != null && fp.getUser().isEmailVerified == false)
              ? Container(
            margin:
            const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            decoration: BoxDecoration(color: Colors.red[300]),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Mail authentication did not complete."
                        "\nPlease check your verification email.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                RaisedButton(
                  color: Colors.lightBlue[400],
                  textColor: Colors.white,
                  child: Text("Resend Verify Email"),
                  onPressed: () {
                    FocusScope.of(context)
                        .requestFocus(new FocusNode()); // 키보드 감춤
                    fp.getUser().sendEmailVerification();
                  },
                )
              ],
            ),
          )
              : Container(),

          // Sign In Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ElevatedButton(

              style:ElevatedButton.styleFrom(
    primary:Colors.lightBlueAccent,
                onPrimary:Colors.white,
    ),
              child: Text(
                "로그인",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                FocusScope.of(context).requestFocus(new FocusNode()); // 키보드 감춤
                _signIn();
              },
            ),
          ),
          // Sign In with Google Account Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.only(top: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("아직 회원이 아니신가요?",
                    style: TextStyle(color: Colors.blueGrey)),
                TextButton(
                  child: Text(
                    "회원가입",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignUpPage()));
                  },
                )
              ],
            ),
          )
        ],
      ),
    ));

  }


  void _signIn() async {
    _scaffoldKey.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: Duration(seconds: 10),
        content: Row(
          children: <Widget>[
            CircularProgressIndicator(),
            Text("   Signing-In...")
          ],
        ),
      ));
    bool result = await fp.signInWithEmail(_mailCon.text, _pwCon.text);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if (result == false) showLastFBMessage();
  }

  getRememberInfo() async {
    logger.d(doRemember);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      doRemember = (prefs.getBool("doRemember") ?? false);
    });
    if (doRemember) {
      setState(() {
        _mailCon.text = (prefs.getString("userEmail") ?? "");
        _pwCon.text = (prefs.getString("userPasswd") ?? "");
      });
    }
  }

  setRememberInfo() async {
    logger.d(doRemember);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("doRemember", doRemember);
    if (doRemember) {
      prefs.setString("userEmail", _mailCon.text);
      prefs.setString("userPasswd", _pwCon.text);
    }
  }

  showLastFBMessage() {
    _scaffoldKey.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        backgroundColor: Colors.red[400],
        duration: Duration(seconds: 10),
        content: Text(fp.getLastFBMessage()),
        action: SnackBarAction(
          label: "Done",
          textColor: Colors.white,
          onPressed: () {},
        ),
      ));
  }
}