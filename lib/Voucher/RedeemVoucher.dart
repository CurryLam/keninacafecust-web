import 'dart:async';
import 'dart:convert';

import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:keninacafecust_web/AppsBar.dart';
import '../Entity/Cart.dart';
import '../Entity/MenuItem.dart';
import '../Entity/User.dart';
import '../Entity/Voucher.dart';
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
      home: RedeemVoucherPage(user: null, cart: null, orderMode: null, orderHistory: null, tableNo: null, tabIndex: null, menuItemList: null, itemCategoryList: null),
    );
  }
}

class RedeemVoucherPage extends StatefulWidget {
  RedeemVoucherPage({super.key, this.user, this.cart, this.orderMode, this.orderHistory, this.tableNo, this.tabIndex, this.menuItemList, this.itemCategoryList});

  User? user;
  final Cart? cart;
  final String? orderMode;
  final List<int>? orderHistory;
  final String? tableNo;
  final int? tabIndex;
  final List<MenuItem>? menuItemList;
  final List<MenuItem>? itemCategoryList;

  @override
  State<RedeemVoucherPage> createState() => _RedeemVoucherPageState();
}

class _RedeemVoucherPageState extends State<RedeemVoucherPage> {
  bool isMenuHomePage = false;
  bool voucherRedeemed = false;

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

    return Scaffold(
      appBar: AppsBarState().buildRedeemVoucherAppBar(context, "Redeem Voucher", currentUser!, currentCart!),
      drawer: AppsBarState().buildDrawer(context, currentUser!, currentCart!, isMenuHomePage, currentOrderMode!, currentOrderHistory!, currentTableNo!, currentTabIndex!, currentMenuItemList!, currentItemCategoryList!),
      body: SafeArea(
        child: SingleChildScrollView (
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 20.0),
            child: FutureBuilder<List<Voucher>>(
                future: getAvailableVoucherList(currentUser),
                builder: (BuildContext context, AsyncSnapshot<List<Voucher>> snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: buildAvailableVoucherList(snapshot.data, currentUser, currentCart),
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

  List<Widget> buildAvailableVoucherList(List<Voucher>? availableVoucherList, User? currentUser, Cart currentCart) {
    List<Widget> voucher = [];
    List<Voucher> discountVoucherList = [];
    List<Voucher> freeMenuItemVoucherList = [];
    List<Voucher> buyOneFreeOneVoucherList = [];

    for (int i = 0; i < availableVoucherList!.length; i++) {
      if (availableVoucherList[i].voucher_type_name == "Discount") {
        discountVoucherList.add(availableVoucherList[i]);
      } else if (availableVoucherList[i].voucher_type_name == "FreeItem") {
        freeMenuItemVoucherList.add(availableVoucherList[i]);
      } else if (availableVoucherList[i].voucher_type_name == "BuyOneFreeOne") {
        buyOneFreeOneVoucherList.add(availableVoucherList[i]);
      }
    }

    voucher.add(
      FutureBuilder<double>(
          future: getCurrentUserRewardPoints(currentUser, currentUser!.uid),
          builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
            if (snapshot.hasData) {
              currentUser.points = snapshot.data!;
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Points : ${snapshot.data?.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 25.0,
                    fontFamily: 'AsapCondensed',
                  ),
                ),
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
      // Align(
      //   alignment: Alignment.centerLeft,
      //   child: Text(
      //     'Points : ${currentUser?.points.toStringAsFixed(2)}',
      //     style: const TextStyle(
      //       fontWeight: FontWeight.w500,
      //       fontSize: 25.0,
      //       fontFamily: 'AsapCondensed',
      //     ),
      //   ),
      // ),
    );
    voucher.add(const SizedBox(height: 15.0),);
    if (discountVoucherList.isNotEmpty) {
      voucher.add(
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Discount',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 25.0,
              fontFamily: 'AsapCondensed',
            ),
          ),
        ),
      );
      voucher.add(const SizedBox(height: 15.0),);
      for (int i = 0; i < discountVoucherList.length; i++) {
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: Icon(
                      Icons.discount_rounded,
                      size: 35.0,
                      color: Colors.grey.shade800,
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
                              discountVoucherList[i].voucher_code,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text(
                                '${discountVoucherList[i].redeem_point} points',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3.0,),
                        Row(
                          children: [
                            Text(
                              'MYR ${discountVoucherList[i].cost_off.toStringAsFixed(0)}',
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
                padding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          'MYR ${discountVoucherList[i].min_spending.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.grey.shade900,
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
                          'Valid for ',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '30 ',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'days Only',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            if (currentUser!.points >= discountVoucherList[i].redeem_point) {
                              showConfirmationCreateDialog(discountVoucherList[i], currentCart, currentUser!);
                            } else {
                              showPointsNotEnoughDialog(discountVoucherList[i].voucher_code);
                            }
                          },
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 15),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.centerLeft),
                          child: Text(
                            'Redeem',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              color: Colors.transparent,
                              shadows: [Shadow(color: Colors.green.shade600, offset: const Offset(0, -2))],
                              decorationThickness: 3,
                              decorationColor: Colors.green.shade600,
                            ),
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
        voucher.add(const SizedBox(height: 30.0));
      }
    }

    if (freeMenuItemVoucherList.isNotEmpty) {
      voucher.add(
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Free Menu Item',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 25.0,
              fontFamily: 'AsapCondensed',
            ),
          ),
        ),
      );
      voucher.add(const SizedBox(height: 15.0),);
      for (int i = 0; i < freeMenuItemVoucherList.length; i++) {
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: Icon(
                      Icons.discount_rounded,
                      size: 35.0,
                      color: Colors.grey.shade800,
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
                              freeMenuItemVoucherList[i].voucher_code,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text(
                                '${freeMenuItemVoucherList[i].redeem_point} points',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3.0,),
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
                              freeMenuItemVoucherList[i].free_menu_item_name,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
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
                padding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          'MYR ${freeMenuItemVoucherList[i].min_spending.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.grey.shade900,
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
                          'Valid for ',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '30 ',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'days Only',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            if (currentUser!.points >= freeMenuItemVoucherList[i].redeem_point) {
                              showConfirmationCreateDialog(freeMenuItemVoucherList[i], currentCart, currentUser!);
                            } else {
                              showPointsNotEnoughDialog(freeMenuItemVoucherList[i].voucher_code);
                            }
                          },
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 15),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.centerLeft),
                          child: Text(
                            'Redeem',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              color: Colors.transparent,
                              shadows: [Shadow(color: Colors.green.shade600, offset: const Offset(0, -2))],
                              decorationThickness: 3,
                              decorationColor: Colors.green.shade600,
                            ),
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
        voucher.add(const SizedBox(height: 30.0));
      }
    }

    if (buyOneFreeOneVoucherList.isNotEmpty) {
      voucher.add(
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Buy 1 Free 1',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 25.0,
              fontFamily: 'AsapCondensed',
            ),
          ),
        ),
      );
      voucher.add(const SizedBox(height: 15.0),);
      for (int i = 0; i < buyOneFreeOneVoucherList.length; i++) {
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: Icon(
                      Icons.discount_rounded,
                      size: 35.0,
                      color: Colors.grey.shade800,
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
                              buyOneFreeOneVoucherList[i].voucher_code,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text(
                                '${buyOneFreeOneVoucherList[i].redeem_point} points',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3.0,),
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
                padding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          '${buyOneFreeOneVoucherList[i].applicable_menu_item_name} ',
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
                          'Valid for ',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '30 ',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'days Only',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            if (currentUser!.points >= buyOneFreeOneVoucherList[i].redeem_point) {
                              showConfirmationCreateDialog(buyOneFreeOneVoucherList[i], currentCart, currentUser!);
                            } else {
                              showPointsNotEnoughDialog(buyOneFreeOneVoucherList[i].voucher_code);
                            }
                          },
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 15),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.centerLeft),
                          child: Text(
                            'Redeem',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              color: Colors.transparent,
                              shadows: [Shadow(color: Colors.green.shade600, offset: const Offset(0, -2))],
                              decorationThickness: 3,
                              decorationColor: Colors.green.shade600,
                            ),
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
        voucher.add(const SizedBox(height: 20.0));
      }
    }
    return voucher;
  }

  void showConfirmationCreateDialog(Voucher currentVoucher, Cart currentCart, User currentUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: const Text('Are you sure to redeem this voucher?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                var (voucherRedeemedAsync, err_code) = await _submitVoucherRedeem(currentVoucher, currentUser);
                setState(() {
                  Navigator.of(context).pop();
                  voucherRedeemed = voucherRedeemedAsync;
                  if (!voucherRedeemed) {
                    if (err_code == ErrorCodes.REDEEM_VOUCHER_FAIL_BACKEND) {
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold,)),
                            content: Text('An Error occurred while trying to redeem this voucher.\n\nError Code: $err_code'),
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
                    // currentCart = Cart(id: 0, menuItem: [], numMenuItemOrder: 0, grandTotalBeforeDiscount: 0, grandTotalAfterDiscount: 0, price_discount: 0, voucherAppliedID: 0, voucherApplied_type_name: "", voucherApplied_cost_off: 0, voucherApplied_free_menu_item_name: "", voucherApplied_applicable_menu_item_name: "", voucherApplied_min_spending: 0);
                    showDialog(context: context, builder: (
                        BuildContext context) =>
                        AlertDialog(
                          title: const Text('Voucher Redeemed Successfully', style: TextStyle(fontWeight: FontWeight.bold,)),
                          content: const Text('Your voucher redeemed can be viewed in the voucher list.'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Ok'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  currentUser.points -= currentVoucher.redeem_point;
                                });
                              },
                            ),
                          ],
                        ),
                    );
                    setState(() {});
                  }
                });
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
  

  void showPointsNotEnoughDialog(String voucherCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Insufficient Points', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: Text('Your points is not enough to redeem this voucher (${voucherCode})'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  Future<List<Voucher>> getAvailableVoucherList(User currentUser) async {
    try {
      final response = await http.get(
        // Uri.parse('http://10.0.2.2:8000/order/request_all_available_voucher_to_redeem'),
        Uri.parse('${IpAddress.ip_addr}/order/request_all_available_voucher_to_redeem'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Voucher.getAvailableVoucherList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the available voucher list of the restaurant for the customer(s) to redeem.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }

  Future<(bool, String)> _submitVoucherRedeem(Voucher currentVoucher, User currentUser) async {
    var (success, err_code) = await redeemVoucher(currentVoucher, currentUser);
    if (success == false) {
      if (kDebugMode) {
        print("Failed to redeem voucher.");
      }
      return (false, err_code);
    }
    return (true, err_code);
  }

  Future<(bool, String)> redeemVoucher(Voucher currentVoucher, User currentUser) async {
    try {
      final response = await http.post(
        // Uri.parse('http://10.0.2.2:8000/order/redeem_voucher/${currentVoucher.id}/'),
        Uri.parse('${IpAddress.ip_addr}/order/redeem_voucher/${currentVoucher.id}/'),

        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<dynamic, dynamic> {
          'user_id': currentUser.uid,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (kDebugMode) {
          print("Voucher Redeemed Successful.");
        }
        return (true, ErrorCodes.OPERATION_OK);
      } else {
        if (kDebugMode) {
          print(response.body);
          print('Failed to redeem voucher.');
        }
        return (false, (ErrorCodes.REDEEM_VOUCHER_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.REDEEM_VOUCHER_FAIL_API_CONNECTION));
    }
  }

  Future<double> getCurrentUserRewardPoints(User? currentUser, int currentUserUid) async {
    try {
      final response = await http.get(
        Uri.parse('${IpAddress.ip_addr}/users/request_user_reward_points/$currentUserUid/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['points'];
      } else {
        throw Exception('Failed to load the item category exist menu item list.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }
}