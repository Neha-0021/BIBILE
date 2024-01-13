import 'dart:io';

import 'package:bible_app/molecules/menu_bar.dart';
import 'package:bible_app/pages/book_mark.dart';
import 'package:bible_app/pages/home_page.dart';
import 'package:bible_app/state-management/book_chapters_state.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<StatefulWidget> createState() {
    return BottomBarTab();
  }
}

class BottomBarTab extends State<BottomBar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  // Function to open the side menu drawer
  void _openSideMenuDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

    @override
  void initState() {
    super.initState();
    initializeAsyncLogic();
    String platform = Platform.isAndroid ? "android" : "ios";
    final bookState = Provider.of<BookState>(context, listen: false);

    bookState.getShareLinkbyPlatform(platform);
  }

  Future<void> initializeAsyncLogic() async {
    String deviceId = "";

    try {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        deviceId = androidInfo.androidId;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        deviceId = iosInfo.identifierForVendor;
      }
    } catch (e) {
      deviceId = 'Failed to get Device ID.';
    }

    if (!mounted) return;

    setState(() {
      deviceId;
    });

   

    final bookState = Provider.of<BookState>(context, listen: false);
    bookState.getBookMarkbydeviceId(deviceId);
  }


  List<PersistentBottomNavBarItem> _navBarsItems(BuildContext context) {
    return [
      PersistentBottomNavBarItem(
        icon: Image.asset(
          'assets/images/Home.png',
          width: 50,
          height: 50,
          color: Colors.red[700],
        ),
        activeColorPrimary: Colors.red[700]!,
        inactiveIcon: Image.asset(
          'assets/images/Home.png',
          width: 40,
          height: 40,
          color: Colors.black,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.bookmark, size: 30, color: Colors.red[700]),
        title: 'BookMark',
        textStyle: GoogleFonts.lato(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        activeColorPrimary: Colors.red[700]!,
        inactiveIcon: const Icon(Icons.bookmark, size: 30, color: Colors.black),
      ),
      PersistentBottomNavBarItem(
          icon: Icon(Icons.menu, size: 30, color: Colors.red[700]),
          title: 'Menu',
          textStyle: GoogleFonts.lato(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          activeColorPrimary: Colors.red[700]!,
          inactiveIcon: const Icon(Icons.menu, size: 30, color: Colors.black),
          // Assign the function to open the side menu drawer
          onPressed: (_) {
            _openSideMenuDrawer();
          }),
    ];
  }

  List<Widget> _screens() {
    return [
      const MyHomePage(),
      const BookMarkPage(),
      const SideMenu()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const SideMenu(),
      endDrawerEnableOpenDragGesture: false,
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _screens(),
        items: _navBarsItems(context),
        handleAndroidBackButtonPress: true,
        stateManagement: true,
        decoration: const NavBarDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        backgroundColor:const  Color(0xFFFFCDD2),
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        navBarStyle: NavBarStyle.style6,
      ),
    );
  }
}
