import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:sportistan_admin/screens/manage_ground.dart';
import 'package:sportistan_admin/widgets/page_router.dart';

class SearchByAlgolia extends StatefulWidget {
  const SearchByAlgolia({super.key});

  @override
  State<SearchByAlgolia> createState() => _SearchByAlgoliaState();
}

class _SearchByAlgoliaState extends State<SearchByAlgolia> {
  var searchController = TextEditingController();
  var priceController = TextEditingController();
  String countryCode = "+91";
  String? phoneNumber;

  final _server = FirebaseFirestore.instance;

  ValueNotifier<bool> searchControllerListener = ValueNotifier<bool>(false);
  final GlobalKey<FormState> searchControllerKey = GlobalKey<FormState>();

  var tag = 0;

  List<String> options = ["Sportistan Partners", "Users"];
  List<String> type = ["SportistanPartners", "SportistanUsers"];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Search Console',
                      style: TextStyle(fontSize: 22, color: Colors.black54)),
                  Icon(
                    Icons.search,
                    color: Colors.green,
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 15,
                  right: MediaQuery.of(context).size.width / 15),
              child: Form(
                key: searchControllerKey,
                child: TextFormField(
                  maxLength: 10,
                  controller: searchController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  showCursor: true,
                  validator: (value) {
                    if (value!.length != 10) {
                      return "Enter Number";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (v) {
                    searchControllerListener.value = false;
                  },
                  decoration: InputDecoration(
                    prefixIcon: CountryCodePicker(
                      showCountryOnly: true,
                      onChanged: (value) {
                        countryCode = value.dialCode.toString();
                      },
                      favorite: const ["IN"],
                      initialSelection: "IN",
                    ),
                    errorStyle: const TextStyle(color: Colors.red),
                    filled: true,
                    hintText: "Search",
                    suffixIcon: InkWell(
                        onTap: () {
                          checkPermissionForContacts(searchController);
                        },
                        child: const Icon(Icons.contacts)),
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            ChipsChoice<int>.single(
              value: tag,
              onChanged: (val) => setState(() => tag = val),
              choiceItems: C2Choice.listFrom<int, String>(
                source: options,
                value: (i, v) => i,
                label: (i, v) => v,
                tooltip: (i, v) => v,
              ),
              choiceCheckmark: true,
              choiceStyle: C2ChipStyle.outlined(
                selectedStyle: const C2ChipStyle(
                  borderRadius: BorderRadius.all(
                    Radius.circular(25),
                  ),
                ),
              ),
            ),
            CupertinoButton(
              onPressed: () {
                if (searchControllerKey.currentState!.validate()) {
                  if (phoneNumber != searchController.value.text) {
                    phoneNumber = countryCode + searchController.value.text;
                    searchControllerListener.value = true;
                  }
                }
              },
              color: Colors.black,
              child:
                  const Text("Search", style: TextStyle(color: Colors.white)),
            ),
            ValueListenableBuilder(
                valueListenable: searchControllerListener,
                builder: (context, value, child) => value
                    ? StreamBuilder(
                        stream: _server
                            .collection(type[tag])
                            .where('phoneNumber', isEqualTo: phoneNumber)
                            .snapshots(),
                        builder: (context, snapshot) {
                          return snapshot.hasData
                              ? ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    final doc = snapshot.data!.docs;
                                    List<dynamic> allbadgesList;
                                    if (tag == 0) {
                                      allbadgesList = doc[index].get("badges");
                                    } else {
                                      allbadgesList = [];
                                    }
                                    int range = index + 1;
                                    return tag == 0
                                        ? Column(
                                            children: [
                                              Card(
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: CircleAvatar(
                                                          backgroundColor:
                                                              Colors.grey,
                                                          child: Text(
                                                            range.toString(),
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                          )),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          const Text(
                                                              'Account Status : ',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      "DMSans",
                                                                  color: Colors
                                                                      .black38)),
                                                          doc[index].get(
                                                                  'isAccountOnHold')
                                                              ? const Icon(
                                                                  Icons
                                                                      .fiber_manual_record,
                                                                  color: Colors
                                                                      .red,
                                                                )
                                                              : const Icon(
                                                                  Icons
                                                                      .fiber_manual_record,
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                          doc[index].get(
                                                                  'isAccountOnHold')
                                                              ? const Text(
                                                                  "InActive",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                )
                                                              : const Text(
                                                                  "Active",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .green),
                                                                ),
                                                          doc[index].get(
                                                                  'isAccountOnHold')
                                                              ? TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    _server
                                                                        .collection(type[
                                                                            tag])
                                                                        .doc(doc[index]
                                                                            .id)
                                                                        .update({
                                                                      'isAccountOnHold':
                                                                          false
                                                                    });
                                                                  },
                                                                  child: const Text(
                                                                      ("Enable")))
                                                              : TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    _server
                                                                        .collection(type[
                                                                            tag])
                                                                        .doc(doc[index]
                                                                            .id)
                                                                        .update({
                                                                      'isAccountOnHold':
                                                                          true
                                                                    });
                                                                  },
                                                                  child: const Text(
                                                                      ("Disable")))
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                              doc[index].get(
                                                                  "groundName"),
                                                              style: const TextStyle(
                                                                  fontFamily:
                                                                      "DMSans",
                                                                  fontSize: 22,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(doc[index]
                                                          .get("locationName")),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const Text(
                                                                "Credits : ",
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        "DMSans")),
                                                            Text(
                                                              doc[index]
                                                                  .get(
                                                                      'sportistanCredit')
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  fontSize: 22,
                                                                  fontFamily:
                                                                      "DMSans"),
                                                            ),
                                                          ],
                                                        ),
                                                        MaterialButton(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50)),
                                                          color: Colors.indigo,
                                                          onPressed: () {
                                                            updateCredits(
                                                              credits: doc[
                                                                      index]
                                                                  .get(
                                                                      'sportistanCredit'),
                                                              ref:
                                                                  doc[index].id,
                                                            );
                                                          },
                                                          child: const Text(
                                                              "Update Credits",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white)),
                                                        )
                                                      ],
                                                    ),
                                                    doc[index].get(
                                                            'isBadgeAllotted')
                                                        ? Column(
                                                            children: [
                                                              Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          editBadges(
                                                                              badges: doc[index].get('badges'),
                                                                              ref: doc[index].id);
                                                                        },
                                                                        child: const Text(
                                                                            "Edit Badges"))
                                                                  ]),
                                                              ListView.builder(
                                                                shrinkWrap:
                                                                    true,
                                                                physics:
                                                                    const BouncingScrollPhysics(),
                                                                itemCount:
                                                                    allbadgesList
                                                                        .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        badgeIndex) {
                                                                  return Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                            allbadgesList[
                                                                                badgeIndex],
                                                                            style:
                                                                                const TextStyle(fontSize: 20, fontFamily: "DMSans")),
                                                                        const Icon(
                                                                          Icons
                                                                              .verified_outlined,
                                                                          color:
                                                                              Colors.indigo,
                                                                        )
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          )
                                                        : CupertinoButton(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .zero,
                                                            color: Colors.teal,
                                                            onPressed: () {
                                                              editBadges(
                                                                  badges: doc[
                                                                          index]
                                                                      .get(
                                                                          'badges'),
                                                                  ref:
                                                                      doc[index]
                                                                          .id);
                                                            },
                                                            child: const Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    "Add Badge",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white)),
                                                                Icon(
                                                                  Icons
                                                                      .badge_outlined,
                                                                  color: Colors
                                                                      .white,
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: CupertinoButton(
                                                        color: Colors.green,
                                                        onPressed: () {
                                                          PageRouter.push(
                                                              context,
                                                              ManageGround(
                                                                  groundID: doc[
                                                                          index]
                                                                      .get(
                                                                          "groundID"),
                                                                  groundType: doc[
                                                                          index]
                                                                      .get(
                                                                          "groundType"),
                                                                  groundName:
                                                                      doc[index].get(
                                                                          "groundName"),
                                                                  groundAddress:
                                                                      doc[index].get(
                                                                          "locationName"),
                                                                  refID:
                                                                      doc[index]
                                                                          .id,
                                                                  onwards: doc[
                                                                          index]
                                                                      .get(
                                                                          'onwards')));
                                                        },
                                                        child: const Text(
                                                            "Create Ground Booking",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          )
                                        : Column(children: [
                                            Card(
                                                child: Column(children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.green,
                                                    child: Text(
                                                      range.toString(),
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    )),
                                              ),
                                              Text(
                                                doc[index].get('name'),
                                                style: const TextStyle(
                                                    fontFamily: "DMSans",
                                                    fontSize: 18),
                                              ),
                                               Card(
                                                shape:  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'User',
                                                    style: TextStyle(
                                                        fontFamily: "DMSans",
                                                        fontSize: 18),
                                                  ),
                                                ),
                                              ),
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          const Text(
                                                              "Credits : ",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                  "DMSans")),
                                                          Text(
                                                            doc[index]
                                                                .get(
                                                                'sportistanCredit')
                                                                .toString(),
                                                            style: const TextStyle(
                                                                fontSize: 22,
                                                                fontFamily:
                                                                "DMSans"),
                                                          ),
                                                        ],
                                                      ),
                                                      MaterialButton(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                50)),
                                                        color: Colors.indigo,
                                                        onPressed: () {
                                                          updateCredits(
                                                            credits: doc[
                                                            index]
                                                                .get(
                                                                'sportistanCredit'),
                                                            ref:
                                                            doc[index].id,
                                                          );
                                                        },
                                                        child: const Text(
                                                            "Update Credits",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                      )
                                                    ],
                                                  ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    const Text(
                                                        'Account Status : ',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "DMSans",
                                                            color: Colors
                                                                .black38)),
                                                    doc[index].get(
                                                            'isAccountOnHold')
                                                        ? const Icon(
                                                            Icons
                                                                .fiber_manual_record,
                                                            color: Colors.red,
                                                          )
                                                        : const Icon(
                                                            Icons
                                                                .fiber_manual_record,
                                                            color: Colors.green,
                                                          ),
                                                    doc[index].get(
                                                            'isAccountOnHold')
                                                        ? const Text(
                                                            "InActive",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red),
                                                          )
                                                        : const Text(
                                                            "Active",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green),
                                                          ),
                                                    doc[index].get(
                                                            'isAccountOnHold')
                                                        ? TextButton(
                                                            onPressed: () {
                                                              _server
                                                                  .collection(
                                                                      type[tag])
                                                                  .doc(
                                                                      doc[index]
                                                                          .id)
                                                                  .update({
                                                                'isAccountOnHold':
                                                                    false
                                                              });
                                                            },
                                                            child: const Text(
                                                                ("Enable")))
                                                        : TextButton(
                                                            onPressed: () {
                                                              _server
                                                                  .collection(
                                                                      type[tag])
                                                                  .doc(
                                                                      doc[index]
                                                                          .id)
                                                                  .update({
                                                                'isAccountOnHold':
                                                                    true
                                                              });
                                                            },
                                                            child: const Text(
                                                                ("Disable")))
                                                  ],
                                                ),
                                              ),
                                            ])),
                                          ]);
                                  },
                                )
                              : const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                        },
                      )
                    : Container()),
            SizedBox(
              height: MediaQuery.of(context).size.height / 8,
            )
          ]),
        ),
      ),
    );
  }

  void updateCredits({required num credits, required String ref}) {
    priceController.text = credits.toString();
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Update Credits",
                style: TextStyle(fontSize: 22, fontFamily: "DMSans"),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  errorStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  hintText: "Credits",
                  suffixIcon: const InkWell(child: Icon(Icons.done_all)),
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoButton(
                  color: Colors.indigo,
                  onPressed: () {
                    try {
                      _server.collection(type[tag]).doc(ref).update({
                        'sportistanCredit':
                            num.parse(priceController.value.text.trim())
                      }).then((value) => {
                            Navigator.pop(ctx),
                            priceController.clear(),
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Credit Updated Successfully"),
                              backgroundColor: Colors.green,
                            ))
                          });
                    } catch (e) {
                      return;
                    }
                  },
                  child: const Text("Update")),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                  "This is a common way to designate a section where you express gratitude or give credit to individuals, organizations, or sources that contributed to a project or provided information. You can tailor the title based on the specific context and nature of the credits you're providing.",
                  style: TextStyle(fontFamily: "DMSans", fontSize: 16)),
            )
          ],
        );
      },
    );
  }

  void editBadges({required List<dynamic> badges, required String ref}) {
    List<String> allBadges = [
      "Trusted Partner",
      "Sportistan Recommend",
      "Hot Seller"
    ];
    List<String> tags = [];
    for (int i = 0; i < badges.length; i++) {
      tags.add(badges[i]);
    }
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Update Badges",
                  style: TextStyle(fontSize: 22, fontFamily: "DMSans"),
                ),
              ),
              const Icon(Icons.architecture),
              ChipsChoice<String>.multiple(
                value: tags,
                onChanged: (value) {
                  setState(() {
                    tags = value;
                  });
                },
                choiceItems: C2Choice.listFrom<String, String>(
                  source: allBadges,
                  value: (i, v) => v,
                  label: (i, v) => v,
                  tooltip: (i, v) => v,
                ),
                choiceCheckmark: true,
                wrapped: true,
                choiceStyle: C2ChipStyle.filled(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CupertinoButton(
                    color: Colors.teal,
                    onPressed: () {
                      if (tags.isNotEmpty) {
                        try {
                          _server.collection(type[tag]).doc(ref).update({
                            'badges': tags,
                            'isBadgeAllotted': true
                          }).then((value) => {
                                Navigator.pop(ctx),
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: const Text("Updated Successfully"),
                                  backgroundColor: Colors.green.shade900,
                                )),
                              });
                        } catch (e) {
                          return;
                        }
                      } else {
                        _server.collection(type[tag]).doc(ref).update({
                          'badges': [],
                          'isBadgeAllotted': false
                        }).then((value) => {
                              Navigator.pop(ctx),
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: const Text("Updated Successfully"),
                                backgroundColor: Colors.green.shade900,
                              )),
                            });
                      }
                    },
                    child: const Text("Update")),
              ),
            ],
          ),
        );
      },
    );
  }
}
