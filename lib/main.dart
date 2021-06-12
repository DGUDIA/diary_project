import 'package:diary_project/login/my_page.dart';
import 'package:flutter/material.dart';
import 'google_signin/google_signin_demo.dart';
import 'package:provider/provider.dart';
import 'login/firebase_provider.dart';
import 'login/auth_page.dart';
import 'login/signin_page.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MultiProvider(

      providers: [
        ChangeNotifierProvider<FirebaseProvider>(
            create: (_) => FirebaseProvider())
      ],
      child: MaterialApp(

        title: "Flutter Firebase",
        home: HomePage(),
        supportedLocales: [const Locale('ko', 'KR')],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    return MaterialApp(

      initialRoute: AuthPage.id,
      debugShowCheckedModeBanner: false,
      routes:{
        AuthPage.id: (context) => AuthPage(),
        SignedInPage.id: (context) => SignedInPage(),

      },
    );
  }
}