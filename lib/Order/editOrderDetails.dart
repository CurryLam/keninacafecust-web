import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:keninacafecust_web/AppsBar.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafecust_web/Entity/CartForOrderFoodItemMoreInfo.dart';
import 'package:keninacafecust_web/Menu/menuHome.dart';
import 'package:keninacafecust_web/Order/orderPlaced.dart';

import '../Entity/Cart.dart';
import '../Entity/FoodOrder.dart';
import '../Entity/MenuItem.dart';
import '../Entity/OrderFoodItemMoreInfo.dart';
import '../Entity/User.dart';
import '../Order/orderOverview.dart';
import '../Utils/error_codes.dart';
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
      home: const EditOrderDetailsPage(user: null, order: null, cart: null),
    );
  }
}

class EditOrderDetailsPage extends StatefulWidget {
  const EditOrderDetailsPage({super.key, this.user, this.order, this.cart, this.cartOrder});

  final User? user;
  final FoodOrder? order;
  final Cart? cart;
  final CartForOrderFoodItemMoreInfo? cartOrder;

  @override
  State<EditOrderDetailsPage> createState() => _EditOrderDetailsPageState();
}

class _EditOrderDetailsPageState extends State<EditOrderDetailsPage> {
  Widget? image;
  String base64Image = "";
  bool orderEdited = false;

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
    FoodOrder? currentOrder = getOrder();
    Cart? currentCart = getCart();
    CartForOrderFoodItemMoreInfo? currentCartOrder = getCartOrder();

    return Scaffold(
      appBar: AppsBarState().buildEditOrderHistoryDetailsAppBar(context, "EDIT ORDER", currentUser!, currentCart!),
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
                              children: buildOrderFoodItemList(snapshot.data, currentUser, currentCart, currentCartOrder!),
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
                  children: buildBottomNavigationBar(snapshot.data, currentUser, currentCart, currentCartOrder),
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
      backgroundColor: Colors.grey.shade100,
    );
  }

  List<Widget> buildBottomNavigationBar(List<FoodOrder>? currentOrder, User currentUser, Cart currentCart, CartForOrderFoodItemMoreInfo? currentCartOrder) {
    if (currentCartOrder?.order_grand_total == 0) {
      for (int i = 0; i < currentOrder!.length; i++) {
        currentCartOrder?.order_grand_total = currentOrder[i]!.grand_total;
      }
    }
    List<Widget> bottomNavigationBar = [];
    bottomNavigationBar.add(
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
              'MYR ${currentCartOrder?.order_grand_total.toStringAsFixed(2)}',
              style: const TextStyle(
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
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
        child: Container(
          padding: const EdgeInsets.only(top: 3, left: 3),
          child: MaterialButton(
            minWidth: double.infinity,
            height: 50,
            onPressed: () {
              showConfirmationUpdateDialog(currentCart, currentUser, currentCartOrder!);
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

  List<Widget> buildOrderFoodItemList(List<OrderFoodItemMoreInfo>? orderFoodItemList, User? currentUser, Cart? currentCart, CartForOrderFoodItemMoreInfo currentCartOrder) {
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
                                    a.menu_item_name,
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
                                        // deleteFoodItemOrder(a);
                                        currentCartOrder.removeFromCartForOrderFoodItemMoreInfo(a);
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
                                      if (a.numOrder == 1) {
                                        setState(() {
                                          // deleteFoodItemOrder(a);
                                          // if (orderFoodItemList.length == 1) {
                                          //   Navigator.push(context,
                                          //       MaterialPageRoute(builder: (context) => OrderHistoryPage(user: currentUser, cart: currentCart))
                                          //   );
                                          // }
                                          currentCartOrder.reduceNumOrderForOrderFoodItemMoreInfo(a);
                                        });
                                      } else {
                                        setState(() {
                                          // updateFoodItemNumOrder(a, (a.numOrder.toInt() - 1));
                                          currentCartOrder.reduceNumOrderForOrderFoodItemMoreInfo(a);
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
                                    a.numOrder.toInt().toString(),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 10), // Add spacing between buttons
                                  InkWell(
                                    onTap: () {
                                      // a.numOrder++;
                                      setState(() {
                                        // updateFoodItemNumOrder(a, (a.numOrder.toInt() + 1));
                                        currentCartOrder.increaseNumOrderForOrderFoodItemMoreInfo(a);
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

  void showConfirmationUpdateDialog(Cart currentCart, User currentUser, CartForOrderFoodItemMoreInfo currentCartOrder) {
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
                            title: const Text('Error'),
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
                            title: const Text('Connection Error'),
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
                    currentCart = Cart(id: 0, menuItem: [], numMenuItemOrder: 0, grandTotalBeforeDiscount: 0, grandTotalAfterDiscount: 0, price_discount: 0, voucherAppliedID: 0, voucherApplied_type_name: "", voucherApplied_cost_off: 0, voucherApplied_free_menu_item_name: "", voucherApplied_applicable_menu_item_name: "", voucherApplied_min_spending: 0);
                    Navigator.of(context).pop();
                    showDialog(context: context, builder: (
                        BuildContext context) =>
                        AlertDialog(
                          title: const Text('Order Edited Successful'),
                          content: const Text('Your latest order details can be viewed in the order history'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Ok'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => OrderHistoryPage(user: currentUser, cart: currentCart)),
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

  Future<List<OrderFoodItemMoreInfo>> getOrderFoodItemDetails(FoodOrder currentOrder) async {
    try {
      final response = await http.get(
        // Uri.parse('http://10.0.2.2:8000/order/request_order_details/${currentOrder.id}/'),
        Uri.parse('http://localhost:8000/order/request_order_details/${currentOrder.id}/'),
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
        Uri.parse('http://localhost:8000/order/request_specific_order_details/${currentOrder.id}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print(FoodOrder.getOrderList(jsonDecode(response.body)));
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
        Uri.parse('http://localhost:8000/order/update_food_item_num_order/${orderFoodItem.id}/'),
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

  Future<(bool, String)> deleteFoodItemOrder(OrderFoodItemMoreInfo orderFoodItem) async {
    try {
      final response = await http.put(
        // Uri.parse('http://10.0.2.2:8000/order/delete_food_item_order/${orderFoodItem.id}/'),
        Uri.parse('http://localhost:8000/order/delete_food_item_order/${orderFoodItem.id}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
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

  Future<(bool, String)> _submitOrderFoodItemUpdateDetails(CartForOrderFoodItemMoreInfo currentCartOrder) async {
    List<OrderFoodItemMoreInfo> orderFoodItemUpdateList = currentCartOrder.getFoodItemOrderList();
    double grand_total = currentCartOrder.getOrderGrandTotal();
    print(grand_total);
    var (success, err_code) = await updateOrderFoodItemDetails(orderFoodItemUpdateList, grand_total);
    if (success == false) {
      if (kDebugMode) {
        print("Failed to edit order.");
      }
      return (false, err_code);
    }
    return (true, err_code);
  }

  Future<(bool, String)> updateOrderFoodItemDetails(List<OrderFoodItemMoreInfo> orderFoodItemUpdateList, double grand_total) async {
    try {
      final response = await http.put(
        // Uri.parse('http://10.0.2.2:8000/order/update_food_item_order'),
        Uri.parse('http://localhost:8000/order/update_food_item_order'),

        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<dynamic, dynamic> {
          'order_food_item_update_list': orderFoodItemUpdateList.map((orderFoodItemList) => orderFoodItemList.toJson()).toList(),
          'order_id': orderFoodItemUpdateList[0].food_order,
          'grand_total': grand_total,
          'gross_total': grand_total,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (kDebugMode) {
          print("Edit Order Successful.");
          print(orderFoodItemUpdateList[0].food_order);
          print(grand_total);
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
}
