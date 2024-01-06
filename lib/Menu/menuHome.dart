import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:keninacafecust_web/AppsBar.dart';
import 'package:keninacafecust_web/Entity/Cart.dart';
import 'package:keninacafecust_web/Menu/viewCart.dart';
import '../Entity/MenuItem.dart';
import '../Entity/User.dart';
import 'menuItemDetails.dart';

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
      home: const MenuHomePage(user: null, cart: null, orderMode: null, orderHistory: null, tableNo: null, tabIndex: null, menuItemList: null, itemCategoryList: null),
      // home: const MenuHomePage(),
    );
  }
}

class MenuHomePage extends StatefulWidget {
  const MenuHomePage({super.key, this.user, this.cart, this.orderMode, this.orderHistory, this.tableNo, this.tabIndex, this.menuItemList, this.itemCategoryList});

  final User? user;
  final Cart? cart;
  final String? orderMode;
  final List<int>? orderHistory;
  final int? tableNo;
  final int? tabIndex;
  final List<MenuItem>? menuItemList;
  final List<MenuItem>? itemCategoryList;
  // final List<MenuItem>? bestSellingFoods;
  // final List<MenuItem>? bestSellingDrinks;

  @override
  State<MenuHomePage> createState() => _MenuHomePageState();
}

class _MenuHomePageState extends State<MenuHomePage> with SingleTickerProviderStateMixin{
  int selectedTabIndex = 1000;
  int numItemCategory = 6;
  bool searchBoolean = false;
  List<MenuItem>? menuItem;
  List<String> bestSeller = ['Best Selling Foods', 'Best Selling Drinks'];
  List<String> bestSellerCategoryImage = ['images/best_selling_food.png', 'images/best_selling_drink.png'];
  // List<MenuItem>? bestSellingFoods;
  // List<MenuItem>? bestSellingDrinks;
  List<MenuItem>? itemCategoryList;
  List<MenuItem>? menuItemList;
  String? categoryName;
  String? tempCategoryName;
  List<int> _searchIndexList = [];
  List<MenuItem>? searchMenuItem = [];
  int itemCount = 0;
  double totalPrice = 0.0;
  bool isMenuHomePage = true;
  Widget? image;
  String base64Image = "";
  List<MenuItem>? menuItems;


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

  void navigateMenuItemDetailsPage(MenuItem currentMenuItem, Cart currentCart, User currentUser, String currentOrderMode, List<int> currentOrderHistory, int currentTableNo, int selectedTabIndex, List<MenuItem> currentMenuItemList, List<MenuItem> currentItemCategoryList){
    Route route = MaterialPageRoute(builder: (context) => MenuItemDetailsPage(cart: currentCart, user: currentUser, menuItem: currentMenuItem, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: selectedTabIndex, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList,));
    Navigator.push(context, route).then(onGoBack);
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    // User? currentUser = User(uid: 1, name: "Goh Chee Lam", is_active: true, email: "clgoh0726@gmail.com", phone: "0165507208", gender: "Male", dob: DateTime.parse("2001-07-26 00:00:00.000000"), points: 1000);
    // Cart? currentCart = Cart(id: 0, menuItem: [], numMenuItemOrder: 0, grandTotalBeforeDiscount: 0, grandTotalAfterDiscount: 0, price_discount: 0, voucherAppliedID: 0, voucherApplied_type_name: "", voucherApplied_cost_off: 0, voucherApplied_free_menu_item_name: "", voucherApplied_applicable_menu_item_name: "", voucherApplied_min_spending: 0);

    User? currentUser = getUser();
    Cart? currentCart = getCart();
    String? currentOrderMode = getOrderMode();
    List<int>? currentOrderHistory = getOrderHistory();
    int? currentTableNo = getTableNo();
    if (menuItemList == null || menuItemList!.isEmpty) {
      menuItemList = getMenuItemStoredList();
    }
    if (itemCategoryList == null || itemCategoryList!.isEmpty) {
      itemCategoryList = getItemCategory();
    }
    if (selectedTabIndex == 1000) {
      selectedTabIndex = widget.tabIndex!;
    }

    return (itemCategoryList == null || itemCategoryList!.isEmpty) ? FutureBuilder<List<MenuItem>>(
      future: getItemCategoryList(),
      builder: (BuildContext context, AsyncSnapshot<List<MenuItem>> snapshot) {
        if (snapshot.hasData) {
          itemCategoryList = snapshot.data;
          return FutureBuilder<List<MenuItem>>(
              future: getMenuItemList(),
              builder: (BuildContext context, AsyncSnapshot<List<MenuItem>> snapshot) {
                if (snapshot.hasData) {
                  menuItemList = snapshot.data;
                  return Container(
                    constraints: const BoxConstraints.expand(), // Make the container cover the entire screen
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("images/menuBackground.png"),
                        fit: BoxFit.cover, // This ensures the image covers the entire container
                      ),
                    ),
                    child: DefaultTabController(
                      initialIndex: widget.tabIndex!,
                      length: itemCategoryList!.length + 2,
                      child: Scaffold(
                        backgroundColor: Colors.transparent,
                        appBar: AppBar(
                          iconTheme: const IconThemeData(color: Colors.white, size: 25.0),
                          elevation: 0,
                          toolbarHeight: 85,
                          title: !searchBoolean ?
                          const Row(
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 35.0,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8.0,),
                              Text(
                                "Menu",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 27.0,
                                  fontFamily: 'BreeSerif',
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ) : searchTextField(currentUser!),
                          backgroundColor: Colors.orange.shade500,
                          // centerTitle: true,
                          actions: !searchBoolean
                              ?[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 22),
                              child: IconButton(
                                onPressed: () {
                                  setState(() { //add
                                    searchBoolean = true;
                                    _searchIndexList = [];
                                  });
                                },
                                icon: const Icon(Icons.search, size: 35,),
                              ),
                            ),
                          ]
                              :[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 22),
                              child: IconButton(
                                onPressed: () {
                                  setState(() { //add
                                    searchBoolean = false;
                                  });
                                },
                                icon: const Icon(Icons.clear, size: 35,),
                              ),
                            ),
                          ],
                          bottom: PreferredSize(
                            preferredSize: const Size(106.5,110.5),
                            child: Container(
                              height: 116.5,
                              decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                    bottom: BorderSide(
                                      color: Colors.grey.shade300,
                                    )
                                ),
                                color: Colors.white,
                              ),
                              child: Material(
                                color: Colors.white,
                                child: TabBar(
                                  onTap: (value) {
                                    // setState(() {
                                    print("onTap: (value) " +value.toString());
                                    setState(() {
                                      selectedTabIndex = value;
                                      print('I am here');
                                      print(menuItemList);
                                      print(itemCategoryList);
                                    });
                                    // context.read<MyProvider>().updateSelectedIndex(value);
                                    // });
                                  },
                                  tabs: buildItemCategoryList(itemCategoryList, currentUser),
                                  isScrollable: true,
                                  // indicatorSize: TabBarIndicatorSize.label,
                                  labelPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  // Space between tabs
                                  indicator: BoxDecoration(
                                    color: Colors.orange.shade500,
                                  ),
                                  unselectedLabelColor: Colors.grey.shade600,
                                  labelColor: Colors.orange.shade500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        drawer: AppsBarState().buildDrawer(context, currentUser!, currentCart!, isMenuHomePage, currentOrderMode!, currentOrderHistory!, currentTableNo!, selectedTabIndex, menuItemList!, itemCategoryList!),
                        body: !searchBoolean ? _defaultListView(currentUser!, currentCart!, currentOrderMode!, currentOrderHistory!, currentTableNo!, selectedTabIndex) : _searchListView(currentUser!, currentCart!, currentOrderMode!, currentOrderHistory!, currentTableNo!, selectedTabIndex),
                        floatingActionButton: currentCart.getMenuItemList().isEmpty
                            ? Stack(
                          children: [
                            Positioned(
                              // bottom: 25.0,
                              // right: 16.0,
                              child: FloatingActionButton(
                                backgroundColor: Colors.orange.shade500,
                                onPressed: () async {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) => ViewCartPage(user: currentUser, cart: currentCart, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: selectedTabIndex, menuItemList: menuItemList, itemCategoryList: itemCategoryList))
                                  );
                                  // navigateViewCartPage(currentCart, currentUser);
                                },
                                child: const Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 35,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ) : Container(height: 0,),
                        bottomNavigationBar: Container(
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: currentCart.getMenuItemList().isNotEmpty
                                ? Padding(
                              padding: const EdgeInsets.fromLTRB(20, 5, 20, 15),
                              child: Container(
                                padding: const EdgeInsets.only(top: 3,left: 3),
                                child: MaterialButton(
                                  minWidth: double.infinity,
                                  height:60,
                                  onPressed: () async {
                                    // navigateViewCartPage(currentCart, currentUser);
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) => ViewCartPage(user: currentUser, cart: currentCart, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: selectedTabIndex, menuItemList: menuItemList, itemCategoryList: itemCategoryList))
                                    );
                                  },
                                  color: Colors.orange.shade500,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)
                                  ),
                                  child: Stack(
                                    alignment: Alignment.topLeft,
                                    children: [
                                      FloatingActionButton(
                                        onPressed: () {
                                          // Handle the shopping cart button tap.
                                        },
                                        backgroundColor: Colors.orange.shade500,
                                        elevation: 0.0,
                                        child: const Icon(
                                          Icons.shopping_cart_outlined,
                                          size: 35,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        left: 35,
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            currentCart.getNumMenuItemOrder().toString(),
                                            style: TextStyle(
                                              color: Colors.orange.shade500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(70, 18, 0, 0),
                                        child: Row(
                                          // mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'RM ${currentCart.getGrandTotalBeforeDiscount().toStringAsFixed(2)}', // Replace with the actual total price.
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.5,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const Spacer(),
                                          ],
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.fromLTRB(207, 18, 0, 0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              'VIEW CART',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 16.5,
                                              ),
                                            ),
                                            SizedBox(width: 5.0,),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(0, 0, 0, 3.5),
                                              child: Icon(
                                                Icons.arrow_forward_ios_sharp,
                                                size: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // const Padding(
                                      //   padding: EdgeInsets.fromLTRB(297, 16, 0, 0),
                                      //   child: Row(
                                      //     mainAxisAlignment: MainAxisAlignment.end,
                                      //     children: [
                                      //       Icon(
                                      //         Icons.arrow_forward_ios_sharp,
                                      //         size: 20,
                                      //         color: Colors.white,
                                      //       )
                                      //     ],
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ) : Container(height: 0,)
                        ),
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
    ) : Container(
      constraints: const BoxConstraints.expand(), // Make the container cover the entire screen
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/menuBackground.png"),
          fit: BoxFit.cover, // This ensures the image covers the entire container
        ),
      ),
      child: DefaultTabController(
        initialIndex: selectedTabIndex,
        length: itemCategoryList!.length + 2,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white, size: 25.0),
            elevation: 0,
            toolbarHeight: 85,
            title: !searchBoolean ?
            const Row(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 35.0,
                  color: Colors.white,
                ),
                SizedBox(width: 8.0,),
                Text(
                  "Menu",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 27.0,
                    fontFamily: 'BreeSerif',
                    color: Colors.white,
                  ),
                ),
              ],
            ) : searchTextField(currentUser!),
            backgroundColor: Colors.orange.shade500,
            // centerTitle: true,
            actions: !searchBoolean
                ?[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: IconButton(
                  onPressed: () {
                    setState(() { //add
                      searchBoolean = true;
                      _searchIndexList = [];
                    });
                  },
                  icon: const Icon(Icons.search, size: 35,),
                ),
              ),
            ]
                :[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: IconButton(
                  onPressed: () {
                    setState(() { //add
                      searchBoolean = false;
                    });
                  },
                  icon: const Icon(Icons.clear, size: 35,),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size(106.5,110.5),
              child: Container(
                height: 116.5,
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                      bottom: BorderSide(
                        color: Colors.grey.shade300,
                      )
                  ),
                  color: Colors.white,
                ),
                child: Material(
                  color: Colors.white,
                  child: TabBar(
                    onTap: (value) {
                      // setState(() {
                      print("onTap: (value) " +value.toString());
                      setState(() {
                        selectedTabIndex = value;
                      });
                      // context.read<MyProvider>().updateSelectedIndex(value);
                      // });
                    },
                    tabs: buildItemCategoryList(itemCategoryList, currentUser),
                    isScrollable: true,
                    // indicatorSize: TabBarIndicatorSize.label,
                    labelPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    // Space between tabs
                    indicator: BoxDecoration(
                      color: Colors.orange.shade500,
                    ),
                    unselectedLabelColor: Colors.grey.shade600,
                    labelColor: Colors.orange.shade500,
                  ),
                ),
              ),
            ),
          ),
          drawer: AppsBarState().buildDrawer(context, currentUser!, currentCart!, isMenuHomePage, currentOrderMode!, currentOrderHistory!, currentTableNo!, selectedTabIndex, menuItemList!, itemCategoryList!),
          body: !searchBoolean ? _defaultListView(currentUser!, currentCart!, currentOrderMode!, currentOrderHistory!, currentTableNo!, selectedTabIndex) : _searchListView(currentUser!, currentCart!, currentOrderMode!, currentOrderHistory, currentTableNo!, selectedTabIndex),
          floatingActionButton: currentCart.getMenuItemList().isEmpty
              ? Stack(
            children: [
              Positioned(
                // bottom: 25.0,
                // right: 16.0,
                child: FloatingActionButton(
                  backgroundColor: Colors.orange.shade500,
                  onPressed: () async {
                    print(menuItemList);
                    // print(bestSellingFoods);
                    // print(bestSellingDrinks);
                    print(itemCategoryList);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ViewCartPage(user: currentUser, cart: currentCart, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: selectedTabIndex, menuItemList: menuItemList, itemCategoryList: itemCategoryList))
                    );
                    // navigateViewCartPage(currentCart, currentUser);
                  },
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    size: 35,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ) : Container(height: 0,),
          bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: currentCart.getMenuItemList().isNotEmpty
                  ? Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 15),
                child: Container(
                  padding: const EdgeInsets.only(top: 3,left: 3),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    height:60,
                    onPressed: () async {
                      // navigateViewCartPage(currentCart, currentUser);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ViewCartPage(user: currentUser, cart: currentCart, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: selectedTabIndex, menuItemList: menuItemList, itemCategoryList: itemCategoryList))
                      );
                    },
                    color: Colors.orange.shade500,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: Stack(
                      alignment: Alignment.topLeft,
                      children: [
                        FloatingActionButton(
                          onPressed: () {
                            // Handle the shopping cart button tap.
                          },
                          backgroundColor: Colors.orange.shade500,
                          elevation: 0.0,
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            size: 35,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 35,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              currentCart.getNumMenuItemOrder().toString(),
                              style: TextStyle(
                                color: Colors.orange.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(70, 18, 0, 0),
                          child: Row(
                            // mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'RM ${currentCart.getGrandTotalBeforeDiscount().toStringAsFixed(2)}', // Replace with the actual total price.
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.5,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(207, 18, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'VIEW CART',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16.5,
                                ),
                              ),
                              SizedBox(width: 5.0,),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 3.5),
                                child: Icon(
                                  Icons.arrow_forward_ios_sharp,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // const Padding(
                        //   padding: EdgeInsets.fromLTRB(297, 16, 0, 0),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.end,
                        //     children: [
                        //       Icon(
                        //         Icons.arrow_forward_ios_sharp,
                        //         size: 20,
                        //         color: Colors.white,
                        //       )
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ) : Container(height: 0,)
          ),
        ),
      ),
    );
  }

  List<Widget> buildItemCategoryList(List<MenuItem>? listItemCategory, User? currentUser) {
    for (int i = 0; i < listItemCategory!.length; i++) {
      base64Image = listItemCategory[i]!.image;
      if (!listItemCategory[i].hasImageStored) {
        if (base64Image == "") {
          print("nothing in base64");
        } else {
          image = Image.memory(base64Decode(base64Image), width: 60, height: 60,);
          listItemCategory[i].imageStored = image!;
          listItemCategory[i].hasImageStored = true;
        }
      }
    }

    List<Widget> tabs = [];
    for (int i = 0; i < bestSeller.length; i++) {
      tabs.add(
        SizedBox(
          height: 116.5,
          width: 110,
          child: Tab(
            child: Column(
              children: [
                SizedBox(
                  height: 112.5, // Adjust the height to your desired size
                  width: 110,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                              right: BorderSide(
                                color: Colors.grey.shade300,
                              )
                          ),
                          color: Colors.white,
                        ),
                        height: 112.5,
                        width: 110,
                        child: Column(
                          children: [
                            const SizedBox(height: 7.5),
                            // CircleAvatar(
                            //   // backgroundColor: Colors.grey.shade500,
                            //   // backgroundColor: selectedTabIndex == i
                            //   //     ? Colors.orange.shade500 // Selected tab color
                            //   //     : Colors.grey.shade500,
                            //   radius: 30.0,
                            //   child: Padding(
                            //     padding: const EdgeInsets.all(2),
                            //     // Border radius
                            //     child: ClipOval(
                            //         child: Image.asset(
                            //             'images/KE_Nina_Cafe_logo.jpg')
                            //     ),
                            //   ),
                            // ),
                            ClipOval(
                              child: Image.asset(bestSellerCategoryImage[i], width: 60, height: 60,)

                            ),
                            const SizedBox(height: 5.0),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 2),
                              child: Text(
                                // 'Signature & Must Try',
                                bestSeller[i],
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: 'Gabarito',
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            ),
          ),
        ),
      );
    }
    for (int i = 0; i < listItemCategory!.length; i++) {
      tabs.add(
        SizedBox(
          height: 116.5,
          width: 110,
          child: Tab(
            child: Column(
                children: [
                  SizedBox(
                    height: 112.5, // Adjust the height to your desired size
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                                right: BorderSide(
                                  color: Colors.grey.shade300,
                                )
                            ),
                            color: Colors.white,
                          ),
                          height: 112.5,
                          width: 110, // Adjust the width to your desired size
                          child: Column(
                            children: [
                              const SizedBox(height: 7.5),
                              // CircleAvatar(
                              //   backgroundColor: selectedTabIndex == i + 2
                              //       ? Colors.orange.shade500 // Selected tab color
                              //       : Colors.grey.shade500,
                              //   radius: 30.0,
                              //   child: Padding(
                              //     padding: const EdgeInsets.all(2),
                              //     // Border radius
                              //     child: ClipOval(
                              //         child: Image.asset(
                              //             'images/KE_Nina_Cafe_logo.jpg')
                              //     ),
                              //   ),
                              // ),
                              ClipOval(
                                child: listItemCategory[i].imageStored,
                              ),

                              const SizedBox(height: 5.0),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: Text(
                                  listItemCategory[i].category_name,
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    fontFamily: 'Gabarito',
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
            ),
          ),
        ),
      );
    }
    return tabs;
  }

  List<Widget> buildMenuItemList(List<MenuItem>? listMenuItem, User? currentUser, Cart currentCart, String currentOrderMode, List<int> currentOrderHistory, int currentTableNo, int selectedTabIndex) {
    List<Widget> tabBarView = [];
    tabBarView.add(
      FutureBuilder<List<MenuItem>>(
        future: getBestSellingFoodList(),
        builder: (BuildContext context, AsyncSnapshot<List<MenuItem>> snapshot) {
          if (snapshot.hasData) {
            // bestSellingFoods = snapshot.data;
            return SingleChildScrollView(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(17, 5, 0, 2),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Best Selling Foods',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20.0,
                          fontFamily: 'AsapCondensed',
                        ),
                      ),
                    ),
                  ),
                  for (int i = 0; i < snapshot.data!.length; i += 2)
                    Row(
                      children: [
                        Expanded(
                          child: i < snapshot.data!.length
                              ? buildMenuItemCard(snapshot.data![i], currentUser!, currentCart!, currentOrderMode!, currentOrderHistory!, currentTableNo, selectedTabIndex, menuItemList!, itemCategoryList!)
                              : const SizedBox.shrink(),
                        ),
                        Expanded(
                          child: (i + 1) < snapshot.data!.length
                              ? buildMenuItemCard(snapshot.data![i + 1], currentUser!, currentCart!, currentOrderMode!, currentOrderHistory!, currentTableNo, selectedTabIndex, menuItemList!, itemCategoryList!)
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                ],
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
    );
    tabBarView.add(
      FutureBuilder<List<MenuItem>>(
          future: getBestSellingDrinkList(),
          builder: (BuildContext context, AsyncSnapshot<List<MenuItem>> snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(17, 5, 0, 2),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Best Selling Drinks',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20.0,
                            fontFamily: 'AsapCondensed',
                          ),
                        ),
                      ),
                    ),
                    for (int i = 0; i < snapshot.data!.length; i += 2)
                      Row(
                        children: [
                          Expanded(
                            child: i < snapshot.data!.length
                                ? buildMenuItemCard(snapshot.data![i], currentUser!, currentCart!, currentOrderMode!, currentOrderHistory!, currentTableNo, selectedTabIndex, menuItemList!, itemCategoryList!)
                                : const SizedBox.shrink(),
                          ),
                          Expanded(
                            child: (i + 1) < snapshot.data!.length
                                ? buildMenuItemCard(snapshot.data![i + 1], currentUser!, currentCart!, currentOrderMode!, currentOrderHistory!, currentTableNo, selectedTabIndex, menuItemList!, itemCategoryList!)
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                  ],
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
    );
    for (int i = 0; i < listMenuItem!.length; i++) {
      searchMenuItem?.add(listMenuItem[i]);
      categoryName = listMenuItem[i].category_name;
      if (tempCategoryName != categoryName) {
        tempCategoryName = categoryName;
        tabBarView.add(
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(17, 5, 0, 2),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      listMenuItem[i].category_name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20.0,
                        fontFamily: 'AsapCondensed',
                      ),
                    ),
                  ),
                ),
                for (int j = i; j < listMenuItem.length; j+=2)
                  if (listMenuItem[j].category_name == tempCategoryName)
                    Row(
                      children: [
                        Expanded(
                          child: j < listMenuItem.length
                              ? buildMenuItemCard(listMenuItem[j], currentUser!, currentCart!, currentOrderMode!, currentOrderHistory!, currentTableNo, selectedTabIndex, menuItemList!, itemCategoryList!)
                              : const SizedBox.shrink(),
                        ),
                        Expanded(
                          child: (j + 1) < listMenuItem.length && listMenuItem[j + 1].category_name == tempCategoryName
                              ? buildMenuItemCard(listMenuItem[j + 1], currentUser!, currentCart!, currentOrderMode!, currentOrderHistory!, currentTableNo, selectedTabIndex, menuItemList!, itemCategoryList!)
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
              ],
            ),
          ),
        );
      }
    }
    return tabBarView;
  }

  List<MenuItem>? buildSearchMenuItemList(List<MenuItem>? listMenuItem, User? currentUser) {
    List<MenuItem> menuItem = [];
    for (int i = 0; i < listMenuItem!.length; i++) {
      menuItem?.add(listMenuItem[i]);
    }
    return menuItem;
  }

  Widget searchTextField(User currentUser) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0), // Adjust the radius to make it more or less rounded
        border: Border.all(
          color: Colors.black, // Color of the outline border
          width: 3.0, // Width of the outline border
        ),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
        child: FutureBuilder<List<MenuItem>>(
            future: getMenuItemList(),
            builder: (BuildContext context, AsyncSnapshot<List<MenuItem>> snapshot) {
              if (snapshot.hasData) {
                return TextField(
                  onChanged: (String s) {
                    setState(() {
                      _searchIndexList = [];
                      searchMenuItem = buildSearchMenuItemList(snapshot.data, currentUser);
                      final String lowercaseSearch = s.toLowerCase();
                      if (lowercaseSearch.isNotEmpty) {
                        for (int i = 0; i < searchMenuItem!.length; i++) {
                          final String lowercaseName = searchMenuItem![i].name
                              .toLowerCase();
                          if (lowercaseName.contains(lowercaseSearch)) {
                            _searchIndexList.add(i);
                          }
                        }
                      }
                    });
                  },
                  autofocus: true, //Display the keyboard when TextField is displayed
                  cursorColor: Colors.black54,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 20,
                  ),
                  textInputAction: TextInputAction.search, //Specify the action button on the keyboard
                  decoration: const InputDecoration( //Style of TextField
                    border: InputBorder.none,
                    hintText: 'Search', //Text that is displayed when nothing is entered.
                    hintStyle: TextStyle( //Style of hintText
                      color: Colors.black54,
                      fontSize: 20,
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
      ),
    );
  }

  Widget buildMenuItemCard(MenuItem currentMenuItem, User currentUser, Cart currentCart, String currentOrderMode, List<int> currentOrderHistory, int currentTableNo, int selectedTabIndex, List<MenuItem> currentMenuItemList, List<MenuItem> currentItemCategoryList) {
    base64Image = currentMenuItem!.image;
    if (!currentMenuItem.hasImageStored) {
      if (base64Image == "") {
        image = Image.asset('images/KE_Nina_Cafe_logo.jpg');
        print("nothing in base64");
      } else {
        image = Image.memory(base64Decode(base64Image), fit: BoxFit.contain, width: 250, height: 193,);
        currentMenuItem.imageStored = image!;
        currentMenuItem.hasImageStored = true;
      }
    } else {
      image = currentMenuItem.imageStored;
    }
    // if (base64Image == "") {
    //   image = Image.asset('images/KE_Nina_Cafe_logo.jpg');
    //   print("nothing in base64");
    // } else {
    //   image = Image.memory(base64Decode(base64Image), fit: BoxFit.contain, width: 250, height: 193,);
    // }

    return SizedBox(
      height: 320,
      child: Card(
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(1.5, 2, 1.5, 10.0),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: currentMenuItem.name,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10.0), // Adjust the radius for the top left corner
                    topRight: Radius.circular(10.0), // Adjust the radius for the top right corner
                  ),
                  child: image,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    currentMenuItem.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0,
                      fontFamily: 'Itim',
                    ),
                  ),
                ),
              ),

              const Spacer(),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'RM ${currentMenuItem.price_standard.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 14.0,
                            fontFamily: "Itim"
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 20.0,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 3.0,),
                  Text(
                    currentMenuItem.total_num_ordered.toString(),
                    style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: "Itim",
                        color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 10.0,),
                ],
              ),
              const Spacer(),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: TextButton(
                    onPressed: () {
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) => MenuItemDetailsPage(user: currentUser, menuItem: currentMenuItem, cart: currentCart))
                      // );
                      print("Selected index: " +selectedTabIndex.toString());
                      navigateMenuItemDetailsPage(currentMenuItem, currentCart, currentUser, currentOrderMode, currentOrderHistory, currentTableNo, selectedTabIndex, currentMenuItemList, currentItemCategoryList);
                      setState(() {
                        currentMenuItem.numOrder = 0;
                        currentMenuItem.sizeChosen = "";
                        currentMenuItem.variantChosen = "";
                        currentMenuItem.remarks = "";
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      minimumSize: const Size(50, 15),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.centerLeft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: Colors.green.shade700,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Add',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  // List<Widget> buildBestSellingMenuItemList(List<MenuItem>? listMenuItem, User? currentUser, Cart currentCart) {
  //   List
  // }

  Widget _searchListView(User currentUser, Cart currentCart, String currentOrderMode, List<int> currentOrderHistory, int currentTableNo, int selectedTabIndex) {
    final List<MenuItem> menuItems = _searchIndexList.map((index) {
      // return MenuItem(name: searchMenuItem![index].name, price: searchMenuItem![index].price);
      return searchMenuItem![index];
    }).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(17, 5, 0, 2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Item Search',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20.0,
                  fontFamily: 'AsapCondensed',
                ),
              ),
            ),
          ),
          for (int i = 0; i < menuItems.length; i += 2)
            Row(
              children: [
                Expanded(
                  child: i < menuItems.length
                      ? buildMenuItemCard(menuItems[i], currentUser!, currentCart!, currentOrderMode!, currentOrderHistory, currentTableNo, selectedTabIndex, menuItemList!, itemCategoryList!)
                      : const SizedBox.shrink(),
                ),
                Expanded(
                  child: (i + 1) < menuItems.length
                      ? buildMenuItemCard(menuItems[i + 1], currentUser!, currentCart!, currentOrderMode!, currentOrderHistory, currentTableNo, selectedTabIndex, menuItemList!, itemCategoryList!)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
        ],
      ),
      // child: MenuCategory(menuCategoryName: 'Item Search', menuItem: menuItems, currentUser: currentUser, currentCart: currentCart,),
    );
  }

  Widget _defaultListView(User currentUser, Cart currentCart, String currentOrderMode, List<int> currentOrderHistory, int currentTableNo, int selectedTabIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: (menuItemList == null || menuItemList!.isEmpty) ? FutureBuilder<List<MenuItem>>(
        future: getMenuItemList(),
        builder: (BuildContext context, AsyncSnapshot<List<MenuItem>> snapshot) {
          if (snapshot.hasData) {
            menuItemList = snapshot.data;
            return TabBarView(
              children: buildMenuItemList(snapshot.data, currentUser, currentCart, currentOrderMode, currentOrderHistory, currentTableNo, selectedTabIndex),
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
      ) : TabBarView(
        children: buildMenuItemList(menuItemList, currentUser, currentCart, currentOrderMode, currentOrderHistory, currentTableNo, selectedTabIndex),
      )
    );
  }

  Future<List<MenuItem>> getMenuItemList() async {

    try {
      final response = await http.get(
        // Uri.parse('http://10.0.2.2:8000/menu/request_menu_item_list'),
        Uri.parse('http://localhost:8000/menu/request_menu_item_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // menuItemList = MenuItem.getMenuItemDataList(jsonDecode(response.body));
        return MenuItem.getMenuItemDataList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the menu item data list.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }

  Future<List<MenuItem>> getBestSellingFoodList() async {
    try {
      final response = await http.get(
        // Uri.parse('http://10.0.2.2:8000/menu/request_menu_item_list'),
        Uri.parse('http://localhost:8000/menu/request_best_selling_food_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // bestSellingFoods = MenuItem.getMenuItemDataList(jsonDecode(response.body));
        return MenuItem.getMenuItemDataList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the best selling food data list.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }

  Future<List<MenuItem>> getBestSellingDrinkList() async {
    try {
      final response = await http.get(
        // Uri.parse('http://10.0.2.2:8000/menu/request_menu_item_list'),
        Uri.parse('http://localhost:8000/menu/request_best_selling_drink_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // bestSellingDrinks = MenuItem.getMenuItemDataList(jsonDecode(response.body));
        return MenuItem.getMenuItemDataList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the best selling drink data list.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }

  Future<List<MenuItem>> getItemCategoryList() async {
    try {
      final response = await http.get(
        // Uri.parse('http://10.0.2.2:8000/menu/request_item_category_list'),
        Uri.parse('http://localhost:8000/menu/request_item_category_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // itemCategory = MenuItem.getItemCategoryExistMenuItemList(jsonDecode(response.body));
        return MenuItem.getItemCategoryExistMenuItemList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the item category exist menu item list.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }
}

// class MyProvider extends ChangeNotifier {
//   int _selectedTabIndex = 0;
//
//   int get selectedTabIndex => _selectedTabIndex;
//
//   void updateSelectedIndex(int value) {
//     _selectedTabIndex = value;
//     notifyListeners();
//   }
// }

    // For the expanded tile (just for backup if needed)
    // return Padding(
    //   padding: EdgeInsets.symmetric(vertical: 10.0),
    //   child: Container(
    //     color: Colors.grey.shade200,
    //     child: ExpansionTile(
    //       title: Text(foodType!,
    //         style: TextStyle(
    //           color: Colors.black,
    //           fontSize: 18.0,
    //           fontWeight: FontWeight.bold,
    //         ),
    //       ),
    //       trailing: Icon(_isExpanded ? Icons.arrow_circle_up : Icons.arrow_circle_down,
    //         color: Colors.black, // Set the color of the icon
    //         size: 30.0,
    //       ),
    //       onExpansionChanged: (value) {
    //         setState(() {
    //           _isExpanded = value;
    //         });
    //       },
    //       children: [
    //         // Wrap the ListView.builder with a Column
    //         Column(
    //           children: [
    //             for (int i = 0; i < foods!.length; i += 2)
    //               Row(
    //                 children: [
    //                   Expanded(
    //                     child: i < foods.length
    //                         ? buildFoodItemCard(foods[i])
    //                         : SizedBox.shrink(),
    //                   ),
    //                   Expanded(
    //                     child: (i + 1) < foods.length
    //                         ? buildFoodItemCard(foods[i + 1])
    //                         : SizedBox.shrink(),
    //                   ),
    //                 ],
    //               ),
    //           ],
    //         );
    //       ],
    //     ),
    //   ),
    // );


