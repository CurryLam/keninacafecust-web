import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:keninacafecust_web/AppsBar.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafecust_web/Menu/menuHome.dart';
import 'package:keninacafecust_web/Order/orderPlaced.dart';

import '../Entity/Cart.dart';
import '../Entity/MenuItem.dart';
import '../Entity/User.dart';
import '../Order/orderOverview.dart';
import '../Utils/error_codes.dart';

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
      home: const ViewCartPage(user: null, cart: null),
    );
  }
}

class ViewCartPage extends StatefulWidget {
  const ViewCartPage({super.key, this.user, this.cart});

  final User? user;
  final Cart? cart;

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

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    // if (base64Image == "") {
    //   base64Image = currentMenuItem!.image;
    //   if (base64Image == "") {
    //     image = Image.asset('images/KE_Nina_Cafe_logo.jpg');
    //     print("nothing in base64");
    //   } else {
    //     image = Image.memory(base64Decode(base64Image), fit: BoxFit.fill);
    //   }
    // } else {
    //   image = Image.memory(base64Decode(base64Image), fit: BoxFit.fill);
    // }

    User? currentUser = getUser();
    Cart? currentCart = getCart();
    hasMenuItem = currentCart!.containMenuItem();

    return Scaffold(
      appBar: AppsBarState().buildCartAppBar(context, "MY CART", currentUser!, currentCart),
      drawer: AppsBarState().buildDrawer(context, currentUser!, currentCart!, isMenuHomePage),
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
                              children: buildCartList(snapshot.data, currentUser, currentCart),
                            );
                          } else {
                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            } else {
                              return const Center(child: Text('Loading....'));
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
                    'MYR ${currentCart.getGrandTotal().toStringAsFixed(2)}',
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
                        MaterialPageRoute(builder: (context) => OrderOverviewPage(user: currentUser, cart: currentCart))
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

  List<Widget> buildCartList(List<MenuItem>? listCart, User? currentUser, Cart? currentCart) {
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
                        MaterialPageRoute(builder: (context) => MenuHomePage(user: currentUser, cart: currentCart))
                    );
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
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        currentCart?.removeFromCart(a);
                                      });
                                    },
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: Colors.grey.shade300,
                                        // border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                      // padding: const EdgeInsets.all(1),
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
                            Text(
                              'MYR ${(a.price*a.numOrder).toStringAsFixed(2)}',
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
