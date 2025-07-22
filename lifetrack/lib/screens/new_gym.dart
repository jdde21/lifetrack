import 'package:flutter/material.dart';
import 'package:lifetrack/providers/auth_provider.dart';
import 'package:lifetrack/providers/firestore_provider.dart';
import 'package:provider/provider.dart';

class NewUser extends StatefulWidget {
  const NewUser({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<NewUser> createState() => _NewUserState();
}

class _NewUserState extends State<NewUser> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  String firstName = "";
  String lastName = "";
  int currentStep = 0;
  int numberOfExer = 0;
  List<String> exercises = [];
  List<dynamic> data = [];
  @override
  Widget build(BuildContext context) {
    print(numberOfExer);
    return Scaffold(
      body: Stepper(
        type: StepperType.horizontal,
        steps: getSteps(),
        currentStep: currentStep,
        onStepContinue: () async {
          if (currentStep == 0) {
            bool isValid = _formKey1.currentState!.validate();
            if (isValid) {
              _formKey1.currentState!.save();
              setState(() {
                currentStep++;
              });
            }
          } else if (currentStep == 1) {
            bool isValid = _formKey2.currentState!.validate();

            if (isValid) {
              _formKey2.currentState!.save();
              setState(() {
                data.add(numberOfExer.toString());
                
                for (int i = 0; i < exercises.length; i++)
                {
                  data.add(exercises[i]);
                }
                currentStep++;
              });
            }
          }
          else
          {
            bool isValid = _formKey3.currentState!.validate();

            if (isValid)
            {
              _formKey3.currentState!.save();
              data.add([]);
              for (int i = 0; i < numberOfExer; i++)
              {
                data[numberOfExer + 1].add([0,0,0]);
              }
              String uid = context.read<UserAuthProvider>().curUser!.uid;
              await context.read<FirestoreProvider>().addExercise(data, "list", uid);
              await context.read<FirestoreProvider>().addUser(firstName, lastName, uid);
              List<dynamic> newData = await context.read<FirestoreProvider>().fetchData(uid);
              Navigator.pushNamed(context, '/home', arguments: newData);
            }
            
          }
        },
        onStepCancel: (){
          if (currentStep != 0)
          {
            setState(() {
            currentStep--;
          });
          }
          
        },
      ),
    );
  }

  List<Step> getSteps() {
    return [
      Step(
        isActive: currentStep >= 0,
        title: Text("Quantity"),
        content: Form(
          key: _formKey1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  label: Text("How many exercises do you have"),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter an input";
                  } else {
                    RegExp digitRegExp = RegExp(r'\d');
                    for (int i = 0; i < value.length; i++) {
                      if (!(digitRegExp.hasMatch(value[i]))) {
                        return "Only numbers";
                      }
                    }
                    return null;
                  }
                },
                onSaved: (value) {
                  numberOfExer = int.parse(value!);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      Step(
        isActive: currentStep >= 1,
        title: Text("Name"),
        content: Form(
          key: _formKey2,
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
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      Step(
        isActive: currentStep >= 2,
        title: Text("Submit"),
      content: Form(
          key: _formKey3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  label: Text("Enter first name"),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter an input";
                  } else {
                    return null;
                  }
                },
                onSaved: (value) {
                  firstName = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  label: Text("Enter last name"),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter an input";
                  } else {
                    return null;
                  }
                },
                onSaved: (value) {
                  lastName = value!;
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),)
    ];
  }
}
