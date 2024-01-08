import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:keninacafecust_web/Menu/menuHome.dart';
import '../Entity/Cart.dart';
import '../Entity/FoodOrder.dart';
import '../Entity/MenuItem.dart';
import '../Entity/User.dart';
import '../Utils/ip_address.dart';
import 'orderHistoryDetails.dart';

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
      home: const OrderPlacedPage(user: null, cart: null, orderID: null, orderMode: null, orderHistory: null, tableNo: null, tabIndex: null, menuItemList: null, itemCategoryList: null),
    );
  }
}

class OrderPlacedPage extends StatefulWidget {
  const OrderPlacedPage({super.key, this.user, this.cart, this.orderID, this.orderMode, this.orderHistory, this.tableNo, this.tabIndex, this.menuItemList, this.itemCategoryList});

  final User? user;
  final Cart? cart;
  final int? orderID;
  final String? orderMode;
  final List<int>? orderHistory;
  final String? tableNo;
  final int? tabIndex;
  final List<MenuItem>? menuItemList;
  final List<MenuItem>? itemCategoryList;

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

  int? getOrderID() {
    return widget.orderID;
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

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    Cart? currentCart = getCart();
    int? currentOrderID = getOrderID();
    String? currentOrderMode = getOrderMode();
    List<int>? currentOrderHistory = getOrderHistory();
    String? currentTableNo = getTableNo();
    int? currentTabIndex = getTabIndex();
    List<MenuItem>? currentMenuItemList = getMenuItemStoredList();
    List<MenuItem>? currentItemCategoryList = getItemCategory();

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView (
            child: FutureBuilder<List<FoodOrder>>(
                future: getFoodOrderDetails(currentOrderID!),
                builder: (BuildContext context, AsyncSnapshot<List<FoodOrder>> snapshot) {
                  if (snapshot.hasData) {
                    return buildOrderPlacedDetails(snapshot.data, currentCart!, currentUser!, currentOrderMode!, currentOrderHistory!, currentTableNo!, currentTabIndex!, currentMenuItemList!, currentItemCategoryList!);
                  } else {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      return Center(
                        child: LoadingAnimationWidget.threeRotatingDots(
                          color: Colors.black,
                          size: 50,
                        ),
                      );
                    }
                  }
                }
            ),
          ),
        ),
        backgroundColor: Colors.grey.shade100,
      ),
    );
  }

  Widget buildOrderPlacedDetails(List<FoodOrder>? currentOrder, Cart currentCart, User currentUser, String currentOrderMode, List<int> currentOrderHistory, String currentTableNo, int currentTabIndex, List<MenuItem> currentMenuItemList, List<MenuItem> currentItemCategoryList) {
    return Container(
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
                "# ${currentOrder?[0].id} [${currentOrderMode}]",
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
                          MaterialPageRoute(builder: (context) => OrderHistoryDetailsPage(user: currentUser, cart: currentCart, order: currentOrder?[0], orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: currentTabIndex, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList,))
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
              child: TextButton(
                onPressed: () {
                  setState(() {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MenuHomePage(user: currentUser, cart: currentCart, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: 0, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList,))
                    );
                  });
                },
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 15),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft),
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
    );
  }

  Future<List<FoodOrder>> getFoodOrderDetails(int currentOrderIDGet) async {
    try {
      final response = await http.get(
        // Uri.parse('http://10.0.2.2:8000/order/request_voucher_applied_details/$voucherAppliedID/'),
        Uri.parse('${IpAddress.ip_addr}/order/request_specific_order_details/$currentOrderIDGet/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return FoodOrder.getOrderList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the food order details made by the user.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }
}
