import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:keninacafecust_web/Entity/OrderFoodItemMoreInfo.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../AppsBar.dart';
import '../Entity/Cart.dart';
import '../Entity/MenuItem.dart';
import '../Entity/User.dart';
import '../Utils/ip_address.dart';
import 'menuHome.dart';

void main() {
  runApp(const MyApp());
}

void enterFullScreen() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MenuItemDetailsPage(user: null, menuItem: null, cart: null, orderMode: null, orderHistory: null, tableNo: null, tabIndex: null, menuItemList: null, itemCategoryList: null),
    );
  }
}

class MenuItemDetailsPage extends StatefulWidget {
  const MenuItemDetailsPage({super.key, this.user, this.menuItem, this.cart, this.orderMode, this.orderHistory, this.tableNo, this.tabIndex, this.menuItemList, this.itemCategoryList});

  final User? user;
  final MenuItem? menuItem;
  final Cart? cart;
  final String? orderMode;
  final List<int>? orderHistory;
  final String? tableNo;
  final int? tabIndex;
  final List<MenuItem>? menuItemList;
  final List<MenuItem>? itemCategoryList;

  @override
  State<MenuItemDetailsPage> createState() => _MenuItemDetailsPageState();
}

class _MenuItemDetailsPageState extends State<MenuItemDetailsPage> {
  int itemCount = 1;
  Widget? image;
  String base64Image = "";
  String selectedSize = "";
  String selectedVariant = "";
  bool isEditPreviousOrderItemDetails = false;
  List<String> sizeList = [];
  List<String> variantList = [];
  bool hasText = false;
  bool isButtonEnabled = true;
  int numText = 0;
  int maxNumText = 200;
  TextEditingController remarkController = TextEditingController();

  User? getUser() {
    return widget.user;
  }

  MenuItem? getMenuItem() {
    return widget.menuItem;
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
  void initState() {
    super.initState();
    if (getMenuItem()!.hasSize || getMenuItem()!.hasVariant) {
      isButtonEnabled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();
    User? currentUser = getUser();
    MenuItem? currentMenuItem = getMenuItem();
    Cart? currentCart = getCart();
    String? currentOrderMode = getOrderMode();
    List<int>? currentOrderHistory = getOrderHistory();
    String? currentTableNo = getTableNo();
    int? currentTabIndex = getTabIndex();
    List<MenuItem>? currentMenuItemList = getMenuItemStoredList();
    List<MenuItem>? currentItemCategoryList = getItemCategory();

    if (base64Image == "") {
      base64Image = currentMenuItem!.image;
      if (base64Image == "") {
        image = Image.asset('images/KE_Nina_Cafe_logo.jpg', width: 250, height: 250,);
        print("nothing in base64");
      } else {
        image = Image.memory(base64Decode(base64Image), fit: BoxFit.contain, width: 250, height: 250,);
      }
    } else {
      image = Image.memory(base64Decode(base64Image), fit: BoxFit.contain, width: 250, height: 250,);
    }

    if (currentMenuItem!.hasSize) {
      sizeList = currentMenuItem.sizes.split(",");
    }
    if (currentMenuItem.hasVariant){
      variantList = currentMenuItem.variants.split(",");
    }

    remarkController.addListener(() {
      if (remarkController.text.length > 200) {
        remarkController.text = remarkController.text.substring(0, 200);
        remarkController.selection = TextSelection.fromPosition(
          TextPosition(offset: remarkController.text.length),
        );
      }
    });

    if (currentUser?.uid != 18) {
      return FutureBuilder<List<OrderFoodItemMoreInfo>>(
          future: getMenuItemOrderDetailsBefore(currentMenuItem, currentUser!),
          builder: (BuildContext context, AsyncSnapshot<List<OrderFoodItemMoreInfo>> snapshot) {
            if (snapshot.hasData) {
              return snapshot.data![0].id == 0 ? buildMenuItemDetails(currentMenuItem, currentCart!, currentUser, currentOrderMode!, currentOrderHistory!, currentTableNo!, currentTabIndex!, currentMenuItemList!, currentItemCategoryList!) : buildMenuItemDetailsOrderBefore(snapshot.data, currentMenuItem, currentCart!, currentUser, currentOrderMode!, currentOrderHistory!, currentTableNo!, currentTabIndex!, currentMenuItemList!, currentItemCategoryList!);
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
      );
    } else {
      if (currentOrderHistory!.isEmpty) {
        return buildMenuItemDetails(currentMenuItem, currentCart!, currentUser!, currentOrderMode!, currentOrderHistory!, currentTableNo!, currentTabIndex!, currentMenuItemList!, currentItemCategoryList!);
      } else {
        return FutureBuilder<List<OrderFoodItemMoreInfo>>(
            future: getMenuItemOrderDetailsBeforeByGuest(currentOrderHistory[currentOrderHistory.length - 1], currentMenuItem, currentUser!),
            builder: (BuildContext context, AsyncSnapshot<List<OrderFoodItemMoreInfo>> snapshot) {
              if (snapshot.hasData) {
                return snapshot.data![0].id == 0 ? buildMenuItemDetails(currentMenuItem, currentCart!, currentUser, currentOrderMode!, currentOrderHistory!, currentTableNo!, currentTabIndex!, currentMenuItemList!, currentItemCategoryList!) : buildMenuItemDetailsOrderBefore(snapshot.data, currentMenuItem, currentCart!, currentUser, currentOrderMode!, currentOrderHistory!, currentTableNo!, currentTabIndex!, currentMenuItemList!, currentItemCategoryList!);
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
        );
      }
    }
  }

  Widget buildMenuItemDetails (MenuItem currentMenuItem, Cart currentCart, User currentUser, String currentOrderMode, List<int> currentOrderHistory, String currentTableNo, int currentTabIndex, List<MenuItem> currentMenuItemList, List<MenuItem> currentItemCategoryList) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppsBarState().buildMenuItemDetailsAppBar(context, "Item Details", currentUser!),
      body: SafeArea(
        child: SingleChildScrollView (
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15.0,),
                  Container(
                    constraints: const BoxConstraints(
                      maxHeight: double.infinity,
                    ),
                    child: Stack(
                      children: [
                        if (image != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: image,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                currentMenuItem!.name,
                                style: const TextStyle(
                                  fontSize: 25.0,
                                  // fontWeight: FontWeight.bold,
                                  fontFamily: 'YoungSerif',
                                ),
                                overflow: TextOverflow.clip,
                              ),
                            ),
                            if (selectedSize == "Standard" || selectedSize == "")
                              Text(
                                'RM ${currentMenuItem.price_standard.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontFamily: 'Gabarito',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (selectedSize == "Large")
                              Text(
                                'RM ${currentMenuItem.price_large.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontFamily: 'Gabarito',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          currentMenuItem.description,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 15.0,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            const Icon(
                              Icons.shopping_cart_outlined,
                              size: 28,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '1.4k',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              height: 30,
                              width: 120,
                              child: Material(
                                  color: Colors.green.shade400,
                                  elevation: 10.0, // Add elevation to simulate a border
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: Colors.grey.shade300, // Border color
                                      width: 5.0, // Border width
                                    ),
                                  ),
                                  child: const Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Available",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        if (currentMenuItem.hasVariant)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.grey.shade500,
                                width: 2.0,
                              ),
                            ),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                                      child: Row(
                                        children: [
                                          const Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              'Choose the variant',
                                              style: TextStyle(
                                                fontSize: 20.5,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Rajdhani',
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          if (selectedVariant == "")
                                            SizedBox(
                                              height: 20,
                                              width: 70,
                                              child: Material(
                                                  elevation: 3.0, // Add elevation to simulate a border
                                                  shape: RoundedRectangleBorder(
                                                    side: const BorderSide(
                                                      color: Colors.red, // Border color
                                                      width: 2.0, // Border width
                                                    ),
                                                    borderRadius: BorderRadius.circular(200), // Apply border radius if needed
                                                  ),
                                                  child: const Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "Required",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 9.0,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  )
                                              ),
                                            )
                                          else if (selectedVariant != "")
                                            SizedBox(
                                              height: 20,
                                              width: 70,
                                              child: Material(
                                                // elevation: 3.0, // Add elevation to simulate a border
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                      color: Colors.grey.shade700, // Border color
                                                      width: 2.0, // Border width
                                                    ),
                                                    borderRadius: BorderRadius.circular(200), // Apply border radius if needed
                                                  ),
                                                  child: const Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "Completed",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 9.0,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  )
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                    RadioListTile(
                                      contentPadding: EdgeInsets.zero,
                                      visualDensity: const VisualDensity(horizontal: -4.0),
                                      dense: true,
                                      activeColor: Colors.red,
                                      selectedTileColor: Colors.red,
                                      title: Text(
                                        variantList[0],
                                        // style: TextStyle(
                                        //   color: Colors.black,
                                        // ),
                                      ),
                                      value: variantList[0],
                                      groupValue: selectedVariant,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedVariant = value.toString();
                                          currentMenuItem.variantChosen = selectedVariant;
                                          if (currentMenuItem.hasSize && selectedSize != "") {
                                            isButtonEnabled = true;
                                          } else if (currentMenuItem.hasSize && selectedSize == "") {
                                            isButtonEnabled = false;
                                          } else if (!currentMenuItem.hasSize) {
                                            isButtonEnabled = true;
                                          }
                                        });
                                      },
                                    ),
                                    RadioListTile(
                                      contentPadding: EdgeInsets.zero,
                                      visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
                                      dense: true,
                                      activeColor: Colors.red,
                                      selectedTileColor: Colors.red,
                                      title: Text(
                                        variantList[1],
                                        // style: TextStyle(
                                        //   color: Colors.black,
                                        // ),
                                      ),
                                      value: variantList[1],
                                      groupValue: selectedVariant,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedVariant = value.toString();
                                          currentMenuItem.variantChosen = selectedVariant;
                                          if (currentMenuItem.hasSize && selectedSize != "") {
                                            isButtonEnabled = true;
                                          } else if (currentMenuItem.hasSize && selectedSize == "") {
                                            isButtonEnabled = false;
                                          } else if (!currentMenuItem.hasSize) {
                                            isButtonEnabled = true;
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                )
                            ),
                          ),
                        if (currentMenuItem.hasVariant)
                          const SizedBox(height: 20.0),
                        if (currentMenuItem.hasSize)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.grey.shade500,
                                width: 2.0,
                              ),
                            ),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                                      child: Row(
                                        children: [
                                          const Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              'Choose the size',
                                              style: TextStyle(
                                                fontSize: 20.5,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Rajdhani',
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          if (selectedSize == "")
                                            SizedBox(
                                              height: 20,
                                              width: 70,
                                              child: Material(
                                                  elevation: 3.0, // Add elevation to simulate a border
                                                  shape: RoundedRectangleBorder(
                                                    side: const BorderSide(
                                                      color: Colors.red, // Border color
                                                      width: 2.0, // Border width
                                                    ),
                                                    borderRadius: BorderRadius.circular(200), // Apply border radius if needed
                                                  ),
                                                  child: const Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "Required",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 9.0,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  )
                                              ),
                                            )
                                          else if (selectedSize != "")
                                            SizedBox(
                                              height: 20,
                                              width: 70,
                                              child: Material(
                                                // elevation: 3.0, // Add elevation to simulate a border
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                      color: Colors.grey.shade700, // Border color
                                                      width: 2.0, // Border width
                                                    ),
                                                    borderRadius: BorderRadius.circular(200), // Apply border radius if needed
                                                  ),
                                                  child: const Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "Completed",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 9.0,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  )
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                    RadioListTile(
                                      contentPadding: EdgeInsets.zero,
                                      visualDensity: const VisualDensity(horizontal: -4.0),
                                      dense: true,
                                      activeColor: Colors.red,
                                      selectedTileColor: Colors.red,
                                      title: Text(
                                        sizeList[0],
                                        // style: TextStyle(
                                        //   color: Colors.black,
                                        // ),
                                      ),
                                      value: sizeList[0],
                                      groupValue: selectedSize,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedSize = value.toString();
                                          currentMenuItem.sizeChosen = value.toString();
                                          if (currentMenuItem.hasVariant && selectedVariant != "") {
                                            isButtonEnabled = true;
                                          } else if (currentMenuItem.hasVariant && selectedVariant == "") {
                                            isButtonEnabled = false;
                                          } else if (!currentMenuItem.hasVariant) {
                                            isButtonEnabled = true;
                                          }
                                        });
                                      },
                                    ),
                                    RadioListTile(
                                      contentPadding: EdgeInsets.zero,
                                      visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
                                      dense: true,
                                      activeColor: Colors.red,
                                      selectedTileColor: Colors.red,
                                      title: Text(
                                        sizeList[1],
                                        // style: TextStyle(
                                        //   color: Colors.black,
                                        // ),
                                      ),
                                      value: sizeList[1],
                                      groupValue: selectedSize,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedSize = value.toString();
                                          currentMenuItem.sizeChosen = value.toString();
                                          if (currentMenuItem.hasVariant && selectedVariant != "") {
                                            isButtonEnabled = true;
                                          } else if (currentMenuItem.hasVariant && selectedVariant == "") {
                                            isButtonEnabled = false;
                                          } else if (!currentMenuItem.hasVariant) {
                                            isButtonEnabled = true;
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                )
                            ),
                          ),
                        if (currentMenuItem.hasSize)
                          const SizedBox(height: 20.0),
                        const Divider(),
                        const SizedBox(height: 10.0),
                        const Text(
                          'Remarks',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            // fontFamily: 'Rajdhani',
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          'Please let us know if you are allergic to anything or if we need to avoid anything',
                          style: TextStyle(
                            fontSize: 13.0,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 10.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10.0),
                          child: TextFormField(
                            controller: remarkController,
                            maxLines: null,
                            onChanged: (text) {
                              setState(() {
                                hasText = text.isNotEmpty;
                                numText = remarkController.text.length;
                                currentMenuItem.remarks = remarkController.text;
                              });
                            },
                            decoration: InputDecoration(
                              // hintText: 'e.g. no onion',
                              // hintStyle: TextStyle(color: Colors.grey.shade400),
                              labelText: 'e.g. no onion',
                              labelStyle: TextStyle(color: Colors.grey.shade400),
                              floatingLabelStyle: const TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: hasText ? Colors.black : Colors.grey.shade400, width: 1.0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black, width: 1.0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              // errorBorder: OutlineInputBorder( // Border style for error state
                              //   borderRadius: BorderRadius.circular(12.0),
                              //   borderSide: const BorderSide(color: Colors.red, width: 4.0,),
                              // ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 18),
                            ),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            '${numText}/${maxNumText}',
                            style: TextStyle(
                              fontSize: 13.0,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 70,
        child: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Container(
                      // padding: const EdgeInsets.all(3),
                      // decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(5),
                      //     color: Colors.red,
                      // ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (itemCount > 1) {
                                setState(() {
                                  itemCount--;
                                });
                              }
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              padding: const EdgeInsets.all(2),
                              child: const Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5.0,),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: Colors.transparent,
                            ),
                            child: Text(
                              itemCount.toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 23,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5.0,),
                          InkWell(
                            onTap: () {
                              setState(() {
                                itemCount++;
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle, // Make the container circular
                                color: Colors.green, // Set the background color
                              ),
                              padding: const EdgeInsets.all(2), // Adjust padding as needed
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: SizedBox(
                  width: 220,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: isButtonEnabled ? () {
                      // setState(() {
                        currentCart!.addToCart(itemCount, currentMenuItem);
                        // Navigator.of(context).pop();
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MenuHomePage(user: currentUser, cart: currentCart, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: currentTabIndex, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList,))
                        );
                      // });
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade500, // Set your desired background color here
                    ),
                    child: const Text(
                      "Add to cart",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuItemDetailsOrderBefore (List<OrderFoodItemMoreInfo>? currentMenuItemMoreInfo, MenuItem currentMenuItem, Cart currentCart, User currentUser, String currentOrderMode, List<int> currentOrderHistory, String currentTableNo, int currentTabIndex, List<MenuItem> currentMenuItemList, List<MenuItem> currentItemCategoryList) {
    if (!isEditPreviousOrderItemDetails) {
      remarkController.text = currentMenuItemMoreInfo![0].remarks;
      selectedVariant = currentMenuItemMoreInfo[0].variant;
      selectedSize = currentMenuItemMoreInfo[0].size;
      isButtonEnabled = true;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppsBarState().buildMenuItemDetailsAppBar(context, "Item Details", currentUser!),
      body: SafeArea(
        child: SingleChildScrollView (
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15.0,),
                  Container(
                    constraints: const BoxConstraints(
                      maxHeight: double.infinity,
                    ),
                    child: Stack(
                      children: [
                        if (image != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: image,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                currentMenuItemMoreInfo![0].menu_item_name,
                                style: const TextStyle(
                                  fontSize: 25.0,
                                  // fontWeight: FontWeight.bold,
                                  fontFamily: 'YoungSerif',
                                ),
                                overflow: TextOverflow.clip,
                              ),
                            ),
                            if (selectedSize == "Standard" || selectedSize == "")
                              Text(
                                'RM ${currentMenuItemMoreInfo[0].menu_item_price_standard.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontFamily: 'Gabarito',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (selectedSize == "Large")
                              Text(
                                'RM ${currentMenuItemMoreInfo[0].menu_item_price_large.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontFamily: 'Gabarito',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          currentMenuItem.description,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 15.0,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            const Icon(
                              Icons.shopping_cart_outlined,
                              size: 28,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '1.4k',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              height: 30,
                              width: 120,
                              child: Material(
                                  color: Colors.green.shade400,
                                  elevation: 10.0, // Add elevation to simulate a border
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: Colors.grey.shade300, // Border color
                                      width: 5.0, // Border width
                                    ),
                                  ),
                                  child: const Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Available",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        if (currentMenuItem.hasVariant)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.grey.shade500,
                                width: 2.0,
                              ),
                            ),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                                      child: Row(
                                        children: [
                                          const Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              'Choose the variant',
                                              style: TextStyle(
                                                fontSize: 20.5,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Rajdhani',
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          if (selectedVariant == "")
                                            SizedBox(
                                              height: 20,
                                              width: 70,
                                              child: Material(
                                                  elevation: 3.0, // Add elevation to simulate a border
                                                  shape: RoundedRectangleBorder(
                                                    side: const BorderSide(
                                                      color: Colors.red, // Border color
                                                      width: 2.0, // Border width
                                                    ),
                                                    borderRadius: BorderRadius.circular(200), // Apply border radius if needed
                                                  ),
                                                  child: const Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "Required",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 9.0,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  )
                                              ),
                                            )
                                          else if (selectedVariant != "")
                                            SizedBox(
                                              height: 20,
                                              width: 70,
                                              child: Material(
                                                // elevation: 3.0, // Add elevation to simulate a border
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                      color: Colors.grey.shade700, // Border color
                                                      width: 2.0, // Border width
                                                    ),
                                                    borderRadius: BorderRadius.circular(200), // Apply border radius if needed
                                                  ),
                                                  child: const Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "Completed",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 9.0,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  )
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                    RadioListTile(
                                      contentPadding: EdgeInsets.zero,
                                      visualDensity: const VisualDensity(horizontal: -4.0),
                                      dense: true,
                                      activeColor: Colors.red,
                                      selectedTileColor: Colors.red,
                                      title: Text(
                                        variantList[0],
                                        // style: TextStyle(
                                        //   color: Colors.black,
                                        // ),
                                      ),
                                      value: variantList[0],
                                      groupValue: selectedVariant,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedVariant = value.toString();
                                          currentMenuItem.variantChosen = selectedVariant;
                                          isEditPreviousOrderItemDetails = true;
                                        });
                                      },
                                    ),
                                    RadioListTile(
                                      contentPadding: EdgeInsets.zero,
                                      visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
                                      dense: true,
                                      activeColor: Colors.red,
                                      selectedTileColor: Colors.red,
                                      title: Text(
                                        variantList[1],
                                        // style: TextStyle(
                                        //   color: Colors.black,
                                        // ),
                                      ),
                                      value: variantList[1],
                                      groupValue: selectedVariant,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedVariant = value.toString();
                                          currentMenuItem.variantChosen = selectedVariant;
                                          isEditPreviousOrderItemDetails = true;
                                        });
                                      },
                                    ),
                                  ],
                                )
                            ),
                          ),
                        if (currentMenuItem.hasVariant)
                          const SizedBox(height: 20.0),
                        if (currentMenuItem.hasSize)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.grey.shade500,
                                width: 2.0,
                              ),
                            ),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                                      child: Row(
                                        children: [
                                          const Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              'Choose the size',
                                              style: TextStyle(
                                                fontSize: 20.5,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Rajdhani',
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          if (selectedSize == "")
                                            SizedBox(
                                              height: 20,
                                              width: 70,
                                              child: Material(
                                                  elevation: 3.0, // Add elevation to simulate a border
                                                  shape: RoundedRectangleBorder(
                                                    side: const BorderSide(
                                                      color: Colors.red, // Border color
                                                      width: 2.0, // Border width
                                                    ),
                                                    borderRadius: BorderRadius.circular(200), // Apply border radius if needed
                                                  ),
                                                  child: const Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "Required",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 9.0,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  )
                                              ),
                                            )
                                          else if (selectedSize != "")
                                            SizedBox(
                                              height: 20,
                                              width: 70,
                                              child: Material(
                                                // elevation: 3.0, // Add elevation to simulate a border
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                      color: Colors.grey.shade700, // Border color
                                                      width: 2.0, // Border width
                                                    ),
                                                    borderRadius: BorderRadius.circular(200), // Apply border radius if needed
                                                  ),
                                                  child: const Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "Completed",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 9.0,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  )
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                    RadioListTile(
                                      contentPadding: EdgeInsets.zero,
                                      visualDensity: const VisualDensity(horizontal: -4.0),
                                      dense: true,
                                      activeColor: Colors.red,
                                      selectedTileColor: Colors.red,
                                      title: Text(
                                        sizeList[0],
                                        // style: TextStyle(
                                        //   color: Colors.black,
                                        // ),
                                      ),
                                      value: sizeList[0],
                                      groupValue: selectedSize,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedSize = value.toString();
                                          currentMenuItem.sizeChosen = value.toString();
                                          isEditPreviousOrderItemDetails = true;
                                        });
                                      },
                                    ),
                                    RadioListTile(
                                      contentPadding: EdgeInsets.zero,
                                      visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
                                      dense: true,
                                      activeColor: Colors.red,
                                      selectedTileColor: Colors.red,
                                      title: Text(
                                        sizeList[1],
                                        // style: TextStyle(
                                        //   color: Colors.black,
                                        // ),
                                      ),
                                      value: sizeList[1],
                                      groupValue: selectedSize,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedSize = value.toString();
                                          currentMenuItem.sizeChosen = value.toString();
                                          isEditPreviousOrderItemDetails = true;
                                        });
                                      },
                                    ),
                                  ],
                                )
                            ),
                          ),
                        if (currentMenuItem.hasSize)
                          const SizedBox(height: 20.0),
                        const Divider(),
                        const SizedBox(height: 10.0),
                        const Text(
                          'Remarks',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            // fontFamily: 'Rajdhani',
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          'Please let us know if you are allergic to anything or if we need to avoid anything',
                          style: TextStyle(
                            fontSize: 13.0,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 10.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10.0),
                          child: TextFormField(
                            controller: remarkController,
                            maxLines: null,
                            onChanged: (text) {
                              setState(() {
                                hasText = text.isNotEmpty;
                                numText = remarkController.text.length;
                                currentMenuItem.remarks = remarkController.text;
                                isEditPreviousOrderItemDetails = true;
                              });
                            },
                            decoration: InputDecoration(
                              // hintText: 'e.g. no onion',
                              // hintStyle: TextStyle(color: Colors.grey.shade400),
                              labelText: 'e.g. no onion',
                              labelStyle: TextStyle(color: Colors.grey.shade400),
                              floatingLabelStyle: const TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: hasText ? Colors.black : Colors.grey.shade400, width: 1.0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black, width: 1.0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              // errorBorder: OutlineInputBorder( // Border style for error state
                              //   borderRadius: BorderRadius.circular(12.0),
                              //   borderSide: const BorderSide(color: Colors.red, width: 4.0,),
                              // ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 18),
                            ),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            '${numText}/${maxNumText}',
                            style: TextStyle(
                              fontSize: 13.0,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 70,
        child: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Container(
                      // padding: const EdgeInsets.all(3),
                      // decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(5),
                      //     color: Colors.red,
                      // ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (itemCount > 1) {
                                setState(() {
                                  itemCount--;
                                });
                              }
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              padding: const EdgeInsets.all(2),
                              child: const Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5.0,),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: Colors.transparent,
                            ),
                            child: Text(
                              itemCount.toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 23,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5.0,),
                          InkWell(
                            onTap: () {
                              setState(() {
                                itemCount++;
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle, // Make the container circular
                                color: Colors.green, // Set the background color
                              ),
                              padding: const EdgeInsets.all(2), // Adjust padding as needed
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: SizedBox(
                  width: 220,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: isButtonEnabled ? () {
                      setState(() {
                        currentMenuItem.variantChosen = selectedVariant;
                        currentMenuItem.sizeChosen = selectedSize;
                        currentMenuItem.remarks = remarkController.text;
                        currentCart!.addToCart(itemCount, currentMenuItem);
                        // Navigator.of(context).pop();
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MenuHomePage(user: currentUser, cart: currentCart, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: currentTabIndex, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList,))
                        );
                      });
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade500,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0), // Adjust the value as needed
                      ),
                    ),
                    child: const Text(
                      "Add to cart",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<OrderFoodItemMoreInfo>> getMenuItemOrderDetailsBefore(MenuItem currentMenuItem, User currentUser) async {
    try {
      final response = await http.post(
        Uri.parse('${IpAddress.ip_addr}/order/request_menu_item_order_details_before'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'current_menu_item_id': currentMenuItem.id,
          'user_id': currentUser.uid,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return OrderFoodItemMoreInfo.getOrderFoodItemDataList(jsonDecode(response.body));
      } else {
        var jsonResp = jsonDecode(response.body);
        var error = jsonResp['error'];
        if (kDebugMode) {
          print('Failed to get the menu item details ordered before.');
        }
        if (error == "This menu item is not ordered before by the user.") {
          return ([OrderFoodItemMoreInfo(id: 0, remarks: "", size: "", variant: "", is_done: false, food_order: 0, menu_item_image: "", menu_item_name: "", menu_item_price_standard: 0, menu_item_price_large: 0, numOrder: 0)]);
        } else {
          return ([OrderFoodItemMoreInfo(id: 0, remarks: "", size: "", variant: "", is_done: false, food_order: 0, menu_item_image: "", menu_item_name: "", menu_item_price_standard: 0, menu_item_price_large: 0, numOrder: 0)]);
        }
        throw Exception('Failed to load the order history list of the current user.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }

  Future<List<OrderFoodItemMoreInfo>> getMenuItemOrderDetailsBeforeByGuest(int foodOrderID, MenuItem currentMenuItem, User currentUser) async {
    try {
      final response = await http.post(
        Uri.parse('${IpAddress.ip_addr}/order/request_menu_item_order_details_before_by_guest'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'food_order_id': foodOrderID,
          'current_menu_item_id': currentMenuItem.id,
          'user_id': currentUser.uid,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return OrderFoodItemMoreInfo.getOrderFoodItemDataList(jsonDecode(response.body));
      } else {
        var jsonResp = jsonDecode(response.body);
        var error = jsonResp['error'];
        if (kDebugMode) {
          print('Failed to get the menu item details ordered before.');
        }
        if (error == "This menu item is not ordered before by the user.") {
          return ([OrderFoodItemMoreInfo(id: 0, remarks: "", size: "", variant: "", is_done: false, food_order: 0, menu_item_image: "", menu_item_name: "", menu_item_price_standard: 0, menu_item_price_large: 0, numOrder: 0)]);
        } else {
          return ([OrderFoodItemMoreInfo(id: 0, remarks: "", size: "", variant: "", is_done: false, food_order: 0, menu_item_image: "", menu_item_name: "", menu_item_price_standard: 0, menu_item_price_large: 0, numOrder: 0)]);
        }
        throw Exception('Failed to load the order history list of the current user.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }
}