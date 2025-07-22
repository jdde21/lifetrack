import 'package:flutter/material.dart';
import 'package:lifetrack/providers/auth_provider.dart';
import 'package:lifetrack/providers/firestore_provider.dart';
import 'package:provider/provider.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  TextEditingController _dateController = TextEditingController();

  int currentStep = 0;
  int numberOfCategs = 0;
  List<List<String>> categories = [[], []];
  List<dynamic> data = [];
  String date = "";
  @override
  Widget build(BuildContext context) {
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
                currentStep++;
              });
            }
          } else {
            bool isValid = _formKey3.currentState!.validate();
            print(categories);
            print(_dateController.text);
            if (isValid) {
              _formKey3.currentState!.save();
              await context.read<FirestoreProvider>().addExpense(categories, _dateController.text, ""); // the third argument (for uid) is empty since i am using huawei phone and i cant sign in so hardcoded muna
            }
          }
        },
        onStepCancel: () {
          if (currentStep != 0) {
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
                  label: Text("How many expense categories do you have"),
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
                  numberOfCategs = int.parse(value!);
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
                  itemCount: numberOfCategs,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          label: Text("Name of category"),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter an input";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          categories[0].add(value!);
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
                controller: _dateController,
                decoration: const InputDecoration(label: Text("Date")),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter an input";
                  } else {
                    return null;
                  }
                },
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    _dateController.text =
                        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                  }
                },
              ),
              SizedBox(
                height: 500,
                child: ListView.builder(
                  itemCount: categories[0].length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        decoration: InputDecoration(
                          label: Text(
                            "Initial expense for ${categories[0][index]}",
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter an input";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          categories[1].add(value!);
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
    ];
  }
}
