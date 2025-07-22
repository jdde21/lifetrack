import 'package:flutter/material.dart';
import 'second.dart';

class MyFormPage extends StatefulWidget {
  const MyFormPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  @override
  State<MyFormPage> createState() => _MyFormPageState();
}

class _MyFormPageState extends State<MyFormPage> {

  final _formKey = GlobalKey<FormState>();
  String _numberOfExer = "";
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  label: Text("How many exercises do you have")
                ),
                validator: (value) {
                  if (value!.isEmpty)
                  {
                    return "Please enter an input";
                  }
                  else
                  {
                    RegExp digitRegExp = RegExp(r'\d');
                    for (int i = 0; i < value.length; i++)
                    {
                      if (!(digitRegExp.hasMatch(value[i])))
                      {
                        return "Only numbers";
                      }
                    }
                     return null;
                  }
                  
                },
                onSaved: (value) {
                  _numberOfExer = value!;
                },
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  bool isValid = _formKey.currentState!.validate();

                  if (isValid)
                  {
                    _formKey.currentState!.save();
                    Navigator.pushNamed(
                      context,
                      '/second',
                      arguments: _numberOfExer,
                    );
                  }
                },
                child: Text("Add")
              )
            ],
          )
          )
    );
  }
}
