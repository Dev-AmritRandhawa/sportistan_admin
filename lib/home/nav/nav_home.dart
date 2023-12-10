import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sportistan_admin/authentication/login.dart';
import 'package:sportistan_admin/home/nav/booking_info.dart';
import 'package:sportistan_admin/widgets/page_router.dart';
import 'booking_entireday_info.dart';

class Bookings extends StatefulWidget {
  const Bookings({super.key});

  @override
  State<Bookings> createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {
  final _server = FirebaseFirestore.instance;

  ValueNotifier<bool> showFilter = ValueNotifier<bool>(false);

  var options = [
    "Today",
    "Yesterday",
    "Tomorrow",
    "Past 30 Days",
    "Upcoming 30 Days"
  ];
  var tag = 0;
  var options2 = [
    "Both",
    "Entire Day",
    "Single Bookings",
  ];
  var tag2 = 0;

  var options3 = [
    'Cricket',
    'Football',
    'Tennis',
    'Hockey',
    'Badminton',
    'Volleyball',
    'Swimming',
  ];

  var tag3 = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(useMaterial3: false),
      home: Scaffold(
          body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        FirebaseAuth.instance
                            .signOut()
                            .then((value) => {
                          PageRouter.pushRemoveUntil(context, const Login())
                        });
                      },
                      icon: const CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.power_settings_new_rounded,
                            color: Colors.white,
                          ))),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Bookings",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: "DMSans",
                          fontSize: MediaQuery.of(context).size.height / 25,
                        ) //TextStyle
                        ),
                  ),
                ],
              ),
              ValueListenableBuilder(
                valueListenable: showFilter,
                builder: (context, value, child) => value
                    ? DelayedDisplay(
                        child: Column(
                          children: [
                            ContentNew(
                              child: ChipsChoice<int>.single(
                                value: tag,
                                onChanged: (val) => setState(() {
                                  tag = val;
                                  createFilterIsGreaterThan(val);
                                  createFilterIsLessThan(val);
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
                            ),
                            ContentNew(
                              child: ChipsChoice<int>.single(
                                value: tag2,
                                onChanged: (val) => setState(() {
                                  tag2 = val;
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
                            ),
                            ContentNew(
                              child: ChipsChoice<int>.single(
                                value: tag3,
                                onChanged: (val) => setState(() {
                                  tag3 = val;
                                }),
                                choiceItems: C2Choice.listFrom<int, String>(
                                  source: options3,
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
                            ),
                            Card(
                              color: Colors.red.shade400,
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("   Close Filter Tray",
                                        style: TextStyle(color: Colors.white)),
                                    IconButton(
                                        onPressed: () {
                                          showFilter.value = false;
                                        },
                                        icon: const Icon(
                                          Icons.clear,
                                          color: Colors.white,
                                        )),
                                  ]),
                            )
                          ],
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Text(
                                "Filter",
                                style: TextStyle(
                                    fontFamily: "DMSans", fontSize: 18),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: CircleAvatar(
                                child: IconButton(
                                    onPressed: () {
                                      showFilter.value = true;
                                    },
                                    icon:
                                        const Icon(Icons.filter_alt_outlined)),
                              ),
                            )
                          ]),
              ),
              const Divider(),
              StreamBuilder<QuerySnapshot>(
                  stream: _server
                      .collection("GroundBookings")
                      .where("bookingCreated",
                          isGreaterThanOrEqualTo:
                              createFilterIsGreaterThan(tag))
                      .where("bookingCreated",
                          isLessThanOrEqualTo: createFilterIsLessThan(tag))
                      .where('groundType',
                          isEqualTo: createFilterForSportsType(tag3))
                      .where('entireDayBooking',
                          whereIn: createFilterForBookingType(tag2))
                      .snapshots(),
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? snapshot.data!.size != 0
                            ? ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot doc =
                                      snapshot.data!.docs[index];
                                  DateTime dt =
                                      (doc['bookedAt'] as Timestamp).toDate();
                                  String bookedDate =
                                      DateFormat.yMMMMEEEEd().format(dt);
                                  List<dynamic> allSlotsRef = [];
                                  if (doc['entireDayBooking']) {
                                    allSlotsRef = doc['includeSlots'];
                                  }
                                  int bookingIndex = index + 1;
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        checkBookingType(
                                            entireDayBooked:
                                                doc['entireDayBooking'],
                                            bookingID: doc['bookingID']);
                                      },
                                      child: Card(
                                        color: Colors.grey.shade50,
                                        child: Column(
                                          children: [
                                            CircleAvatar(
                                                backgroundColor:
                                                    doc['isBookingCancelled']
                                                        ? Colors.red
                                                        : Colors.green,
                                                child: Text(
                                                  bookingIndex.toString(),
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                )),
                                            Row(
                                              children: [
                                                Card(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                          doc['groundType']),
                                                    ))
                                              ],
                                            ),
                                            const Text(
                                              "Booked by",
                                              style: TextStyle(
                                                  fontFamily: "DMSans",
                                                  color: Colors.black45),
                                            ),
                                            Text(
                                              doc["bookingPerson"],
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black87,
                                                  fontFamily: "DMSans",
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            doc['entireDayBooking']
                                                ? Card(
                                                    color: Colors.indigo,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                          "Entire Day Booked - ${DateFormat.yMMMMEEEEd().format(DateTime.parse(doc["group"]))}",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white)),
                                                    ))
                                                : Container(),
                                            doc["isBookingCancelled"]
                                                ? const Text(
                                                    "Cancelled",
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.red,
                                                        fontFamily: "DMSans",
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                : Container(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Text("Booked at : "),
                                                Text(bookedDate,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                            const Row(
                                              children: [
                                                Text("   Booking Details",
                                                    style: TextStyle(
                                                        fontFamily: "DMSans")),
                                              ],
                                            ),
                                            doc['entireDayBooking']
                                                ? Container()
                                                : ListTile(
                                                    title: Text(doc["slotTime"],
                                                        style: const TextStyle(
                                                            fontSize: 20)),
                                                    subtitle: Text(DateFormat
                                                            .yMMMMEEEEd()
                                                        .format(DateTime.parse(
                                                            doc["group"]))),
                                                    trailing: const Icon(Icons
                                                        .arrow_forward_ios),
                                                  ),
                                            doc['entireDayBooking']
                                                ? Container()
                                                : Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                            '(${doc["slotStatus"]})',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: setStatusColor(doc[
                                                                    "slotStatus"]),
                                                                fontFamily:
                                                                    "DMSans")),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child:
                                                            doc["feesDue"] == 0
                                                                ? const Text(
                                                                    "Paid",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .green),
                                                                  )
                                                                : Row(
                                                                    children: [
                                                                      Text(
                                                                        "Due Amount : Rs.",
                                                                        style:
                                                                            TextStyle(
                                                                          color: Colors
                                                                              .red
                                                                              .shade200,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                          doc["feesDue"]
                                                                              .toString(),
                                                                          style: TextStyle(
                                                                              color: Colors.red.shade200,
                                                                              fontSize: 15,
                                                                              fontFamily: "DMSans")),
                                                                    ],
                                                                  ),
                                                      ),
                                                    ],
                                                  ),
                                            doc.get('entireDayBooking')
                                                ? SizedBox(
                                                    width: double.infinity,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            15,
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          allSlotsRef.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: OutlinedButton(
                                                              onPressed: null,
                                                              child: Text(
                                                                  allSlotsRef[
                                                                          index]
                                                                      .toString())),
                                                        );
                                                      },
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                })
                            : Column(
                                children: [
                                  const Center(
                                      child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "No Booking Found",
                                      style: TextStyle(
                                          color: Colors.black38,
                                          fontFamily: "DMSans"),
                                    ),
                                  )),
                                  Image.asset(
                                    "assets/logo.png",
                                    width:
                                        MediaQuery.of(context).size.height / 8,
                                    height:
                                        MediaQuery.of(context).size.height / 8,
                                  )
                                ],
                              )
                        : const Column(
                            children: [
                              Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            ],
                          );
                  })
            ],
          ),
        ),
      )),
    );
  }

  Color setStatusColor(String result) {
    switch (result) {
      case "Booked":
        {
          return Colors.green;
        }
      case "Half Booked":
        {
          return Colors.orangeAccent;
        }
      case "Fees Due":
        {
          return Colors.red.shade200;
        }
    }
    return Colors.white;
  }

  void checkBookingType(
      {required bool entireDayBooked, required String bookingID}) {
    if (entireDayBooked) {
      PageRouter.push(
          context,
          BookingEntireDayInfo(
            bookingID: bookingID,
          ));
    } else {
      PageRouter.push(
          context,
          BookingInfo(
            bookingID: bookingID,
          ));
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
                  DateTime.now().year, DateTime.now().month, DateTime.now().day)
              .subtract(const Duration(days: 1));
        }
      case 2:
        {
          return DateTime(
                  DateTime.now().year, DateTime.now().month, DateTime.now().day)
              .add(const Duration(days: 2));
        }
      case 3:
        {
          return DateTime(now.year, now.month, now.day)
              .subtract(const Duration(days: 1));
        }
      case 4:
        {
          return DateTime(now.year, now.month, now.day)
              .add(const Duration(days: 30));
        }
    }
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
          return DateTime(now.year, now.month, now.day)
              .add(const Duration(days: 1));
        }
    }
  }

  createFilterForBookingType(int val) {
    switch (val) {
      case 0:
        {
          return [true, false];
        }
      case 1:
        {
          return [true];
        }
      case 2:
        {
          return [false];
        }
    }
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

class ContentNew extends StatefulWidget {
  const ContentNew({super.key, required this.child});

  final Widget child;

  @override
  State<ContentNew> createState() => _ContentNewState();
}

class _ContentNewState extends State<ContentNew> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(fit: FlexFit.loose, child: widget.child),
        ],
      ),
    );
  }
}
