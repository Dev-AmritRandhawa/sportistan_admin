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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50)),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Search Console',
                style: TextStyle(fontSize: 24, fontFamily: 'DMSans'),
              ),
            ),
          ),
          const Text(
            "A Search Console for Sportistan",
            style: TextStyle(fontFamily: "DMSans", color: Colors.black45),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/logo.png',height: MediaQuery.of(context).size.height/8,),
          )
        ],
                  ),
                  Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              InkWell(
                onTap: () {
                  PageRouter.push(context, const SportistanPartnerSearch());
                },
                child: CircleAvatar(
                  backgroundColor: Colors.green.shade900,
                  minRadius: MediaQuery.of(context).size.height / 25,
                  child: Icon(
                    Icons.supervisor_account_outlined,
                    size: MediaQuery.of(context).size.height / 25,
                    color: Colors.white,
                  ),
                ),
              ),
              const Text(
                "Search Partners",
                style: TextStyle(fontSize: 16, fontFamily: "DMSans"),
              )
            ],
          ),
          Column(
            children: [
              InkWell(
                onTap: () {
                  PageRouter.push(context, const SportistanUserSearch());
                },
                child: CircleAvatar(
                  minRadius: MediaQuery.of(context).size.height / 25,
                  child: Icon(
                    Icons.person,
                    size: MediaQuery.of(context).size.height / 25,
                  ),
                ),
              ),
              const Text(
                "Search Users",
                style: TextStyle(fontSize: 16, fontFamily: "DMSans"),
              )
            ],
          ),
        ],
                  )
                ]),
      ),
    );
  }
}

class SportistanPartnerSearch extends StatefulWidget {
  const SportistanPartnerSearch({super.key});

  @override
  State<SportistanPartnerSearch> createState() =>
      _SportistanPartnerSearchState();
}

class _SportistanPartnerSearchState extends State<SportistanPartnerSearch> {
  var searchController = TextEditingController();

  final _server = FirebaseFirestore.instance;
  final GlobalKey<FormState> searchControllerKey = GlobalKey<FormState>();

  var priceController = TextEditingController();


  @override
  void dispose() {
    searchController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black45,
        elevation: 0,
        title: const Text("Back"),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                    decoration: InputDecoration(
                      prefixIcon: const CountryCodePicker(
                        showCountryOnly: true,
                        favorite: ["IN"],
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
              CupertinoButton(
                color: Colors.green,
                  child: const Text("Search Partner"), onPressed: () {
                  if(searchControllerKey.currentState!.validate()){
                    setState(() {
                      FocusScope.of(context).requestFocus(FocusNode());
                    });
                  }

              }),StreamBuilder(
                      stream: _server
                          .collection("SportistanPartners")
                          .where('phoneNumber',
                              isEqualTo: '+91${searchController.value.text}')
                          .snapshots(),
                      builder: (context, snapshot) {
                        return snapshot.hasData
                            ? ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  final doc = snapshot.data!.docs;
                                  List<dynamic> allbadgesList =
                                      doc[index].get("badges");
                                  int range = index + 1;
                                  return Column(
                                    children: [
                                      Card(
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: CircleAvatar(
                                                  backgroundColor: Colors.grey,
                                                  child: Text(
                                                    range.toString(),
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  )),
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
                                                          fontFamily: "DMSans",
                                                          color:
                                                              Colors.black38)),
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
                                                              color:
                                                                  Colors.green),
                                                        ),
                                                  doc[index].get(
                                                          'isAccountOnHold')
                                                      ? TextButton(
                                                          onPressed: () {
                                                            _server
                                                                .collection(
                                                                    'SportistanPartners')
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
                                                          onPressed: () {
                                                            _server
                                                                .collection(
                                                                    'SportistanPartners')
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
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      doc[index]
                                                          .get("groundName"),
                                                      style: const TextStyle(
                                                          fontFamily: "DMSans",
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(doc[index]
                                                  .get("locationName")),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Text("Credits : ",
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
                                                          fontFamily: "DMSans"),
                                                    ),
                                                  ],
                                                ),
                                                MaterialButton(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50)),
                                                  color: Colors.indigo,
                                                  onPressed: () {
                                                    updateCredits(
                                                      credits: doc[index].get(
                                                          'sportistanCredit'),
                                                      ref: doc[index].id,
                                                    );
                                                  },
                                                  child: const Text(
                                                      "Update Credits",
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                )
                                              ],
                                            ),
                                            doc[index].get('isBadgeAllotted')
                                                ? Column(
                                                    children: [
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            TextButton(
                                                                onPressed: () {
                                                                  editBadges(
                                                                      badges: doc[
                                                                              index]
                                                                          .get(
                                                                              'badges'),
                                                                      ref: doc[
                                                                              index]
                                                                          .id);
                                                                },
                                                                child: const Text(
                                                                    "Edit Badges"))
                                                          ]),
                                                      ListView.builder(
                                                        shrinkWrap: true,
                                                        physics:
                                                            const BouncingScrollPhysics(),
                                                        itemCount: allbadgesList
                                                            .length,
                                                        itemBuilder: (context,
                                                            badgeIndex) {
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    allbadgesList[
                                                                        badgeIndex],
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        fontFamily:
                                                                            "DMSans")),
                                                                const Icon(
                                                                  Icons
                                                                      .verified_outlined,
                                                                  color: Colors
                                                                      .indigo,
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
                                                        BorderRadius.zero,
                                                    color: Colors.teal,
                                                    onPressed: () {
                                                      editBadges(
                                                          badges: doc[index]
                                                              .get('badges'),
                                                          ref: doc[index].id);
                                                    },
                                                    child: const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text("Add Badge",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                        Icon(
                                                          Icons.badge_outlined,
                                                          color: Colors.white,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: CupertinoButton(
                                                color: Colors.green,
                                                onPressed: () {
                                                  PageRouter.push(
                                                      context,
                                                      ManageGround(
                                                          groundID: doc[index]
                                                              .get("groundID"),
                                                          groundType: doc[index]
                                                              .get(
                                                                  "groundType"),
                                                          groundName: doc[index]
                                                              .get(
                                                                  "groundName"),
                                                          groundAddress:
                                                              doc[index].get(
                                                                  "locationName"),
                                                          refID: doc[index].id,
                                                          onwards: doc[index]
                                                              .get('onwards')));
                                                },
                                                child: const Text(
                                                    "Create Ground Booking",
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                                })
                            : const Text(
                                'No Partner Found',
                                style: TextStyle(fontFamily: 'DMSans'),
                              );
                      },
                    )
            ],
          ),
        ),
      ),
    );
  }

  PhoneContact? _phoneContact;
  requestPermission(controller) async {
    await FlutterContactPicker.requestPermission();
    checkPermissionForContacts(controller);
  }

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
                      _server.collection('SportistanPartners').doc(ref).update({
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
                          _server
                              .collection('SportistanPartners')
                              .doc(ref)
                              .update({
                            'badges': tags,
                            'isBadgeAllotted': true
                          }).then((value) => {
                                    Navigator.pop(ctx),
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content:
                                          const Text("Updated Successfully"),
                                      backgroundColor: Colors.green.shade900,
                                    )),
                                  });
                        } catch (e) {
                          return;
                        }
                      } else {
                        _server
                            .collection("SportistanPartners")
                            .doc(ref)
                            .update({
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


class SportistanUserSearch extends StatefulWidget {
  const SportistanUserSearch({super.key});

  @override
  State<SportistanUserSearch> createState() => _SportistanUserSearchState();
}

class _SportistanUserSearchState extends State<SportistanUserSearch> {

  final _server = FirebaseFirestore.instance;
  final GlobalKey<FormState> searchControllerKey2 = GlobalKey<FormState>();

  var priceController2 = TextEditingController();
  var searchController2 = TextEditingController();


  @override
  void dispose() {
    searchController2.dispose();
    priceController2.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black45,
        elevation: 0,
        title: const Text("Back"),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                  key: searchControllerKey2,
                  child: TextFormField(
                    maxLength: 10,
                    controller: searchController2,
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
                    decoration: InputDecoration(
                      prefixIcon: const CountryCodePicker(
                        showCountryOnly: true,
                        favorite: ["IN"],
                        initialSelection: "IN",
                      ),
                      errorStyle: const TextStyle(color: Colors.red),
                      filled: true,
                      hintText: "Search",
                      suffixIcon: InkWell(
                          onTap: () {
                            checkPermissionForContacts(searchController2);
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
              CupertinoButton(
                  color: Colors.blue,
                  child: const Text("Search User"), onPressed: () {
                if(searchControllerKey2.currentState!.validate()){
                  setState(() {
                    FocusScope.of(context).requestFocus(FocusNode());
                  });
                }

              }),StreamBuilder(
                stream: _server
                    .collection("SportistanUsers")
                    .where('phoneNumber',
                    isEqualTo: searchController2.value.text)
                    .snapshots(),
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs;
                        int range = index + 1;
                        return Column(children: [
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
                                                .collection('SportistanUsers')
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
                                                'SportistanUsers')
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
                      })
                      : const Text(
                    'No Partner Found',
                    style: TextStyle(fontFamily: 'DMSans'),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  PhoneContact? _phoneContact;
  requestPermission(controller) async {
    await FlutterContactPicker.requestPermission();
    checkPermissionForContacts(controller);
  }

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

  void updateCredits({required num credits, required String ref}) {
    priceController2.text = credits.toString();
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
                controller: priceController2,
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
                      _server.collection('SportistanUsers').doc(ref).update({
                        'sportistanCredit':
                        num.parse(priceController2.value.text.trim())
                      }).then((value) => {
                        Navigator.pop(ctx),
                        priceController2.clear(),
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

}
