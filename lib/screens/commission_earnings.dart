import 'package:flutter/material.dart';

class CommissionEarnings extends StatefulWidget {
  const CommissionEarnings({super.key});

  @override
  State<CommissionEarnings> createState() => _CommissionEarningsState();
}

class _CommissionEarningsState extends State<CommissionEarnings> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(children: [
            Text("Your Earnings",style: TextStyle(fontFamily: "DMSans",fontSize: 22),)
          ]),
        ),
      ),
    );
  }
}
