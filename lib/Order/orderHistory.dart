import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keninacafecust_web/AppsBar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../Entity/Cart.dart';
import '../Entity/CartForOrderFoodItemMoreInfo.dart';
import '../Entity/FoodOrder.dart';
import '../Entity/MenuItem.dart';
import '../Entity/User.dart';
import 'editOrderDetails.dart';
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
      home: const OrderHistoryPage(user: null, cart: null, orderMode: null, orderHistory: null, tableNo: null, tabIndex: null, menuItemList: null, itemCategoryList: null),
    );
  }
}

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key, this.user, this.cart, this.orderMode, this.orderHistory, this.tableNo, this.tabIndex, this.menuItemList, this.itemCategoryList});

  final User? user;
  final Cart? cart;
  final String? orderMode;
  final List<int>? orderHistory;
  final int? tableNo;
  final int? tabIndex;
  final List<MenuItem>? menuItemList;
  final List<MenuItem>? itemCategoryList;

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  bool isMenuHomePage = false;

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

  int? getTableNo() {
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
    String? currentOrderMode = getOrderMode();
    List<MenuItem> menuItemList = currentCart!.getMenuItemList();
    List<int>? currentOrderHistory = getOrderHistory();
    int? currentTableNo = getTableNo();
    int? currentTabIndex = getTabIndex();
    List<MenuItem>? currentMenuItemList = getMenuItemStoredList();
    List<MenuItem>? currentItemCategoryList = getItemCategory();

    return Scaffold(
      appBar: AppsBarState().buildOrderHistoryAppBar(context, "ORDER HISTORY", currentUser!, currentCart),
      drawer: AppsBarState().buildDrawer(context, currentUser!, currentCart!, isMenuHomePage, currentOrderMode!, currentOrderHistory!, currentTableNo!, currentTabIndex!, currentMenuItemList!, currentItemCategoryList!),
      body: SafeArea(
        child: SingleChildScrollView (
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 20.0),
            child: currentUser.email != "guestkeninacafe@gmail.com" ? FutureBuilder<List<FoodOrder>>(
                future: getOrderHistoryList(currentUser),
                builder: (BuildContext context, AsyncSnapshot<List<FoodOrder>> snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: buildOrderHistoryList(snapshot.data, currentUser, currentCart, currentOrderMode, currentOrderHistory!, currentTableNo!, currentTabIndex!, currentMenuItemList!, currentItemCategoryList!),
                    );
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
            ) : FutureBuilder<List<FoodOrder>>(
                future: getOrderHistoryListByGuest(currentOrderHistory),
                builder: (BuildContext context, AsyncSnapshot<List<FoodOrder>> snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: buildOrderHistoryList(snapshot.data, currentUser, currentCart, currentOrderMode, currentOrderHistory!, currentTableNo!, currentTabIndex!, currentMenuItemList!, currentItemCategoryList!),
                    );
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
      ),
      backgroundColor: Colors.grey.shade200,
    );
  }

  List<Widget> buildOrderHistoryList(List<FoodOrder>? orderList, User? currentUser, Cart currentCart, String currentOrderMode, List<int> currentOrderHistory, int currentTableNo, int currentTabIndex, List<MenuItem> currentMenuItemList, List<MenuItem> currentItemCategoryList) {
    List<Widget> card = [];
    if (orderList!.isEmpty) {
      card.add(
        Column(
          mainAxisAlignment: MainAxisAlignment.center, // Vertically center the content
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 50, 0, 10),
              child: Image.asset(
                "images/emptyOrder.png",
                // fit: BoxFit.cover,
                // height: 500,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                child: Text(
                  "No Order is Placed",
                  style: TextStyle(
                    fontSize: 30.0,
                    color: Colors.grey.shade900,
                    fontFamily: "BreeSerif",
                  ),
                ),
              ),
            ),
            // Center(
            //   child: Padding(
            //     padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
            //     child: Text(
            //       "You haven't added anything to your cart",
            //       style: TextStyle(
            //         fontSize: 18.0,
            //         color: Colors.grey.shade600,
            //       ),
            //     ),
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 6),
            //   child: Container(
            //     padding: const EdgeInsets.only(top: 3,left: 3),
            //     child: MaterialButton(
            //       minWidth: double.infinity,
            //       height:50,
            //       onPressed: () {
            //         Navigator.push(context,
            //             MaterialPageRoute(builder: (context) => MenuHomePage(user: currentUser, cart: currentCart, orderMode: currentOrderMode, orderHistory: currentOrderHistory))
            //         );
            //         // Navigator.push(context,
            //         //     MaterialPageRoute(builder: (context) => MenuHomePage())
            //         // );
            //       },
            //       color: Colors.white,
            //       shape: const RoundedRectangleBorder(
            //         side: BorderSide(
            //           color: Colors.orangeAccent, // Border color
            //           width: 5.0, // Border width
            //         ),
            //       ),
            //       child: const Text(
            //         "Menu",
            //         style: TextStyle(
            //             fontWeight: FontWeight.bold,
            //             fontSize: 20,
            //             color: Colors.orangeAccent
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      );
    } else {
      for (int i = 0; i < orderList!.length; i++) {
        DateTime dateTime = orderList[i].dateTime;
        String formattedDate = DateFormat('yyyy-MM-dd  HH:mm:ss').format(dateTime);
        card.add(
          Card(
            color: Colors.white,
            elevation: 20.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0), // Adjust the radius as needed
              // side: BorderSide(color: Colors.deepOrangeAccent.shade200, width: 1.0), // Border color and width
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => OrderHistoryDetailsPage(user: currentUser, order: orderList[i], cart: currentCart, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: currentTabIndex, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList,))
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          // padding: const EdgeInsets.all(16.0),
                          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.asset(
                              "images/KE_Nina_Cafe_logo.jpg",
                              width: 80,
                              height: 80,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10.0),
                              Row(
                                  children: [
                                    Text(
                                      "Order ",
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.grey.shade900,
                                        fontFamily: "Itim",
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "#${orderList[i].id}  [${orderList[i].order_mode}]",
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.grey.shade900,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Itim"
                                      ),
                                    ),
                                    const Spacer(),
                                    if (orderList[i].order_status == "PL")
                                      Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.grey.shade300),
                                          onPressed: () async {
                                            CartForOrderFoodItemMoreInfo currentCartOrder = CartForOrderFoodItemMoreInfo(orderFoodItemMoreInfoList: [], order_grand_total: 0, order_grand_total_before_discount: 0, price_discount_voucher: 0, voucherAppliedIDBefore: 0, voucherAppliedID: 0, voucherApplied_type_name: "", voucherApplied_cost_off: 0, voucherApplied_free_menu_item_name: "", voucherApplied_applicable_menu_item_name: "", voucherApplied_min_spending: 0, isEditCartOrder: false);
                                            Navigator.push(context,
                                                MaterialPageRoute(builder: (context) => EditOrderDetailsPage(user: currentUser, order: orderList[i], cart: currentCart, cartOrder: currentCartOrder, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: currentTabIndex, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList,))
                                            );
                                          },
                                          child: Icon(Icons.edit, color: Colors.grey.shade800),
                                        ),
                                      ),
                                    const SizedBox(width: 15.0),
                                  ]
                              ),
                              const SizedBox(height: 10.0,),
                              if (orderList[i].order_status == "CP")
                                SizedBox(
                                  height: 30,
                                  width: 90,
                                  child: Material(
                                      elevation: 3.0,
                                      color: Colors.greenAccent.shade400,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(200),
                                      ),
                                      child: const Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Completed",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                  ),
                                ),
                              if (orderList[i].order_status == "RJ")
                                SizedBox(
                                  height: 30,
                                  width: 90,
                                  child: Material(
                                      elevation: 3.0,
                                      color: Colors.redAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(200),
                                      ),
                                      child: const Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Rejected",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                  ),
                                ),
                              if (orderList[i].order_status == "CF")
                                SizedBox(
                                  height: 30,
                                  width: 90,
                                  child: Material(
                                      elevation: 3.0,
                                      color: Color(0xFFFFD700),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(200),
                                      ),
                                      child: const Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Preparing",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                  ),
                                ),
                              if (orderList[i].order_status == "PL")
                                SizedBox(
                                  height: 30,
                                  width: 130,
                                  child: Material(
                                      elevation: 3.0,
                                      color: Colors.grey.shade500,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(200), // Apply border radius if needed
                                      ),
                                      child: const Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Pending Payment",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Order Time",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                                color: Colors.grey.shade600,
                                fontFamily: "Rajdhani",
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                                color: Colors.grey.shade800,
                                fontFamily: "Rajdhani",
                              ),
                            ),
                          ],
                        )
                    ),
                    const SizedBox(height: 6.0),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Table No.",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                                color: Colors.grey.shade600,
                                fontFamily: "Rajdhani",
                              ),
                            ),
                            Text(
                              "13",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                                color: Colors.grey.shade800,
                                fontFamily: "Rajdhani",
                              ),
                            ),
                          ],
                        )
                    ),
                    const SizedBox(height: 6.0),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Payment",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                                color: Colors.grey.shade600,
                                fontFamily: "Rajdhani",
                              ),
                            ),
                            if (orderList[i].order_status != "RJ")
                              Text(
                                "MYR ${orderList[i].grand_total.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17.0,
                                  color: Colors.grey.shade800,
                                  fontFamily: "Rajdhani",
                                ),
                              )
                            else
                              Text(
                                " - ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17.0,
                                  color: Colors.grey.shade800,
                                  fontFamily: "Rajdhani",
                                ),
                              ),
                          ],
                        )
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        card.add(const SizedBox(height: 20.0));
      }
    }
    return card;
  }

  Future<List<FoodOrder>> getOrderHistoryList(User currentUser) async {
    try {
      final response = await http.post(
        // Uri.parse('http://10.0.2.2:8000/order/request_order_list'),
        Uri.parse('http://localhost:8000/order/request_order_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'user_id': currentUser.uid,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return FoodOrder.getOrderList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the order history list of the current user.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }

  Future<List<FoodOrder>> getOrderHistoryListByGuest(List<int> orderHistoryIDList) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/order/request_order_list_by_guest'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'order_history_id_list': orderHistoryIDList,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return FoodOrder.getOrderList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the order history list of the guest.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }
}