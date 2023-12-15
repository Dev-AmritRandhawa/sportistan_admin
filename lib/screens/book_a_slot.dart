import 'dart:io';
import 'dart:math';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:sportistan_admin/home/nav/booking_info.dart';
import 'package:sportistan_admin/widgets/errors.dart';
import 'package:sportistan_admin/widgets/page_router.dart';

class BookASlot extends StatefulWidget {
  final String group;

  final String slotID;
  final String bookingID;
  final String date;
  final String groundID;
  final String groundName;
  final String groundAddress;
  final int slotPrice;
  final String slotTime;
  final String groundType;
  final String slotStatus;

  const BookASlot({
    super.key,
    required this.group,
    required this.date,
    required this.slotID,
    required this.bookingID,
    required this.slotTime,
    required this.slotStatus,
    required this.slotPrice,
    required this.groundName,
    required this.groundType,
    required this.groundID,
    required this.groundAddress,
  });

  @override
  State<BookASlot> createState() => _BookASlotState();
}

class _BookASlotState extends State<BookASlot> {
  String countryCode = '+91';
  TextEditingController teamControllerA = TextEditingController();
  TextEditingController teamControllerB = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController advancePaymentController = TextEditingController();
  TextEditingController advancePaymentControllerTeamB = TextEditingController();
  GlobalKey<FormState> advancePaymentKey = GlobalKey<FormState>();
  GlobalKey<FormState> advancePaymentKeyTeamB = GlobalKey<FormState>();
  TextEditingController nameControllerB = TextEditingController();
  TextEditingController nameControllerA = TextEditingController();
  TextEditingController numberControllerA = TextEditingController();
  TextEditingController numberControllerB = TextEditingController();
  GlobalKey<FormState> nameKeyA = GlobalKey<FormState>();
  GlobalKey<FormState> nameKeyB = GlobalKey<FormState>();
  GlobalKey<FormState> numberKeyA = GlobalKey<FormState>();
  GlobalKey<FormState> numberKeyB = GlobalKey<FormState>();
  GlobalKey<FormState> teamControllerKeyA = GlobalKey<FormState>();
  GlobalKey<FormState> teamControllerKeyB = GlobalKey<FormState>();

  ValueNotifier<bool> checkBoxTeamB = ValueNotifier<bool>(false);
  ValueNotifier<bool> showTeamB = ValueNotifier<bool>(false);
  ValueNotifier<bool> readOnly = ValueNotifier<bool>(true);
  ValueNotifier<bool> amountUpdateListener = ValueNotifier<bool>(true);
  ValueNotifier<bool> copyAsAbove = ValueNotifier<bool>(false);

  bool amountUpdated = false;

  final _server = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  TextEditingController notesTeamA = TextEditingController();
  TextEditingController notesTeamB = TextEditingController();

  late int updatedPrice;

  bool updateSmsAlert = true;

  bool alreadyCommissionCharged = false;

  Future<void> serverInit() async {
    if (widget.bookingID.isNotEmpty) {
      await _server
          .collection("GroundBookings")
          .where("bookingID", isEqualTo: widget.bookingID)
          .get()
          .then((value) => {
                if (value.docs.isNotEmpty)
                  {
                    updatedPrice = value.docs[0]["feesDue"],
                    advancePaymentController.text =
                        value.docs[0]["advancePayment"].toString(),
                    teamControllerA.text =
                        value.docs.first["teamA"]["teamName"],
                    teamControllerB.text =
                        value.docs.first["teamB"]["teamName"],
                    numberControllerA.text =
                        value.docs.first["teamA"]["phoneNumber"],
                    numberControllerB.text =
                        value.docs.first["teamB"]["phoneNumber"],
                    nameControllerA.text =
                        value.docs.first["teamA"]["personName"],
                    nameControllerB.text =
                        value.docs.first["teamB"]["personName"],
                    notesTeamA.text = value.docs.first["teamA"]["notesTeamA"],
                    notesTeamB.text = value.docs.first["teamB"]["notesTeamB"],
                    updatedPrice = value.docs.first["slotPrice"],
                    priceController.text =
                        value.docs.first["totalSlotPrice"].toString(),
                    checkBoxTeamB.value = true,
                    readOnly.value = false,
                    showTeamB.value = true,
                    amountUpdateListener.value = false,
                    alreadyCommissionCharged = true,
                  }
              });
    } else {
      priceController.text = widget.slotPrice.toString();
      updatedPrice = widget.slotPrice;
      double newAmount = updatedPrice / 2.toInt().round();
      priceController.text = newAmount.round().toInt().toString();
    }
  }

  @override
  void dispose() {
    priceController.dispose();
    teamControllerA.dispose();
    teamControllerB.dispose();
    numberControllerA.dispose();
    numberControllerB.dispose();
    nameControllerA.dispose();
    nameControllerB.dispose();
    super.dispose();
  }

  @override
  void initState() {
    serverInit();
    super.initState();
  }

  PhoneContact? _phoneContact;

  checkPermissionForContacts(TextEditingController controller) async {
    final granted = await FlutterContactPicker.hasPermission();
    if (granted) {
      final PhoneContact contact =
          await FlutterContactPicker.pickPhoneContact();
      setState(() {
        _phoneContact = contact;
      });
      if (_phoneContact!.phoneNumber != null) {
        if (_phoneContact!.phoneNumber!.number!.length > 10) {
          controller.text = _phoneContact!.phoneNumber!.number!
              .substring(3)
              .split(" ")
              .join("");
        } else {
          controller.text =
              _phoneContact!.phoneNumber!.number!.split(" ").join("");
        }
      }
    } else {
      requestPermission(controller);
    }
  }

  requestPermission(controller) async {
    await FlutterContactPicker.requestPermission();
    checkPermissionForContacts(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Text(
                widget.groundName,
                style: TextStyle(
                    color: Colors.black87,
                    fontFamily: "Nunito",
                    fontSize: MediaQuery.of(context).size.width / 25),
              ),
              Text(
                textAlign: TextAlign.center,
                widget.groundAddress,
                style: TextStyle(
                    color: Colors.black87,
                    fontFamily: "Nunito",
                    fontSize: MediaQuery.of(context).size.width / 25),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            const Text("Slot Time :",
                                style: TextStyle(
                                    color: Colors.black45,
                                    fontWeight: FontWeight.bold)),
                            Text(widget.slotTime,
                                style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            const Text("Date :",
                                style: TextStyle(
                                    color: Colors.black45,
                                    fontWeight: FontWeight.bold)),
                            Text(
                                DateFormat.yMMMd()
                                    .format(DateTime.parse(widget.group)),
                                style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              widget.bookingID.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          PageRouter.push(context,
                              BookingInfo(bookingID: widget.bookingID));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.bookingID,
                              style: const TextStyle(color: Colors.green),
                            ),
                            TextButton(
                                onPressed: () {
                                  PageRouter.push(context,
                                      BookingInfo(bookingID: widget.bookingID));
                                },
                                child: const Text(
                                  "View Receipt",
                                  style: TextStyle(color: Colors.black87),
                                )),
                          ],
                        ),
                      ),
                    )
                  : Container(),
              SizedBox(
                width: double.infinity,
                child: Card(
                  color: Colors.grey.shade100,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          key: teamControllerKeyA,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 1.2,
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Team name required.";
                                } else if (value.length <= 2) {
                                  return "Enter Correct Name.";
                                } else {
                                  return null;
                                }
                              },
                              controller: teamControllerA,
                              onChanged: (data) {
                                nameKeyA.currentState!.validate();
                              },
                              decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  border: InputBorder.none,
                                  errorStyle: TextStyle(color: Colors.red),
                                  labelText: "Team A Name*",
                                  filled: true,
                                  labelStyle: TextStyle(color: Colors.black)),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          key: nameKeyA,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 1.2,
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Name required.";
                                } else if (value.length <= 2) {
                                  return "Enter Correct Name.";
                                } else {
                                  return null;
                                }
                              },
                              controller: nameControllerA,
                              onChanged: (data) {
                                nameKeyA.currentState!.validate();
                              },
                              keyboardType: TextInputType.name,
                              decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  labelText: "Contact Person*",
                                  border: InputBorder.none,
                                  errorStyle: TextStyle(color: Colors.red),
                                  filled: true,
                                  labelStyle: TextStyle(color: Colors.black)),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          key: numberKeyA,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 1.2,
                            child: TextFormField(
                              maxLength: 10,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Number required.";
                                } else if (value.length != 10) {
                                  return "Enter 10 digits.";
                                } else {
                                  return null;
                                }
                              },
                              controller: numberControllerA,
                              onChanged: (data) {
                                numberKeyA.currentState!.validate();
                              },
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp('[0-9]')),
                              ],
                              autofillHints: const [
                                AutofillHints.telephoneNumberLocal
                              ],
                              decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  border: InputBorder.none,
                                  errorStyle:
                                      const TextStyle(color: Colors.red),
                                  filled: true,
                                  prefixIcon: IconButton(
                                      onPressed: () async {
                                        checkPermissionForContacts(
                                            numberControllerA);
                                      },
                                      icon: const Icon(Icons.contacts_rounded)),
                                  suffixIcon: IconButton(
                                      onPressed: () async {
                                        if (numberControllerA
                                            .value.text.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      "No Number Available")));
                                        } else {
                                          FlutterPhoneDirectCaller.callNumber(
                                              numberControllerA.value.text);
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.call,
                                        color: Colors.blue,
                                      )),
                                  labelText: "Contact Number*",
                                  labelStyle:
                                      const TextStyle(color: Colors.black)),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          child: TextFormField(
                            controller: notesTeamA,
                            decoration: const InputDecoration(
                              fillColor: Colors.white,
                              border: InputBorder.none,
                              errorStyle: TextStyle(color: Colors.red),
                              filled: true,
                              hintText: "Notes (Optional)",
                              hintStyle: TextStyle(color: Colors.black45),
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 40),
                            ),
                          ),
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: amountUpdateListener,
                        builder: (BuildContext context, value, Widget? child) {
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    child: Form(
                                      key: advancePaymentKey,
                                      child: TextFormField(
                                        enabled: value,
                                        controller: advancePaymentController,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            Errors.flushBarInform(
                                                "Advance Amount is Missing",
                                                context,
                                                "Error");
                                            return "Enter Advance";
                                          } else if (double.parse(
                                                      advancePaymentController
                                                          .value.text)
                                                  .round()
                                                  .toInt() >
                                              double.parse(priceController
                                                      .value.text)
                                                  .round()
                                                  .toInt()) {
                                            return "Invalid Amount";
                                          } else {
                                            return null;
                                          }
                                        },
                                        keyboardType: TextInputType.phone,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        autofillHints: const [
                                          AutofillHints.telephoneNumberLocal
                                        ],
                                        decoration: const InputDecoration(
                                          label: Text("Advance Team A"),
                                          fillColor: Colors.white,
                                          border: InputBorder.none,
                                          errorStyle:
                                              TextStyle(color: Colors.red),
                                          filled: true,
                                          hintText: "Booking Amt?",
                                        ),
                                      ),
                                    ),
                                  ),
                                  ValueListenableBuilder(
                                    valueListenable: readOnly,
                                    builder: (context, value, child) {
                                      return SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        child: TextFormField(
                                          enabled: false,
                                          onTap: () {
                                            amountUpdateListener.value = true;
                                          },
                                          keyboardType: TextInputType.phone,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          controller: priceController,
                                          decoration: const InputDecoration(
                                            prefix: Text("₹",
                                                style: TextStyle(
                                                    color: Colors.green)),
                                            fillColor: Colors.white,
                                            border: InputBorder.none,
                                            filled: true,
                                            label: Text("Slot Price"),
                                            hintStyle:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ValueListenableBuilder(
                                    valueListenable: checkBoxTeamB,
                                    builder: (context, value, child) =>
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CupertinoSwitch(
                                                  value: value,
                                                  onChanged: widget
                                                          .bookingID.isNotEmpty
                                                      ? null
                                                      : (result) {
                                                          if (nameKeyA
                                                                  .currentState!
                                                                  .validate() &
                                                              numberKeyA
                                                                  .currentState!
                                                                  .validate() &
                                                              teamControllerKeyA
                                                                  .currentState!
                                                                  .validate()) {
                                                            checkBoxTeamB
                                                                .value = result;
                                                            teamControllerB
                                                                    .text =
                                                                teamControllerA
                                                                    .value.text;
                                                            nameControllerB
                                                                    .text =
                                                                nameControllerA
                                                                    .value.text;
                                                            numberControllerB
                                                                    .text =
                                                                numberControllerA
                                                                    .value.text;
                                                            showTeamB.value =
                                                                result;
                                                            if (result) {
                                                              setState(() {
                                                                int newAmount =
                                                                    updatedPrice;
                                                                priceController
                                                                        .text =
                                                                    newAmount
                                                                        .toString();
                                                              });
                                                            } else {
                                                              setState(() {
                                                                double
                                                                    newAmount =
                                                                    updatedPrice /
                                                                        2
                                                                            .toInt()
                                                                            .round();
                                                                priceController
                                                                        .text =
                                                                    newAmount
                                                                        .round()
                                                                        .toInt()
                                                                        .toString();
                                                              });
                                                            }
                                                          }
                                                        }),
                                              const Text(
                                                "Book for both Teams",
                                                style: TextStyle(
                                                    fontFamily: "DMSans"),
                                              )
                                            ],
                                          ),
                                        )),
                              ),
                              ListView(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                addAutomaticKeepAlives: true,
                                children: <Widget>[
                                  Content(
                                    title: 'Choose Mode Of Payment',
                                    child: ChipsChoice<String>.single(
                                      value: PaymentMode.type,
                                      onChanged: (val) => setState(
                                          () => PaymentMode.type = val),
                                      choiceItems:
                                          C2Choice.listFrom<String, String>(
                                        source: PaymentMode.paymentOptions,
                                        value: (i, v) => v,
                                        label: (i, v) => v,
                                        tooltip: (i, v) => v,
                                      ),
                                      choiceCheckmark: true,
                                      choiceStyle: C2ChipStyle.filled(
                                        color: Colors.blue,
                                        selectedStyle: const C2ChipStyle(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(25),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  MaterialButton(
                                      color: Colors.red,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        "Go Back",
                                        style: TextStyle(color: Colors.white),
                                      )),
                                  MaterialButton(
                                      color: Colors.green,
                                      onPressed: () async {
                                        if (nameKeyA.currentState!.validate() &
                                            numberKeyA.currentState!
                                                .validate() &
                                            teamControllerKeyA.currentState!
                                                .validate()) {
                                          if (checkBoxTeamB.value) {
                                            if (nameKeyB.currentState!
                                                    .validate() &
                                                numberKeyB.currentState!
                                                    .validate() &
                                                teamControllerKeyB.currentState!
                                                    .validate()) {
                                              if (numberControllerA
                                                      .value.text !=
                                                  numberControllerB
                                                      .value.text) {}
                                              if (advancePaymentKey
                                                  .currentState!
                                                  .validate()) {
                                                if (advancePaymentKeyTeamB
                                                    .currentState!
                                                    .validate()) {
                                                  await _bookSlot();
                                                }
                                              }
                                            } else {
                                              Errors.flushBarInform(
                                                  "Field Required for Team B*",
                                                  context,
                                                  "Enter field");
                                            }
                                          } else {
                                            if (advancePaymentKey.currentState!
                                                .validate()) {
                                              await _bookSlot();
                                            }
                                          }
                                        } else {
                                          Errors.flushBarInform(
                                              "Field Required for Team A*",
                                              context,
                                              "Enter field");
                                        }
                                      },
                                      child: const Text(
                                        "Book Slot",
                                        style: TextStyle(color: Colors.white),
                                      ))
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      Column(
                        children: [
                          widget.bookingID.isEmpty
                              ? Container()
                              : const Text("Copy As Above Team Details?"),
                          widget.bookingID.isEmpty
                              ? Container()
                              : ValueListenableBuilder(
                                  valueListenable: copyAsAbove,
                                  builder: (context, value, child) {
                                    return CupertinoSwitch(
                                      value: value,
                                      onChanged: (value) {
                                        if (copyAsAbove.value) {
                                          copyAsAbove.value = false;
                                          nameControllerB.clear();
                                          numberControllerB.clear();
                                          teamControllerB.clear();
                                        } else {
                                          nameControllerB.text =
                                              nameControllerA.value.text;
                                          numberControllerB.text =
                                              numberControllerA.value.text;
                                          teamControllerB.text =
                                              teamControllerA.value.text;
                                          copyAsAbove.value = true;
                                        }
                                      },
                                    );
                                  },
                                ),
                          ValueListenableBuilder(
                            valueListenable: showTeamB,
                            builder: (context, value, child) {
                              return value
                                  ? Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Form(
                                            key: teamControllerKeyB,
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.2,
                                              child: TextFormField(
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return "Team name required.";
                                                  } else if (value.length <=
                                                      2) {
                                                    return "Enter Correct Name.";
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                controller: teamControllerB,
                                                onChanged: (data) {
                                                  nameKeyB.currentState!
                                                      .validate();
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                        fillColor: Colors.white,
                                                        border:
                                                            InputBorder.none,
                                                        errorStyle: TextStyle(
                                                            color: Colors.red),
                                                        labelText:
                                                            "Team B Name*",
                                                        filled: true,
                                                        labelStyle: TextStyle(
                                                            color:
                                                                Colors.black)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Form(
                                            key: nameKeyB,
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.2,
                                              child: TextFormField(
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return "Name required.";
                                                  } else if (value.length <=
                                                      2) {
                                                    return "Enter Correct Name.";
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                controller: nameControllerB,
                                                onChanged: (data) {
                                                  nameKeyB.currentState!
                                                      .validate();
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                        fillColor: Colors.white,
                                                        labelText:
                                                            "Contact Person*",
                                                        border:
                                                            InputBorder.none,
                                                        errorStyle: TextStyle(
                                                            color: Colors.red),
                                                        filled: true,
                                                        labelStyle: TextStyle(
                                                            color:
                                                                Colors.black)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Form(
                                            key: numberKeyB,
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.2,
                                              child: TextFormField(
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return "Number required.";
                                                  } else if (value.length !=
                                                      10) {
                                                    return "Enter 10 digits.";
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                maxLength: 10,
                                                controller: numberControllerB,
                                                onChanged: (data) {
                                                  numberKeyB.currentState!
                                                      .validate();
                                                },
                                                keyboardType:
                                                    TextInputType.phone,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp('[0-9]')),
                                                ],
                                                autofillHints: const [
                                                  AutofillHints
                                                      .telephoneNumberLocal
                                                ],
                                                decoration: InputDecoration(
                                                    fillColor: Colors.white,
                                                    border: InputBorder.none,
                                                    errorStyle: const TextStyle(
                                                        color: Colors.red),
                                                    filled: true,
                                                    prefixIcon: IconButton(
                                                        onPressed: () async {
                                                          checkPermissionForContacts(
                                                              numberControllerB);
                                                        },
                                                        icon: const Icon(Icons
                                                            .contacts_rounded)),
                                                    suffixIcon: IconButton(
                                                        onPressed: () async {
                                                          if (numberControllerB
                                                              .value
                                                              .text
                                                              .isEmpty) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    const SnackBar(
                                                                        content:
                                                                            Text("No Number Available")));
                                                          } else {
                                                            FlutterPhoneDirectCaller
                                                                .callNumber(
                                                                    numberControllerB
                                                                        .value
                                                                        .text);
                                                          }
                                                        },
                                                        icon: const Icon(
                                                          Icons.call,
                                                          color: Colors.blue,
                                                        )),
                                                    labelText:
                                                        "Contact Number*",
                                                    labelStyle: const TextStyle(
                                                        color: Colors.black)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3,
                                          child: Form(
                                            key: advancePaymentKeyTeamB,
                                            child: TextFormField(
                                              enabled: value,
                                              controller:
                                                  advancePaymentControllerTeamB,
                                              validator: (value) {
                                                int advanceB = 0;
                                                if (checkBoxTeamB.value) {
                                                  advanceB = double.parse(
                                                          advancePaymentControllerTeamB
                                                              .value.text)
                                                      .round()
                                                      .toInt();
                                                }
                                                var advanceA = double.parse(
                                                        advancePaymentController
                                                            .value.text)
                                                    .round()
                                                    .toInt();
                                                var totalSlot = double.parse(
                                                        priceController
                                                            .value.text)
                                                    .round()
                                                    .toInt();
                                                if (value!.isEmpty) {
                                                  Errors.flushBarInform(
                                                      "Advance Amount is Missing",
                                                      context,
                                                      "Error");
                                                  return "Enter Advance";
                                                } else if (advanceA + advanceB >
                                                    totalSlot) {
                                                  return "Invalid Amount";
                                                } else {
                                                  return null;
                                                }
                                              },
                                              keyboardType: TextInputType.phone,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              autofillHints: const [
                                                AutofillHints
                                                    .telephoneNumberLocal
                                              ],
                                              decoration: const InputDecoration(
                                                label: Text("Advance Team B"),
                                                fillColor: Colors.white,
                                                border: InputBorder.none,
                                                errorStyle: TextStyle(
                                                    color: Colors.red),
                                                filled: true,
                                                hintText: "Booking Amt?",
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SizedBox(
                                            child: TextFormField(
                                              controller: notesTeamB,
                                              decoration: const InputDecoration(
                                                fillColor: Colors.white,
                                                border: InputBorder.none,
                                                errorStyle: TextStyle(
                                                    color: Colors.red),
                                                filled: true,
                                                hintText: "Notes (Optional)",
                                                hintStyle: TextStyle(
                                                    color: Colors.black45),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 40),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  late List<DocumentChange<Map<String, dynamic>>> data;

  Future<void> _bookSlot() async {
    if (widget.bookingID.isEmpty) {
      String uniqueID = UniqueID.generateRandomString();

      try {
        await _server.collection("GroundBookings").add({
          'slotTime': widget.slotTime,
          'bookingPerson': 'Ground Owner',
          'groundName': widget.groundName,
          'bookingCreated': DateTime.parse(widget.date),
          'bookedAt': DateTime.now(),
          'userID': _auth.currentUser!.uid,
          'groundType': widget.groundType,
          'group': widget.group,
          'isBookingCancelled': false,
          'shouldCountInBalance': false,
          'entireDayBooking': false,
          'bookingCommissionCharged': 0,
          'entireDayBookingID': [],
          'feesDue': calculateFeesDue(),
          'paymentMode': PaymentMode.type,
          'ratingGiven': false,
          'rating': 3.0,
          'bothTeamBooked': checkBoxTeamB.value,
          'groundID': widget.groundID,
          "teamA": {
            'teamName': teamControllerA.value.text,
            'personName': nameControllerA.value.text,
            'phoneNumber': numberControllerA.value.text,
            "notesTeamA": notesTeamA.value.text.isNotEmpty
                ? notesTeamA.value.text.toString()
                : "",
          },
          "teamB": {
            'teamName': checkBoxTeamB.value ? teamControllerB.value.text : '',
            'personName': checkBoxTeamB.value ? nameControllerB.value.text : '',
            'phoneNumber':
                checkBoxTeamB.value ? numberControllerB.value.text : '',
            "notesTeamB": notesTeamB.value.text.isNotEmpty
                ? notesTeamB.value.text.toString()
                : "",
          },
          'totalSlotPrice': updatedPrice,
          'slotPrice': int.parse(priceController.value.text.toString()),
          'advancePayment': checkBoxTeamB.value
              ? double.parse(advancePaymentController.value.text)
                      .round()
                      .toInt() +
                  double.parse(advancePaymentControllerTeamB.value.text)
                      .round()
                      .toInt()
              : double.parse(advancePaymentController.value.text)
                  .round()
                  .toInt(),
          'slotStatus': slotStatus(),
          'slotID': widget.slotID,
          'bookingID': uniqueID,
          'date': widget.date,
        });
        alertUser(bookingID: uniqueID);

      } on SocketException catch (e) {
        if (mounted) {
          Errors.flushBarInform(e.toString(), context, "Internet Connectivity");
        }
      } catch (e) {
        if (mounted) {
          Errors.flushBarInform(e.toString(), context, "Error");
        }
      }
    } else {
      try {
        var refDetails = await _server
            .collection("GroundBookings")
            .where("bookingID", isEqualTo: widget.bookingID)
            .get();
        await _server
            .collection("GroundBookings")
            .doc(refDetails.docs.first.id)
            .update({
          'slotTime': widget.slotTime,
          'bookingPerson': 'Ground Owner',
          'groundName': widget.groundName,
          'bookingCreated': DateTime.parse(widget.date),
          'bookedAt': DateTime.now(),
          'groundType': widget.groundType,
          'shouldCountInBalance': false,
          'isBookingCancelled': false,
          'userID': _auth.currentUser!.uid,
          'bookingCommissionCharged': 0,
          'feesDue': calculateFeesDue(),
          'paymentMode': PaymentMode.type,
          'ratingGiven': false,
          'rating': 3.0,
          'ratingTags': [],
          'groundID': widget.groundID,
          "teamA": {
            'teamName': teamControllerA.value.text,
            'personName': nameControllerA.value.text,
            'phoneNumber': numberControllerA.value.text,
            "notesTeamA": notesTeamA.value.text.isNotEmpty
                ? notesTeamA.value.text.toString()
                : "",
          },
          "teamB": {
            'teamName': checkBoxTeamB.value ? teamControllerB.value.text : '',
            'personName': checkBoxTeamB.value ? nameControllerB.value.text : '',
            'phoneNumber':
                checkBoxTeamB.value ? numberControllerB.value.text : '',
            "notesTeamB": notesTeamB.value.text.isNotEmpty
                ? notesTeamB.value.text.toString()
                : "",
          },
          'slotPrice': int.parse(priceController.value.text.toString()),
          'totalSlotPrice': updatedPrice,
          'advancePayment': checkBoxTeamB.value
              ? double.parse(advancePaymentController.value.text)
                      .round()
                      .toInt() +
                  double.parse(advancePaymentControllerTeamB.value.text)
                      .round()
                      .toInt()
              : double.parse(advancePaymentController.value.text)
                  .round()
                  .toInt(),
          'slotStatus': slotStatus(),
          'bothTeamBooked': checkBoxTeamB.value,
          'slotID': widget.slotID,
          'bookingID': widget.bookingID,
          'date': widget.date,
        });
        alertUser(bookingID: widget.bookingID);

      } on SocketException catch (e) {
        if (mounted) {
          Errors.flushBarInform(e.toString(), context, "Internet Connectivity");
        }
      } catch (e) {
        if (mounted) {
          Errors.flushBarInform(e.toString(), context, "Error");
        }
      }
    }
  }

  Future<void> sendSms({required String number}) async {
    String url =
        'http://api.bulksmsgateway.in/sendmessage.php?user=sportslovez&password=7788330&mobile=$number&message=Your Booking is Confirmed for ${widget.groundName} on ${DateFormat.yMMMd().format(DateTime.parse(widget.group))} at ${widget.slotTime} Thanks for Choosing Facility on Sportistan&sender=SPTNOT&type=3&template_id=1407170003612415391';
    await http.post(Uri.parse(url));
  }

  Future<void> alertUser({required String bookingID}) async {
    if (updateSmsAlert) {
      if (numberControllerA.value.text.isNotEmpty) {
        await sendSms(number: numberControllerA.value.text);
        if (showTeamB.value) {
          if (numberControllerA.value.text != numberControllerB.value.text) {
            await sendSms(number: numberControllerB.value.text);
          }
        }
      }
    }
    updateSmsAlert = false;
    moveToReceipt(bookingID: bookingID);
  }

  num calculateSlotPriceTeamA() {
    if (checkBoxTeamB.value) {
      return updatedPrice;
    }
    return updatedPrice / 2;
  }

  moveToReceipt({required String bookingID}) async {
    PageRouter.pushReplacement(context, BookingInfo(bookingID: bookingID));
  }

  String slotStatus() {
    if (checkBoxTeamB.value) {
      return 'Booked';
    } else {
      return 'Half Booked';
    }
  }

  int calculateFeesDue() {
    if (checkBoxTeamB.value) {
      int newBalance = int.parse(advancePaymentController.value.text.trim()) +
          int.parse(advancePaymentControllerTeamB.value.text.trim());
      return int.parse(priceController.value.text.trim()) - newBalance;
    }
    return int.parse(priceController.value.text.trim()) -
        int.parse(advancePaymentController.value.text.trim());
  }
}

class Content extends StatefulWidget {
  final String title;
  final Widget child;

  const Content({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  ContentState createState() => ContentState();
}

class ContentState extends State<Content> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(5),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontFamily: "DMSans",
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Flexible(fit: FlexFit.loose, child: widget.child),
        ],
      ),
    );
  }
}

class PaymentMode {
  static String type = "Cash";
  static List<String> paymentOptions = [
    "Cash",
    "UPI",
    "Wallet",
  ];
}

class UniqueID {
  static String generateRandomString() {
    var random = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(25, (index) => chars[random.nextInt(chars.length)])
        .join();
  }
}
