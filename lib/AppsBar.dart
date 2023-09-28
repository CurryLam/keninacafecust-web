import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Auth/login.dart';
import 'Entity/User.dart';


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
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 28),
        //     child: IconButton(
        //       onPressed: () {
        //         // Navigator.of(context).push(
        //         //     MaterialPageRoute(builder: (context) => CreateAnnouncementPage(user: currentUser))
        //         // );
        //       },
        //       icon: const Icon(Icons.login, size: 35,),
        //     ),
        //   ),
        //   // IconButton(
        //   //   onPressed: () {
        //   //     Navigator.of(context).push(
        //   //         MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUser))
        //   //     );
        //   //   },
        //   //   icon: const Icon(Icons.account_circle_rounded, size: 35,),
        // ],
      ),
    );
  }

  @override
  PreferredSizeWidget buildFoodMenuAppBar(BuildContext context, String title, bool searchBoolean) {

    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        elevation: 0,
        toolbarHeight: 100,
        title: Text(title,
          style: const TextStyle(
            // fontWeight: FontWeight.bold,
            fontSize: 25.0,
          ),
        ),
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
      ),
    );
  }

  // @override
  // PreferredSizeWidget buildMenuAppBar(BuildContext context, String title) {
  //
  //   return PreferredSize( //wrap with PreferredSize
  //     preferredSize: const Size.fromHeight(80),
  //     child: Padding(
  //         padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             InkWell(
  //               onTap: () {
  //                 Scaffold.of(context).openDrawer();
  //               },
  //               child: Container(
  //                 padding: EdgeInsets.all(8),
  //                 decoration: BoxDecoration(
  //                     color: Colors.black,
  //                     borderRadius: BorderRadius.circular(20),
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: Colors.grey[600]!,
  //                         spreadRadius: 1,
  //                         blurRadius: 6,
  //                       )
  //                     ]),
  //                 child: Icon(
  //                   CupertinoIcons.bars,
  //                   color: Colors.amber,
  //                   // color:Colors.white
  //                 ),
  //               ),
  //             ),
  //             InkWell(
  //                 onTap: () {},
  //                 child: Container(
  //                   padding: EdgeInsets.all(8),
  //                   decoration: BoxDecoration(
  //                       color: Colors.black,
  //                       borderRadius: BorderRadius.circular(20),
  //                       boxShadow: [
  //                         BoxShadow(
  //                           color: Colors.grey[600]!,
  //                           spreadRadius: 1,
  //                           blurRadius: 6,
  //                         )
  //                       ]),
  //                   child: Icon(
  //                     Icons.notifications,
  //                     color: Colors.amber,
  //                   ),
  //                 ))
  //           ],
  //         )),
  //   );
  // }

  Widget buildDrawer(BuildContext context) {
    enterFullScreen();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
                color: Colors.green,
                // image: DecorationImage(
                //     fit: BoxFit.fill,
                //     image: AssetImage('images/KE_Nina_Cafe_appsbar.jpg'))
            ),
            child: Text(
              'Side menu',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.input),
            title: const Text('Welcome'),
            onTap: () => {},
          ),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('Profile'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.border_color),
            title: const Text('Feedback'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () => {Navigator.of(context).pop()},
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