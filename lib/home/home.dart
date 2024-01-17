import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sportistan_admin/home/nav/nav_home.dart';
import 'package:sportistan_admin/screens/account_kyc.dart';
import 'package:sportistan_admin/screens/commission_earnings.dart';
import 'package:sportistan_admin/screens/search_by_algolia.dart';
import 'package:sportistan_admin/widgets/page_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _selectedIndex = 0;

  final _widgetOptions = [
    const Bookings(),
    const AccountKYC(),
    const SearchByAlgolia(),
    const CommissionEarnings(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        themeMode: ThemeMode.light,
        theme: ThemeData.light(useMaterial3: false),
        home: Scaffold(
            bottomSheet: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                margin: Platform.isIOS
                    ? const EdgeInsets.only(bottom: 50)
                    : const EdgeInsets.all(0),
                child: GNav(
                  mainAxisAlignment: MainAxisAlignment.center,
                  rippleColor: Colors.grey[300]!,
                  hoverColor: Colors.grey[100]!,
                  activeColor: Colors.green,
                  iconSize: 24,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  duration: const Duration(milliseconds: 400),
                  tabBackgroundColor: Colors.grey[100]!,
                  color: Colors.black54,
                  tabs: const [
                    GButton(
                      icon: Icons.home,
                      text: 'All Bookings',
                    ),
                    GButton(
                      icon: Icons.verified,
                      text: 'Pending KYC',
                    ),
                    GButton(
                      icon: Icons.search,
                      text: 'Search User',
                    ),
                    GButton(
                      icon: Icons.account_balance_wallet,
                      text: 'Earning',
                    ),
                  ],
                  selectedIndex: _selectedIndex,
                  onTabChange: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              ),
            ),
            body: _widgetOptions.elementAt(_selectedIndex)));
  }

  void searchByAlgolia() {
    PageRouter.push(context, const SearchByAlgolia());
  }

  void myEarnings() {
    PageRouter.push(context, const SearchByAlgolia());
  }
}
