import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgetPW extends StatefulWidget {
  @override
  _ForgetPWState createState() => _ForgetPWState();
}

class _ForgetPWState extends State<ForgetPW> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('비밀번호 찾기'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                  icon: Icon(Icons.account_circle), labelText: '이메일'),
              validator: (String value) {
                if (value.isEmpty) {
                  return '알맞은 이메일을 입력해주세요.';
                }
                return null;
              },
            ),
            FlatButton(
              onPressed: () async {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
                final snackBar = SnackBar(
                  content: Text('비밀번호 재설정을 위해 이메일을 확인해주세요.'),
                );
                Scaffold.of(_formKey.currentContext).showSnackBar(snackBar);
              },
              child: Text('비밀번호 재설정'),
            ),
          ],
        ),
      ),
    );
  }
}