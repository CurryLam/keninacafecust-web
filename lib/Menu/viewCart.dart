import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keninacafecust_web/AppsBar.dart';
import 'package:http/http.dart' as http;

import 'package:keninacafecust_web/Menu/menuHome.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../Entity/Cart.dart';
import '../Entity/MenuItem.dart';
import '../Entity/User.dart';
import '../Order/orderOverview.dart';

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
      home: const ViewCartPage(user: null, cart: null, orderMode: null, orderHistory: null, tableNo: null, tabIndex: null, menuItemList: null, itemCategoryList: null),
    );
  }
}

class ViewCartPage extends StatefulWidget {
  const ViewCartPage({super.key, this.user, this.cart, this.orderMode, this.orderHistory, this.tableNo, this.tabIndex, this.menuItemList, this.itemCategoryList});

  final User? user;
  final Cart? cart;
  final String? orderMode;
  final List<int>? orderHistory;
  final String? tableNo;
  final int? tabIndex;
  final List<MenuItem>? menuItemList;
  final List<MenuItem>? itemCategoryList;
  // final List<MenuItem>? bestSellingFoods;
  // final List<MenuItem>? bestSellingDrinks;

  @override
  State<ViewCartPage> createState() => _ViewCartPageState();
}

class _ViewCartPageState extends State<ViewCartPage> {
  Widget? image;
  String base64Image = "";
  bool hasMenuItem = false;
  bool orderCreated = false;
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

  String? getTableNo() {
    return widget.tableNo;
  }

  int? getTabIndex() {
    return widget.tabIndex;
  }

  List<MenuItem>? getMenuItemList() {
    return widget.menuItemList;
  }

  List<MenuItem>? getItemCategory() {
    return widget.itemCategoryList;
  }

  // List<MenuItem>? getBestSellingFoods() {
  //   return widget.bestSellingFoods;
  // }
  //
  // List<MenuItem>? getBestSellingDrinks() {
  //   return widget.bestSellingDrinks;
  // }

  void showConfirmationRemoveItemFromCart(Cart currentCart, MenuItem currentMenuItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: Text('Confirm to remove this item (${currentMenuItem.name})?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  Navigator.of(context).pop();
                  currentCart?.removeFromCart(currentMenuItem);
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

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    Cart? currentCart = getCart();
    String? currentOrderMode = getOrderMode();
    List<int>? currentOrderHistory = getOrderHistory();
    String? currentTableNo = getTableNo();
    int? currentTabIndex = getTabIndex();
    List<MenuItem>? currentMenuItemList = getMenuItemList();
    List<MenuItem>? currentItemCategoryList = getItemCategory();
    // List<MenuItem>? currentBestSellingFoods = getBestSellingFoods();
    // List<MenuItem>? currentBestSellingDrinks = getBestSellingDrinks();
    hasMenuItem = currentCart!.containMenuItem();

    return Scaffold(
      appBar: AppsBarState().buildCartAppBar(context, "MY CART", currentUser!, currentCart, currentOrderMode!, currentOrderHistory!, currentTableNo, currentTabIndex!, currentMenuItemList!, currentItemCategoryList!),
      drawer: AppsBarState().buildDrawer(context, currentUser!, currentCart!, isMenuHomePage, currentOrderMode, currentOrderHistory, currentTableNo!, currentTabIndex, currentMenuItemList, currentItemCategoryList),
      body: SafeArea(
        child: SingleChildScrollView (
          child: SizedBox(
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FutureBuilder<List<MenuItem>>(
                        future: getCartList(hasMenuItem, currentCart!),
                        builder: (BuildContext context, AsyncSnapshot<List<MenuItem>> snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              children: buildCartList(snapshot.data, currentUser, currentCart, currentOrderMode, currentOrderHistory, currentTableNo!, currentTabIndex, currentMenuItemList, currentItemCategoryList),
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: hasMenuItem == true
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 13, 20, 10),
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
                  Text(
                    'MYR ${currentCart.getGrandTotalBeforeDiscount().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22.0,
                      fontFamily: 'Gabarito',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
              child: Container(
                padding: const EdgeInsets.only(top: 3, left: 3),
                child: MaterialButton(
                  minWidth: double.infinity,
                  height: 50,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => OrderOverviewPage(user: currentUser, cart: currentCart, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: currentTabIndex, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList,))
                    );
                  },
                  color: Colors.orange.shade500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    'Checkout',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
            : Container(height: 0),
      ),
      backgroundColor: Colors.grey.shade100,
    );
  }

  List<Widget> buildCartList(List<MenuItem>? listCart, User? currentUser, Cart? currentCart, String currentOrderMode, List<int> currentOrderHistory, String currentTableNo, int currentTabIndex, List<MenuItem> currentMenuItemList, List<MenuItem> currentItemCategoryList) {
    List<Widget> cards = [];
    if (listCart!.isEmpty) {
      hasMenuItem = true;
      cards.add(
        Column(
          mainAxisAlignment: MainAxisAlignment.center, // Vertically center the content
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 70, 0, 10),
              child: Image.asset(
                "images/emptyCart.png",
                // fit: BoxFit.cover,
                // height: 500,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                child: Text(
                  "Cart is Empty",
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
                  "You haven't added anything to your cart",
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
                padding: const EdgeInsets.only(top: 3,left: 3),
                child: MaterialButton(
                  minWidth: double.infinity,
                  height:50,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MenuHomePage(user: currentUser, cart: currentCart, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: currentTabIndex, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList))
                    );
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) => MenuHomePage())
                    // );
                  },
                  color: Colors.white,
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.orangeAccent, // Border color
                      width: 5.0, // Border width
                    ),
                  ),
                  child: const Text(
                    "Menu",
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
    }
    else {
      cards.add(
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5.0),
        ),
      );
      for (MenuItem a in listCart!) {
        if (a.image == "") {
          image = Image.asset('images/supplierLogo.jpg', width: 120, height: 120,);
        } else {
          image = Image.memory(base64Decode(a.image), width: 120, height: 120,);
        }
        cards.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5.0),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                // side: BorderSide(
                //   color: Colors.blueGrey, // Border color
                //   width: 2.0, // Border width
                // ),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    a.name,
                                    style: const TextStyle(
                                      fontSize: 15.0,
                                      fontFamily: 'YoungSerif',
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.grey.shade300),
                                      onPressed: () async {
                                        setState(() {
                                          showConfirmationRemoveItemFromCart(currentCart!, a);
                                        });
                                      },
                                      child: Icon(
                                        Icons.delete,
                                        size: 22.0,
                                        color: Colors.grey.shade700,
                                      ),
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
                                  if (a.variantChosen != "")
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
                                          a.variantChosen,
                                          style: const TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.black,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (a.variantChosen != "")
                                    const SizedBox(width: 10.0),
                                  if (a.sizeChosen != "")
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
                                          a.sizeChosen,
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
                            if (a.hasSize && a.sizeChosen == "Large")
                              Text(
                                'MYR ${(a.price_large*a.numOrder).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  fontFamily: 'BreeSerif',
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (!a.hasSize || a.sizeChosen == "Standard")
                              Text(
                                'MYR ${(a.price_standard*a.numOrder).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  fontFamily: 'BreeSerif',
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (a.variantChosen == "" && a.sizeChosen == "")
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
                                      if (a.numOrder == 1) {
                                        setState(() {
                                          currentCart?.removeFromCart(a);
                                        });
                                      } else {
                                        setState(() {
                                          currentCart?.reduceNumOrderOfMenuItem(a);
                                        });
                                      }
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
                                    a.numOrder.toString(),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 10), // Add spacing between buttons
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        currentCart?.addToCart(1, a);
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

  Future<List<MenuItem>> getCartList(bool hasMenuItem, Cart currentCart) async {
    if (currentCart.getMenuItemList().isNotEmpty) {
      hasMenuItem = true;
    }
    return currentCart.getMenuItemList();
  }
}
