import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../AppsBar.dart';
import '../Entity/Cart.dart';
import '../Entity/MenuItem.dart';
import '../Entity/User.dart';
import 'menuHome.dart';

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
      home: const MenuItemDetailsPage(user: null, menuItem: null, cart: null),
    );
  }
}

class MenuItemDetailsPage extends StatefulWidget {
  const MenuItemDetailsPage({super.key, this.user, this.menuItem, this.cart});

  final User? user;
  final MenuItem? menuItem;
  final Cart? cart;

  @override
  State<MenuItemDetailsPage> createState() => _MenuItemDetailsPageState();
}

class _MenuItemDetailsPageState extends State<MenuItemDetailsPage> {
  int itemCount = 1;
  Widget? image;
  String base64Image = "";
  String selectedSize = "";
  String selectedVariant = "";
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

    if (base64Image == "") {
      base64Image = currentMenuItem!.image;
      if (base64Image == "") {
        image = Image.asset('images/KE_Nina_Cafe_logo.jpg');
        print("nothing in base64");
      } else {
        image = Image.memory(base64Decode(base64Image), fit: BoxFit.fill);
      }
    } else {
      image = Image.memory(base64Decode(base64Image), fit: BoxFit.fill);
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      // backgroundColor: const Color(0xFFEFE1DB),
      // backgroundColor: Colors.white,
      // appBar: AppsBarState().buildMenuItemDetailsAppsBar(context),
      body: SafeArea(
        child: SingleChildScrollView (
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Container(
                //   height: 600 * 0.42,
                //   width: 400,
                //   child: image,
                // ),
                SizedBox(
                  height: 600 * 0.42,
                  width: 400,
                  child: Stack(
                    children: [
                      if (image != null)
                        Positioned.fill(
                          child: image!,
                        ),
                      Positioned(
                        top: 16, // Adjust the position as needed
                        left: 16, // Adjust the position as needed
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              padding: const EdgeInsets.all(2), // Adjust padding as needed
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.black, // Adjust the color as needed
                                size: 32, // Adjust the size as needed
                              ),
                            ),
                          ),
                        ),
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
                              // fontFamily: 'Itim',
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
                                // borderRadius: BorderRadius.circular(200), // Apply border radius if needed
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
                      const SizedBox(height: 20),
                      // const Text(
                      //   "Description",
                      //   style: TextStyle(
                      //     fontSize: 20.5,
                      //     fontWeight: FontWeight.bold,
                      //     fontFamily: 'Rajdhani',
                      //   ),
                      // ),
                      const SizedBox(height: 5.0),
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
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: Colors.white,
                            ),
                            child: Text(
                              itemCount.toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 23,
                              ),
                            ),
                          ),
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
                child: Container(
                  width: 220,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: isButtonEnabled ? () {
                      currentCart!.addToCart(itemCount, currentMenuItem);
                      Navigator.pop(context);
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) => MenuHomePage(user: currentUser, cart: currentCart))
                      // );
                    } : null,
                    child: const Text(
                      "Add to cart",
                      style: TextStyle(
                        fontSize: 18,
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
}