import 'package:flutter/material.dart';
import 'google_signin/google_signin_demo.dart';
import 'package:provider/provider.dart';
import 'login/firebase_provider.dart';
import 'login/auth_page.dart';


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
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AuthPage.id,
      routes:{
        AuthPage.id: (context) => AuthPage(),
      },
    );
  }
}