import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../AppsBar.dart';
import '../Entity/Cart.dart';
import '../Entity/MenuItem.dart';
import '../Entity/User.dart';
import '../Security/Encryptor.dart';
import '../Utils/error_codes.dart';
import '../Utils/ip_address.dart';

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
      home: const ChangePasswordPage(user: null, cart: null, orderMode: null, orderHistory: null, tableNo: null, tabIndex: null, menuItemList: null, itemCategoryList: null),
      // home: const ChangePasswordPage(),
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key, this.user, this.cart, this.orderMode, this.orderHistory, this.tableNo, this.tabIndex, this.menuItemList, this.itemCategoryList});

  final User? user;
  final Cart? cart;
  final String? orderMode;
  final List<int>? orderHistory;
  final String? tableNo;
  final int? tabIndex;
  final List<MenuItem>? menuItemList;
  final List<MenuItem>? itemCategoryList;

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool profileUpdated = false;
  bool secureOldPasswordText = true;
  bool secureNewPasswordText = true;
  bool secureConfirmPasswordText = true;
  bool isHomePage = false;

  User? getUser() {
    return widget.user;
  }

  Cart? getCart() {
    return widget.cart;
  }

  String? getOrderMode() {
    return widget.orderMode;
  }

  List<int>? getOrderHistory() {
    return widget.orderHistory;
  }

  String? getTableNo() {
    return widget.tableNo;
  }

  int? getTabIndex() {
    return widget.tabIndex;
  }

  List<MenuItem>? getMenuItemStoredList() {
    return widget.menuItemList;
  }

  List<MenuItem>? getItemCategory() {
    return widget.itemCategoryList;
  }

  void _toggleOldPasswordView() {
    setState(() {
      secureOldPasswordText = !secureOldPasswordText;
    });
  }

  void _toggleNewPasswordView() {
    setState(() {
      secureNewPasswordText = !secureNewPasswordText;
    });
  }

  void _toggleConfirmPasswordView() {
    setState(() {
      secureConfirmPasswordText = !secureConfirmPasswordText;
    });
  }

  void showConfirmationDialog(TextEditingController oldPasswordController, TextEditingController newPasswordController, User currentUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: const Text('Are you sure you want to update the password?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  var (err_code, currentUserUpdated) = await _submitUpdatePasswordDetails(oldPasswordController, newPasswordController, currentUser);
                  setState(() {
                    Navigator.of(context).pop();
                    if (err_code == ErrorCodes.CHANGE_PASSWORD_FAIL_BACKEND) {
                      showDialog(
                        context: context, builder: (BuildContext context) =>
                          AlertDialog(
                            title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold,)),
                            content: Text(
                                'An Error occurred while trying to update the password.\n\nError Code: $err_code'),
                            actions: <Widget>[
                              TextButton(onPressed: () =>
                                  Navigator.pop(context, 'Ok'),
                                  child: const Text('Ok')),
                            ],
                          ),
                      );
                    } else if (err_code ==
                        ErrorCodes.CHANGE_PASSWORD_FAIL_API_CONNECTION) {
                      showDialog(
                        context: context, builder: (BuildContext context) =>
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
                    } else if (err_code == ErrorCodes.OLD_PASSWORD_DOES_NOT_MATCH_DIALOG) {
                      showDialog(
                        context: context, builder: (BuildContext context) =>
                          AlertDialog(
                            title: const Text('Old Password Incorrect.', style: TextStyle(fontWeight: FontWeight.bold,)),
                            content: Text(
                                'The old password entered is not matched.\n\nError Code: $err_code'),
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
                            title: const Text('Update Password Successful'),
                            content: const Text('You can try to login using the new password.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Ok'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                      );
                      _formKey.currentState?.reset();
                      setState(() {
                      });
                    }
                  });
                }
                // saveAnnouncement(title, text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Yes',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),

            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'No',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    Cart? currentCart = getCart();
    String? currentOrderMode = getOrderMode();
    List<int>? currentOrderHistory = getOrderHistory();
    String? currentTableNo = getTableNo();
    int? currentTabIndex = getTabIndex();
    List<MenuItem>? currentMenuItemList = getMenuItemStoredList();
    List<MenuItem>? currentItemCategoryList = getItemCategory();
    // User? currentUser = User(uid: 1, name: "Goh Chee Lam", is_active: true, email: "clgoh0726@gmail.com", phone: "0165507208", gender: "Male", dob: DateTime.parse("2001-07-26 00:00:00.000000"), points: 1000);
    // Cart? currentCart = Cart(id: 0, menuItem: [], numMenuItemOrder: 0, grandTotalBeforeDiscount: 0, grandTotalAfterDiscount: 0, price_discount: 0, voucherAppliedID: 0, voucherApplied_type_name: "", voucherApplied_cost_off: 0, voucherApplied_free_menu_item_name: "", voucherApplied_applicable_menu_item_name: "", voucherApplied_min_spending: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppsBarState().buildDrawer(context, currentUser!, currentCart!, isHomePage, currentOrderMode!, currentOrderHistory!, currentTableNo!, currentTabIndex!, currentMenuItemList!, currentItemCategoryList!),
      appBar: AppsBarState().buildChangePasswordAppBar(context, 'Change Password', currentUser!),
      body: SafeArea(
          child: SingleChildScrollView(
              child: SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Center(
                      child: Form(
                        key: _formKey,
                        child: Column(
                            children: [
                              const SizedBox(height: 13,),
                              const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                                  child: Row(
                                      children: [
                                        Text('Old Password', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                                        // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                      ]
                                  )
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                child:
                                TextFormField(
                                  obscureText: secureOldPasswordText,
                                  controller: oldPasswordController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your old password';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    suffix: InkWell(
                                      onTap: _toggleOldPasswordView,
                                      child: Icon(
                                        secureOldPasswordText ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.black,
                                      ),
                                    ),
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
                              const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                                  child: Row(
                                      children: [
                                        Text('New Password', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                                        // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                      ]
                                  )
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                child:
                                TextFormField(
                                  obscureText: secureNewPasswordText,
                                  controller: newPasswordController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    final passwordRegex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#&*~]).{8,}$');
                                    if (!passwordRegex.hasMatch(value)) {
                                      return 'Please enter a valid password with at least:\nOne capital letter\nOne small letter\nOne number\nOne symbol from !, @, #, &, * or ~';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    suffix: InkWell(
                                      onTap: _toggleNewPasswordView,
                                      child: Icon(
                                        secureNewPasswordText ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.black,
                                      ),
                                    ),
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
                              const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                                  child: Row(
                                      children: [
                                        Text('Confirm Password', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                                        // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                      ]
                                  )
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                child: TextFormField(
                                  obscureText: secureConfirmPasswordText,
                                  controller: confirmNewPasswordController,
                                  validator: (value) {
                                    if (value != newPasswordController.text) {
                                      return 'Passwords do not match with new passwords!';
                                    } else if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    return null;
                                  },
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Gabarito",
                                  ),
                                  decoration: InputDecoration(
                                    suffix: InkWell(
                                      onTap: _toggleConfirmPasswordView,
                                      child: Icon(
                                        secureConfirmPasswordText ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.black,
                                      ),
                                    ),
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
                                    // hintText: 'Please enter the password again',
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
                                        showConfirmationDialog(oldPasswordController, newPasswordController, currentUser);
                                      }
                                    },
                                    color: Colors.lightBlueAccent.shade400,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(40)
                                    ),
                                    child: const Text("Update",style:
                                    TextStyle(
                                      fontWeight: FontWeight.bold,fontSize: 16, color: Colors.white,
                                    ),
                                    ),
                                  ),
                                ),
                              ),
                            ]
                        ),
                      ),
                    ),
                  )
              )
          )
      ),
    );
  }

  Future<(String, User)> _submitUpdatePasswordDetails(TextEditingController oldPasswordController, TextEditingController newPasswordController, User currentUser) async {
    String oldPassword = oldPasswordController.text;
    String newPassword = newPasswordController.text;
    if (kDebugMode) {
      print('Email: $oldPassword');
      print('Password: $newPassword');
    }
    String encOpw = Encryptor().encryptPassword(oldPassword);
    String encNpw = Encryptor().encryptPassword(newPassword);
    var (thisUser, err_code) = await updateProfilePassword(encOpw, encNpw, currentUser);
    if (thisUser.uid == -1) {
      if (kDebugMode) {
        print("Failed to update password.");
      }
      return (err_code, currentUser);
    }
    currentUser = thisUser;
    return (err_code, currentUser);
  }

  Future<(User, String)> updateProfilePassword(String encOpw, String encNpw, User currentUser) async {
    try {
      final response = await http.put(
        // Uri.parse('http://10.0.2.2:8000/editProfile/update_user_password/${currentUser.uid}/'),
        Uri.parse('${IpAddress.ip_addr}/editProfile/update_user_password/${currentUser.uid}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'encOpw': encOpw,
          'encNpw': encNpw,
        }),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        var jsonResp = jsonDecode(response.body);
        var jwtToken = jsonResp['token'];
        return (User.fromJWT(jwtToken), (ErrorCodes.OPERATION_OK));
      } else {
        var jsonResp = jsonDecode(response.body);
        var error = jsonResp['error'];
        if (error == "Old Password do not match") {
          if (kDebugMode) {
            print(error);
          }
          return (User(uid: -1,
              name: '',
              is_active: false,
              email: '',
              gender: '',
              dob: DateTime.now(),
              // phone: '',
              points: 0), (ErrorCodes.OLD_PASSWORD_DOES_NOT_MATCH_DIALOG));
        } else {
          if (kDebugMode) {
            print(error);
          }
          return (User(uid: -1,
              name: '',
              is_active: false,
              email: '',
              gender: '',
              dob: DateTime.now(),
              // phone: '',
              points: 0), (ErrorCodes.CHANGE_PASSWORD_FAIL_BACKEND));
        }
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (User(uid: -1, name: '', email: '', gender: '', dob: DateTime.now(), is_active: false, points: 0, ), (ErrorCodes.CHANGE_PASSWORD_FAIL_API_CONNECTION));
    }
  }
}