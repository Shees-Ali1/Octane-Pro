import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:octane_pro/Screens/total_sales/total_sales_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import '../Screens/Details/Details.dart';
import '../Screens/Details/realData.dart';
import '../Screens/HomePage/home_Page.dart';
import '../Screens/Listing/listing_screen.dart';
import '../Screens/Profile/ProfilePage.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  PersistentTabController _controller = PersistentTabController(initialIndex: 0);
  int _selectedIndex = 0;

  List<Widget> _buildScreens() {
    return [
      HomePage(),
      ListingScreen(), // Replace with actual screens
      DetailsScreen(),
      TotalSalesScreen(),
      ProfilePage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: ColorFiltered(
          colorFilter: ColorFilter.mode(
            _selectedIndex == 0 ?Color.fromRGBO(255, 62, 71, 1) : Colors.grey,
            BlendMode.srcIn,
          ),
          child: SvgPicture.asset(
            'assets/icons/House.svg', // Replace with actual path
            width: 24.w,
            height: 24.h,
            fit: BoxFit.contain,
          ),
        ),
        activeColorSecondary: Color.fromRGBO(255, 62, 71, 1),
        activeColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: ColorFiltered(
          colorFilter: ColorFilter.mode(
            _selectedIndex == 1 ? Color.fromRGBO(255, 62, 71, 1) : Colors.grey,
            BlendMode.srcIn,
          ),
          child: SvgPicture.asset(
            'assets/icons/stat.svg', // Replace with actual path
            width: 24.w,
            height: 24.h,
            fit: BoxFit.contain,
          ),
        ),
        activeColorSecondary: Color.fromRGBO(255, 62, 71, 1),
        activeColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: ColorFiltered(
          colorFilter: ColorFilter.mode(
            _selectedIndex == 2 ? Color.fromRGBO(255, 62, 71, 1) : Colors.grey,
            BlendMode.srcIn,
          ),
          child: SvgPicture.asset(
            'assets/icons/MapPin.svg', // Replace with actual path
            width: 24.w,
            height: 24.h,
            fit: BoxFit.contain,
          ),
        ),
        activeColorSecondary: Color.fromRGBO(255, 62, 71, 1),
        activeColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.table_chart,
          size: 30,
          color:  _selectedIndex == 3 ?Color.fromRGBO(255, 62, 71, 1) : Colors.grey,),
        activeColorSecondary: Color.fromRGBO(255, 62, 71, 1),
        activeColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: ColorFiltered(
          colorFilter: ColorFilter.mode(
            _selectedIndex == 4 ?Color.fromRGBO(255, 62, 71, 1) : Colors.grey,
            BlendMode.srcIn,
          ),
          child: SvgPicture.asset(
            'assets/icons/Group.svg', // Replace with actual path
            width: 24.w,
            height: 24.h,
            fit: BoxFit.contain,
          ),
        ),
        activeColorSecondary: Color.fromRGBO(255, 62, 71, 1),
        activeColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineInSafeArea: true,
        backgroundColor: Color.fromRGBO(32, 35, 37, 1),
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        hideNavigationBarWhenKeyboardShows: true,
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          colorBehindNavBar: Colors.white,
        ),
        popAllScreensOnTapOfSelectedTab: true,
        itemAnimationProperties: ItemAnimationProperties(
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimation(
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle: NavBarStyle.style6,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
