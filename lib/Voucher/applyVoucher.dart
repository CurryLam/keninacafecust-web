import 'dart:async';
import 'dart:convert';

import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:keninacafecust_web/AppsBar.dart';
import '../Entity/Cart.dart';
import '../Entity/MenuItem.dart';
import '../Entity/User.dart';
import '../Entity/VoucherAssignUserMoreInfo.dart';
import 'RedeemVoucher.dart';

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
      home: const ApplyVoucherPage(user: null, cart: null, orderMode: null, orderHistory: null, tableNo: null, tabIndex: null, menuItemList: null, itemCategoryList: null),
    );
  }
}

class ApplyVoucherPage extends StatefulWidget {
  const ApplyVoucherPage({super.key, this.user, this.cart, this.orderMode, this.orderHistory, this.tableNo, this.tabIndex, this.menuItemList, this.itemCategoryList});

  final User? user;
  final Cart? cart;
  final String? orderMode;
  final List<int>? orderHistory;
  final int? tableNo;
  final int? tabIndex;
  final List<MenuItem>? menuItemList;
  final List<MenuItem>? itemCategoryList;

  @override
  State<ApplyVoucherPage> createState() => _ApplyVoucherPageState();
}

class _ApplyVoucherPageState extends State<ApplyVoucherPage> {
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

  onGoBack(dynamic value) {
    setState(() {});
  }

  void navigateRedeemVoucherPage(Cart currentCart, User currentUser, String currentOrderMode, List<int> currentOrderHistory, int currentTableNo, int currentTabIndex, List<MenuItem> currentMenuItemList, List<MenuItem> currentItemCategoryList) {
    Route route = MaterialPageRoute(builder: (context) => RedeemVoucherPage(cart: currentCart, user: currentUser, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: currentTabIndex, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList,));
    Navigator.push(context, route).then(onGoBack);
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    Cart? currentCart = getCart();
    String? currentOrderMode = getOrderMode();
    List<int>? currentOrderHistory = getOrderHistory();
    int? currentTableNo = getTableNo();
    int? currentTabIndex = getTabIndex();
    List<MenuItem>? currentMenuItemList = getMenuItemStoredList();
    List<MenuItem>? currentItemCategoryList = getItemCategory();

    return Scaffold(
      appBar: AppsBarState().buildApplyVoucherAppBar(context, "Apply a voucher", currentUser!, currentCart!),
      drawer: AppsBarState().buildDrawer(context, currentUser!, currentCart!, isMenuHomePage, currentOrderMode!, currentOrderHistory!, currentTableNo!, currentTabIndex!, currentMenuItemList!, currentItemCategoryList!),
      body: SafeArea(
        child: SingleChildScrollView (
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 20.0),
            child: FutureBuilder<List<VoucherAssignUserMoreInfo>>(
                future: getAvailableVoucherRedeemedList(currentUser),
                builder: (BuildContext context, AsyncSnapshot<List<VoucherAssignUserMoreInfo>> snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: buildAvailableVoucherRedeemedList(snapshot.data, currentUser, currentCart, currentOrderMode, currentOrderHistory!, currentTableNo!, currentTabIndex!, currentMenuItemList!, currentItemCategoryList!),
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

  List<Widget> buildAvailableVoucherRedeemedList(List<VoucherAssignUserMoreInfo>? availableVoucherRedeemedList, User? currentUser, Cart currentCart, String currentOrderMode, List<int> currentOrderHistory, int currentTableNo, int currentTabIndex, List<MenuItem> currentMenuItemList, List<MenuItem> currentItemCategoryList) {
    List<Widget> voucher = [];
    List<VoucherAssignUserMoreInfo> validVoucher = [];
    List<VoucherAssignUserMoreInfo> nonValidVoucher = [];
    if (availableVoucherRedeemedList!.isEmpty) {
      voucher.add(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 70, 0, 10),
              child: Image.asset(
                "images/emptyVoucherList.png",
                // fit: BoxFit.cover,
                // height: 500,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                child: Text(
                  "No Voucher Available",
                  style: TextStyle(
                    fontSize: 25.0,
                    color: Colors.grey.shade900,
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                child: Text(
                  "Redeem Voucher Now ! ! !",
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 6),
              child: Container(
                padding: const EdgeInsets.only(top: 3, left: 3),
                child: MaterialButton(
                  minWidth: double.infinity,
                  height: 50,
                  onPressed: () {
                    navigateRedeemVoucherPage(currentCart, currentUser!, currentOrderMode!, currentOrderHistory, currentTableNo, currentTabIndex, currentMenuItemList, currentItemCategoryList);
                  },
                  color: Colors.white,
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.orangeAccent, // Border color
                      width: 5.0, // Border width
                    ),
                  ),
                  child: const Text(
                    "Redeem",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.orangeAccent
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      int numOrderOfCurrentFoodItem = 0;
      for (int i = 0; i < availableVoucherRedeemedList!.length; i++) {
        DateTime currentDate = DateTime.now();
        DateTime expiryDateTime = availableVoucherRedeemedList![i].expiry_date;
        if (availableVoucherRedeemedList[i].is_available && currentDate.isBefore(expiryDateTime)) {
          if (availableVoucherRedeemedList[i].voucher_type_name == "Discount" && currentCart.grandTotalBeforeDiscount >= availableVoucherRedeemedList[i].min_spending) {
            validVoucher.add(availableVoucherRedeemedList[i]);
            continue;
          }
          numOrderOfCurrentFoodItem = 0;
          for (int j = 0; j < currentCart.menuItem.length; j++) {
            if (availableVoucherRedeemedList[i].voucher_type_name == "FreeItem" && availableVoucherRedeemedList[i].free_menu_item_name == currentCart.menuItem[j].name) {
              validVoucher.add(availableVoucherRedeemedList[i]);
              break;
            }
            if (availableVoucherRedeemedList[i].voucher_type_name == "BuyOneFreeOne" && availableVoucherRedeemedList[i].applicable_menu_item_name == currentCart.menuItem[j].name) {
              numOrderOfCurrentFoodItem += currentCart.menuItem[j].numOrder;
              if (numOrderOfCurrentFoodItem >= 2) {
                validVoucher.add(availableVoucherRedeemedList[i]);
                break;
              }
            }
            if (j == currentCart.menuItem.length - 1) {
              nonValidVoucher.add(availableVoucherRedeemedList[i]);
            }
          }
        }
      }
      if (validVoucher.isEmpty && nonValidVoucher.isEmpty) {
        voucher.add(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 70, 0, 10),
                child: Image.asset(
                  "images/emptyVoucherList.png",
                  // fit: BoxFit.cover,
                  // height: 500,
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                  child: Text(
                    "No Voucher Available",
                    style: TextStyle(
                      fontSize: 25.0,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                  child: Text(
                    "Redeem Voucher Now ! ! !",
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.only(top: 3, left: 3),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    height: 50,
                    onPressed: () {
                      navigateRedeemVoucherPage(currentCart, currentUser!, currentOrderMode, currentOrderHistory, currentTableNo, currentTabIndex, currentMenuItemList, currentItemCategoryList);
                    },
                    color: Colors.white,
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.orangeAccent, // Border color
                        width: 5.0, // Border width
                      ),
                    ),
                    child: const Text(
                      "Redeem",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.orangeAccent
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        if (validVoucher.isNotEmpty) {
          voucher.add(
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Select a voucher',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          );
          voucher.add(const SizedBox(height: 10.0,));
          for (int i = 0; i < validVoucher.length; i++) {
            DateTime currentDate = DateTime.now();
            DateTime expiryDateTime = validVoucher[i].expiry_date;
            String formattedDate = DateFormat('yyyy-MM-dd  HH:mm:ss').format(expiryDateTime);
            voucher.add(
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
                                  validVoucher[i].voucher_code,
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
                                      currentCart.applyVoucher(validVoucher[i].id, validVoucher[i].voucher_type_name, validVoucher[i].cost_off, validVoucher[i].free_menu_item_name, validVoucher[i].applicable_menu_item_name, validVoucher[i].min_spending);
                                      Navigator.pop(context);
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(50, 15),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      alignment: Alignment.centerLeft),
                                  child: Text(
                                    'Apply',
                                    style: TextStyle(
                                      fontSize: 17.0,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.transparent,
                                      shadows: [Shadow(color: Colors.redAccent.shade200, offset: const Offset(0, -2))],
                                      decorationThickness: 3,
                                      decorationColor: Colors.redAccent.shade200,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20.0),
                                // GestureDetector(
                                //   onTap: () {
                                //     setState(() {
                                //       // currentCart.voucherAppliedID = validVoucher[i].id;
                                //       currentCart.applyVoucher(validVoucher[i].id, validVoucher[i].voucher_type_name, validVoucher[i].cost_off, validVoucher[i].free_menu_item_name, validVoucher[i].applicable_menu_item_name, validVoucher[i].min_spending);
                                //       Navigator.pop(context);
                                //     });
                                //     // Navigator.push(context,
                                //     //     MaterialPageRoute(builder: (context) => ApplyVoucherPage(user: currentUser, cart: currentCart))
                                //     // );
                                //   },
                                //   child: Container(
                                //     decoration: const BoxDecoration(
                                //       shape: BoxShape.rectangle,
                                //       color: Colors.transparent,
                                //     ),
                                //     child: Row(
                                //       mainAxisAlignment: MainAxisAlignment.start,
                                //       children: [
                                //         Text(
                                //           "Apply",
                                //           style: TextStyle(
                                //             fontWeight: FontWeight.bold,
                                //             fontSize: 17,
                                //             color: Colors.redAccent.shade200,
                                //           ),
                                //         ),
                                //         const SizedBox(width: 20.0),
                                //       ],
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                            const SizedBox(height: 3.0,),
                            if (validVoucher[i].voucher_type_name == "Discount")
                              Row(
                                children: [
                                  Text(
                                    'MYR ${validVoucher[i].cost_off.toStringAsFixed(0)}',
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
                            if (validVoucher[i].voucher_type_name == "FreeItem")
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
                                    validVoucher[i].free_menu_item_name,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            if (validVoucher[i].voucher_type_name == "BuyOneFreeOne")
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
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (validVoucher[i].voucher_type_name == "Discount" || validVoucher[i].voucher_type_name == "FreeItem")
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
                                'MYR ${validVoucher[i].min_spending.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: Colors.grey.shade900,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        if (validVoucher[i].voucher_type_name == "BuyOneFreeOne")
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
                                '${validVoucher[i].applicable_menu_item_name} ',
                                style: TextStyle(
                                  color: Colors.grey.shade900,
                                  fontSize: 15,
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
                            Text(
                              'Valid Until ',
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                color: Colors.red,
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
            voucher.add(const SizedBox(height: 30,),);
          }
        }
        if (nonValidVoucher.isNotEmpty) {
          if (validVoucher.isNotEmpty) {
            voucher.add(const Divider(height: 30.0,));
          }
          voucher.add(
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Not valid for this order',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          );

          voucher.add(const SizedBox(height: 10.0,));
          for (int i = 0; i < nonValidVoucher.length; i++) {
            DateTime expiryDateTime = nonValidVoucher[i].expiry_date;
            String formattedDate = DateFormat('yyyy-MM-dd  HH:mm:ss').format(expiryDateTime);
            voucher.add(
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
                                  nonValidVoucher[i].voucher_code,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3.0,),
                            if (nonValidVoucher[i].voucher_type_name == "Discount")
                              Row(
                                children: [
                                  Text(
                                    'MYR ${nonValidVoucher[i].cost_off.toStringAsFixed(0)}',
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
                            if (nonValidVoucher[i].voucher_type_name == "FreeItem")
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
                                    nonValidVoucher[i].free_menu_item_name,
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            if (nonValidVoucher[i].voucher_type_name == "BuyOneFreeOne")
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
                        if (nonValidVoucher[i].voucher_type_name == "Discount" || nonValidVoucher[i].voucher_type_name == "FreeItem")
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
                                'MYR ${nonValidVoucher[i].min_spending.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        if (nonValidVoucher[i].voucher_type_name == "BuyOneFreeOne")
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
                                '${nonValidVoucher[i].applicable_menu_item_name} ',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 15,
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
                              'Valid Until ',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                color: Colors.grey.shade500,
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
            voucher.add(const SizedBox(height: 30,),);
          }
        }
        voucher.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 0),
            child: Container(
              padding: const EdgeInsets.only(top: 3, left: 3),
              child: MaterialButton(
                minWidth: double.infinity,
                height: 50,
                onPressed: () {
                  navigateRedeemVoucherPage(currentCart, currentUser!, currentOrderMode, currentOrderHistory, currentTableNo, currentTabIndex, currentMenuItemList, currentItemCategoryList);
                },
                color: Colors.white,
                shape: const RoundedRectangleBorder(
                  side: BorderSide(
                    color: Colors.orangeAccent, // Border color
                    width: 5.0, // Border width
                  ),
                ),
                child: const Text(
                  "Redeem",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.orangeAccent
                  ),
                ),
              ),
            ),
          ),
        );
        voucher.add(const SizedBox(height: 10,),);
      }
    }
    return voucher;
  }

  Future<List<VoucherAssignUserMoreInfo>> getAvailableVoucherRedeemedList(User currentUser) async {
    try {
      final response = await http.post(
        // Uri.parse('http://10.0.2.2:8000/order/request_available_voucher_redeemed'),
        Uri.parse('http://localhost:8000/order/request_available_voucher_redeemed'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<dynamic, dynamic> {
          'user_id': currentUser.uid,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return VoucherAssignUserMoreInfo.getAvailableVoucherRedeemedList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the available voucher redeemed by the user.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }

}