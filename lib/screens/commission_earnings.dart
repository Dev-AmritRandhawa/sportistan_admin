import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sportistan_admin/home/nav/nav_home.dart';

class CommissionEarnings extends StatefulWidget {
  const CommissionEarnings({super.key});

  @override
  State<CommissionEarnings> createState() => _CommissionEarningsState();
}

class _CommissionEarningsState extends State<CommissionEarnings> {
  double result = 0;
  double data = 0;
  var options = [
    "Today",
    "Yesterday",
    "Tomorrow",
    "Past 30 Days",
    "Upcoming 30 Days"
  ];
  var tag = 0;
  var options2 = [
    'Cricket',
    'Football',
    'Tennis',
    'Hockey',
    'Badminton',
    'Volleyball',
    'Swimming',
  ];

  var tag2 = 0;
  final _server = FirebaseFirestore.instance;
  ValueNotifier<bool> totalAmountListener = ValueNotifier<bool>(false);

  @override
  void initState() {
    calculate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            ValueListenableBuilder(
                valueListenable: totalAmountListener,
                builder: (context, value, child) {
                  return value
                      ? ContentNew(
                          title: '',
                          child: ChipsChoice<int>.single(
                            value: tag,
                            onChanged: (val) => setState(() {
                              tag = val;
                              createFilterIsGreaterThan(val);
                              createFilterIsLessThan(val);
                              calculate();
                            }),
                            choiceItems: C2Choice.listFrom<int, String>(
                              source: options,
                              value: (i, v) => i,
                              label: (i, v) => v,
                              tooltip: (i, v) => v,
                            ),
                            choiceStyle: C2ChipStyle.toned(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                            wrapped: true,
                          ),
                        )
                      : const Text(
                          "Please Wait",
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.black38,
                              fontFamily: "Nunito"),
                        );
                }),
            ValueListenableBuilder(
                valueListenable: totalAmountListener,
                builder: (context, value, child) {
                  return value
                      ? ContentNew(
                          title: '',
                          child: ChipsChoice<int>.single(
                            value: tag2,
                            onChanged: (val) => setState(() {
                              tag2 = val;
                              calculate();
                            }),
                            choiceItems: C2Choice.listFrom<int, String>(
                              source: options2,
                              value: (i, v) => i,
                              label: (i, v) => v,
                              tooltip: (i, v) => v,
                            ),
                            choiceStyle: C2ChipStyle.toned(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                            wrapped: true,
                          ),
                        )
                      : Container();
                }),
            const Text(
              "Your Commission Earning",
              style: TextStyle(
                fontFamily: "DMSans",
                fontSize: 22,
              ),
            ),
            ValueListenableBuilder(
              valueListenable: totalAmountListener,
              builder: (context, value, child) {
                return value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Rs.",
                              style: TextStyle(
                                  fontFamily: "DMSans",
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54)),
                          Text(result.toString(),
                              style: const TextStyle(
                                  fontFamily: "DMSans",
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                        ],
                      )
                    : const CircularProgressIndicator(
                        strokeWidth: 1,
                      );
              },
            ),
            StreamBuilder(
              stream: _server
                  .collection("GroundBookings")
                  .where('groundType',
                      isEqualTo: createFilterForSportsType(tag2))
                  .where("bookingCreated",
                      isGreaterThanOrEqualTo: createFilterIsGreaterThan(tag))
                  .where("bookingCreated",
                      isLessThanOrEqualTo: createFilterIsLessThan(tag))
                  .where('shouldCountInBalance', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                return snapshot.hasData
                    ? Column(
                        children: [
                          const Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text(
                                  "Payment History",
                                  style: TextStyle(
                                      fontFamily: "DMSans",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22),
                                ),
                              )
                            ],
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot doc = snapshot.data!.docs[index];
                              DateTime dt =
                                  (doc['bookedAt'] as Timestamp).toDate();
                              DateTime dt2 =
                                  (doc['bookingCreated'] as Timestamp).toDate();
                              String paymentDay =
                                  DateFormat.yMMMMEEEEd().format(dt);
                               String bookedActualDate =
                                  DateFormat.yMMMMEEEEd().format(dt2);
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(doc["groundName"],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontFamily: "DMSans",
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500)),
                                    const Text('Booking Day',
                                        style: TextStyle(
                                            fontFamily: "DMSans",
                                            color: Colors.black38)),  Text(bookedActualDate,
                                        style: const TextStyle(
                                            fontFamily: "DMSans",
                                            color: Colors.black38)),

                                    const Row(
                                      children: [
                                        Text("Received",
                                            style:
                                                TextStyle(color: Colors.green)),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(doc["bookingPerson"],
                                            style: const TextStyle(
                                                fontFamily: "DMSans",
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500)),
                                        Text(
                                            '+${doc["bookingCommissionCharged"]}',
                                            style: const TextStyle(
                                                fontFamily: "DMSans",
                                                color: Colors.green,
                                                fontSize: 18)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text("Amount Received : ",
                                            style: TextStyle(
                                                color: Colors.black45)),
                                        Text(paymentDay,
                                            style: const TextStyle(
                                              fontFamily: "DMSans",
                                            ))
                                      ],
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Divider(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    : Container();
              },
            )
          ]),
        ),
      ),
    );
  }

  createFilterIsGreaterThan(int val) {
    DateTime now = DateTime.now();
    switch (val) {
      case 0:
        {
          return DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day);
        }
      case 1:
        {
          return DateTime(
                  DateTime.now().year, DateTime.now().month, DateTime.now().day)
              .subtract(const Duration(days: 1));
        }
      case 2:
        {
          return DateTime(
                  DateTime.now().year, DateTime.now().month, DateTime.now().day)
              .add(const Duration(days: 1));
        }
      case 3:
        {
          return DateTime(now.year, now.month, now.day)
              .subtract(const Duration(days: 30));
        }
      case 4:
        {
          return DateTime(now.year, now.month, now.day);
        }
    }
  }

  createFilterIsLessThan(int val) {
    DateTime now = DateTime.now();
    switch (val) {
      case 0:
        {
          return DateTime(
                  DateTime.now().year, DateTime.now().month, DateTime.now().day)
              .add(const Duration(days: 1));
        }
      case 1:
        {
          return DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day);
        }
      case 2:
        {
          return DateTime(
                  DateTime.now().year, DateTime.now().month, DateTime.now().day)
              .add(const Duration(days: 2));
        }
      case 3:
        {
          return DateTime(now.year, now.month, now.day);
        }
      case 4:
        {
          return DateTime(now.year, now.month, now.day)
              .add(const Duration(days: 30));
        }
    }
  }

  Future<void> calculate() async {
    result = 0;
    data = 0;
    totalAmountListener.value = false;

    await _server
        .collection("GroundBookings")
        .where('groundType', isEqualTo: createFilterForSportsType(tag2))
        .where('shouldCountInBalance', whereIn: [true])
        .where("bookingCreated",
            isGreaterThanOrEqualTo: createFilterIsGreaterThan(tag))
        .where("bookingCreated",
            isLessThanOrEqualTo: createFilterIsLessThan(tag))
        .get()
        .then((value) => {
              for (int i = 0; i < value.docChanges.length; i++)
                {
                  data =
                      value.docChanges[i].doc.get("bookingCommissionCharged"),
                  result = result + data,
                },
              totalAmountListener.value = true
            });
  }

  createFilterForSportsType(int val) {
    switch (val) {
      case 0:
        {
          return 'Cricket';
        }
      case 1:
        {
          return 'Football';
        }
      case 2:
        {
          return 'Tennis';
        }
      case 3:
        {
          return 'Hockey';
        }
      case 4:
        {
          return 'Badminton';
        }
      case 5:
        {
          return 'Volleyball';
        }
      case 6:
        {
          return 'Swimming';
        }
    }
  }
}
