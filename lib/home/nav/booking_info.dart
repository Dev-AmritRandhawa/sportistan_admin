import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:sportistan_admin/home/home.dart';
import 'package:sportistan_admin/widgets/page_router.dart';
import 'package:sportistan_admin/widgets/send_cloud_message.dart';

class BookingInfo extends StatefulWidget {
  final String bookingID;

  const BookingInfo({super.key, required this.bookingID});

  @override
  State<BookingInfo> createState() => _BookingInfoState();
}

class _BookingInfoState extends State<BookingInfo> {
  String? bookingType;

  String? refDetails;

  String? userID;
  String? groundName;

  String? token;

  String? date;

  String? slotTime;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  final _server = FirebaseFirestore.instance;

  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: [
            StreamBuilder(
              stream: _server
                  .collection("GroundBookings")
                  .where("bookingID", isEqualTo: widget.bookingID)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = snapshot.data!.docs[index];
                      bookingType = doc['bookingPerson'];
                      refDetails = doc.id;
                      userID = doc['userID'];
                      groundName = doc['groundName'];
                      slotTime = doc['slotTime'];

                      Timestamp time = doc['bookedAt'];

                      Timestamp day = doc['bookingCreated'];
                      date = DateFormat.MMMMEEEEd().format(day.toDate());
                      DateTime booked = time.toDate();
                      bool isTeamBAvailable = doc["bothTeamBooked"];
                      return Column(
                        children: [
                          Screenshot(
                            controller: screenshotController,
                            child: Container(
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            "Booking ID",
                                            style: TextStyle(
                                                fontFamily: "DMSans",
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    50),
                                          ),
                                          Text(
                                            doc["bookingID"],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "DMSans",
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    50),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width /
                                          20,
                                      right: MediaQuery.of(context).size.width /
                                          20,
                                      top: MediaQuery.of(context).size.width /
                                          20,
                                      bottom:
                                          MediaQuery.of(context).size.width /
                                              20,
                                    ),
                                    child: Image.asset(
                                      "assets/logo.png",
                                      width: MediaQuery.of(context).size.width /
                                          15,
                                      height:
                                          MediaQuery.of(context).size.width /
                                              15,
                                    ),
                                  ),
                                  Text(doc["groundName"],
                                      style: const TextStyle(
                                          fontFamily: "DMSans", fontSize: 18)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Booking Generate : "),
                                      Text(
                                          "${DateFormat.yMMMMEEEEd().format(booked)} - ${DateFormat.jms().format(booked)}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Slot : ",
                                      ),
                                      Text(
                                        doc["slotTime"],
                                        style: const TextStyle(
                                            fontFamily: "DMSans",
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                  Card(
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                        MediaQuery.of(context).size.width / 20,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Row(
                                            children: [
                                              const Text("Booking Day : "),
                                              Text(
                                                DateFormat.MMMMEEEEd()
                                                    .format(day.toDate()),
                                                style: const TextStyle(
                                                    fontFamily: "DMSans",
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  doc['isBookingCancelled']
                                      ? const Card(
                                          child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text("Booking is Cancelled",
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ))
                                      : Container(),
                                  Padding(
                                    padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.width / 20,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Text("Advance Received : ",
                                                style: TextStyle(
                                                    color: Colors.green)),
                                            Text(
                                              "Rs. ${doc["advancePayment"]}",
                                              style: const TextStyle(
                                                  fontFamily: "DMSans",
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Text("Slot Amount : "),
                                            Text(
                                              "Rs. ${doc["slotPrice"]}",
                                              style: const TextStyle(
                                                  fontFamily: "DMSans",
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Fees Due : "),
                                      Text(
                                        "Rs. ${doc["feesDue"]}",
                                        style: TextStyle(
                                            color: Colors.red.shade200,
                                            fontFamily: "DMSans",
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Card(
                                    child: Column(children: [
                                      const Card(
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text("Team A"),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const Text("Team Name :"),
                                            Text(doc["teamA"]["teamName"],
                                                style: const TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: "DMSans")),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const Text("Contact Number :"),
                                            Text(doc["teamA"]["phoneNumber"],
                                                style: const TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: "DMSans")),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const Text("Contact Name :"),
                                            Text(doc["teamA"]["personName"],
                                                style: const TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: "DMSans")),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const Text("Notes : "),
                                            Expanded(
                                              child: Text(
                                                  doc["teamA"]["notesTeamA"],
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.visible,
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontFamily: "DMSans")),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]),
                                  ),
                                  isTeamBAvailable
                                      ? Card(
                                          child: Column(children: [
                                            const Card(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text("Team B"),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Text("Team Name :"),
                                                  Text(doc["teamB"]["teamName"],
                                                      style: const TextStyle(
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              "DMSans")),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                      "Contact Number :"),
                                                  Text(
                                                      doc["teamB"]
                                                          ["phoneNumber"],
                                                      style: const TextStyle(
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              "DMSans")),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Text("Contact Name :"),
                                                  Text(
                                                      doc["teamB"]
                                                          ["personName"],
                                                      style: const TextStyle(
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              "DMSans")),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Text("Notes : "),
                                                  Expanded(
                                                    child: Text(
                                                        doc["teamB"]
                                                            ["notesTeamB"],
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .visible,
                                                        style: const TextStyle(
                                                            fontSize: 18,
                                                            fontFamily:
                                                                "DMSans")),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ]),
                                        )
                                      : Container(),
                                  doc["isBookingCancelled"]
                                      ? const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            "Booking Cancelled",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 22,
                                                fontFamily: "DMSaNS"),
                                          ),
                                        )
                                      : const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            "Booking Confirmed",
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 22,
                                                fontFamily: "DMSaNS"),
                                          ),
                                        ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CupertinoButton(
                                          color: Colors.green,
                                          onPressed: () {
                                            PageRouter.pushRemoveUntil(
                                                context, const Home());
                                          },
                                          child: const Text("Home"),
                                        ),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CupertinoButton(
                                              color: Colors.indigo,
                                              onPressed: () {
                                                takeScreenshot();
                                              },
                                              child: const Text("Share"))),
                                    ],
                                  ),
                                  doc['isBookingCancelled']
                                      ? Container()
                                      : Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CupertinoButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (ctx) => Platform
                                                          .isAndroid
                                                      ? AlertDialog(
                                                          content: const Text(
                                                              "Would you like to cancel booking?",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                  fontFamily:
                                                                      "DMSans")),
                                                          title: const Text(
                                                              "Cancel Booking",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontFamily:
                                                                      "DMSans")),
                                                          actions: [
                                                            TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  await _server
                                                                      .collection(
                                                                          "GroundBookings")
                                                                      .doc(
                                                                          refDetails)
                                                                      .update({
                                                                    'isBookingCancelled':
                                                                        true
                                                                  }).then((value) async =>
                                                                          {
                                                                            Navigator.pop(ctx),
                                                                            refundInit(
                                                                                groundID: doc['groundID'],
                                                                                refund: doc['bookingCommissionCharged']),
                                                                          });
                                                                },
                                                                child: const Text(
                                                                    "Cancel Booking",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red,
                                                                        fontFamily:
                                                                            "DMSans"))),
                                                            TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      ctx);
                                                                },
                                                                child: const Text(
                                                                    "No",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black54,
                                                                        fontFamily:
                                                                            "DMSans"))),
                                                            TextButton(
                                                                onPressed: () {
                                                                  const number =
                                                                      '+918591719905'; //set the number here
                                                                  FlutterPhoneDirectCaller
                                                                      .callNumber(
                                                                          number);
                                                                },
                                                                child: const Text(
                                                                    "Call Customer Support",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .green,
                                                                        fontFamily:
                                                                            "DMSans"))),
                                                          ],
                                                        )
                                                      : CupertinoAlertDialog(
                                                          content: const Text(
                                                              "Would you like to cancel booking?",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                  fontFamily:
                                                                      "DMSans")),
                                                          title: const Text(
                                                              "Cancel Booking Entire Day",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontFamily:
                                                                      "DMSans")),
                                                          actions: [
                                                            TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  await _server
                                                                      .collection(
                                                                          "GroundBookings")
                                                                      .doc(
                                                                          refDetails)
                                                                      .update({
                                                                    'isBookingCancelled':
                                                                        true
                                                                  }).then((value) async =>
                                                                          {
                                                                            Navigator.pop(ctx),
                                                                            refundInit(
                                                                                groundID: doc['groundID'],
                                                                                refund: doc['bookingCommissionCharged']),
                                                                          });
                                                                },
                                                                child: const Text(
                                                                    "Cancel Booking",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red,
                                                                        fontFamily:
                                                                            "DMSans"))),
                                                            TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      ctx);
                                                                },
                                                                child: const Text(
                                                                    "No",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black54,
                                                                        fontFamily:
                                                                            "DMSans"))),
                                                            TextButton(
                                                                onPressed: () {
                                                                  const number =
                                                                      '+918591719905'; //set the number here
                                                                  FlutterPhoneDirectCaller
                                                                      .callNumber(
                                                                          number);
                                                                },
                                                                child: const Text(
                                                                    "Call Customer Support",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .green,
                                                                        fontFamily:
                                                                            "DMSans"))),
                                                          ],
                                                        ),
                                                );
                                              },
                                              child: const Text(
                                                "Cancel Booking",
                                                style: TextStyle(
                                                    color: Colors.red),
                                              )),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 1,
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 12,
            )
          ]),
        ),
      ),
    );
  }

  Future<void> takeScreenshot() async {
    await screenshotController
        .capture(delay: const Duration(milliseconds: 10))
        .then((Uint8List? image) async {
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File('${directory.path}/image.png').create();
        await imagePath.writeAsBytes(image);
        await Share.shareFiles([imagePath.path],
            text: 'Download Sportistan App for Your Sports Facility Booking https://www.sportistan.co.in/');
      }
    });
  }

  refundInit({
    required String groundID,
    required num refund,
  }) async {
    num sportistanCredit;
    try {
      await sendNotification();
      await _server
          .collection("SportistanPartners")
          .where("userID", isEqualTo: userID)
          .get()
          .then((value) async => {
                if (value.docChanges.isNotEmpty)
                  {
                    await _server
                        .collection("SportistanPartners")
                        .where("groundID", isEqualTo: groundID)
                        .get()
                        .then((value) async => {
                              sportistanCredit = value.docChanges.first.doc
                                  .get('sportistanCredit'),
                              await _server
                                  .collection("SportistanPartners")
                                  .doc(value.docChanges.first.doc.id)
                                  .update({
                                'sportistanCredit': sportistanCredit + refund
                              }).then((value) => {})
                            })
                  }
                else
                  {
                    await _server
                        .collection("Sportistan")
                        .where("userID", isEqualTo: userID)
                        .get()
                        .then((value) async => {
                              sportistanCredit = value.docChanges.first.doc
                                  .get('sportistanCredit'),
                              await _server
                                  .collection("Sportistan")
                                  .doc(value.docChanges.first.doc.id)
                                  .update({
                                'sportistanCredit': sportistanCredit + refund
                              }).then((value) => {})
                            })
                  }
              });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Failed to Refund")));
      }
    }
  }

  sendNotification() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _server
        .collection("DeviceTokens")
        .where("userID", isEqualTo: userID)
        .get();

    final token = snapshot.docs[0].get("token");

    FirebaseCloudMessaging.sendPushMessage(
        "$groundName Booking is Cancelled of Slot $slotTime and $date",
        "Booking Cancelled",
        token);
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
