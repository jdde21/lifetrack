import 'package:flutter/material.dart';
import 'second.dart';

class MySecondFormPage extends StatefulWidget {
  const MySecondFormPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MySecondFormPage> createState() => _MyFormPageState();
}

class _MyFormPageState extends State<MySecondFormPage> {
  final _formKey = GlobalKey<FormState>();

  List<dynamic> exercises = [];
  @override
  Widget build(BuildContext context) {
    int numberOfExer = int.parse(
      ModalRoute.of(context)!.settings.arguments as String,
    );


    exercises.add(numberOfExer.toString());
    


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 500,
              child: ListView.builder(
                itemCount: numberOfExer,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextFormField(
                    decoration: const InputDecoration(
                      label: Text("Name of exercise"),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter an input";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      exercises.add(value!);
                    },
                  ));
                },
              ),
            ),

            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                bool isValid = _formKey.currentState!.validate();

                if (isValid) {
                  _formKey.currentState!.save();
                  Navigator.pushNamed(
                      context,
                      '/third',
                      arguments: exercises,
                    );
                }
              },
              child: Text("Add"),
            ),
          ],
        ),
      ),
    );
  }
}
