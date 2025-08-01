import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/auth.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String? errorMessage = "";

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  Widget _entryField(String title, TextEditingController text) {
    if (title == "Email") {
      return TextFormField(
        controller: text,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          suffixIcon: Icon(Icons.email_outlined),
          hintText: "Enter your email",
          hintStyle: TextStyle(color: Colors.black),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30), // circular edges
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.blue[500]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.blue[500]!, width: 2),
          ),
        ),
        autocorrect: false,
      );
    }
    return TextFormField(
      controller: text,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        suffixIcon: Icon(Icons.lock_outline),
        hintText: "Enter your password",
        hintStyle: TextStyle(color: Colors.black),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), // circular edges
          borderSide: BorderSide(),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.blue[500]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.blue[500]!, width: 2),
        ),
      ),
      autocorrect: false,
    );
  }

  Widget submitButton() {
    return ElevatedButton(
      onPressed: () async {
        int code = await context.read<UserAuthProvider>().signUp(
          _email.text,
          _password.text,
        );

        if (code == 1) {
          Navigator.pushNamed(context, '/');
        }
      },
      child: Text("Register"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: Card(
              elevation: 8,
              shadowColor: Colors.blue,
              margin: EdgeInsets.all(12),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Register now",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        "Register with your email and password",
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
                              Navigator.pushNamed(context, '/sign-in');
                            },
                            style: ButtonStyle(
                              elevation: WidgetStateProperty.all(0),
                              backgroundColor: WidgetStateProperty.all(
                                Colors.blue,
                              ),
                            ),
                            child: Text(
                              "Back",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(4),
                          child: ElevatedButton(
                            onPressed: () async {
                              int code = await context
                                  .read<UserAuthProvider>()
                                  .signUp(_email.text, _password.text);

                              if (code == 1) {
                                Navigator.pushNamed(context, '/');
                              }
                            },
                            style: ButtonStyle(
                              elevation: WidgetStateProperty.all(0),
                              backgroundColor: WidgetStateProperty.all(
                                Colors.blue,
                              ),
                            ),
                            child: Text(
                              "Register",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
