import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafecust_web/Auth/register.dart';
import 'package:keninacafecust_web/Entity/User.dart';
import 'package:keninacafecust_web/Security/Encryptor.dart';
import 'package:keninacafecust_web/Utils/error_codes.dart';
import 'dart:convert';

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
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool userFound = false;
  bool submittedOnce = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    enterFullScreen();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return MaterialApp(
        title: 'Login Page',
        // theme: ThemeData(scaffoldBackgroundColor: Colors.grey),
        home: Scaffold(
            // body: ListView (
            body: SafeArea(
              child: SingleChildScrollView(
                child: SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 60),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 430,
                                child: Image.asset('images/KE_Nina_Cafe_logo.jpg'),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                                child: Text('Welcome to KE Nina Café !', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                              ),

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      const Padding (
                                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                                        child: Row(
                                          children: [
                                            Text('Email', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                            Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                          ]
                                        )
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                                        child:
                                        TextFormField(
                                          controller: emailController,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter your email';
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText: 'Please enter your email',
                                          ),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                                        child: Row(
                                          children: [
                                            Text('Password', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                            Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                          ]
                                        )
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                                          child:
                                          TextFormField(
                                            controller: passwordController,
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter your password';
                                              }
                                              return null;
                                            },
                                            obscureText: true,
                                            enableSuggestions: false,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: 'Please enter your password',
                                            ),
                                          )
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 32),
                                          child:
                                          FilledButton(
                                            onPressed: () async {
                                              if (_formKey.currentState!.validate()) {
                                                var (userFoundAsync, err_code) = await _submitLoginDetails(emailController, passwordController);
                                                setState(() {
                                                  userFound = userFoundAsync;
                                                  submittedOnce = true;
                                                  if (!userFound) {
                                                    passwordController.text = '';
                                                    if (err_code == ErrorCodes.LOGIN_FAIL_NO_USER) {
                                                      showDialog(context: context, builder: (
                                                        BuildContext context) =>
                                                        AlertDialog(
                                                          title: const Text('Details Mismatch'),
                                                          content: Text(
                                                              'Wrong combination of email and password. Please check your details.\n\nError Code: $err_code'),
                                                          actions: <Widget>[
                                                            TextButton(onPressed: () =>
                                                                Navigator.pop(context, 'Ok'),
                                                                child: const Text('Ok')),
                                                          ],
                                                        ),
                                                      );
                                                    } else {
                                                      showDialog(context: context, builder: (
                                                        BuildContext context) =>
                                                        AlertDialog(
                                                          title: const Text('Connection Error'),
                                                          content: Text(
                                                              'Unable to establish connection to our services. Please make sure you have an internet connection.\n\nError Code: $err_code'),
                                                          actions: <Widget>[
                                                            TextButton(onPressed: () =>
                                                                Navigator.pop(context, 'Ok'),
                                                                child: const Text('Ok')),
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                  } else {
                                                    // Navigator.push(
                                                    //   context,
                                                    //   MaterialPageRoute(
                                                    //     builder: (context) =>
                                                    //         const HomePage(),
                                                    //   ),
                                                    // );
                                                  }
                                                });
                                              }
                                            },
                                            child: const Text('Login', textAlign: TextAlign.center)
                                          ),
                                        ),
                                      ),
                                    ]
                                  ),
                                ),
                              ),
                              pleaseRegister()
                            ],
                          )
                        ),
                      ]
                  ),
                ) ,
              ),
            ),
        )
    );
  }

  // Returns true if match user and password, else returns false.
  Future<(bool, String)> _submitLoginDetails(TextEditingController emailController, TextEditingController passwordController) async {
    String email = emailController.text;
    String password = passwordController.text;
    if (kDebugMode) {
      print('Email: $email');
      print('Password: $password');
    }
    String enc_pw = Encryptor().encryptPassword(password);
    var (thisUser, err_code) = await createUser(email, enc_pw);
    if (thisUser.uid == -1) {
      if (kDebugMode) {
        print("Failed to retrieve User data.");
      }
      return (false, err_code);
    }
    return (true, err_code);
  }

  Future<(User, String)> createUser(String email, String enc_pw) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/users/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'enc_pw': enc_pw,
        }),
      );

      if (response.statusCode == 201) {
        var jsonResp = jsonDecode(response.body);
        var jwtToken = jsonResp['token'];
        return (User.fromJWT(jwtToken), (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print('No User found.');
        }
        return (User(uid: -1, name: '', email: '', gender: '', dob: DateTime.now()), (ErrorCodes.LOGIN_FAIL_NO_USER));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (User(uid: -1, name: '', email: '', gender: '', dob: DateTime.now()), (ErrorCodes.LOGIN_FAIL_API_CONNECTION));
    }
  }

  Widget pleaseRegister() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
      child: Align(
        alignment: Alignment.center,
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Don’t have an account? Please  ',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.transparent,
                    shadows: [Shadow(color: Colors.black, offset: Offset(0, -4))],
                )
              ),

              TextSpan(
                text: 'Register',
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
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
              ),

              const TextSpan(
                  text: '  or  ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.transparent,
                    shadows: [Shadow(color: Colors.black, offset: Offset(0, -4))],
                  )
              ),

              TextSpan(
                text: 'Continue as Guest',
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
    );
  }
}