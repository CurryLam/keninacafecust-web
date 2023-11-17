import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:keninacafecust_web/AppsBar.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafecust_web/Menu/menuHome.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:badges/badges.dart' as badges;


import '../Entity/Cart.dart';
import '../Entity/MenuItem.dart';
import '../Entity/User.dart';
import '../Menu/viewCart.dart';
import '../Utils/error_codes.dart';
import '../Widget/DottedLine.dart';


import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:keninacafecust_web/AppsBar.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafecust_web/Menu/menuHome.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:badges/badges.dart' as badges;
import 'package:keninacafecust_web/Order/orderPlaced.dart';


import '../Entity/Cart.dart';
import '../Entity/MenuItem.dart';
import '../Entity/User.dart';
import '../Menu/viewCart.dart';
import '../Utils/error_codes.dart';
import '../Widget/DottedLine.dart';

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
      home: const OrderPlacedPage(user: null, cart: null,),
    );
  }
}

class OrderPlacedPage extends StatefulWidget {
  const OrderPlacedPage({super.key, this.user, this.cart});

  final User? user;
  final Cart? cart;

  @override
  State<OrderPlacedPage> createState() => _OrderPlacedPageState();
}

class _OrderPlacedPageState extends State<OrderPlacedPage> {

  User? getUser() {
    return widget.user;
  }

  Cart? getCart() {
    return widget.cart;
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    Cart? currentCart = getCart();
    List<MenuItem> menuItemList = currentCart!.getMenuItemList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView (
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                    child: Image.asset(
                      "images/orderConfirmation.png",
                      width: 300,
                      height: 300,
                      // fit: BoxFit.cover,
                      // height: 500,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    "Order Successfully",
                    style: TextStyle(
                      fontSize: 27.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Center(
                    child: Text(
                      "#645072896",
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                Divider(height: 40.0, color: Colors.grey.shade400,),
                const SizedBox(height: 10.0),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(
                    child: Text(
                      "- Please Make Payment First -",
                      style: TextStyle(
                        fontSize: 21.0,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(
                    child: Text(
                      "Food will only be prepared after payment.",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Center(
                    child: Text(
                      "Kindly show this page to the cashier !",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 300.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.greenAccent.shade400,
                          // border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(50.0), // Adjust the radius as needed
                        ),
                        child: MaterialButton(
                          // minWidth: double.infinity,
                          height:40,
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => MenuHomePage(user: currentUser, cart: currentCart))
                            );
                          },
                          // color: Colors.red,
                          child: const Text(
                            "View Receipt Details",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => MenuHomePage(user: currentUser, cart: currentCart))
                        );
                      },
                      child: const Text(
                        "Menu",
                        style: TextStyle(
                          fontSize: 18.0,
                          // color: Colors.blueAccent,
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                          color: Colors.transparent,
                          shadows: [Shadow(color: Colors.blueAccent, offset: Offset(0, -4))],
                          decorationThickness: 3,
                          decorationColor: Colors.blueAccent,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey.shade100,
    );
  }
}
