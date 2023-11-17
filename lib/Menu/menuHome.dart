import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafecust_web/AppsBar.dart';
import 'package:flutter/material.dart';
import 'package:keninacafecust_web/Entity/Cart.dart';
import 'package:keninacafecust_web/Menu/viewCart.dart';
// import 'package:flutter_search_bar/flutter_search_bar.dart';

import '../Entity/ItemCategory.dart';
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
      home: const MenuHomePage(user: null, cart: null),
    );
  }
}

class MenuHomePage extends StatefulWidget {
  const MenuHomePage({super.key, this.user, this.cart});

  final User? user;
  final Cart? cart;

  @override
  State<MenuHomePage> createState() => _MenuHomePageState();
}

class _MenuHomePageState extends State<MenuHomePage> with SingleTickerProviderStateMixin{
  int selectedTabIndex = 0;
  int numItemCategory = 6;
  bool searchBoolean = false;
  List<MenuItem>? menuItem;
  List<String> bestSeller = ['Best Seller For Foods', 'Best Seller For Drinks'];
  String? categoryName;
  String? tempCategoryName;
  List<int> _searchIndexList = [];
  List<MenuItem>? searchMenuItem = [];
  int itemCount = 0;
  double totalPrice = 0.0;
  bool isMenuHomePage = true;


  User? getUser() {
    return widget.user;
  }

  Cart? getCart() {
    return widget.cart;
  }

  onGoBack(dynamic value) {
    setState(() {});
  }

  void navigateViewCartPage(Cart currentCart, User currentUser) {
    Route route = MaterialPageRoute(builder: (context) => ViewCartPage(cart: currentCart, user: currentUser,));
    Navigator.push(context, route).then(onGoBack);
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    Cart? currentCart = getCart();

    return Container(
      constraints: const BoxConstraints.expand(), // Make the container cover the entire screen
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/menuBackground.png"),
          fit: BoxFit.cover, // This ensures the image covers the entire container
        ),
      ),
      child: DefaultTabController(
        length: numItemCategory,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            toolbarHeight: 85,
            title: !searchBoolean ?
            const Text('Food Menu',
              style: TextStyle(
                // fontWeight: FontWeight.bold,
                fontSize: 25.0,
              ),
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
            bottom:
            PreferredSize(
              preferredSize: const Size(100,110),
              child: Container(
                height: 110.0,
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
                  child: FutureBuilder<List<MenuItem>>(
                      future: getItemCategoryList(),
                      builder: (BuildContext context, AsyncSnapshot<List<MenuItem>> snapshot) {
                        if (snapshot.hasData) {
                          return TabBar(
                            onTap: (value) {
                              setState(() {
                                selectedTabIndex = value;
                              });
                            },
                            tabs: buildItemCategoryList(snapshot.data, currentUser),
                            isScrollable: true,
                            // indicatorSize: TabBarIndicatorSize.label,
                            labelPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            // Space between tabs
                            indicator: BoxDecoration(
                              color: Colors.orange.shade500,
                            ),
                            unselectedLabelColor: Colors.grey.shade600,
                            labelColor: Colors.orange.shade500,

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
          ),
          drawer: AppsBarState().buildDrawer(context, currentUser!, currentCart!, isMenuHomePage),
          body: !searchBoolean ? _defaultListView(currentUser!, currentCart!) : _searchListView(currentUser!, currentCart!),
          // bottomNavigationBar:
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
                        MaterialPageRoute(builder: (context) => ViewCartPage(user: currentUser, cart: currentCart))
                    );
                  },
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    size: 35,
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
                    height:50,
                    onPressed: () async {
                      navigateViewCartPage(currentCart, currentUser);
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) => ViewCartPage(user: currentUser, cart: currentCart))
                      // );
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
                          ),
                        ),
                        Positioned(
                          top: 3,
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
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(207, 18, 0, 0),
                          child: Row(
                            // mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'CHECKOUT', // Replace with the actual total price.
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(297, 16, 0, 0),
                          child: Row(
                            // mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_forward_ios_sharp,
                                size: 20,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
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
    List<Widget> tabs = [];
    numItemCategory = listItemCategory!.length + 2;

    for (int i = 0; i < bestSeller.length; i++) {
      tabs.add(
        SizedBox(
          height: 110,
          child: Tab(
            child: Column(
                children: [
                  SizedBox(
                    height: 106.0, // Adjust the height to your desired size
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
                          height: 106.0,
                          width: 90, // Adjust the width to your desired size
                          child: Column(
                            children: [
                              const SizedBox(height: 7.5),
                              CircleAvatar(
                                // backgroundColor: Colors.grey.shade500,
                                backgroundColor: selectedTabIndex == i
                                    ? Colors.orange.shade500 // Selected tab color
                                    : Colors.grey.shade500,
                                radius: 30.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  // Border radius
                                  child: ClipOval(
                                      child: Image.asset(
                                          'images/KE_Nina_Cafe_logo.jpg')
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2),
                                child: Text(
                                  // 'Signature & Must Try',
                                  bestSeller[i],
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontFamily: 'AsapCondensed',
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
    for (int i = 0; i < listItemCategory.length; i++) {
      tabs.add(
        SizedBox(
          height: 110,
          child: Tab(
            child: Column(
                children: [
                  SizedBox(
                    height: 106.0, // Adjust the height to your desired size
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
                          height: 106.0,
                          width: 90, // Adjust the width to your desired size
                          child: Column(
                            children: [
                              const SizedBox(height: 7.5),
                              CircleAvatar(
                                // backgroundColor: Colors.grey.shade500,

                                backgroundColor: selectedTabIndex == i + 2
                                    ? Colors.orange.shade500 // Selected tab color
                                    : Colors.grey.shade500,
                                radius: 30.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  // Border radius
                                  child: ClipOval(
                                      child: Image.asset(
                                          'images/KE_Nina_Cafe_logo.jpg')
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: Text(
                                  // 'Signature & Must Try',
                                  listItemCategory[i].category_name,
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontFamily: 'AsapCondensed',
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

  List<Widget> buildMenuItemList(List<MenuItem>? listMenuItem, User? currentUser, Cart currentCart) {
    List<Widget> tabBarView = [];
    tabBarView.add(
      SingleChildScrollView(
        child: MenuCategory(currentUser: currentUser!, currentCart: currentCart, menuCategoryName: 'Best Seller For Foods', menuItem: [
          for (int i = 0; i < listMenuItem!.length; i++)
            // if (listMenuItem[i].isOutOfStock)
            //   FoodItem(name: listMenuItem[i].name, price: listMenuItem[i].price),
            listMenuItem[i],
        ]),
      ),
    );
    tabBarView.add(
      SingleChildScrollView(
        child: MenuCategory(currentUser: currentUser, currentCart: currentCart, menuCategoryName: 'Best Seller For Drinks', menuItem: [
          for (int i = 0; i < listMenuItem.length; i++)
            // if (listMenuItem[i].isOutOfStock == false)
            //   FoodItem(name: listMenuItem[i].name, price: listMenuItem[i].price),
            listMenuItem[i],
        ]),
      ),
    );
    for (int i = 0; i < listMenuItem.length; i++) {
      searchMenuItem?.add(listMenuItem[i]);
      categoryName = listMenuItem[i].category_name;
      if (tempCategoryName != categoryName) {
          tempCategoryName = categoryName;
          tabBarView.add(
            SingleChildScrollView(
              child: MenuCategory(currentUser: currentUser, currentCart: currentCart, menuCategoryName: listMenuItem[i].category_name, menuItem: [
                for (int j = i; j < listMenuItem.length; j++)
                  if (listMenuItem[j].category_name == tempCategoryName)
                    // FoodItem(name: listMenuItem[j].name, price: listMenuItem[j].price),
                    listMenuItem[j],
              ]),
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
                  return const Center(child: Text('Loading....'));
                }
              }
            }
        ),
      ),
    );
  }

  Widget _searchListView(User currentUser, Cart currentCart) {
    final List<MenuItem> menuItems = _searchIndexList.map((index) {
      // return MenuItem(name: searchMenuItem![index].name, price: searchMenuItem![index].price);
      return searchMenuItem![index];
    }).toList();

    return SingleChildScrollView(
      child: MenuCategory(menuCategoryName: 'Item Search', menuItem: menuItems, currentUser: currentUser, currentCart: currentCart,),
    );
  }

  Widget _defaultListView(User currentUser, Cart currentCart) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: FutureBuilder<List<MenuItem>>(
        future: getMenuItemList(),
        builder: (BuildContext context, AsyncSnapshot<List<MenuItem>> snapshot) {
          if (snapshot.hasData) {
            return TabBarView(
              children: buildMenuItemList(snapshot.data, currentUser, currentCart),
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
        return MenuItem.getMenuItemDataList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the menu item data list.');
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
        return MenuItem.getItemCategoryExistMenuItemList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the item category exist menu item list.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }
}

class MenuCategory extends StatefulWidget {
  final String menuCategoryName;
  final List<MenuItem> menuItem;
  final User currentUser;
  final Cart currentCart;

  const MenuCategory({super.key, required this.menuCategoryName, required this.menuItem, required this.currentUser, required this.currentCart});

  @override
  _MenuCategoryState createState() => _MenuCategoryState();
}

class _MenuCategoryState extends State<MenuCategory> {
  Widget? image;
  String base64Image = "";

  User? getUser() {
    return widget.currentUser;
  }

  String? getFoodType() {
    return widget.menuCategoryName;
  }

  List<MenuItem>? getFoods(){
    return widget.menuItem;
  }

  Cart? getCart() {
    return widget.currentCart;
  }

  // onGoBack(dynamic value) {
  //   setState(() {});
  // }
  //
  // void navigateMenuItemDetailsPage(MenuItem currentMenuItem, Cart currentCart, User currentUser) {
  //   Route route = MaterialPageRoute(builder: (context) => MenuItemDetailsPage(menuItem: currentMenuItem, cart: currentCart, user: currentUser,));
  //   Navigator.push(context, route).then(onGoBack);
  // }

  @override
  Widget build(BuildContext context) {

    String? foodType = getFoodType();
    List<MenuItem>? foods = getFoods();
    User? currentUser = getUser();
    Cart? currentCart = getCart();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(17, 5, 0, 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              foodType!,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20.0,
                fontFamily: 'AsapCondensed',
              ),
            ),
          ),
        ),
        for (int i = 0; i < foods!.length; i += 2)
          Row(
            children: [
              Expanded(
                child: i < foods.length
                    ? buildMenuItemCard(foods[i], currentUser!, currentCart!)
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: (i + 1) < foods.length
                    ? buildMenuItemCard(foods[i + 1], currentUser!, currentCart!)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
      ],
    );


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
  }

  Widget buildMenuItemCard(MenuItem currentMenuItem, User currentUser, Cart currentCart) {

    if (base64Image == "") {
      base64Image = currentMenuItem!.image;
      if (base64Image == "") {
        image = Image.asset('images/KE_Nina_Cafe_logo.jpg');
        print("nothing in base64");
      } else {
        image = Image.memory(base64Decode(base64Image), fit: BoxFit.cover);
      }
    } else {
      image = Image.memory(base64Decode(base64Image), fit: BoxFit.cover);
    }

    return SizedBox(
      height: 310,
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
                    topLeft: Radius.circular(3.0), // Adjust the radius for the top left corner
                    topRight: Radius.circular(3.0), // Adjust the radius for the top right corner
                  ),
                  // child: Image.asset(
                  //   'images/KE_Nina_Cafe_logo.jpg',
                  //   fit: BoxFit.cover,
                  // ),
                  child: image,
                ),
              ),


                // const SizedBox(height: 5.0,),
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
              // GestureDetector(
              //   onTap: () {
              //     Navigator.push(context,
              //       MaterialPageRoute(
              //         builder: (context) => MenuItemDetailsPage(user: currentUser, menuItem: currentMenuItem, cart: currentCart)),
              //     );
              //     setState(() {
              //       currentMenuItem.numOrder = 0;
              //       currentMenuItem.sizeChosen = "";
              //       currentMenuItem.variantChosen = "";
              //       currentMenuItem.remarks = "";
              //     });
              //   },
              //   child: Hero(
              //     tag: currentMenuItem.name,
              //     child: ClipRRect(
              //       borderRadius: const BorderRadius.only(
              //         topLeft: Radius.circular(3.0), // Adjust the radius for the top left corner
              //         topRight: Radius.circular(3.0), // Adjust the radius for the top right corner
              //       ),
              //       child: Image.asset(
              //         'images/KE_Nina_Cafe_logo.jpg',
              //         fit: BoxFit.cover,
              //       ),
              //     ),
              //   ),
              // ),
              //
              //   // const SizedBox(height: 5.0,),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.push(context,
              //       MaterialPageRoute(
              //           builder: (context) => MenuItemDetailsPage(user: currentUser, menuItem: currentMenuItem, cart: currentCart)),
              //     );
              //     setState(() {
              //       currentMenuItem.numOrder = 0;
              //       currentMenuItem.sizeChosen = "";
              //       currentMenuItem.variantChosen = "";
              //       currentMenuItem.remarks = "";
              //     });
              //   },
              //   child: Padding(
              //     padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
              //     child: Align(
              //       alignment: Alignment.centerLeft,
              //       child: Text(
              //         currentMenuItem.name,
              //         style: const TextStyle(
              //           fontWeight: FontWeight.bold,
              //           fontSize: 17.0,
              //           fontFamily: 'Itim',
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.push(context,
              //       MaterialPageRoute(
              //           builder: (context) => MenuItemDetailsPage(user: currentUser, menuItem: currentMenuItem, cart: currentCart)),
              //     );
              //     setState(() {
              //       currentMenuItem.numOrder = 0;
              //       currentMenuItem.sizeChosen = "";
              //       currentMenuItem.variantChosen = "";
              //       currentMenuItem.remarks = "";
              //     });
              //   },
              //   child: const Spacer(),
              // ),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.push(context,
              //       MaterialPageRoute(
              //           builder: (context) => MenuItemDetailsPage(user: currentUser, menuItem: currentMenuItem, cart: currentCart)),
              //     );
              //     setState(() {
              //       currentMenuItem.numOrder = 0;
              //       currentMenuItem.sizeChosen = "";
              //       currentMenuItem.variantChosen = "";
              //       currentMenuItem.remarks = "";
              //     });
              //   },
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              //     child: Align(
              //       alignment: Alignment.centerLeft,
              //       child: Text(
              //         'RM ${currentMenuItem.price.toStringAsFixed(2)}',
              //         style: const TextStyle(
              //           fontSize: 14.0,
              //           fontFamily: "Itim"
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.push(context,
              //       MaterialPageRoute(
              //           builder: (context) => MenuItemDetailsPage(user: currentUser, menuItem: currentMenuItem, cart: currentCart)),
              //     );
              //     setState(() {
              //       currentMenuItem.numOrder = 0;
              //       currentMenuItem.sizeChosen = "";
              //       currentMenuItem.variantChosen = "";
              //       currentMenuItem.remarks = "";
              //     });
              //   },
              //   child: const Spacer(),
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.green.shade700,
                    ),
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 50),
                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                          child: GestureDetector(
                            onTap: () async {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => MenuItemDetailsPage(user: currentUser, menuItem: currentMenuItem, cart: currentCart))
                              );
                              // navigateMenuItemDetailsPage(currentMenuItem, currentCart, currentUser);
                              setState(() {
                                currentMenuItem.numOrder = 0;
                                currentMenuItem.sizeChosen = "";
                                currentMenuItem.variantChosen = "";
                                currentMenuItem.remarks = "";
                              });
                              // if (currentMenuItem.hasSize == false && currentMenuItem.hasVariant == false) {
                              //   currentCart.addToCart(1, currentMenuItem);
                              // }
                            },
                            child: const Row(
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
    );
  }
}

// class FoodItem {
//   final String name;
//   final double price;
//
//   FoodItem({required this.name, required this.price});
// }


