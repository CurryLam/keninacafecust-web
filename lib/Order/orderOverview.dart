import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:keninacafecust_web/Order/orderPlaced.dart';
import '../Entity/Cart.dart';
import '../Entity/FoodOrder.dart';
import '../Entity/MenuItem.dart';
import '../Entity/User.dart';
import '../Entity/Voucher.dart';
import '../Menu/viewCart.dart';
import '../Utils/error_codes.dart';
import '../Voucher/applyVoucher.dart';

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
      home: const OrderOverviewPage(user: null, cart: null, orderMode: null, orderHistory: null, tableNo: null, tabIndex: null, menuItemList: null, itemCategoryList: null),
    );
  }
}

class OrderOverviewPage extends StatefulWidget {
  const OrderOverviewPage({super.key, this.user, this.cart, this.orderMode, this.orderHistory, this.tableNo, this.tabIndex, this.menuItemList, this.itemCategoryList});

  final User? user;
  final Cart? cart;
  final String? orderMode;
  final List<int>? orderHistory;
  final int? tableNo;
  final int? tabIndex;
  final List<MenuItem>? menuItemList;
  final List<MenuItem>? itemCategoryList;

  @override
  State<OrderOverviewPage> createState() => _OrderOverviewPageState();
}

class _OrderOverviewPageState extends State<OrderOverviewPage> {
  int currentOrderIDGet = 0;

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

  onGoBack(dynamic value) {
    setState(() {});
  }

  void navigateApplyVoucherPage(Cart currentCart, User currentUser, String currentOrderMode, List<int> currentOrderHistory, int currentTableNo, int currentTabIndex, List<MenuItem> currentMenuItemList, List<MenuItem> currentItemCategoryList) {
    Route route = MaterialPageRoute(builder: (context) => ApplyVoucherPage(cart: currentCart, user: currentUser, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: currentTabIndex, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList,));
    Navigator.push(context, route).then(onGoBack);
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    Cart? currentCart = getCart();
    String? currentOrderMode = getOrderMode();
    int? currentTableNo = getTableNo();
    List<MenuItem> menuItemList = currentCart!.getMenuItemList();
    List<int>? currentOrderHistory = getOrderHistory() ?? [];
    int? currentTabIndex = getTabIndex();
    int voucherAppliedID = currentCart!.getVoucherAppliedID();
    List<MenuItem>? currentMenuItemList = getMenuItemStoredList();
    List<MenuItem>? currentItemCategoryList = getItemCategory();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView (
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Image.asset(
                          "images/orderSummary.png",
                          width: 200,
                          height: 200,
                          // fit: BoxFit.cover,
                          // height: 500,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.grey.shade300),
                          onPressed: () async {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 32,
                          ),
                        ),
                      ),
                      // child: GestureDetector(
                      //   onTap: () {
                      //     Navigator.pop(context);
                      //   },
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       shape: BoxShape.circle,
                      //       color: Colors.grey.withOpacity(0.4),
                      //     ),
                      //     padding: const EdgeInsets.all(2),
                      //     child: const Icon(
                      //       Icons.arrow_back,
                      //       color: Colors.black,
                      //       size: 32,
                      //     ),
                      //   ),
                      // ),
                    ),
                  ],
                ),
                // Center(
                //   child: Padding(
                //     padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                //     child: Image.asset(
                //       "images/orderSummary.png",
                //       width: 200,
                //       height: 200,
                //       // fit: BoxFit.cover,
                //       // height: 500,
                //     ),
                //   ),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Ordering for ",
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.grey.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (currentUser?.email != "guestkeninacafe@gmail.com")
                      Text(
                        currentUser!.email,
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.red,
                        ),
                      )
                    else if (currentUser?.email == "guestkeninacafe@gmail.com")
                      const Text(
                        "Guest",
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.red,
                        ),
                      )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Center(
                    child: Text(
                      "#Table 10",
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                Divider(height: 20.0, color: Colors.grey.shade400,),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                  elevation: 20.0,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.white,
                      // border: Border.all(color: Colors.grey),
                      // borderRadius: BorderRadius.circular(120.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.5, vertical: 15.0,),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.receipt_outlined,
                                      color: Colors.redAccent,
                                      size: 30.0,
                                    ),
                                    SizedBox(width: 8.0,),
                                    Text(
                                      "Order Summary",
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.black,
                                        fontFamily: 'YoungSerif',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 35.0,),
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
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 15,
                                child: Text(
                                  'Item',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Spacer(),
                              Expanded(
                                flex: 0,
                                child: Text(
                                  'Price',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ]
                          ),
                          const SizedBox(height: 10.0,),
                          for (int i = 0; i < currentCart!.getMenuItemList().length; i++)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 5.0,),
                                          child: Text(
                                            menuItemList[i].numOrder.toString(),
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.grey.shade700,
                                              fontFamily: 'BebasNeue',
                                              // fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // const SizedBox(width: 5.0),
                                      Expanded(
                                        flex: 15,
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                menuItemList[i].name,
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.grey.shade700,
                                                  fontFamily: 'BebasNeue',
                                                  // fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.clip,
                                              ),
                                            ),
                                            if (menuItemList[i].remarks != "")
                                              const Text(
                                                ' *',
                                                style: TextStyle(
                                                  fontSize: 16.0,
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
                                        flex: 0,
                                        child: menuItemList[i].sizeChosen == "Standard" || menuItemList[i].sizeChosen == "" ?
                                        Text(
                                          "MYR ${(menuItemList[i].price_standard*menuItemList[i].numOrder).toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.grey.shade700,
                                            fontFamily: 'BebasNeue',
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ) : Text(
                                          "MYR ${(menuItemList[i].price_large*menuItemList[i].numOrder).toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontSize: 16.0,
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
                                      const Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 5.0,),
                                          child: Text(
                                            "",
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 15,
                                        child: Row(
                                          children: [
                                            if (menuItemList[i].sizeChosen != "" || menuItemList[i].variantChosen != "")
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                                                child: Row(
                                                  children: [
                                                    if (menuItemList[i].variantChosen != "")
                                                      Text(
                                                        menuItemList[i].variantChosen,
                                                        style: const TextStyle(
                                                          fontSize: 10.0,
                                                          color: Colors.red,
                                                          // fontFamily: 'YoungSerif',
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    if (menuItemList[i].sizeChosen != "" && menuItemList[i].variantChosen != "")
                                                      const Text(
                                                        ", ",
                                                        style: TextStyle(
                                                          fontSize: 10.0,
                                                          color: Colors.red,
                                                          // fontFamily: 'YoungSerif',
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    if (menuItemList[i].sizeChosen != "")
                                                      Text(
                                                        menuItemList[i].sizeChosen,
                                                        style: const TextStyle(
                                                          fontSize: 10.0,
                                                          color: Colors.red,
                                                          // fontFamily: 'YoungSerif',
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      const Expanded(
                                        flex: 0,
                                        child: Text(
                                          "",
                                        ),
                                      ),
                                    ]
                                  )
                                ],
                              ),
                            ),
                          Divider(color: Colors.grey.shade400,),
                          const SizedBox(height: 10.0,),
                          if (currentUser?.email != "guestkeninacafe@gmail.com")
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Subtotal",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.black,
                                    fontFamily: 'Itim',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "MYR ${currentCart.getGrandTotalBeforeDiscount().toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.black,
                                    fontFamily: 'Itim',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          if (voucherAppliedID == 0 && currentUser?.email != "guestkeninacafe@gmail.com")
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () {
                                    navigateApplyVoucherPage(currentCart, currentUser!, currentOrderMode!, currentOrderHistory!, currentTableNo!, currentTabIndex!, currentMenuItemList!, currentItemCategoryList!);
                                  },
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(50, 15),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      alignment: Alignment.centerLeft),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.local_activity_outlined,
                                        color: Colors.redAccent.shade200,
                                        size: 25.0,
                                      ),
                                      const SizedBox(width: 8.0), // Add spacing between icon and text
                                      Text(
                                        "Apply a voucher",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          color: Colors.redAccent.shade200,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // child: GestureDetector(
                                //   onTap: () {
                                //     navigateApplyVoucherPage(currentCart, currentUser);
                                //   },
                                //   child: Container(
                                //     width: double.infinity,
                                //     decoration: const BoxDecoration(
                                //       shape: BoxShape.rectangle,
                                //       color: Colors.transparent,
                                //       // borderRadius: BorderRadius.circular(15.0),
                                //     ),
                                //     child: Row(
                                //       mainAxisAlignment: MainAxisAlignment.start,
                                //       children: [
                                //         Icon(
                                //           Icons.local_activity_outlined,
                                //           color: Colors.redAccent.shade200,
                                //           size: 25.0,
                                //         ),
                                //         const SizedBox(width: 8.0), // Add spacing between icon and text
                                //         Text(
                                //           "Apply a voucher",
                                //           style: TextStyle(
                                //             fontWeight: FontWeight.bold,
                                //             fontSize: 17,
                                //             color: Colors.redAccent.shade200,
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // ),
                              ),
                            )
                          else if (voucherAppliedID != 0 && currentUser?.email != "guestkeninacafe@gmail.com")
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: FutureBuilder<List<Voucher>>(
                                  future: getVoucherAppliedDetails(currentCart.voucherAppliedID),
                                  builder: (BuildContext context, AsyncSnapshot <List<Voucher>> snapshot) {
                                    if (snapshot.hasData) {
                                      return Column(
                                        children: buildVoucherApplied(snapshot.data, currentCart),
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
                          if (voucherAppliedID == 0)
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Total: ",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.black,
                                    fontFamily: 'Itim',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${currentCart.getNumMenuItemOrder()}",
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.red,
                                    fontFamily: 'Itim',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  " Item(s)",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.black,
                                    fontFamily: 'Itim',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "MYR ${currentCart.getGrandTotalAfterDiscount().toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.red,
                                    fontFamily: 'Itim',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 130.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.red,
                          // border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(15.0), // Adjust the radius as needed
                        ),
                        child: MaterialButton(
                          // minWidth: double.infinity,
                          height:40,
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => ViewCartPage(user: currentUser, cart: currentCart, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: currentTabIndex, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList,))
                            );
                          },
                          // color: Colors.red,
                          child: const Text(
                            "Back To Cart",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      Container(
                        width: 130.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.greenAccent.shade400,
                          borderRadius: BorderRadius.circular(15.0), // Adjust the radius as needed
                        ),
                        child: MaterialButton(
                          // minWidth: double.infinity,
                          height:40,
                          onPressed: () {
                            showConfirmationCreateDialog(currentCart, currentUser!, currentOrderMode!, currentOrderHistory!, currentTableNo!, currentTabIndex!, currentMenuItemList!, currentItemCategoryList!);
                          },
                          child: const Text(
                            "Confirm",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15,),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey.shade100,
    );
  }

  List<Widget> buildVoucherApplied (List<Voucher>? voucherAppliedDetails, Cart currentCart) {
    List<Widget> voucherApplied = [];
    var verifyResult = currentCart.verifyVoucher();
    bool voucherAppliedSuccessfully = verifyResult.item1;
    String requirement = verifyResult.item2;

    if (voucherAppliedSuccessfully == true) {
      voucherApplied.add(
        CouponCard(
          height: 150,
          backgroundColor: Colors.transparent,
          clockwise: true,
          curvePosition: 65,
          curveRadius: 30,
          curveAxis: Axis.horizontal,
          borderRadius: 10,
          border: const BorderSide(
            color: Colors.grey, // Border color
            width: 3.0, // Border width
          ),
          firstChild: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFDAB9).withOpacity(0.7),
            ),
            child: Row(
              children: [
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: Icon(
                      Icons.discount_rounded,
                      size: 35.0,
                    )
                  // child: Image.asset(
                  //   "images/voucherLogo.png",
                  //   width: 50,
                  //   height: 60,
                  //   // fit: BoxFit.cover,
                  //   // height: 500,
                  // ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Code : ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            voucherAppliedDetails![0].voucher_code,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                currentCart.removeVoucher(voucherAppliedSuccessfully);
                              });
                            },
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 15),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                alignment: Alignment.centerLeft),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Remove",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.redAccent.shade200,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20.0),
                        ],
                      ),
                      const SizedBox(height: 3.0,),
                      if (voucherAppliedDetails[0].voucher_type_name == "Discount")
                        Row(
                          children: [
                            Text(
                              'MYR ${voucherAppliedDetails[0].cost_off.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 5.0,),
                            const Text(
                              'OFF',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      if (voucherAppliedDetails[0].voucher_type_name == "FreeItem")
                        Row(
                          children: [
                            const Text(
                              'Free ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              voucherAppliedDetails[0].free_menu_item_name,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      if (voucherAppliedDetails[0].voucher_type_name == "BuyOneFreeOne")
                        const Row(
                          children: [
                            Text(
                              'Buy 1 Free 1',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
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
          secondChild: Container(
            width: double.maxFinite,
            // padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFDAB9).withOpacity(0.4),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (voucherAppliedDetails[0].voucher_type_name == "Discount" || voucherAppliedDetails[0].voucher_type_name == "FreeItem")
                    Row(
                      children: [
                        Text(
                          'Min. Spend : ',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'MYR ${voucherAppliedDetails[0].min_spending.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.grey.shade900,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  if (voucherAppliedDetails[0].voucher_type_name == "BuyOneFreeOne")
                    Row(
                      children: [
                        Text(
                          'Applicable For ',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${voucherAppliedDetails[0].applicable_menu_item_name} ',
                          style: TextStyle(
                            color: Colors.grey.shade900,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Text(
                          'Only',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4.0,),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green.shade600,
                        size: 20.0,
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        'Voucher Applied !',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "- MYR ${currentCart.getDiffBetweenPriceGrandAndGross()}",
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.red,
                          fontFamily: 'Itim',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      voucherApplied.add(
        CouponCard(
          height: 150,
          backgroundColor: Colors.transparent,
          clockwise: true,
          curvePosition: 65,
          curveRadius: 30,
          curveAxis: Axis.horizontal,
          borderRadius: 10,
          border: const BorderSide(
            color: Colors.grey, // Border color
            width: 3.0, // Border width
          ),
          firstChild: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Icon(
                    Icons.discount_rounded,
                    size: 35.0,
                    color: Colors.grey.shade500,
                  ),
                  // child: Image.asset(
                  //   "images/voucherLogo.png",
                  //   width: 50,
                  //   height: 60,
                  //   // fit: BoxFit.cover,
                  //   // height: 500,
                  // ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Code : ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          Text(
                            voucherAppliedDetails![0].voucher_code,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                currentCart.removeVoucher(voucherAppliedSuccessfully);
                              });
                              // Navigator.push(context,
                              //     MaterialPageRoute(builder: (context) => ApplyVoucherPage(user: currentUser, cart: currentCart))
                              // );
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Colors.transparent,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Remove",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.redAccent.shade200,
                                    ),
                                  ),
                                  const SizedBox(width: 20.0),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3.0,),
                      if (voucherAppliedDetails[0].voucher_type_name == "Discount")
                        Row(
                          children: [
                            Text(
                              'MYR ${voucherAppliedDetails[0].cost_off.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 5.0,),
                            Text(
                              'OFF',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      if (voucherAppliedDetails[0].voucher_type_name == "FreeItem")
                        Row(
                          children: [
                            Text(
                              'Free ',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              voucherAppliedDetails[0].free_menu_item_name,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      if (voucherAppliedDetails[0].voucher_type_name == "BuyOneFreeOne")
                        Row(
                          children: [
                            Text(
                              'Buy 1 Free 1',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
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
          secondChild: Container(
            width: double.maxFinite,
            // padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 30.0, vertical: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (voucherAppliedDetails[0].voucher_type_name == "Discount" || voucherAppliedDetails[0].voucher_type_name == "FreeItem")
                    Row(
                      children: [
                        Text(
                          'Min. Spend : ',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'MYR ${voucherAppliedDetails[0].min_spending.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  if (voucherAppliedDetails[0].voucher_type_name == "BuyOneFreeOne")
                    Row(
                      children: [
                        Text(
                          'Applicable For ',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${voucherAppliedDetails[0].applicable_menu_item_name} ',
                          style: TextStyle(
                            color: Colors.redAccent.shade200,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Text(
                          'Only',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4.0,),
                  Row(
                    children: [
                      Text(
                        requirement,
                        style: TextStyle(
                          color: Colors.redAccent.shade200,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    voucherApplied.add(const SizedBox(height: 20.0));
    voucherApplied.add(
      Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Total: ",
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              fontFamily: 'Itim',
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "${currentCart.getNumMenuItemOrder()}",
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.red,
              fontFamily: 'Itim',
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            " Item(s)",
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              fontFamily: 'Itim',
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            "MYR ${currentCart.getGrandTotalAfterDiscount().toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.red,
              fontFamily: 'Itim',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
    return voucherApplied;
  }

  Future<(int, String)> _submitOrderDetails(Cart currentCart, User currentUser, String currentOrderMode) async {
    double gross_total = currentCart.getGrandTotalBeforeDiscount();
    double grand_total = currentCart.getGrandTotalAfterDiscount();
    List<MenuItem> menuItemList = currentCart.getMenuItemList();
    int voucherAppliedID = currentCart.voucherAppliedID;
    var (currentOrderID, err_code) = await createOrder(gross_total, grand_total, menuItemList, voucherAppliedID, currentUser, currentOrderMode);
    if (currentOrderID == 0) {
      if (kDebugMode) {
        print("Failed to create order.");
      }
      return (currentOrderID, err_code);
    }
    return (currentOrderID, err_code);
  }

  Future<(int, String)> createOrder(double gross_total, double grand_total, List<MenuItem> menuItemList, int voucherAppliedID, User currentUser, String currentOrderMode) async {
    try {
      final response = await http.post(
        // Uri.parse('http://10.0.2.2:8000/order/create_order'),
        Uri.parse('http://localhost:8000/order/create_order'),

        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<dynamic, dynamic> {
          'gross_total': gross_total,
          'grand_total': grand_total,
          'user_id': currentUser.uid,
          'menu_items': menuItemList.map((menuItem) => menuItem.toJson()).toList(),
          'voucher_applied_id': voucherAppliedID,
          'is_done': false,
          'order_mode': currentOrderMode,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (kDebugMode) {
          print("Create Order Successful.");
        }
        var jsonResp = jsonDecode(response.body);
        int currentOrderID = jsonResp['data'];
        return (currentOrderID, ErrorCodes.OPERATION_OK);
      } else {
        if (kDebugMode) {
          print(response.body);
          print('Failed to create order.');
        }
        return (0, (ErrorCodes.CREATE_ORDER_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (0, (ErrorCodes.CREATE_ORDER_FAIL_API_CONNECTION));
    }
  }

  Future<List<Voucher>> getVoucherAppliedDetails(int voucherAppliedID) async {
    try {
      final response = await http.get(
        // Uri.parse('http://10.0.2.2:8000/order/request_voucher_applied_details/$voucherAppliedID/'),
        Uri.parse('http://localhost:8000/order/request_voucher_applied_details/$voucherAppliedID/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Voucher.getVoucherAppliedDetails(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the voucher details applied by the user.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }

  Future<List<FoodOrder>> getFoodOrderDetails(int currentOrderIDGet) async {
    try {
      final response = await http.get(
        // Uri.parse('http://10.0.2.2:8000/order/request_voucher_applied_details/$voucherAppliedID/'),
        Uri.parse('http://localhost:8000/order/request_specific_order_details/$currentOrderIDGet/'),
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

  void showConfirmationCreateDialog(Cart currentCart, User currentUser, String currentOrderMode, List<int> currentOrderHistory, int currentTableNo, int currentTabIndex, List<MenuItem> currentMenuItemList, List<MenuItem> currentItemCategoryList) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: const Text('Are you sure to confirm your order?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                var (currentOrderIDAsync, err_code) = await _submitOrderDetails(currentCart, currentUser, currentOrderMode);
                setState(() {
                  currentOrderIDGet = currentOrderIDAsync;
                  if (currentOrderIDGet == 0) {
                    if (err_code == ErrorCodes.CREATE_ORDER_FAIL_BACKEND) {
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: const Text('Error'),
                            content: Text('An Error occurred while trying to create a new order.\n\nError Code: $err_code'),
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
                    currentCart = Cart(id: 0, menuItem: [], numMenuItemOrder: 0, grandTotalBeforeDiscount: 0, grandTotalAfterDiscount: 0, price_discount: 0, voucherAppliedID: 0, voucherApplied_type_name: "", voucherApplied_cost_off: 0, voucherApplied_free_menu_item_name: "", voucherApplied_applicable_menu_item_name: "", voucherApplied_min_spending: 0);
                    Navigator.of(context).pop();
                    currentOrderHistory = [...currentOrderHistory, currentOrderIDGet];
                    showDialog(context: context, builder: (
                        BuildContext context) =>
                        AlertDialog(
                          title: const Text('Order Placed Successful'),
                          content: const Text('Your order placed can be viewed in the order history'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Ok'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => OrderPlacedPage(user: currentUser, cart: currentCart, orderID: currentOrderIDGet, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: currentTabIndex, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList,)),
                                );
                              },
                            ),
                          ],
                        ),
                    );
                    setState(() {

                    });
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Yes'),

            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }
}
