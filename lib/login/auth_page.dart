import 'package:flutter/material.dart';
import 'firebase_provider.dart';
import '../chat/chat_screen.dart';
import 'signin_page.dart';
import 'package:provider/provider.dart';
import '../menu/menu.dart';

AuthPageState pageState;

class AuthPage extends StatefulWidget {
  static const String id = 'login_screen';
  @override
  AuthPageState createState() {
    pageState = AuthPageState();
    return pageState;
  }
}

class AuthPageState extends State<AuthPage> {
  FirebaseProvider fp;

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);

    logger.d("user: ${fp.getUser()}");
    if (fp.getUser() != null && fp.getUser().isEmailVerified == true) {
      return Menu();
    } else {
      return SignInPage();
    }
  }
}