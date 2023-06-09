import 'package:flutter/material.dart';
import 'package:flutter_tanya_mama/basics/screens/base_screen.dart';
import 'package:flutter_tanya_mama/constants/page_name.dart';
import 'package:flutter_tanya_mama/functions/routes.dart';
import 'package:flutter_tanya_mama/screens/home/home_page.dart';

class HomeScreen extends BaseScreen {
  const HomeScreen({super.key}) : super(PageName.Home);
  @override
  // TODO: implement padding
  EdgeInsets get padding => EdgeInsets.zero;
  @override
  // TODO: implement scrollable
  bool get scrollable => false;
  @override
  Widget content(BuildContext context) {
    return const HomePage();
  }

  static var navBarRoutes = [
    PageName.Home,
    PageName.Settings,
  ];

  @override
  Widget? bottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black87,
      unselectedItemColor: Colors.white,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Akun',
        ),
      ],
      currentIndex: 0,
      selectedItemColor: Colors.blue[400],
      onTap: (index) async {
        await Routes.pushReplacement(
          context,
          navBarRoutes[index],
        );
      },
    );
  }
}
