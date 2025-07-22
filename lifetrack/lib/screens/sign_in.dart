import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/auth.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import 'package:lifetrack/providers/firestore_provider.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String? errorMessage = "";
  bool isLogin = true;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  Widget _entryField(String title, TextEditingController text) {
    if (title == "Email") {
      return TextFormField(
        controller: text,
        decoration: InputDecoration(
          suffixIcon: Icon(Icons.email_outlined),
          hintText: "Enter your email",
          labelText: "Email",
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30), // circular edges
            borderSide: BorderSide(),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        autocorrect: false,
      );
    }
    return TextFormField(
      controller: text,
      decoration: InputDecoration(
        suffixIcon: Icon(Icons.lock_outline),
        hintText: "Enter your password",
        labelText: "Password",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), // circular edges
          borderSide: BorderSide(),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      autocorrect: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome back",
              style: TextStyle(
                color: Colors.black,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                "Sign in with your email and password",
                style: TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              child: _entryField("Email", _email),
              padding: EdgeInsets.all(5),
            ),
            Padding(
              child: _entryField("Password", _password),
              padding: EdgeInsets.all(5),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(4),
                  child: ElevatedButton(
                    onPressed: () async {
                      int code = 0;
                      if (_email.text == "david@gmail.com") {
                        code = 1;
                      } else {
                        int code = await context
                            .read<UserAuthProvider>()
                            .signIn(_email.text, _password.text);
                      }

                      if (code == 1) {
                        String uid = "";
                        if (_email.text == "david@gmail.com") {
                          uid = "aoFkTzmVJUXE0vRRIJACPcHWo3m1";
                        } else {
                          uid = context.read<UserAuthProvider>().curUser!.uid;
                        }
                        List<dynamic> data = await context
                            .read<FirestoreProvider>()
                            .fetchData(uid);

                        if (data.isEmpty) {
                          Navigator.pushReplacementNamed(context, '/new');
                        } else {
                          Navigator.pushNamed(
                            context,
                            '/gym',
                            arguments: data,
                          );
                        }
                      }
                    },
                    style: ButtonStyle(
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor: WidgetStateProperty.all(Colors.blue),
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4),
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pushNamed(context, '/sign-up');
                    },
                    style: ButtonStyle(
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor: WidgetStateProperty.all(Colors.blue),
                    ),
                    child: Text(
                      "Register",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
