import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../main.dart';
import 'Entity/Cart.dart';
import 'Entity/MenuItem.dart';
import 'Entity/User.dart';
import 'Menu/menuHome.dart';
import 'Menu/viewCart.dart';
import 'Order/orderHistory.dart';
import 'PersonalProfile/changePassword.dart';
import 'PersonalProfile/viewPersonalProfile.dart';
import 'Voucher/VoucherList.dart';


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
      home: const AppsBar(),
    );
  }
}

class AppsBar extends StatefulWidget {
  const AppsBar({super.key});

  @override
  State<AppsBar> createState() => AppsBarState();
}

class AppsBarState extends State<AppsBar> {

  @override
  PreferredSizeWidget buildSignUpAppBar(BuildContext context, String title) {

    return PreferredSize( //wrap with PreferredSize
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        automaticallyImplyLeading: false,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios_rounded),
        //   onPressed: () {
        //     Navigator.of(context).push(
        //         MaterialPageRoute(builder: (context) => const LoginPage())
        //     );
        //   },
        // ),
        elevation: 0,
        toolbarHeight: 100,
        title: Text(title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25.0,
          ),
        ),
        backgroundColor: Colors.orange.shade500,
        centerTitle: true,
      ),
    );
  }

  @override
  PreferredSizeWidget buildProfileAppBar(BuildContext context, String title, User currentUser) {
    return PreferredSize( //wrap with PreferredSize
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 25.0),
        elevation: 0,
        toolbarHeight: 100,
        title: Row(
          children: [
            const Icon(
              Icons.person_2_outlined,
              size: 35.0,
              color: Colors.white,
            ),
            const SizedBox(width: 8.0,),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 27.0,
                fontFamily: 'BreeSerif',
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade500,
        centerTitle: true,
      ),
    );
  }

  @override
  PreferredSizeWidget buildChangePasswordAppBar(BuildContext context, String title, User currentUser) {
    return PreferredSize( //wrap with PreferredSize
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 25.0),
        elevation: 0,
        toolbarHeight: 100,
        title: Row(
          children: [
            const Icon(
              Icons.key_outlined,
              size: 35.0,
              color: Colors.white,
            ),
            const SizedBox(width: 8.0,),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 27.0,
                fontFamily: 'BreeSerif',
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade500,
        centerTitle: true,
      ),
    );
  }

  @override
  PreferredSizeWidget buildMenuItemDetailsAppBar(BuildContext context, String title, User currentUser) {

    return PreferredSize( //wrap with PreferredSize
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 25.0),
        elevation: 0,
        toolbarHeight: 100,
        title: Row(
          children: [
            const Icon(
              Icons.details_outlined,
              size: 35.0,
              color: Colors.white,
            ),
            const SizedBox(width: 8.0,),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 27.0,
                fontFamily: 'BreeSerif',
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade500,
        centerTitle: true,
      ),
    );
  }

  @override
  PreferredSizeWidget buildCartAppBar(BuildContext context, String title, User currentUser, Cart currentCart, String currentOrderMode, List<int>? currentOrderHistory,String? currentTableNo, int currentTabIndex, List<MenuItem> currentMenuItemList, List<MenuItem> currentItemCategoryList) {

    return PreferredSize( //wrap with PreferredSize
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              size: 30.0,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MenuHomePage(user: currentUser, cart: currentCart, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: currentTabIndex, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList,))
              );
            },
          ),
        ),
        elevation: 0,
        toolbarHeight: 100,
        title: Row(
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 35.0,
              color: Colors.white,
            ),
            const SizedBox(width: 8.0,),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 27.0,
                fontFamily: 'BreeSerif',
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade500,
        centerTitle: true,
      ),
    );
  }

  @override
  PreferredSizeWidget buildOrderHistoryAppBar(BuildContext context, String title, User currentUser, Cart currentCart) {

    return PreferredSize( //wrap with PreferredSize
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 25.0),
        elevation: 0,
        toolbarHeight: 100,
        title: Row(
          children: [
            const Icon(
              Icons.history,
              size: 35.0,
              color: Colors.white,
            ),
            const SizedBox(width: 8.0,),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 27.0,
                fontFamily: 'BreeSerif',
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade500,
        centerTitle: true,
      ),
    );
  }

  @override
  PreferredSizeWidget buildOrderHistoryDetailsAppBar(BuildContext context, String title, User currentUser, Cart currentCart, String currentOrderMode, List<int> currentOrderHistory, String currentTableNo, int currentTabIndex, List<MenuItem> currentMenuItemList, List<MenuItem> currentItemCategoryList) {

    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        leading: IconButton(
          onPressed: () => {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => OrderHistoryPage(user: currentUser, cart: currentCart, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: currentTabIndex, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList,))
            ),
          },
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        ),
        // iconTheme: const IconThemeData(color: Colors.white, size: 25.0),
        elevation: 0,
        toolbarHeight: 100,
        title: Row(
          children: [
            const Icon(
              Icons.history,
              size: 35.0,
              color: Colors.white,
            ),
            const SizedBox(width: 8.0,),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 27.0,
                fontFamily: 'BreeSerif',
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade500,
        centerTitle: true,
      ),
    );
  }

  @override
  PreferredSizeWidget buildEditOrderHistoryDetailsAppBar(BuildContext context, String title, User currentUser, Cart currentCart) {

    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        ),
        // iconTheme: const IconThemeData(color: Colors.white, size: 25.0),
        elevation: 0,
        toolbarHeight: 100,
        title: Row(
          children: [
            const Icon(
              Icons.edit,
              size: 35.0,
              color: Colors.white,
            ),
            const SizedBox(width: 8.0,),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 27.0,
                fontFamily: 'BreeSerif',
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade500,
        centerTitle: true,
      ),
    );
  }

  @override
  PreferredSizeWidget buildVoucherListAppBar(BuildContext context, String title, User currentUser, Cart currentCart) {

    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        // leading: IconButton(
        //   onPressed: () => Navigator.pop(context),
        //   icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        // ),
        // iconTheme: const IconThemeData(color: Colors.white, size: 25.0),
        elevation: 0,
        toolbarHeight: 100,
        title: Row(
          children: [
            const Icon(
              Icons.card_giftcard,
              size: 35.0,
              color: Colors.white,
            ),
            const SizedBox(width: 8.0,),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 27.0,
                fontFamily: 'BreeSerif',
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade500,
        centerTitle: true,
      ),
    );
  }

  @override
  PreferredSizeWidget buildRedeemVoucherAppBar(BuildContext context, String title, User currentUser, Cart currentCart) {

    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        ),
        // iconTheme: const IconThemeData(color: Colors.white, size: 25.0),
        elevation: 0,
        toolbarHeight: 100,
        title: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 27.0,
                fontFamily: 'BreeSerif',
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade500,
        centerTitle: true,
      ),
    );
  }

  @override
  PreferredSizeWidget buildApplyVoucherAppBar(BuildContext context, String title, User currentUser, Cart currentCart) {

    return PreferredSize( //wrap with PreferredSize
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              size: 25.0,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        elevation: 0,
        toolbarHeight: 100,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                  fontFamily: 'BreeSerif',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.orange.shade500,
      ),
    );
  }

  @override
  PreferredSizeWidget buildMenuItemDetailsAppsBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.black),
      ),
    );
  }

  Widget buildDrawer(BuildContext context, User currentUser, Cart currentCart, bool isMenuHomePage, String currentOrderMode, List<int> currentOrderHistory, String currentTableNo, int currentTabIndex, List<MenuItem> currentMenuItemList, List<MenuItem> currentItemCategoryList) {
    enterFullScreen();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            color: Colors.transparent,
            padding: const EdgeInsets.fromLTRB(0, 30, 0, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange.shade500,
                  radius: 45,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0), // Border radius
                    child: ClipOval(child: Image.asset('images/KE_Nina_Cafe_logo.jpg')),
                  ),
                ),
                const SizedBox(width: 20.0,),
                Text(
                  'Food Ordering',
                  style: TextStyle(color: Colors.deepOrangeAccent.shade700, fontSize: 23, fontWeight: FontWeight.bold),
                ),
              ]
            ),
          ),
          Divider(color: Colors.deepOrangeAccent.shade700, thickness: 3.0,),
          if (isMenuHomePage == false)
            ListTile(
              leading: Icon(
                Icons.menu_book_outlined,
                color: Colors.deepOrangeAccent.shade700,
              ),
              title: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.deepOrangeAccent.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                ),
              ),
              onTap: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MenuHomePage(user: currentUser, cart: currentCart, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: currentTabIndex, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList,))
                ),
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => MenuHomePage())
                // ),
              },
            ),
          ListTile(
            leading: Icon(
                Icons.shopping_cart_outlined,
                color: Colors.deepOrangeAccent.shade700
            ),
            title: Text(
              'Cart',
              style: TextStyle(
                color: Colors.deepOrangeAccent.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              ),
            ),
            onTap: () => {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => ViewCartPage(user: currentUser, cart: currentCart, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: currentTabIndex, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList,))
              ),
            },
          ),
          ListTile(
            leading: Icon(
                Icons.receipt_outlined,
                color: Colors.deepOrangeAccent.shade700,
            ),
            title: Text(
              'Order History',
              style: TextStyle(
                color: Colors.deepOrangeAccent.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              ),
            ),
            onTap: () => {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => OrderHistoryPage(user: currentUser, cart: currentCart, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: currentTabIndex, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList,))
              ),
            },
          ),
          if (currentUser.email != "guestkeninacafe@gmail.com")
            ListTile(
              leading: Icon(
                  Icons.card_giftcard,
                  color: Colors.deepOrangeAccent.shade700
              ),
              title: Text(
                'Voucher(s)',
                style: TextStyle(
                  color: Colors.deepOrangeAccent.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                ),
              ),
              onTap: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => VoucherListPage(user: currentUser, cart: currentCart, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: currentTabIndex, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList,))
                ),
              },
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
            child: Text(
              'My Account',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 19, fontWeight: FontWeight.bold),
            ),
          ),
          if (currentUser.email == "guestkeninacafe@gmail.com")
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.user,
                color: Colors.deepOrangeAccent.shade700,
              ),
              title: Text(
                'Login',
                style: TextStyle(
                  color: Colors.deepOrangeAccent.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                ),
              ),
              onTap: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const LoginPage())
                ),
              },
            ),
          if (currentUser.email != "guestkeninacafe@gmail.com")
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.user,
                color: Colors.deepOrangeAccent.shade700,
              ),
              title: Text(
                'Profile',
                style: TextStyle(
                  color: Colors.deepOrangeAccent.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                ),
              ),
              onTap: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUser, cart: currentCart, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: currentTabIndex, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList,))
                ),
              },
            ),
          if (currentUser.email != "guestkeninacafe@gmail.com")
            ListTile(
              leading: Icon(
                Icons.key_outlined,
                color: Colors.deepOrangeAccent.shade700,
              ),
              title: Text(
                'Change Password',
                style: TextStyle(
                  color: Colors.deepOrangeAccent.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                ),
              ),
              onTap: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ChangePasswordPage(user: currentUser, cart: currentCart, orderMode: currentOrderMode, orderHistory: currentOrderHistory, tableNo: currentTableNo, tabIndex: currentTabIndex, menuItemList: currentMenuItemList, itemCategoryList: currentItemCategoryList,))
                ),
              },
            ),
          if (currentUser.email != "guestkeninacafe@gmail.com")
            ListTile(
              leading: Icon(
                  Icons.exit_to_app,
                  color: Colors.deepOrangeAccent.shade700
              ),
              title: Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.deepOrangeAccent.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                ),
              ),
              onTap: () => {
                showConfirmationLogOutDialog(context, currentTableNo)
              },
            ),
        ],
      ),
    );
  }

  void showConfirmationLogOutDialog(BuildContext context, String currentTableNo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: const Text('Are you sure to log out your account?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                showDialog(context: context, builder: (
                    BuildContext context) =>
                    AlertDialog(
                      title: const Text('Log Out Successfully', style: TextStyle(fontWeight: FontWeight.bold,)),
                      // content: Text('An Error occurred while trying to create a new order.\n\nError Code: $err_code'),
                      actions: <Widget>[
                        TextButton(onPressed: () =>
                            Navigator.pop(context, 'Ok'),
                            child: const Text('Ok')),
                      ],
                    ),
                );
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage())
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}