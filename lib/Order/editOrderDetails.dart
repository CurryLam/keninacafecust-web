import 'dart:convert';

import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:keninacafecust_web/Entity/CartForOrderFoodItemMoreInfo.dart';
import '../Entity/Cart.dart';
import '../Entity/FoodOrder.dart';
import '../Entity/MenuItem.dart';
import '../Entity/OrderFoodItemMoreInfo.dart';
import '../Entity/User.dart';
import '../Entity/Voucher.dart';
import '../Utils/error_codes.dart';
import '../Utils/ip_address.dart';
import '../Voucher/applyVoucherInEditOrder.dart';
import 'orderHistory.dart';

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
      home: const EditOrderDetailsPage(user: null, order: null, cart: null, cartOrder: null, orderMode: null, orderHistory: null, tableNo: null, tabIndex: null, menuItemList: null, itemCategoryList: null),
    );
  }
}

class EditOrderDetailsPage extends StatefulWidget {
  const EditOrderDetailsPage({super.key, this.user, this.order, this.cart, this.cartOrder, this.orderMode, this.orderHistory, this.tableNo, this.tabIndex, this.menuItemList, this.itemCategoryList});

  final User? user;
  final FoodOrder? order;
  final Cart? cart;
  final CartForOrderFoodItemMoreInfo? cartOrder;
  final String? orderMode;
  final List<int>? orderHistory;
  final String? tableNo;
  final int? tabIndex;
  final List<MenuItem>? menuItemList;
  final List<MenuItem>? itemCategoryList;

  @override
  State<EditOrderDetailsPage> createState() => _EditOrderDetailsPageState();
}

class _EditOrderDetailsPageState extends State<EditOrderDetailsPage> {
  Widget? image;
  String base64Image = "";
  bool orderEdited = false;
  bool orderDeleted = false;

  User? getUser() {
    return widget.user;
  }

  FoodOrder? getOrder() {
    return widget.order;
  }

  Cart? getCart() {
    return widget.cart;
  }

  CartForOrderFoodItemMoreInfo? getCartOrder() {
    return widget.cartOrder;
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

  onGoBack(dynamic value) {
    setState(() {});
  }

  void navigateApplyVoucherInEditOrderPage(Cart currentCart, CartForOrderFoodItemMoreInfo currentCartOrder, User currentUser, String currentOrderMode, List<int> currentOrderHistory, String currentTableNo, int currentTabIndex, List<MenuItem> currentMenuItemList, List<MenuItem> currentItemCategoryList) {
    Route route = MaterialPageRoute(builder: (context) => ApplyVoucherInEditOrderPage(cart: currentCart, cartOrder: currentCartOrder, user: currentUser, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: currentTabIndex, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList,));
    Navigator.push(context, route).then(onGoBack);
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    FoodOrder? currentOrder = getOrder();
    Cart? currentCart = getCart();
    CartForOrderFoodItemMoreInfo? currentCartOrder = getCartOrder();
    String? currentOrderMode = getOrderMode();
    List<int>? currentOrderHistory = getOrderHistory();
    String? currentTableNo = getTableNo();
    int? currentTabIndex = getTabIndex();
    List<MenuItem>? currentMenuItemList = getMenuItemStoredList();
    List<MenuItem>? currentItemCategoryList = getItemCategory();

    if (!currentCartOrder!.isEditCartOrder) {
      currentCartOrder?.order_grand_total = currentOrder!.grand_total;
      currentCartOrder?.order_grand_total_before_discount = currentOrder!.gross_total;
      currentCartOrder?.price_discount_voucher = (currentOrder!.gross_total - currentOrder.grand_total);
      currentCartOrder?.voucherAppliedID = currentOrder!.voucher_assign_id;
      currentCartOrder?.voucherAppliedIDBefore = currentOrder!.voucher_assign_id;
    }

    return WillPopScope(
      onWillPop: () async {
        if (currentCartOrder.isEditCartOrder) {
          showConfirmNoSaveDialog(currentCartOrder);
        } else {
          Navigator.of(context).pop();
          makeTheVoucherAvailableOrUnavailable(currentCartOrder!.voucherAppliedIDBefore, false);
        }
        return false;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: AppBar(
            leading: IconButton(
              onPressed: () => {
                if (currentCartOrder.isEditCartOrder) {
                  showConfirmNoSaveDialog(currentCartOrder),
                } else {
                  Navigator.of(context).pop(),
                  makeTheVoucherAvailableOrUnavailable(currentCartOrder!.voucherAppliedIDBefore, false),
                }
              },
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            ),
            elevation: 0,
            toolbarHeight: 100,
            title: const Row(
              children: [
                Icon(
                  Icons.edit,
                  size: 35.0,
                  color: Colors.white,
                ),
                SizedBox(width: 8.0,),
                Text(
                  "Edit Order",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 27.0,
                    fontFamily: 'BreeSerif',
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade500,
            centerTitle: true,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView (
            child: SizedBox(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FutureBuilder<List<OrderFoodItemMoreInfo>>(
                      future: getOrderFoodItemDetails(currentOrder!),
                      builder: (BuildContext context, AsyncSnapshot<List<OrderFoodItemMoreInfo>> snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            children: buildOrderFoodItemList(snapshot.data, currentUser, currentCart, currentCartOrder!, currentOrderMode!, currentOrderHistory!, currentTableNo!, currentTabIndex!, currentMenuItemList!, currentItemCategoryList!),
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
                    )
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: FutureBuilder<List<FoodOrder>>(
            future: getOrderGrandTotal(currentOrder!),
            builder: (BuildContext context, AsyncSnapshot<List<FoodOrder>> snapshot) {
              if (snapshot.hasData) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: buildBottomNavigationBar(snapshot.data, currentUser!, currentCart!, currentCartOrder, currentOrderMode, currentOrderHistory!, currentTableNo!, currentTabIndex!, currentMenuItemList!, currentItemCategoryList!),
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
        backgroundColor: Colors.grey.shade100,
      ),
    );
  }

  List<Widget> buildBottomNavigationBar(List<FoodOrder>? currentOrder, User currentUser, Cart currentCart, CartForOrderFoodItemMoreInfo? currentCartOrder, String? currentOrderMode, List<int> currentOrderHistory, String currentTableNo, int currentTabIndex, List<MenuItem> currentMenuItemList, List<MenuItem> currentItemCategoryList) {
    List<Widget> bottomNavigationBar = [];
    // bottomNavigationBar.add(
    //   Padding(
    //     padding: const EdgeInsets.fromLTRB(20, 13, 20, 10),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         const Text(
    //           'Total :',
    //           style: TextStyle(
    //             fontWeight: FontWeight.bold,
    //             fontSize: 22.0,
    //             fontFamily: 'Itim',
    //           ),
    //         ),
    //         Text(
    //           'MYR ${currentCartOrder?.order_grand_total.toStringAsFixed(2)}',
    //           style: const TextStyle(
    //             fontWeight: FontWeight.bold,
    //             fontSize: 22.0,
    //             fontFamily: 'Gabarito',
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
    if (currentUser.uid != 18) {
      if (currentCartOrder?.voucherAppliedID != 0) {
        bottomNavigationBar.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: FutureBuilder<List<Voucher>>(
                future: getVoucherAppliedDetails(currentCartOrder!.voucherAppliedID),
                builder: (BuildContext context, AsyncSnapshot <List<Voucher>> snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: buildVoucherApplied(snapshot.data, currentCartOrder!, currentCart),
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
        );
      } else {
        bottomNavigationBar.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: TextButton(
              onPressed: () {
                navigateApplyVoucherInEditOrderPage(currentCart, currentCartOrder!, currentUser, currentOrderMode!, currentOrderHistory, currentTableNo, currentTabIndex, currentMenuItemList, currentItemCategoryList);
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
          ),
        );
      }
    }
    bottomNavigationBar.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total :',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22.0,
                fontFamily: 'Itim',
              ),
            ),
            if (currentCartOrder?.order_grand_total != -0 || currentCartOrder?.order_grand_total != 0)
              Text(
                'MYR ${currentCartOrder?.order_grand_total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                  fontFamily: 'Gabarito',
                ),
              )
            else
              const Text(
                'MYR 0',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                  fontFamily: 'Gabarito',
                ),
              ),
          ],
        ),
      ),
    );
    bottomNavigationBar.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
        child: Container(
          padding: const EdgeInsets.only(top: 3, left: 3),
          child: MaterialButton(
            minWidth: double.infinity,
            height: 50,
            onPressed: () {
              showConfirmationUpdateDialog(currentCart, currentUser, currentCartOrder!, currentOrderMode!, currentOrderHistory, currentTableNo, currentTabIndex, currentMenuItemList, currentItemCategoryList);
            },
            color: Colors.orange.shade500,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18.0,
              ),
            ),
          ),
        ),
      ),
    );
    return bottomNavigationBar;
  }

  List<Widget> buildOrderFoodItemList(List<OrderFoodItemMoreInfo>? orderFoodItemList, User? currentUser, Cart? currentCart, CartForOrderFoodItemMoreInfo currentCartOrder, String currentOrderMode, List<int> currentOrderHistory, String currentTableNo, int currentTabIndex, List<MenuItem> currentMenuItemList, List<MenuItem> currentItemCategoryList) {
    if (!currentCartOrder.containFoodItem()) {
      for (OrderFoodItemMoreInfo a in orderFoodItemList!) {
        currentCartOrder.addToCartForOrderFoodItemMoreInfo(a);
      }
    }
    List<OrderFoodItemMoreInfo> tempOrderFoodItemMoreInfoList = currentCartOrder.getFoodItemOrderList();
    List<Widget> cards = [];
    cards.add(
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5.0),
      ),
    );
    for (OrderFoodItemMoreInfo a in tempOrderFoodItemMoreInfoList) {
      if (a.numOrder > 0) {
        if (a.menu_item_image == "") {
          image = Image.asset('images/supplierLogo.jpg', width: 120, height: 120,);
        } else {
          image = Image.memory(base64Decode(a.menu_item_image), width: 120, height: 120,);
        }
        cards.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5.0),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 15.0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 3.0,),
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.blueGrey, width: 4.0),
                  borderRadius: BorderRadius.circular(15.0),
                  // color: Colors.white,
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: image
                        )
                    ),
                    const SizedBox(width: 3.0,),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(height: 10.0,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    a.menu_item_name,
                                    style: const TextStyle(
                                      fontSize: 15.0,
                                      fontFamily: 'YoungSerif',
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                                const Spacer(),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.grey.shade300),
                                      onPressed: () {
                                        setState(() {
                                          if (currentCartOrder.checkIsLastItem(a)) {
                                            showDeleteLastItemConfirmationDialog(a, currentCartOrder, currentCart!, currentUser!, currentOrderMode, currentOrderHistory, currentTableNo, currentTabIndex, currentMenuItemList, currentItemCategoryList);
                                          } else if (!currentCartOrder.checkIsLastItem(a)) {
                                            showDeleteSpecificItemConfirmationDialog(currentCartOrder, a);
                                          }
                                        });
                                      },
                                      child: Icon(Icons.delete, color: Colors.grey.shade800),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3.0,),
                            Opacity(
                              opacity: 0.5,
                              child: Row(
                                children: [
                                  if (a.variant != "")
                                    Row(
                                      children: [
                                        const Text(
                                          'Variant: ',
                                          style: TextStyle(
                                            fontSize: 10.0,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          a.variant,
                                          style: const TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.black,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (a.variant != "")
                                    const SizedBox(width: 10.0),
                                  if (a.size != "")
                                    Row(
                                      children: [
                                        const Text(
                                          'Size: ',
                                          style: TextStyle(
                                            fontSize: 10.0,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          a.size,
                                          style: const TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.black,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            if (a.remarks != "")
                              Opacity(
                                opacity: 0.5,
                                child: Row(
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Remarks: ',
                                          style: TextStyle(
                                            fontSize: 10.0,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 150,
                                          child: Text(
                                            a.remarks,
                                            style: const TextStyle(
                                              fontSize: 10.0,
                                              color: Colors.black,
                                              overflow: TextOverflow.ellipsis,
                                              // fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 10.0),
                                  ],
                                ),
                              ),
                            // if (a.variantChosen == "" && a.sizeChosen == "")
                            //   const SizedBox(height: 10.0,),
                            // if (a.remarks == "")
                            //   const SizedBox(height: 22.0,),
                            const SizedBox(height: 10.0),
                            if (a.size == "Standard" || a.size == "")
                              Text(
                                'MYR ${(a.menu_item_price_standard*a.numOrder).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  fontFamily: 'BreeSerif',
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (a.size == "Large")
                              Text(
                                'MYR ${(a.menu_item_price_large*a.numOrder).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  fontFamily: 'BreeSerif',
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (a.variant == "" && a.size == "")
                              const SizedBox(height: 10.0,),
                            if (a.remarks == "")
                              const SizedBox(height: 17.0,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (a.numOrder == 1 && currentCartOrder.checkIsLastItem(a)) {
                                          showDeleteLastItemConfirmationDialog(a, currentCartOrder, currentCart!, currentUser!, currentOrderMode, currentOrderHistory, currentTableNo, currentTabIndex, currentMenuItemList, currentItemCategoryList);
                                        } else if (a.numOrder == 1 && !currentCartOrder.checkIsLastItem(a)) {
                                          showDeleteLastNumOrderItemConfirmationDialog(currentCartOrder, a);
                                        } else if (a.numOrder > 1) {
                                          currentCartOrder.reduceNumOrderForOrderFoodItemMoreInfo(a, 1);
                                          currentCartOrder.isEditCartOrder = true;
                                        }
                                      });
                                    },
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(10.0),
                                        color: Colors.white,
                                      ),
                                      // padding: const EdgeInsets.all(1),
                                      child: const Icon(
                                        Icons.remove,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10), // Add spacing between buttons
                                  Text(
                                    a.numOrder.toInt().toString(),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 10), // Add spacing between buttons
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        // updateFoodItemNumOrder(a, (a.numOrder.toInt() + 1));
                                        currentCartOrder.increaseNumOrderForOrderFoodItemMoreInfo(a);
                                        currentCartOrder.isEditCartOrder = true;
                                      });
                                    },
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(10.0),
                                        color: Colors.white,
                                      ),
                                      // padding: const EdgeInsets.all(1),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }
    return cards;
  }

  List<Widget> buildVoucherApplied (List<Voucher>? voucherAppliedDetails, CartForOrderFoodItemMoreInfo currentCartOrder, Cart currentCart) {
    currentCartOrder.voucherApplied_type_name = voucherAppliedDetails![0].voucher_type_name;
    currentCartOrder.voucherApplied_cost_off = voucherAppliedDetails[0].cost_off;
    currentCartOrder.voucherApplied_free_menu_item_name = voucherAppliedDetails[0].free_menu_item_name;
    currentCartOrder.voucherApplied_applicable_menu_item_name = voucherAppliedDetails[0].applicable_menu_item_name;
    currentCartOrder.voucherApplied_min_spending = voucherAppliedDetails[0].min_spending;
    List<Widget> voucherApplied = [];
    var verifyResult = currentCartOrder.verifyVoucher();
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
                                makeTheVoucherAvailableOrUnavailable(currentCartOrder.voucherAppliedIDBefore, true);
                                setState(() {
                                  currentCartOrder.removeVoucher(voucherAppliedSuccessfully);
                                  currentCartOrder.isEditCartOrder = true;
                                });
                              });
                            },
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 15),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                alignment: Alignment.centerLeft),
                            child: Text(
                              'Remove',
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
                          TextButton(
                            onPressed: () {
                              setState(() {
                                makeTheVoucherAvailableOrUnavailable(currentCartOrder.voucherAppliedIDBefore, true);
                                setState(() {
                                  currentCartOrder.removeVoucher(voucherAppliedSuccessfully);
                                  currentCartOrder.isEditCartOrder = true;
                                });
                              });
                            },
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 15),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                alignment: Alignment.centerLeft),
                            child: Text(
                              'Remove',
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
    return voucherApplied;
  }

  void showDeleteLastItemConfirmationDialog(OrderFoodItemMoreInfo orderFoodItemMoreInfo, CartForOrderFoodItemMoreInfo currentCartOrder, Cart currentCart, User currentUser, String currentOrderMode, List<int> currentOrderHistory, String currentTableNo, int currentTabIndex, List<MenuItem> currentMenuItemList, List<MenuItem> currentItemCategoryList) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: const Text('This Order will be deleted if the last item is deleted.'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                var (orderDeletedAsync, err_code) = await deleteFoodOrder(orderFoodItemMoreInfo);
                setState(() {
                  Navigator.of(context).pop();
                  orderDeleted = orderDeletedAsync;
                  if (!orderDeleted) {
                    if (err_code == ErrorCodes.DELETE_ORDER_FAIL_BACKEND) {
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold,)),
                            content: Text('An Error occurred while trying to delete the order.\n\nError Code: $err_code'),
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
                          title: const Text('Order Deleted Successful', style: TextStyle(fontWeight: FontWeight.bold,)),
                          content: const Text('New Order can be make in the menu home page.'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Ok'),
                              onPressed: () {
                                setState(() {
                                  currentCartOrder.reduceNumOrderForOrderFoodItemMoreInfo(orderFoodItemMoreInfo, orderFoodItemMoreInfo.numOrder);
                                  currentCartOrder.isEditCartOrder = true;
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => OrderHistoryPage(user: currentUser, cart: currentCart, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: currentTabIndex, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList,)),
                                  );
                                });
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

  void showDeleteLastNumOrderItemConfirmationDialog(CartForOrderFoodItemMoreInfo currentCartOrder, OrderFoodItemMoreInfo orderFoodItemMoreInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: const Text('The last number of this item will be deleted.'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  currentCartOrder.reduceNumOrderForOrderFoodItemMoreInfo(orderFoodItemMoreInfo, 1);
                  currentCartOrder.isEditCartOrder = true;
                  Navigator.of(context).pop();
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

  void showDeleteSpecificItemConfirmationDialog(CartForOrderFoodItemMoreInfo currentCartOrder, OrderFoodItemMoreInfo orderFoodItemMoreInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: const Text('This item will be deleted.'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  currentCartOrder.reduceNumOrderForOrderFoodItemMoreInfo(orderFoodItemMoreInfo, orderFoodItemMoreInfo.numOrder);
                  currentCartOrder.isEditCartOrder = true;
                  Navigator.of(context).pop();
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

  void showConfirmNoSaveDialog(CartForOrderFoodItemMoreInfo currentCartOrder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Leave site?', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: const Text('Changes you made may not be saved.'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                makeTheVoucherAvailableOrUnavailable(currentCartOrder!.voucherAppliedIDBefore, false);
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

  void showConfirmationUpdateDialog(Cart currentCart, User currentUser, CartForOrderFoodItemMoreInfo currentCartOrder, String currentOrderMode, List<int> currentOrderHistory, String currentTableNo, int currentTabIndex, List<MenuItem> currentMenuItemList, List<MenuItem> currentItemCategoryList) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: const Text('Are you sure to edit your order?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                var (orderEditedAsync, err_code) = await _submitOrderFoodItemUpdateDetails(currentCartOrder);
                setState(() {
                  orderEdited = orderEditedAsync;
                  if (!orderEdited) {
                    if (err_code == ErrorCodes.EDIT_ORDER_FAIL_BACKEND) {
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold,)),
                            content: Text('An Error occurred while trying to edit the order.\n\nError Code: $err_code'),
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
                    Navigator.of(context).pop();
                    showDialog(context: context, builder: (
                        BuildContext context) =>
                        AlertDialog(
                          title: const Text('Order Edited Successful', style: TextStyle(fontWeight: FontWeight.bold,)),
                          content: const Text('Your latest order details can be viewed in the order history'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Ok'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => OrderHistoryPage(user: currentUser, cart: currentCart, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: currentTabIndex, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList,)),
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

  Future<List<OrderFoodItemMoreInfo>> getOrderFoodItemDetails(FoodOrder currentOrder) async {
    try {
      final response = await http.get(
        // Uri.parse('http://10.0.2.2:8000/order/request_order_details/${currentOrder.id}/'),
        Uri.parse('${IpAddress.ip_addr}/order/request_order_details/${currentOrder.id}/'),
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

  Future<List<FoodOrder>> getOrderGrandTotal(FoodOrder currentOrder) async {
    try {
      final response = await http.get(
        // Uri.parse('http://10.0.2.2:8000/order/request_specific_order_details/${currentOrder.id}/'),
        Uri.parse('${IpAddress.ip_addr}/order/request_specific_order_details/${currentOrder.id}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return FoodOrder.getOrderList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the order details.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }

  Future<(bool, String)> updateFoodItemNumOrder(OrderFoodItemMoreInfo orderFoodItem, int numOrder) async {
    try {
      final response = await http.put(
        // Uri.parse('http://10.0.2.2:8000/order/update_food_item_num_order/${orderFoodItem.id}/'),
        Uri.parse('${IpAddress.ip_addr}/order/update_food_item_num_order/${orderFoodItem.id}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'numOrder': numOrder,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return (true, (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print('Update Number Order Of Food Item Failed.');
        }
        return (false, (ErrorCodes.UPDATE_NUM_ORDER_FOOD_ITEM_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.UPDATE_NUM_ORDER_FOOD_ITEM_FAIL_API_CONNECTION));
    }
  }

  Future<(bool, String)> makeTheVoucherAvailableOrUnavailable(int currentCartOrderVoucherAppliedID, bool is_available) async {
    try {
      final response = await http.put(
        // Uri.parse('http://10.0.2.2:8000/order/update_food_item_num_order/${orderFoodItem.id}/'),
        Uri.parse('${IpAddress.ip_addr}/order/update_voucher_available_status'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'voucher_assign_id': currentCartOrderVoucherAppliedID,
          'is_available': is_available,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return (true, (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print('Update Number Order Of Food Item Failed.');
        }
        return (false, (ErrorCodes.UPDATE_VOUCHER_AVAILABLE_STATUS_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.UPDATE_VOUCHER_AVAILABLE_STATUS_FAIL_API_CONNECTION));
    }
  }

  Future<(bool, String)> deleteFoodOrder(OrderFoodItemMoreInfo orderFoodItem) async {
    try {
      final response = await http.put(
        // Uri.parse('http://10.0.2.2:8000/order/delete_food_item_order/${orderFoodItem.id}/'),
        Uri.parse('${IpAddress.ip_addr}/order/delete_food_order/${orderFoodItem.food_order}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return (true, (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print('Delete Food Order Failed.');
        }
        return (false, (ErrorCodes.DELETE_ORDER_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.DELETE_ORDER_FAIL_API_CONNECTION));
    }
  }

  Future<(bool, String)> _submitOrderFoodItemUpdateDetails(CartForOrderFoodItemMoreInfo currentCartOrder) async {
    List<OrderFoodItemMoreInfo> orderFoodItemUpdateList = currentCartOrder.getFoodItemOrderList();
    // double grand_total = currentCartOrder.getOrderGrandTotal();
    var (success, err_code) = await updateOrderFoodItemDetails(orderFoodItemUpdateList, currentCartOrder);
    if (success == false) {
      if (kDebugMode) {
        print("Failed to edit order.");
      }
      return (false, err_code);
    }
    return (true, err_code);
  }

  Future<(bool, String)> updateOrderFoodItemDetails(List<OrderFoodItemMoreInfo> orderFoodItemUpdateList, CartForOrderFoodItemMoreInfo currentCartOrder) async {
    bool voucherAppliedSuccessfullySubmit = false;
    if (currentCartOrder.voucherAppliedID != 0) {
      var verifyResultSubmit = currentCartOrder.verifyVoucher();
      voucherAppliedSuccessfullySubmit = verifyResultSubmit.item1;
    } else {
      voucherAppliedSuccessfullySubmit = false;
    }
    try {
      final response = await http.put(
        // Uri.parse('http://10.0.2.2:8000/order/update_food_item_order'),
        Uri.parse('${IpAddress.ip_addr}/order/update_food_item_order'),

        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<dynamic, dynamic> {
          'order_food_item_update_list': orderFoodItemUpdateList.map((orderFoodItemList) => orderFoodItemList.toJson()).toList(),
          'order_id': orderFoodItemUpdateList[0].food_order,
          'grand_total': currentCartOrder.order_grand_total,
          'gross_total': currentCartOrder.order_grand_total_before_discount,
          'voucher_assign_id': currentCartOrder.voucherAppliedID,
          'voucher_applied_successfully': voucherAppliedSuccessfullySubmit,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (kDebugMode) {
          print("Edit Order Successful.");
        }
        return (true, ErrorCodes.OPERATION_OK);
      } else {
        if (kDebugMode) {
          print(response.body);
          print('Failed to edit order.');
        }
        return (false, (ErrorCodes.EDIT_ORDER_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.EDIT_ORDER_FAIL_API_CONNECTION));
    }
  }

  Future<List<Voucher>> getVoucherAppliedDetails(int voucherAppliedID) async {
    try {
      final response = await http.get(
        // Uri.parse('http://10.0.2.2:8000/order/request_voucher_applied_details/$voucherAppliedID/'),
        Uri.parse('${IpAddress.ip_addr}/order/request_voucher_applied_details/$voucherAppliedID/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Voucher.getVoucherAppliedDetails(jsonDecode(response.body));
      } else {
        throw Exception('Failed to edit order by user.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }
}
