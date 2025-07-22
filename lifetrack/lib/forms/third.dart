import 'package:flutter/material.dart';
import 'package:lifetrack/providers/auth_provider.dart';
import 'package:lifetrack/providers/firestore_provider.dart';
import 'package:provider/provider.dart';

class MyThirdFormPage extends StatefulWidget {
  const MyThirdFormPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyThirdFormPage> createState() => _MyFormPageState();
}

class _MyFormPageState extends State<MyThirdFormPage> {
  final _formKey = GlobalKey<FormState>();

  List<String> exercises = [];
  @override
  Widget build(BuildContext context) {
    List<dynamic> data = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    List<List<String>> repsAndSets = [];



    for (int i = 0; i  < int.parse(data[0]); i++)
    {
      repsAndSets.add([]);
    }
    print(data);
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
                itemCount: int.parse(data[0]),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Text(data[index + 1]),
                        Expanded
                        (child: TextFormField(
                          decoration: const InputDecoration(
                            label: Text("Sets"),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter an input";
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            repsAndSets[index].add(value!);
                          },
                        )),
                        Expanded(child :TextFormField(
                          decoration: const InputDecoration(
                            label: Text("Reps"),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter an input";
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            repsAndSets[index].add(value!);
                          },
                        )),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                bool isValid = _formKey.currentState!.validate();
                
                data[int.parse(data[0]) + 1] = repsAndSets;
                for (int i = 1; i < data.length; i++)
                {
                  if (data[i] == data[0])
                  {
                    data.removeAt(i);
                  }
                }
                print(data);
                if (isValid) {
                  _formKey.currentState!.save();
                  print(data);
                  String uid = context.read<UserAuthProvider>().curUser!.uid;
                  await context.read<FirestoreProvider>().addExercise(data, "2025-02-03", uid);
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
