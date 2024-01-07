import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:keninacafecust_web/Auth/enterEmailToRegister.dart';
import 'package:keninacafecust_web/Security/Encryptor.dart';
import 'package:keninacafecust_web/Utils/error_codes.dart';

import '../Entity/Cart.dart';
import '../Entity/User.dart';
import 'Auth/passwordResetScreen.dart';
import 'Menu/dineInOrTakeAway.dart';

void main() {
  runApp(const MyApp());
}

void enterFullScreen() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // primaryColor: Colors.black, // Set primary color to black
        // hintColor: Colors.white, // Set accent color to white
        // fontFamily: 'Poppins',
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // useMaterial3: true,
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

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin{
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  bool securePasswordText = true;
  bool userFound = false;
  String? tableParam;

  // int? getTableNo() {
  //   return widget.tableNo;
  // }

  @override
  void initState() {
    // super.initState();
    _animationController = AnimationController(
      vsync: this, // Provide the vsync here
      duration: Duration(seconds: 1),
    );
    _animationController.forward();
    Uri uri = Uri.base;
    tableParam = uri.queryParameters['table'];
    if (tableParam != null) {
      int tableNo = int.tryParse(tableParam!) ?? 0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    // super.dispose();
  }

  void _togglePasswordView() {
    setState(() {
      securePasswordText = !securePasswordText;
    });
  }

  User guestUser = User(uid: 18, name: "Guest", is_active: true, email: 'guestkeninacafe@gmail.com', gender: '', dob: DateTime.now(), points: 0);
  Cart currentCart = Cart(id: 0, menuItem: [], numMenuItemOrder: 0, grandTotalBeforeDiscount: 0, grandTotalAfterDiscount: 0, price_discount: 0, voucherAppliedID: 0, voucherApplied_type_name: "", voucherApplied_cost_off: 0, voucherApplied_free_menu_item_name: "", voucherApplied_applicable_menu_item_name: "", voucherApplied_min_spending: 0);

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    // int? currentTableNo = getTableNo();
    String? currentTableNo = tableParam;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            // height: MediaQuery.of(context).size.height,
            constraints: const BoxConstraints(
              maxHeight: double.infinity,
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/login_background.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 30,),
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.fastOutSlowIn,
                  width: 250,
                  height: 250,
                  child: ScaleTransition(
                      scale: Tween<double>(begin: 0, end: 1).animate(
                        CurvedAnimation(
                          parent: _animationController, // Use the provided AnimationController
                          curve: Curves.fastOutSlowIn,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.white70,
                        radius: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(15), // Border radius
                          child: ClipOval(child: Image.asset('images/KE_Nina_Cafe_logo.jpg')),
                        ),
                      )
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Welcome to KE Nina Café !',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Set text color to white
                  ),
                ),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: const TextStyle(color: Colors.black), // Set label color to white
                            prefixIcon: const Icon(Icons.email, color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black, width: 4.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black, width: 4.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            errorBorder: OutlineInputBorder( // Border style for error state
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Colors.red, width: 4.0,),
                            ),
                            // hintText: 'Please enter your email',
                            // hintStyle: TextStyle(color: Colors.white),
                            contentPadding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25.0),
                          ),
                          style: const TextStyle(color: Colors.black),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextFormField(
                          obscureText: securePasswordText,
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: Colors.black),
                            prefixIcon: const Icon(Icons.lock, color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black, width: 4.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black, width: 4.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            errorBorder: OutlineInputBorder( // Border style for error state
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Colors.red, width: 4.0,),
                            ),
                            suffix: InkWell(
                              onTap: _togglePasswordView,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                child: Icon(securePasswordText ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            // hintText: 'Please enter your password',
                            // hintStyle: const TextStyle(color: Colors.white),
                            contentPadding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25.0),
                          ),
                          style: const TextStyle(color: Colors.black),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(25.0, 5.0, 0, 0),
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PasswordResetScreenPage(tableNo: currentTableNo),
                                ),
                              );
                            },

                            child: Text(
                              'Forgot Password ?',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.transparent,
                                fontWeight: FontWeight.bold,
                                shadows: [Shadow(color: Colors.blue.shade900, offset: Offset(0, -4))],
                                decorationThickness: 2,
                                decorationColor: Colors.blue.shade900,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0,),
                      AnimatedOpacity(
                        duration: const Duration(seconds: 1),
                        opacity: 1.0,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              var (userFoundAsync, currentUser, err_code) = await _submitLoginDetails(emailController, passwordController);
                              setState(() {
                                userFound = userFoundAsync;
                                if (!userFound) {
                                  passwordController.text = '';
                                  if (err_code == ErrorCodes.LOGIN_FAIL_NO_USER) {
                                    showDialog(context: context, builder: (
                                        BuildContext context) =>
                                        AlertDialog(
                                          title: const Text('User Not Found', style: TextStyle(fontWeight: FontWeight.bold,)),
                                          content: Text(
                                              'Please sign up first before login.\n\nError Code: $err_code'),
                                          actions: <Widget>[
                                            TextButton(onPressed: () =>
                                                Navigator.pop(context, 'Ok'),
                                                child: const Text('Ok')),
                                          ],
                                        ),
                                    );
                                  } else if (err_code == ErrorCodes.LOGIN_FAIL_PASSWORD_INCORRECT) {
                                    showDialog(context: context, builder: (
                                        BuildContext context) =>
                                        AlertDialog(
                                          title: const Text('Details Mismatch', style: TextStyle(fontWeight: FontWeight.bold,)),
                                          content: Text(
                                              'Wrong combination of email and password. Please check your details.\n\nError Code: $err_code'),
                                          actions: <Widget>[
                                            TextButton(onPressed: () =>
                                                Navigator.pop(context, 'Ok'),
                                                child: const Text('Ok')),
                                          ],
                                        ),
                                    );
                                  } else if (err_code == ErrorCodes.LOGIN_FAIL_USER_DEACTIVATED_DELETED ){
                                    showDialog(context: context, builder: (
                                        BuildContext context) =>
                                        AlertDialog(
                                          title: const Text('User Deactivated or Deleted', style: TextStyle(fontWeight: FontWeight.bold,)),
                                          content: Text(
                                              'User have been deactivated or deleted.\n\nError Code: $err_code'),
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
                                          title: const Text('Connection Error', style: TextStyle(fontWeight: FontWeight.bold,)),
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
                                  showDialog(context: context, builder: (
                                      BuildContext context) =>
                                      AlertDialog(
                                        title: const Text('Login Successful', style: TextStyle(fontWeight: FontWeight.bold,)),
                                        content: Text(
                                            'Welcome back, ${currentUser.name}!'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => DineInOrTakeAwayPage(user: currentUser, cart: currentCart, orderHistory: const [], tableNo: currentTableNo)));
                                            },
                                            child: const Text('Ok'),
                                          ),
                                        ],
                                      ),
                                  );
                                }
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            minimumSize: const Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0), // Adjust the value as needed
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Don\'t have an account?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.transparent,
                                  shadows: [Shadow(color: Colors.black, offset: Offset(0, -2))],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EnterEmailToRegisterPage(tableNo: currentTableNo,),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.transparent,
                                    shadows: [Shadow(color: Colors.deepOrange.shade600, offset: Offset(0, -4))],
                                    decorationThickness: 2,
                                    decorationColor: Colors.deepOrange.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5.0,),
                      Padding(
                        padding: const EdgeInsets.symmetric(),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DineInOrTakeAwayPage(user: guestUser, cart: currentCart, orderHistory: const [], tableNo: currentTableNo),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Continue As Guest',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.transparent,
                                    shadows: [Shadow(color: Colors.blue.shade900, offset: const Offset(0, -4))],
                                    decorationThickness: 2,
                                    decorationColor: Colors.blue.shade900,
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
                const SizedBox(height: 70.0,),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<(bool, User, String)> _submitLoginDetails(TextEditingController emailController, TextEditingController passwordController) async {
    String email = emailController.text;
    String password = passwordController.text;
    if (kDebugMode) {
      print('Email: $email');
      print('Password: $password');
    }
    String enc_pw = Encryptor().encryptPassword(password);
    if (kDebugMode) {
      print(enc_pw);
    }
    var (thisUser, err_code) = await createUser(email, enc_pw);
    if (thisUser.uid == -1) {
      if (kDebugMode) {
        print("Failed to retrieve User data.");
      }
      return (false, thisUser, err_code);
    }
    return (true, thisUser, err_code);
  }

  Future<(User, String)> createUser(String email, String enc_pw) async {
    try {
      final response = await http.post(
        // Uri.parse('http://10.0.2.2:8000/users/login'),  // For phone
        Uri.parse('http://localhost:8000/users/customer_login'), // For website
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': enc_pw,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        var jsonResp = jsonDecode(response.body);
        var jwtToken = jsonResp['token'];
        if (kDebugMode) {
          print('User found.');
          print('JWT Token: $jwtToken');
        }
        return (User.fromJWT(jwtToken), (ErrorCodes.OPERATION_OK));
      } else {
        var jsonResp = jsonDecode(response.body);
        var error = jsonResp['detail'];
        if (error == "User not found!") {
          print(error);
          return (User(uid: -1, name: '', is_active: false, email: '', gender: '', dob: DateTime.now(), points: 0), (ErrorCodes.LOGIN_FAIL_NO_USER));
        }
        else if (error == "Incorrect password!") {
          print(error);
          return (User(uid: -1, name: '', is_active: false, email: '', gender: '', dob: DateTime.now(), points: 0), (ErrorCodes.LOGIN_FAIL_PASSWORD_INCORRECT));
        }
        else if (error == "User deactivated or deleted!") {
          print(error);
          return (User(uid: -1, name: '', is_active: false, email: '', gender: '', dob: DateTime.now(), points: 0), (ErrorCodes.LOGIN_FAIL_USER_DEACTIVATED_DELETED));
        }
        if (kDebugMode) {
          print('No User found.');
        }
        return (User(uid: -1, name: '', is_active: false, email: '', gender: '', dob: DateTime.now(), points: 0), (ErrorCodes.LOGIN_FAIL_NO_USER));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (User(uid: -1, name: '', is_active: false, email: '', gender: '', dob: DateTime.now(), points: 0), (ErrorCodes.LOGIN_FAIL_API_CONNECTION));
    }
  }

  Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('https://your-django-backend.com/api/password-reset/'),
      body: {'email': email},
    );

    if (response.statusCode == 200) {
      // Password reset email sent successfully
      print('Password reset email sent!');
    } else {
      // Handle error
      print('Error: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }
}