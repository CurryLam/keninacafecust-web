import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../Utils/ip_address.dart';
import '../main.dart';
import 'otpEnterScreen.dart';

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
      home: const PasswordResetScreenPage(tableNo: null),
    );
  }
}

class PasswordResetScreenPage extends StatefulWidget {
  const PasswordResetScreenPage({super.key, this.tableNo});

  final String? tableNo;

  @override
  State<PasswordResetScreenPage> createState() => _PasswordResetScreenPageState();
}

class _PasswordResetScreenPageState extends State<PasswordResetScreenPage> {
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
    const String apiUrl = '${IpAddress.ip_addr}/users/password_reset_customer';

    final response = await http.post(
      Uri.parse(apiUrl),
      body: {'email': email},
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
                  MaterialPageRoute(builder: (context) => OtpEnterScreenPage(otp_id: responseData['otp_id'].toString(), uid: responseData['uid'], tableNo: currentTableNo,),
                ));
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Email Not Found', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: Text('Please enter the valid registered email.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
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
            title: const Text(
              'Forgot Password',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
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
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'To reset your password, please enter your email address. An OTP will be sent to you within a few minutes.',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
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
