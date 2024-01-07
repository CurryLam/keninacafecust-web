import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:keninacafecust_web/Auth/verifyEmail.dart';

import '../main.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const EnterEmailToRegisterPage(tableNo: null),
    );
  }
}

class EnterEmailToRegisterPage extends StatefulWidget {
  const EnterEmailToRegisterPage({super.key, this.tableNo,});

  final String? tableNo;

  @override
  State<EnterEmailToRegisterPage> createState() => _EnterEmailToRegisterPageState();
}

class _EnterEmailToRegisterPageState extends State<EnterEmailToRegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  String? getTableNo() {
    return widget.tableNo;
  }

  Future<void> resetPassword(BuildContext context, String currentTableNo) async {
    setState(() {
      isLoading = true;
    });

    final String email = emailController.text;
    const String apiUrl = 'http://localhost:8000/users/email_verification';

    final response = await http.post(
      Uri.parse(apiUrl),
      body: {'email': email, 'current_otp_id': "0",},
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Success', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: Text(responseData['success']),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VerifyEmailPage(otp_id: responseData['otp_id'].toString(), tableNo: currentTableNo, email: emailController.text),
                    ));
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(context: context, builder: (BuildContext context) =>
          AlertDialog(
            title: const Text('Registration', style: TextStyle(fontWeight: FontWeight.bold,)),
            content: Text('User already exists! Please Login instead.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: const Text('Login'),
              ),
            ],
          )
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    String? currentTableNo = getTableNo();

    return WillPopScope(
      onWillPop: () async {
        // Navigate to the desired page when the Android back button is pressed
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );

        // Prevent the default back button behavior
        return false;
      },
      child: Scaffold(
        appBar: PreferredSize( //wrap with PreferredSize
          preferredSize: const Size.fromHeight(80),
          child: AppBar(
            title: const Text('Sign Up'),
            leading: IconButton(
              onPressed: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage())
                ),
              },
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            ),
            toolbarHeight: 100,
            backgroundColor: Colors.orange.shade500,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(height: 10,),
                    Text("Create an Account to get more benefits !",style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),),
                    const SizedBox(height: 10,)
                  ],
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                    child: Row(
                        children: [
                          Text('Email', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                          // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                        ]
                    )
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child:
                  TextFormField(
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20), // Set border radius here
                        borderSide: BorderSide(
                          color: Colors.grey.shade500,
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20), // Set border radius here
                        borderSide: BorderSide(
                          color: Colors.grey.shade500,
                          width: 2.0,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20), // Set border radius here
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2.0,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20), // Set border radius here
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2.0,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      // hintText: 'Please enter your password',
                    ),
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Gabarito",
                    ),
                  ),
                ),
                const SizedBox(height: 13,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  child: Container(
                    padding: const EdgeInsets.only(top: 3,left: 3),
                    child: MaterialButton(
                      minWidth: double.infinity,
                      height:50,
                      onPressed: (){
                        if (_formKey.currentState!.validate()) {
                          resetPassword(context, currentTableNo!);
                        }
                      },
                      color: Colors.lightBlueAccent.shade400,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)
                      ),
                      child: isLoading
                          ? LoadingAnimationWidget.threeRotatingDots(
                        color: Colors.black,
                        size: 20,
                      )
                          : const Text(
                        "Confirm",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      // child: const Text("Confirm",style:
                      //   TextStyle(
                      //     fontWeight: FontWeight.bold,fontSize: 16, color: Colors.white,
                      //   ),
                      // ),
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
}
