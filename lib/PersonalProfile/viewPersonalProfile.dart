import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../AppsBar.dart';
import '../Entity/Cart.dart';
import '../Entity/MenuItem.dart';
import '../Entity/User.dart';

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
      home: const ViewPersonalProfilePage(user: null, cart: null, orderMode: null, orderHistory: null, tableNo: null, tabIndex: null, menuItemList: null, itemCategoryList: null),
    );
  }
}

class ViewPersonalProfilePage extends StatefulWidget {
  const ViewPersonalProfilePage({super.key, this.user, this.cart, this.orderMode, this.orderHistory, this.tableNo, this.tabIndex, this.menuItemList, this.itemCategoryList});

  final User? user;
  final Cart? cart;
  final String? orderMode;
  final List<int>? orderHistory;
  final String? tableNo;
  final int? tabIndex;
  final List<MenuItem>? menuItemList;
  final List<MenuItem>? itemCategoryList;

  @override
  State<ViewPersonalProfilePage> createState() => _ViewPersonalProfilePageState();
}

class _ViewPersonalProfilePageState extends State<ViewPersonalProfilePage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  // final phoneNumberController = TextEditingController();
  final genderController = TextEditingController();
  final dobController = TextEditingController();
  final pointController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isHomePage = false;

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

  List<MenuItem>? getMenuItemStoredList() {
    return widget.menuItemList;
  }

  List<MenuItem>? getItemCategory() {
    return widget.itemCategoryList;
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
    List<MenuItem>? currentMenuItemList = getMenuItemStoredList();
    List<MenuItem>? currentItemCategoryList = getItemCategory();
    nameController.text = currentUser!.name;
    emailController.text = currentUser.email;
    // phoneNumberController.text = currentUser.phone;
    genderController.text = currentUser.gender;
    dobController.text = currentUser.dob.toString().substring(0,10);
    pointController.text = currentUser.points.toString();

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppsBarState().buildDrawer(context, currentUser!, currentCart!, isHomePage, currentOrderMode!, currentOrderHistory!, currentTableNo!, currentTabIndex!, currentMenuItemList!, currentItemCategoryList!),
      appBar: AppsBarState().buildProfileAppBar(context, "PROFILE", currentUser!),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                        children: [
                          TextFormField(
                            controller: nameController,
                            enabled: false,
                            decoration: InputDecoration(
                              label: Text('Name', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.grey.shade500),), prefixIcon: Icon(Icons.person_2_outlined, color: Colors.grey.shade700,),
                            ),
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Gabarito",
                            ),
                          ),
                          const SizedBox(height: 13),
                          TextFormField(
                            enabled: false,
                            controller: emailController,
                            decoration: InputDecoration(
                                label: Text('Email', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.grey.shade500),), prefixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade700,)
                            ),
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Gabarito",
                            ),
                          ),
                          const SizedBox(height: 13),
                          // TextFormField(
                          //   enabled: false,
                          //   controller: phoneNumberController,
                          //   decoration: InputDecoration(
                          //       label: Text('Phone Number', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.grey.shade500),), prefixIcon: Icon(Icons.phone_android, color: Colors.grey.shade700,)
                          //   ),
                          //   style: TextStyle(
                          //     fontSize: 18.0,
                          //     color: Colors.grey.shade700,
                          //     fontWeight: FontWeight.bold,
                          //     fontFamily: "Gabarito",
                          //   ),
                          // ),
                          // const SizedBox(height: 13),
                          TextFormField(
                            enabled: false,
                            controller: genderController,
                            decoration: InputDecoration(
                                label: Text('Gender', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.grey.shade500),), prefixIcon: genderController.text == "Male" ? Icon(Icons.male, color: Colors.grey.shade700,) : Icon(Icons.female, color: Colors.grey.shade700,)
                            ),
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Gabarito",
                            ),
                          ),
                          const SizedBox(height: 13),
                          TextFormField(
                            enabled: false,
                            controller: dobController,
                            decoration: InputDecoration(
                                label: Text('Date Of Birth', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.grey.shade500),), prefixIcon: Icon(Icons.cake_outlined, color: Colors.grey.shade700,)
                            ),
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Gabarito",
                            ),
                          ),
                          const SizedBox(height: 13),
                          TextFormField(
                            enabled: false,
                            controller: pointController,
                            decoration: InputDecoration(
                                label: Text('Points', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.grey.shade500),), prefixIcon: Icon(Icons.stars, color: Colors.grey.shade700,)
                            ),
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Gabarito",
                            ),
                          ),
                          const SizedBox(height: 13),
                        ]
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}