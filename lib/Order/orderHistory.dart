import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keninacafecust_web/AppsBar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
      home: const OrderHistoryPage(user: null, cart: null,),
    );
  }
}

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key, this.user, this.cart});

  final User? user;
  final Cart? cart;

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

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    Cart? currentCart = getCart();
    List<MenuItem> menuItemList = currentCart!.getMenuItemList();

    return Scaffold(
      appBar: AppsBarState().buildOrderHistoryAppBar(context, "ORDER HISTORY", currentUser!, currentCart),
      drawer: AppsBarState().buildDrawer(context, currentUser!, currentCart!, isMenuHomePage),
      body: SafeArea(
        child: SingleChildScrollView (
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 20.0),
            child: FutureBuilder<List<FoodOrder>>(
                future: getOrderHistoryList(currentUser),
                builder: (BuildContext context, AsyncSnapshot<List<FoodOrder>> snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: buildOrderHistoryList(snapshot.data, currentUser, currentCart),
                    );
                  } else {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      return const Center(child: Text('Loading....'));
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

  List<Widget> buildOrderHistoryList(List<FoodOrder>? orderList, User? currentUser, Cart currentCart) {
    List<Widget> card = [];
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
                  MaterialPageRoute(builder: (context) => OrderHistoryDetailsPage(user: currentUser, order: orderList[i], cart: currentCart))
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
                                    "#${orderList[i].id}",
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.grey.shade900,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Itim"
                                    ),
                                  ),
                                  const Spacer(),
                                  if (orderList[i].order_status == "PL")
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                                      child: GestureDetector(
                                        onTap: () {
                                          CartForOrderFoodItemMoreInfo currentCartOrder = CartForOrderFoodItemMoreInfo(orderFoodItemMoreInfoList: [], order_grand_total: 0);
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (context) => EditOrderDetailsPage(user: currentUser, order: orderList[i], cart: currentCart, cartOrder: currentCartOrder,))
                                          );
                                        },
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            color: Colors.grey.shade300,
                                            borderRadius: BorderRadius.circular(5.0),
                                          ),
                                          // padding: const EdgeInsets.all(1),
                                          child: Icon(
                                            Icons.edit,
                                            size: 22.0,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                    ),
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
                            "Table",
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
                            "Total",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0,
                              color: Colors.grey.shade600,
                              fontFamily: "Rajdhani",
                            ),
                          ),
                          Text(
                            "MYR ${orderList[i].grand_total.toStringAsFixed(2)}",
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

}