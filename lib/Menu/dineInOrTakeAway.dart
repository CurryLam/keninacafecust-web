import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import '../Auth/login.dart';
import '../Entity/Cart.dart';
import '../Entity/User.dart';
import '../Menu/menuHome.dart';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

      ),
      home: const DineInOrTakeAwayPage(user: null, cart: null, orderHistory: null, tableNo: null),
    );
  }
}

class DineInOrTakeAwayPage extends StatefulWidget {
  const DineInOrTakeAwayPage({super.key, this.user, this.cart, this.orderHistory, this.tableNo});

  final User? user;
  final Cart? cart;
  final List<int>? orderHistory;
  final String? tableNo;

  @override
  State<DineInOrTakeAwayPage> createState() => _DineInOrTakeAwayPageState();

}

class _DineInOrTakeAwayPageState extends State<DineInOrTakeAwayPage> with SingleTickerProviderStateMixin{
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  late AnimationController _animationController;
  bool securePasswordText = true;
  bool userFound = false;

  User? getUser() {
    return widget.user;
  }

  Cart? getCart() {
    return widget.cart;
  }

  List<int>? getOrderHistory() {
    return widget.orderHistory;
  }

  String? getTableNo() {
    return widget.tableNo;
  }

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this, // Provide the vsync here
      duration: const Duration(seconds: 1),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    // super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    Cart? currentCart = getCart();
    List<int>? currentOrderHistory = getOrderHistory();
    String? currentTableNo = getTableNo();

    return WillPopScope(
      onWillPop: () async {
        if (currentUser?.uid == 18) {
          Navigator.of(context).pop();
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
                content: const Text('Are you sure to log out ?'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
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
        return false;
      },
      child: Container(
        // constraints: const BoxConstraints.expand(),
        // decoration: const BoxDecoration(
        //     image: DecorationImage(
        //         image: AssetImage("images/login_background.png"),
        //         fit: BoxFit.cover
        //     )
        // ),
        child:Scaffold(
          backgroundColor: const Color.fromRGBO(245, 245, 220, 1.0),
          body: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 100.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        curve: Curves.fastOutSlowIn,
                        width: 250,
                        height: 250,
                        child: ScaleTransition(
                            scale: Tween<double>(begin: 0, end: 1).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: Curves.fastOutSlowIn,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.white70,
                              radius: 200,
                              child: Padding(
                                padding: const EdgeInsets.all(15), // Border radius
                                child: ClipOval(child: Image.asset('images/KE_Nina_Cafe_logo.jpg')),
                              ),
                            )
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Welcome to KE Nina Café !',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Set text color to white
                    ),
                  ),
                  const SizedBox(height: 150),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            height: 94, // Set your desired height
            // padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: Colors.grey.shade600,
                  height: 40.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Table No: $currentTableNo',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Gabarito",
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => MenuHomePage(user: currentUser, cart: currentCart, orderMode: "Dine In", orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: 0,)));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Set your desired color
                          elevation: 0, // Optional: Set elevation to 0 to remove the shadow
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero, // Optional: Set borderRadius to 0
                          ),
                          minimumSize: const Size(double.infinity, 60), // Optional: Set the minimum size
                          textStyle: const TextStyle(fontSize: 20), // Optional: Set the text style
                        ),
                        child: const Text(
                          'Dine In',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => MenuHomePage(user: currentUser, cart: currentCart, orderMode: "Take Away", orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: 0,)));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900, // Set your desired color
                          elevation: 0, // Optional: Set elevation to 0 to remove the shadow
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero, // Optional: Set borderRadius to 0
                          ),
                          minimumSize: const Size(double.infinity, 60), // Optional: Set the minimum size
                          textStyle: const TextStyle(fontSize: 20), // Optional: Set the text style
                        ),
                        child: const Text(
                          'Take Away',
                          style: TextStyle(
                            color: Colors.white,
                          ),
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
  }
}