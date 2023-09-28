import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:keninacafecust_web/AppsBar.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_search_bar/flutter_search_bar.dart';

import '../Entity/User.dart';

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
      home: const MenuHomePage(user: null),
    );
  }
}

class MenuHomePage extends StatefulWidget {
  const MenuHomePage({super.key, this.user});

  final User? user;

  @override
  State<MenuHomePage> createState() => _MenuHomePageState();
}

class _MenuHomePageState extends State<MenuHomePage> {
  bool _showAppbar = true; //this is to show app bar
  ScrollController _scrollBottomBarController = new ScrollController(); // set controller on scrolling
  bool isScrollingDown = false;
  bool _show = true;
  double bottomBarHeight = 75; // set bottom bar height
  double _bottomBarOffset = 0;

  bool searchBoolean = false;

  User? getUser() {
    return widget.user;
  }

  @override
  void initState() {
    super.initState();
    myScroll();
  }

  @override
  void dispose() {
    _scrollBottomBarController.removeListener(() {});
    super.dispose();
  }

  void showBottomBar() {
    setState(() {
      _show = true;
    });
  }

  void hideBottomBar() {
    setState(() {
      _show = false;
    });
  }

  void myScroll() async {
    _scrollBottomBarController.addListener(() {
      if (_scrollBottomBarController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          _showAppbar = false;
          hideBottomBar();
        }
      }
      if (_scrollBottomBarController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (isScrollingDown) {
          isScrollingDown = false;
          _showAppbar = true;
          showBottomBar();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();

    return Container(
      constraints: const BoxConstraints.expand(), // Make the container cover the entire screen
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/login_background.png"),
          fit: BoxFit.cover, // This ensures the image covers the entire container
        ),
      ),
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            toolbarHeight: 100,
            title: !searchBoolean ?
            const Text('Food Menu',
              style: TextStyle(
                // fontWeight: FontWeight.bold,
                fontSize: 25.0,
              ),
            ) : searchTextField(),
            backgroundColor: Colors.blueAccent,
            // centerTitle: true,
            actions: !searchBoolean
                ?[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: IconButton(
                  onPressed: () {
                    setState(() { //add
                      searchBoolean = true;
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
            bottom: TabBar(
              tabs: const [
                Tab(
                  child: SizedBox(
                    width: 120, // Adjust the width to your desired size
                    child: Column(
                      children: [
                        Icon(Icons.call),
                        Text('Call'),
                      ],
                    ),
                  ),
                ),
                Tab(child: SizedBox(
                  width: 120, // Adjust the width to your desired size
                  child: Column(
                    children: [
                      Icon(Icons.call),
                      Text('Message'),
                    ],
                  ),
                ),),
                Tab(child: SizedBox(
                  width: 120, // Adjust the width to your desired size
                  child: Column(
                    children: [
                      Icon(Icons.call),
                      Text('Call'),
                    ],
                  ),
                ),),
                Tab(child: SizedBox(
                  width: 120, // Adjust the width to your desired size
                  child: Column(
                    children: [
                      Icon(Icons.call),
                      Text('Message'),
                    ],
                  ),
                ),),
              ],
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.label,
              labelPadding: const EdgeInsets.symmetric(vertical: 10),
              // Space between tabs
              indicator: BoxDecoration(
                color: Colors.blue.shade700, // Color for the selected tab
              ),
              unselectedLabelStyle: const TextStyle(
                color: Colors.black, // Color for unselected tab label
              ),
            ),
          ),
          drawer: AppsBarState().buildDrawer(context),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ListView(
                  //   children: [
                  FoodTypeCollapsible(foodType: 'Appetizers', foods: [
                    FoodItem(name: 'Item 1', price: 10.0),
                    FoodItem(name: 'Item 1', price: 10.0),
                    FoodItem(name: 'Item 1', price: 10.0),
                    FoodItem(name: 'Item 1', price: 10.0),
                    FoodItem(name: 'Item 1', price: 10.0),
                    FoodItem(name: 'Item 2', price: 12.0),
                    // Add more appetizer items
                  ]),
                  FoodTypeCollapsible(foodType: 'Main Course', foods: [
                    FoodItem(name: 'Item 1', price: 15.0),
                    FoodItem(name: 'Item 2', price: 18.0),
                    // Add more main course items
                  ]),
                  FoodTypeCollapsible(foodType: 'Main ', foods: [
                    FoodItem(name: 'Item 1', price: 15.0),
                    FoodItem(name: 'Item 2', price: 18.0),
                    // Add more main course items
                  ]),
                  FoodTypeCollapsible(foodType: 'Main ', foods: [
                    FoodItem(name: 'Item 1', price: 15.0),
                    FoodItem(name: 'Item 2', price: 18.0),
                    // Add more main course items
                  ]),
                  // Add more food type collapsibles
                  // ],
                  // ),
                  // FutureBuilder<Tuple2<List<String>, List<String>>>(
                  //   future: getSupplierStockList(currentSupplier!),
                  //   builder: (BuildContext context, AsyncSnapshot<Tuple2<List<String>, List<String>>> snapshot) {
                  //     if (snapshot.hasData) {
                  //       return Column(
                  //         children: buildStockList(snapshot.data, currentUser),
                  //       );
                  //     } else {
                  //       if (snapshot.hasError) {
                  //         return Center(child: Text('Error: ${snapshot.error}'));
                  //       } else {
                  //         return const Center(child: Text('Error: invalid state'));
                  //       }
                  //     }
                  //   }
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget searchTextField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0), // Adjust the radius to make it more or less rounded
        border: Border.all(
          color: Colors.black, // Color of the outline border
          width: 3.0, // Width of the outline border
        ),
        color: Colors.white,
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
        child: TextField(
          autofocus: true, //Display the keyboard when TextField is displayed
          cursorColor: Colors.black54,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 20,
          ),
          textInputAction: TextInputAction.search, //Specify the action button on the keyboard
          decoration: InputDecoration( //Style of TextField
            border: InputBorder.none,
            hintText: 'Search', //Text that is displayed when nothing is entered.
            hintStyle: TextStyle( //Style of hintText
              color: Colors.black54,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class FoodTypeCollapsible extends StatefulWidget {
  final String foodType;
  final List<FoodItem> foods;

  FoodTypeCollapsible({required this.foodType, required this.foods});

  @override
  _FoodTypeCollapsibleState createState() => _FoodTypeCollapsibleState();
}

class _FoodTypeCollapsibleState extends State<FoodTypeCollapsible> {
  bool _isExpanded = false;

  String? getFoodType() {
    return widget.foodType;
  }

  List<FoodItem>? getFoods(){
    return widget.foods;
  }

  @override
  Widget build(BuildContext context) {

    String? foodType = getFoodType();
    List<FoodItem>? foods = getFoods();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        color: Colors.grey.shade700,
        child: ExpansionTile(
          title: Text(foodType!,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Icon(_isExpanded ? Icons.arrow_circle_up : Icons.arrow_circle_down,
            color: Colors.white, // Set the color of the icon
            size: 30.0,
          ),
          onExpansionChanged: (value) {
            setState(() {
              _isExpanded = value;
            });
          },
          children: [
            // Wrap the ListView.builder with a Column
            Column(
              children: [
                for (int i = 0; i < foods!.length; i += 2)
                  Row(
                    children: [
                      Expanded(
                        child: i < foods.length
                            ? buildFoodItemCard(foods[i])
                            : SizedBox.shrink(),
                      ),
                      Expanded(
                        child: (i + 1) < foods.length
                            ? buildFoodItemCard(foods[i + 1])
                            : SizedBox.shrink(),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFoodItemCard(FoodItem food) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: food.name,
              child: CircleAvatar(
                backgroundImage: AssetImage('images/login_background.png'),
                radius: 30.0,
              ),
            ),
            Text(
              food.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            Text('\$${food.price.toStringAsFixed(2)}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    // Handle decreasing the quantity
                  },
                ),
                Text(
                  '1', // Replace with the actual quantity
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    // Handle increasing the quantity
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FoodItem {
  final String name;
  final double price;

  FoodItem({required this.name, required this.price});
}






// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:keninacafecust_web/AppsBar.dart';
//
//
// class SizeConfig {
//   double heightSize(BuildContext context, double value) {
//     value /= 100;
//     return MediaQuery.of(context).size.height * value;
//   }
//
//   double widthSize(BuildContext context, double value) {
//     value /= 100;
//     return MediaQuery.of(context).size.width * value;
//   }
//
//   double fontSize(BuildContext context, double value) {
//     value /= 100;
//     value = MediaQuery.of(context).size.height * value;
//     if (value > 40) value = 40;
//     return value;
//   }
// }
//
// void main() {
//   runApp(const MyApp());
// }
//
// void enterFullScreen() {
//   SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         // scaffoldBackgroundColor: Colors.black,
//       ),
//       home: const MenuHomePage(),
//     );
//   }
// }
//
// class MenuHomePage extends StatefulWidget {
//   const MenuHomePage({super.key});
//
//   @override
//   State<MenuHomePage> createState() => _MenuHomePageState();
//
// }
//
// class _MenuHomePageState extends State<MenuHomePage>{
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppsBarState().buildMenuAppBar(context, ""),
//       body: ListView(
//         children: [
//           //Custom appbar
//           // Appbarwidget(),
//
//           //search Button
//           SingleChildScrollView(
//             child: Padding(
//               padding: EdgeInsets.symmetric(
//                 vertical: 10,
//                 horizontal: 15,
//               ),
//               child: Container(
//                 width: double.infinity,
//                 // height:SizeConfig().heightSize(context, 5.0),
//                 decoration: BoxDecoration(
//                     color: Colors.black,
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey[700]!,
//                         spreadRadius: 1,
//                         blurRadius: 6,
//                       )
//                     ]),
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 5),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Icon(
//                             size: SizeConfig().widthSize(context, 4.0),
//                             CupertinoIcons.search,
//                             color: Colors.amber),
//                       ),
//                       Expanded(
//                         flex: 4,
//                         child: Container(
//                           // height: 50,
//                           // width:SizeConfig().widthSize(context, 50.0) ,
//                           child: Padding(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 5,
//                               ),
//                               child: TextFormField(
//                                 decoration: InputDecoration(
//                                     hintStyle: TextStyle(
//                                       color: Colors.white60,
//                                       fontSize:
//                                       SizeConfig().fontSize(context, 3.0),
//                                     ),
//                                     hintText: "Search for Food",
//                                     border: InputBorder.none),
//                                 style: TextStyle(
//                                     fontSize:
//                                     SizeConfig().fontSize(context, 3.0),
//                                     color: Colors.white),
//                               )),
//                         ),
//                       ),
//                       Expanded(
//                         child: Icon(
//                             color: Colors.amber,
//                             size: SizeConfig().widthSize(context, 5.0),
//                             Icons.filter_list),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           //category
//           Padding(
//               padding: EdgeInsets.only(top: 20, left: 10),
//               child: Text(
//                 "Categories",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: SizeConfig().fontSize(context, 3.0),
//                   color: Colors.amber,
//                 ),
//               )),
//
//           /////category display
//           // Categorylist(),
//           //popular heading
//           Padding(
//               padding: EdgeInsets.only(top: 20, left: 10),
//               child: Text(
//                 "Popular items",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: SizeConfig().fontSize(context, 3.0),
//                   color: Colors.amber,
//                 ),
//               )),
//
//           //popular items list
//           // Popularlist(),
//           //Newest items
//           Padding(
//               padding: EdgeInsets.only(top: 20, left: 10),
//               child: Text(
//                 "Newest items",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: SizeConfig().fontSize(context, 3.0),
//                   color: Colors.amber,
//                 ),
//               )),
//           //newest list
//           // Newslist()
//         ],
//       ),
//
//       //drawer
//       // drawer: Drawerwidget(),
//
//       floatingActionButton: Container(
//         decoration: BoxDecoration(
//             color: Colors.black,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey[600]!,
//                 spreadRadius: 1,
//                 blurRadius: 6,
//                 // offset: Offset(0, 0),
//               )
//             ]),
//         child: FloatingActionButton(
//           onPressed: () {
//             Navigator.pushNamed(context, "cartPage");
//           },
//           child: Icon(
//             CupertinoIcons.cart,
//             color: Colors.amber,
//             size: 26,
//           ),
//           backgroundColor: Colors.black,
//         ),
//       ),
//     );
//   }
// }
