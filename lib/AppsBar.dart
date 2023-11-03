import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'Auth/login.dart';
import 'Entity/Cart.dart';
import 'Entity/User.dart';
import 'Menu/menuHome.dart';
import 'Menu/viewCart.dart';
import 'Order/orderHistory.dart';


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
        // leading: Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 20),
        //   child: IconButton(
        //     icon: const Icon(Icons.arrow_back_ios_outlined),
        //     onPressed: () {
        //       Navigator.of(context).push(
        //           MaterialPageRoute(builder: (context) => const LoginPage())
        //       );
        //     },
        //   ),
        // ),
        elevation: 0,
        toolbarHeight: 100,
        title: Text(title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25.0,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
    );
  }

  @override
  PreferredSizeWidget buildCartAppBar(BuildContext context, String title, User currentUser, Cart currentCart) {

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
                  MaterialPageRoute(builder: (context) => MenuHomePage(user: currentUser, cart: currentCart))
              );
            },
          ),
        ),
        elevation: 0,
        toolbarHeight: 100,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45),
          child: Row(
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
  PreferredSizeWidget buildOrderHistoryDetailsAppBar(BuildContext context, String title, User currentUser, Cart currentCart) {

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
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 0),
          child: Row(
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
        ),
        backgroundColor: Colors.orange.shade500,
        centerTitle: true,
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

  Widget buildDrawer(BuildContext context, User currentUser, Cart currentCart, bool isMenuHomePage) {
    enterFullScreen();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // const DrawerHeader(
          //   decoration: BoxDecoration(
          //       color: Colors.green,
          //       // image: DecorationImage(
          //       //     fit: BoxFit.fill,
          //       //     image: AssetImage('images/KE_Nina_Cafe_appsbar.jpg'))
          //   ),
          //   child: Text(
          //     'Side menu',
          //     style: TextStyle(color: Colors.white, fontSize: 25),
          //   ),
          // ),
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
                    MaterialPageRoute(builder: (context) => MenuHomePage(user: currentUser, cart: currentCart))
                ),
              },
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 18, 15, 10),
            child: Text(
              'My Account',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 19, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.user,
              color: Colors.deepOrangeAccent.shade700,
            ),
            title: Text(
              'My Profile',
              style: TextStyle(
                color: Colors.deepOrangeAccent.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              ),
            ),
            onTap: () => {},
          ),
          ListTile(
            leading: Icon(
                Icons.shopping_cart_outlined,
                color: Colors.deepOrangeAccent.shade700
            ),
            title: Text(
              'My Cart',
              style: TextStyle(
                color: Colors.deepOrangeAccent.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              ),
            ),
            onTap: () => {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => ViewCartPage(user: currentUser, cart: currentCart))
              ),
            },
          ),
          ListTile(
            leading: Icon(
                Icons.receipt_outlined,
                color: Colors.deepOrangeAccent.shade700,
            ),
            title: Text(
              'My Order History',
              style: TextStyle(
                color: Colors.deepOrangeAccent.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              ),
            ),
            onTap: () => {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => OrderHistoryPage(user: currentUser, cart: currentCart))
              ),
            },
          ),
          ListTile(
            leading: Icon(
                Icons.card_giftcard,
                color: Colors.deepOrangeAccent.shade700
            ),
            title: Text(
              'My Voucher(s)',
              style: TextStyle(
                color: Colors.deepOrangeAccent.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              ),
            ),
            onTap: () => {},
          ),
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
            onTap: () => {},
          ),
        ],
      ),
    );
  }

  // @override
  // Widget buildDrawer(BuildContext context) {
  //   enterFullScreen();
  //   return Drawer(
  //     child: ListView(
  //       padding: EdgeInsets.zero,
  //       children: <Widget>[
  //         const DrawerHeader(
  //           decoration: BoxDecoration(
  //               color: Colors.green,
  //               image: DecorationImage(
  //                   fit: BoxFit.fill,
  //                   image: AssetImage('images/KE_Nina_Cafe_appsbar.jpg'))
  //           ),
  //           child: Text(
  //             'Side menu',
  //             style: TextStyle(color: Colors.white, fontSize: 25),
  //           ),
  //         ),
  //         ListTile(
  //           leading: const Icon(Icons.input),
  //           title: const Text('Welcome'),
  //           onTap: () => {},
  //         ),
  //         ListTile(
  //           leading: const Icon(Icons.verified_user),
  //           title: const Text('Profile'),
  //           onTap: () => {Navigator.of(context).pop()},
  //         ),
  //         ListTile(
  //           leading: const Icon(Icons.settings),
  //           title: const Text('Settings'),
  //           onTap: () => {Navigator.of(context).pop()},
  //         ),
  //         ListTile(
  //           leading: const Icon(Icons.border_color),
  //           title: const Text('Feedback'),
  //           onTap: () => {Navigator.of(context).pop()},
  //         ),
  //         ListTile(
  //           leading: const Icon(Icons.exit_to_app),
  //           title: const Text('Logout'),
  //           onTap: () => {Navigator.of(context).pop()},
  //         ),
  //       ],
  //     ),
  //   );
  // }


  // PreferredSize buildBottomNavigationBar(User currentUser, BuildContext context) {
  //   int selectedIndex = 0;
  //   print(currentUser.staff_type);
  //
  //   void _onItemTapped(int index) {
  //     // setState(() {
  //     selectedIndex = index;
  //     // });
  //
  //     // Perform specific actions based on user and index
  //     if (currentUser.staff_type == "Restaurant Owner") {
  //       // Admin-specific logic
  //       // List<Widget> _widgetOptions = <Widget>[
  //       //   HomePage(user: currentUser,),
  //       //   ViewPersonalProfilePage(user: currentUser,),
  //       // ];
  //       // _widgetOptions.elementAt(selectedIndex);
  //       if (index == 0) {
  //         Navigator.push(context,
  //           MaterialPageRoute(builder: (context) => HomePage(user: currentUser)),
  //         );
  //       } else if (selectedIndex == 1) {
  //         Navigator.of(context).push(
  //             MaterialPageRoute(builder: (context) => StaffDashboardPage(user: currentUser))
  //         );
  //       } else if (selectedIndex == 2) {
  //         Navigator.of(context).push(
  //             MaterialPageRoute(builder: (context) => SupplierDashboardPage(user: currentUser))
  //         );
  //       } else if (selectedIndex == 3) {
  //         Navigator.of(context).push(
  //             MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUser))
  //         );
  //       }
  //     } else if (currentUser.staff_type == "Restaurant Manager") {
  //       // List<Widget> _widgetOptions = <Widget>[
  //       //   HomePage(user: currentUser,),
  //       //   ViewPersonalProfilePage(user: currentUser,),
  //       // ];
  //       // _widgetOptions.elementAt(selectedIndex);
  //       // Regular user-specific logic
  //       if (index == 0) {
  //         Navigator.push(context,
  //           MaterialPageRoute(builder: (context) => HomePage(user: currentUser)),
  //         );
  //       } else if (index == 1) {
  //         Navigator.push(context,
  //           MaterialPageRoute(builder: (context) => StaffDashboardPage(user: currentUser)),
  //         );
  //       } else if (index == 2) {
  //         // Navigator.of(context).push(
  //         //     MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUser))
  //         // );
  //       } else if (index == 3) {
  //         // Navigator.of(context).push(
  //         //     MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUser))
  //         // );
  //       } else if (index == 4) {
  //         // Navigator.of(context).push(
  //         //     MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUser))
  //         // );
  //       } else if (index == 5) {
  //         Navigator.of(context).push(
  //             MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUser))
  //         );
  //       }
  //     } else if (currentUser.staff_type == "Restaurant Worker") {
  //
  //       if (index == 0) {
  //         Navigator.of(context).push(
  //             MaterialPageRoute(builder: (context) => HomePage(user: currentUser))
  //         );
  //       } else if (index == 1) {
  //         // Navigator.of(context).push(
  //         //     MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUser))
  //         // );
  //       } else if (index == 2) {
  //         Navigator.of(context).push(
  //             MaterialPageRoute(builder: (context) => AttendanceDashboardPage(user: currentUser))
  //         );
  //       } else if (index == 3) {
  //         Navigator.of(context).push(
  //             MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUser))
  //         );
  //       }
  //     }
  //     // setState(() {
  //     //   selectedIndex = index;
  //     // });
  //   }
  //
  //
  //   List<BottomNavigationBarItem> bottomNavBarItems = [];
  //   if (currentUser.staff_type == "Restaurant Owner") {
  //     bottomNavBarItems = const <BottomNavigationBarItem>[
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.home),
  //         label: 'Home',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.people_outline_outlined),
  //         label: 'Staff',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.local_shipping_outlined),
  //         label: 'Supplier',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.account_circle_rounded),
  //         label: 'Profile',
  //       ),
  //     ];
  //   } else if (currentUser.staff_type == "Restaurant Manager") {
  //     bottomNavBarItems = const <BottomNavigationBarItem>[
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.home),
  //         label: 'Home',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.people_outline_outlined),
  //         label: 'Staff',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.local_shipping_outlined),
  //         label: 'Supplier',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.restaurant_menu),
  //         label: 'Menu',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.receipt_long),
  //         label: 'Bills',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.account_circle_rounded),
  //         label: 'Profile',
  //       ),
  //     ];
  //   } else if (currentUser.staff_type == "Restaurant Worker") {
  //     bottomNavBarItems = const <BottomNavigationBarItem>[
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.home),
  //         label: 'Home',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.shopping_cart),
  //         label: 'Order',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.calendar_month),
  //         label: 'Attendance',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.account_circle_rounded),
  //         label: 'Profile',
  //       ),
  //     ];
  //   }
  //
  //   return PreferredSize(
  //     preferredSize: const Size.fromHeight(80),
  //     child: BottomNavigationBar(
  //       currentIndex: selectedIndex, // Set the current selected index
  //       selectedItemColor: Colors.amber[800],
  //       unselectedItemColor: Colors.grey,
  //       items: bottomNavBarItems, // Use the dynamically defined bottomNavBarItems
  //       onTap: _onItemTapped,
  //       showSelectedLabels: true, // Add this line to show the selected labels
  //       showUnselectedLabels: true, // Add this line to show the unselected labels
  //       selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold), // Customize the style of the selected label
  //       unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}