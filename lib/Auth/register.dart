import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:keninacafecust_web/AppsBar.dart';
import 'package:keninacafecust_web/Auth/login.dart';
import 'package:keninacafecust_web/Security/Encryptor.dart';
import 'package:keninacafecust_web/Utils/error_codes.dart';

import 'package:keninacafecust_web/AppsBar.dart';
import '../Entity/User.dart';

void main() {
  runApp(const MyApp());
}

void enterFullScreen() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const RegisterPage(),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  // final String title;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final dateInput = TextEditingController();
  bool securePasswordText = true;
  bool secureConfirmPasswordText = true;
  String gender = "";
  bool userRegistered = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    dateInput.text = ""; //set the initial value of text field
    super.initState();
  }

  void _togglePasswordView() {
    setState(() {
      securePasswordText = !securePasswordText;
    });
  }

  void _toggleConfirmPasswordView() {
    setState(() {
      secureConfirmPasswordText = !secureConfirmPasswordText;
    });
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppsBarState().buildAppBar(context, "Sign Up"),

      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(height: 20,),
                    Text("Create an Account to get more benefits !",style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),),
                    const SizedBox(height: 20,)
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 6),
                            child: Row(
                                children: [
                                  Text('Full Name', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                  Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          child:
                          TextFormField(
                            controller: nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Please enter your full name',
                            ),
                          ),
                        ),

                        const SizedBox(height: 13,),

                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 6),
                            child: Row(
                                children: [
                                  Text('Email', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                  Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          child:
                          TextFormField(
                            controller: emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                              if (!emailRegex.hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Please enter your email',
                            ),
                          ),
                        ),

                        const SizedBox(height: 13,),

                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 6),
                            child: Row(
                                children: [
                                  Text('Phone Number', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                  Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          child:
                          TextFormField(
                            controller: phoneNumberController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Please enter your phone number',
                            ),
                          ),
                        ),

                        const SizedBox(height: 13,),

                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 6),
                            child: Row(
                                children: [
                                  Text('Password', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                  Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          child:
                          TextFormField(
                            obscureText: securePasswordText,
                            controller: passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              final passwordRegex =
                              RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#&*~]).{8,}$');

                              if (!passwordRegex.hasMatch(value)) {
                                return 'Please enter a valid password with at least one\ncapital letter, one small letter, one number, and\none symbol from '
                                    '!, @, #, &, * or ~';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              suffix: InkWell(
                                onTap: _togglePasswordView,
                                child: const Icon( Icons.visibility),
                              ),
                              hintText: 'Please enter your password',
                            ),
                          ),
                        ),

                        const SizedBox(height: 13,),

                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 6),
                            child: Row(
                                children: [
                                  Text('Confirm Password', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                  Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          child:
                          TextFormField(
                            obscureText: secureConfirmPasswordText,
                            controller: confirmPasswordController,
                            validator: (value) {
                              if (value != passwordController.text) {
                                return 'Passwords do not match!';
                              } else if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              suffix: InkWell(
                                onTap: _toggleConfirmPasswordView,
                                child: const Icon( Icons.visibility),
                              ),
                              hintText: 'Please enter the password again',
                            ),
                          ),
                        ),

                        const SizedBox(height: 13,),

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 6),
                          child: Row(
                            children: [
                             Text("What is your gender?", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                             Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          child: Column(
                            children: [
                              RadioListTile(
                                title: const Text("Male"),
                                value: "male",
                                groupValue: gender,
                                onChanged: (value){
                                  setState(() {
                                    gender = value.toString();
                                  });
                                },
                              ),
                              RadioListTile(
                                title: const Text("Female"),
                                value: "female",
                                groupValue: gender,
                                onChanged: (value){
                                  setState(() {
                                    gender = value.toString();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          child:TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your date of birth';
                              }
                              return null;
                            },
                            controller: dateInput, //editing controller of this TextField
                            decoration: const InputDecoration(
                                icon: Icon(Icons.calendar_today), //icon of text field
                                labelText: "Date Of Birth" //label text of field
                            ),
                            readOnly: true,  //set it true, so that user will not able to edit text
                            onTap: () async {
                              var pickedDate = await showDatePicker(
                                  context: context, initialDate: DateTime.now(),
                                  firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                                  lastDate: DateTime(2101)
                              );

                              if(pickedDate != null ){
                                // print(pickedDate);  //pickedDate output format => 2021-03-10 00:00:00.000
                                String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                                // print(formattedDate); //formatted date output using intl package =>  2021-03-16
                                //you can implement different kind of Date Format here according to your requirement

                                setState(() {
                                  dateInput.text = formattedDate; //set output date to TextField value.
                                });
                              }else{
                                // print("Date is not selected");
                              }
                            },
                          )
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 6),
                          child: Container(
                            padding: const EdgeInsets.only(top: 3,left: 3),
                            // decoration: BoxDecoration(
                            //     borderRadius: BorderRadius.circular(40),
                            //     border: const Border(
                            //         bottom: BorderSide(color: Colors.black),
                            //         top: BorderSide(color: Colors.black),
                            //         right: BorderSide(color: Colors.black),
                            //         left: BorderSide(color: Colors.black)
                            //     )
                            // ),
                            child: MaterialButton(
                              minWidth: double.infinity,
                              height:50,
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  var (userRegisteredAsync, err_code) = await _submitRegisterDetails();
                                  setState(() {
                                    userRegistered = userRegisteredAsync;
                                    if (!userRegistered) {
                                      if (err_code == ErrorCodes.REGISTER_FAIL_USER_EXISTS) {
                                        showDialog(context: context, builder: (BuildContext context) =>
                                          AlertDialog(
                                            title: const Text('Registration'),
                                            content: Text('User already exists! Please Login instead.\n\nError Code: $err_code'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                                                },
                                                child: const Text('Login'),
                                              ),
                                            ],
                                          )
                                        );
                                      } else {
                                        showDialog(context: context, builder: (BuildContext context) =>
                                          AlertDialog(
                                            title: const Text('Registration'),
                                            content: Text('Registration failed! Please try again later.\n\nError Code: $err_code'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          )
                                        );
                                      }
                                    } else {
                                      showDialog(context: context, builder: (BuildContext context) =>
                                        AlertDialog(
                                          title: const Text('Registration'),
                                          content: const Text('Registration successful! Please login.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                                              },
                                              child: const Text('Login'),
                                            ),
                                          ],
                                        )
                                      );
                                    }
                                  });
                                }
                                  // Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                              },
                              color: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40)
                              ),
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,fontSize: 18,
                                  color: Colors.white
                                ),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                    text: 'Already have an account?  ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.transparent,
                                      shadows: [Shadow(color: Colors.black, offset: Offset(0, -4))],
                                    )
                                ),

                                TextSpan(
                                  text: 'Login',
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.transparent,
                                    shadows: [Shadow(color: Colors.blue, offset: Offset(0, -4))],
                                    decorationThickness: 4,
                                    decorationColor: Colors.blue,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                    );
                                  },
                                ),
                              ]
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<(bool, String)> _submitRegisterDetails() async {
    String name = nameController.text;
    String email = emailController.text;
    String phone = phoneNumberController.text;
    String password = passwordController.text;
    String confirmPw = confirmPasswordController.text;
    String gender = this.gender;
    DateTime dob = DateTime.parse(dateInput.text);

    if (kDebugMode) {
      print('name: $name');
      print('email: $email');
      print('phone: $phone');
      print('password: $password');
      print('confirmPw: $confirmPw');
      print('gender: $gender');
      print('dob: $dob');
    }
    String enc_pw = Encryptor().encryptPassword(password);
    var (thisUser, err_code) = await createUser(name, email, phone, enc_pw, gender, dob);
    if (thisUser.uid == -1) {
      if (kDebugMode) {
        print("Failed to retrieve User data.");
      }
      return (false, err_code);
    }
    return (true, err_code);
  }

  Future<(User, String)> createUser(String name, String email, String phone, String enc_pw, String gender, DateTime dob) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/users/register'),  // For phone
        // Uri.parse('http://localhost:8000/users/register'),  // For website
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'image': null,
          'is_staff': false,
          'is_active': true,
          'staff_type': null,
          'name': name,
          'email': email,
          'password': enc_pw,
          'address': null,
          'phone': phone,
          'gender': gender,
          'dob': dob.toString(),
          'ic': null,
          'points': 0,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        var jsonResp = jsonDecode(response.body);
        var jwtToken = jsonResp['token'];
        return (User.fromJWT(jwtToken), (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print('User exist in system.');
        }
        return (User(uid: -1, name: '', is_active: false, email: '', gender: '', dob: DateTime.now(), phone: '', points: 0), (ErrorCodes.REGISTER_FAIL_USER_EXISTS));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (User(uid: -1, name: '', is_active: false, email: '', gender: '', dob: DateTime.now(), phone: '', points: 0), (ErrorCodes.REGISTER_FAIL_API_CONNECTION));
    }
  }
}

