import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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
import '../Entity/FoodOrder.dart';
import '../Entity/MenuItem.dart';
import '../Entity/OrderFoodItemMoreInfo.dart';
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
      home: const OrderHistoryDetailsPage(user: null, order: null, cart: null,),
    );
  }
}

class OrderHistoryDetailsPage extends StatefulWidget {
  const OrderHistoryDetailsPage({super.key, this.user, this.order, this.cart});

  final User? user;
  final FoodOrder? order;
  final Cart? cart;

  @override
  State<OrderHistoryDetailsPage> createState() => _OrderHistoryDetailsPageState();
}

class _OrderHistoryDetailsPageState extends State<OrderHistoryDetailsPage> {

  User? getUser() {
    return widget.user;
  }

  FoodOrder? getOrder() {
    return widget.order;
  }

  Cart? getCart() {
    return widget.cart;
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    FoodOrder? currentOrder = getOrder();
    Cart? currentCart = getCart();

    return Scaffold(
      appBar: AppsBarState().buildOrderHistoryDetailsAppBar(context, "ORDER DETAILS", currentUser!, currentCart!),
      body: SafeArea(
        child: SingleChildScrollView (
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 30, 25, 0),
            child: FutureBuilder<List<OrderFoodItemMoreInfo>>(
                future: getOrderFoodItemDetails(currentOrder!, currentUser),
                builder: (BuildContext context, AsyncSnapshot<List<OrderFoodItemMoreInfo>> snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: buildOrderHistoryDetailsList(snapshot.data, currentOrder, currentUser),
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

  List<Widget> buildOrderHistoryDetailsList(List<OrderFoodItemMoreInfo>? orderFoodItemList, FoodOrder? currentOrder, User? currentUser) {
    print(orderFoodItemList?[0].menu_item_name);
    List<Widget> card = [];
    card.add(
      Card (
        color: Colors.white,
        shadowColor: Colors.black,
        // elevation: 15,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: const BorderSide(
            color: Colors.grey, // Color of the outline border
            width: 2.0, // Width of the outline border
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
              ),
              child: const ListTile(
                title: Text(
                  "Order Summary",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "Itim", overflow: TextOverflow.ellipsis,),
                ),
                // trailing: IconButton(
                //   icon: const Icon(Icons.edit),
                //   onPressed: () {
                //     // Handle the edit action here
                //   },
                // ),
              ),
            ),
            // SizedBox(
            //   child: Text(a.description, style: const TextStyle(fontSize: 15, overflow: TextOverflow.ellipsis,),),
            // ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.5, vertical: 8.0,),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0,),
                          child: Row(
                            children: [
                              Text(
                                '( * ) represents food with remarks',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.red,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Qty',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                              // fontWeight: FontWeight.bold,
                              fontFamily: 'BebasNeue',
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 14,
                          child: Text(
                            'Item',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                              // fontWeight: FontWeight.bold,
                              fontFamily: 'BebasNeue',
                            ),
                          ),
                        ),
                        Spacer(),
                        Expanded(
                          flex: 5,
                          child: Text(
                            'Price',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                              // fontWeight: FontWeight.bold,
                              fontFamily: 'BebasNeue',
                            ),
                          ),
                        ),
                      ]
                  ),
                  const SizedBox(height: 10.0,),
                  for (int i = 0; i < orderFoodItemList!.length; i++)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Column(
                        children: [
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0,),
                                  child: Text(
                                    orderFoodItemList[i].numOrder.toInt().toString(),
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.grey.shade700,
                                      fontFamily: 'BebasNeue',
                                      // fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              // const SizedBox(width: 5.0),
                              Expanded(
                                flex: 14,
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        orderFoodItemList[i].menu_item_name,
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.grey.shade700,
                                          fontFamily: 'BebasNeue',
                                          // fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                    if (orderFoodItemList[i].remarks != "")
                                      const Text(
                                        '*',
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.red,
                                          fontFamily: 'BebasNeue',
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Expanded(
                                flex: 5,
                                child: orderFoodItemList[i].size == "Standard" || orderFoodItemList[i].size == ""
                                    ? Text(
                                  "MYR ${(orderFoodItemList[i].numOrder*orderFoodItemList[i].menu_item_price_standard).toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.grey.shade700,
                                    fontFamily: 'BebasNeue',
                                    // fontWeight: FontWeight.bold,
                                  ),
                                ) : Text(
                                    "MYR ${(orderFoodItemList[i].numOrder*orderFoodItemList[i].menu_item_price_large).toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.grey.shade700,
                                      fontFamily: 'BebasNeue',
                                      // fontWeight: FontWeight.bold,
                                    ),
                                ),
                              ),
                            ]
                          ),
                          Row(
                            children: [
                              if (orderFoodItemList[i].size != "" || orderFoodItemList[i].variant != "")
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(40, 2, 0, 0),
                                  child: Row(
                                    children: [
                                      if (orderFoodItemList[i].variant != "")
                                        Text(
                                          orderFoodItemList[i].variant,
                                          style: const TextStyle(
                                            fontSize: 8.0,
                                            color: Colors.red,
                                            // fontFamily: 'YoungSerif',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      if (orderFoodItemList[i].size != "" && orderFoodItemList[i].variant != "")
                                        const Text(
                                          ", ",
                                          style: TextStyle(
                                            fontSize: 8.0,
                                            color: Colors.red,
                                            // fontFamily: 'YoungSerif',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      if (orderFoodItemList[i].size != "")
                                        Text(
                                          orderFoodItemList[i].size,
                                          style: const TextStyle(
                                            fontSize: 8.0,
                                            color: Colors.red,
                                            // fontFamily: 'YoungSerif',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                            ]
                          )
                        ],
                      ),
                    ),
                  Divider(color: Colors.grey.shade700,),
                  const SizedBox(height: 10.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Subtotal",
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey.shade700,
                          fontFamily: 'BebasNeue',
                        ),
                      ),
                      Text(
                        "MYR ${currentOrder?.gross_total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                          fontFamily: 'BebasNeue',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Voucher Discount",
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey.shade700,
                          fontFamily: 'BebasNeue',
                        ),
                      ),
                      Text(
                        "- MYR ${currentOrder?.grand_total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                          fontFamily: 'BebasNeue',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0,),
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total",
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey.shade700,
                          fontFamily: 'BebasNeue',
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "MYR ${currentOrder?.grand_total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.red,
                          fontFamily: 'BebasNeue',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    card.add(
      Center(
        child: Image.asset(
          "images/enjoyMeal.png",
          width: 220,
          height: 220,
        ),
      ),
    );
    return card;

  }

  Future<List<OrderFoodItemMoreInfo>> getOrderFoodItemDetails(FoodOrder currentOrder, User currentUser) async {
    try {
      final response = await http.get(
        // Uri.parse('http://10.0.2.2:8000/order/request_order_details/${currentOrder.id}/'),
        Uri.parse('http://localhost:8000/order/request_order_details/${currentOrder.id}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return OrderFoodItemMoreInfo.getOrderFoodItemDataList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the order details.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }
}
