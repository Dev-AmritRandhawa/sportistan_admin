import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:sportistan_admin/widgets/send_cloud_message.dart';

class AccountKYC extends StatefulWidget {
  const AccountKYC({super.key});

  @override
  State<AccountKYC> createState() => _AccountKYCState();
}

class _AccountKYCState extends State<AccountKYC> {
  final _server = FirebaseFirestore.instance;

  var currentPage = 0;
  List<String> serviceTags = ['Invalid Photos'];
  List<String> serviceOptions = [
    'Invalid Photos',
    'Images are not Clear',
    'Wrong Documents',
    'Inappropriate Details',
    'Wrong Information',
  ];

  var otherService = TextEditingController();
  GlobalKey<FormState> otherServiceKey = GlobalKey<FormState>();

  final commissionController = TextEditingController();
  final GlobalKey<FormState> commissionKey = GlobalKey<FormState>();
  ValueNotifier<bool> setCommission = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.green.shade900,
          elevation: 0,
          foregroundColor: Colors.white,
          title: const Text("KYC"),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: [
            SafeArea(
                child: StreamBuilder(
              stream: _server
                  .collection("SportistanPartners")
                  .where("kycStatus", isEqualTo: "Under Review")
                  .where('isVerified', isEqualTo: false)
                  .where('isKYCPending', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                return snapshot.hasData
                    && snapshot.data!.docChanges.isNotEmpty && snapshot.data!.size > 0
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.size,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Card(
                                child: Column(
                                  children: [
                                    Text(
                                      snapshot.data!.docChanges[index].doc
                                          .get("groundName"),
                                      overflow: TextOverflow.visible,
                                      maxLines: 2,
                                      style: const TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22),
                                    ),
                                    Text(
                                      snapshot.data!.docChanges[index].doc
                                          .get("locationName"),
                                      overflow: TextOverflow.visible,
                                      maxLines: 2,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          getStatus(
                                              status: snapshot
                                                  .data!.docChanges[index].doc
                                                  .get("kycStatus")),
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: "DMSans+",
                                              color: getStatusColor(
                                                  status: snapshot.data!
                                                      .docChanges[index].doc
                                                      .get("kycStatus"))),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CupertinoButton(
                                        color: Colors.red,
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (ctx) {
                                              return Container(
                                                margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height/15),
                                                child: Wrap(
                                                  alignment: WrapAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: CupertinoButton(
                                                          color: Colors.green,
                                                          onPressed: () {
                                                            showModalBottomSheet(
                                                              context: context,
                                                              builder: (newCtx) {
                                                                return StatefulBuilder(
                                                                  builder: (context,
                                                                      setState) {
                                                                    return Column(
                                                                      children: [
                                                                        const Text(
                                                                          "Set Commission",
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                22,
                                                                          ),
                                                                        ),
                                                                        Form(
                                                                          key:
                                                                              commissionKey,
                                                                          child:
                                                                              Padding(
                                                                            padding: EdgeInsets.only(
                                                                                left: MediaQuery.of(context).size.width / 15,
                                                                                right: MediaQuery.of(context).size.width / 15),
                                                                            child:
                                                                                TextFormField(
                                                                              controller:
                                                                                  commissionController,
                                                                              keyboardType:
                                                                                  TextInputType.number,
                                                                              inputFormatters: [
                                                                                FilteringTextInputFormatter.digitsOnly
                                                                              ],
                                                                              validator:
                                                                                  (v) {
                                                                                if (v!.isEmpty) {
                                                                                  return 'Enter Commission';
                                                                                } else if (int.parse(v) > 99 || int.parse(v) == 0) {
                                                                                  return "Not Valid";
                                                                                } else {
                                                                                  return null;
                                                                                }
                                                                              },
                                                                              maxLength:
                                                                                  2,
                                                                              decoration: InputDecoration(
                                                                                  errorStyle: const TextStyle(color: Colors.red),
                                                                                  filled: true,
                                                                                  hintText: "Commission",
                                                                                  suffixIcon: InkWell(
                                                                                      onTap: () {
                                                                                        commissionController.clear();
                                                                                      },
                                                                                      child: const Icon(Icons.close)),
                                                                                  prefixIcon: const Icon(Icons.percent, color: Colors.black54, size: 20),
                                                                                  fillColor: Colors.grey.shade100,
                                                                                  border: OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                    borderSide: BorderSide.none,
                                                                                  )),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        ValueListenableBuilder(
                                                                          valueListenable:
                                                                              setCommission,
                                                                          builder: (context, value, child) => value ? const CircularProgressIndicator(strokeWidth: 1,) :CupertinoButton(
                                                                              color: Colors.green,
                                                                              onPressed: () {
                                                                                setCommission.value = true;
                                                                                if (commissionKey.currentState!.validate()) {
                                                                                  _server.collection("SportistanPartners").doc(snapshot.data!.docChanges[index].doc.id).update({
                                                                                    'isKYCPending': false,
                                                                                    'isVerified': true,
                                                                                    'kycStatus': 'Approved',
                                                                                  }).then((value) async => {
                                                                                        Navigator.pop(newCtx),
                                                                                        Navigator.pop(ctx),
                                                                                        await _server.collection("DeviceTokens").where('userID', isEqualTo: snapshot.data!.docChanges[index].doc.get("userID")).get().then((v) => {
                                                                                              FirebaseCloudMessaging.sendPushMessage("Your Ground KYC is Successfully Verified Start Booking Now", "Congratulations", v.docChanges.first.doc.get("token"))
                                                                                            })
                                                                                      });
                                                                                }
                                                                              },
                                                                              child: const Text("Set Commission")),
                                                                        )
                                                                      ],
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child: const Text(
                                                              "Approved",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      "DMSans"))),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: CupertinoButton(
                                                          color: Colors.red,
                                                          onPressed: () {
                                                            showModalBottomSheet(
                                                              context: context,
                                                              builder: (newCtx) {
                                                                return StatefulBuilder(
                                                                  builder: (context,
                                                                      setState) {
                                                                    return SingleChildScrollView(
                                                                      physics:
                                                                          const BouncingScrollPhysics(),
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          const Padding(
                                                                            padding:
                                                                                EdgeInsets.all(8.0),
                                                                            child:
                                                                                Text(
                                                                              'Please Mention The Reason of Rejection',
                                                                              style:
                                                                                  TextStyle(
                                                                                fontSize: 22,
                                                                                fontFamily: "Nunito",
                                                                                color: Colors.redAccent,
                                                                              ),
                                                                              softWrap:
                                                                                  true,
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: const EdgeInsets
                                                                                .all(
                                                                                8.0),
                                                                            child:
                                                                                ListView(
                                                                              physics:
                                                                                  const BouncingScrollPhysics(),
                                                                              shrinkWrap:
                                                                                  true,
                                                                              addAutomaticKeepAlives:
                                                                                  true,
                                                                              children: <Widget>[
                                                                                Content(
                                                                                  title: 'Choose Reject Reasons',
                                                                                  child: ChipsChoice<String>.multiple(
                                                                                    value: serviceTags,
                                                                                    onChanged: (val) => setState(() => serviceTags = val),
                                                                                    choiceItems: C2Choice.listFrom<String, String>(
                                                                                      source: serviceOptions,
                                                                                      value: (i, v) => v,
                                                                                      label: (i, v) => v,
                                                                                      tooltip: (i, v) => v,
                                                                                    ),
                                                                                    choiceCheckmark: true,
                                                                                    choiceStyle: C2ChipStyle.filled(
                                                                                      color: Colors.green,
                                                                                      selectedStyle: const C2ChipStyle(
                                                                                        borderRadius: BorderRadius.all(
                                                                                          Radius.circular(25),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    wrapped: true,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: const EdgeInsets
                                                                                .all(
                                                                                8.0),
                                                                            child:
                                                                                Form(
                                                                              key:
                                                                                  otherServiceKey,
                                                                              child:
                                                                                  SizedBox(
                                                                                width: MediaQuery.of(context).size.width / 1.2,
                                                                                child: TextFormField(
                                                                                  validator: (v) {
                                                                                    if (v!.isEmpty) {
                                                                                      return "Empty Field";
                                                                                    } else {
                                                                                      return null;
                                                                                    }
                                                                                  },
                                                                                  controller: otherService,
                                                                                  decoration: InputDecoration(fillColor: Colors.grey.shade200, hintText: "Add any other reason", border: InputBorder.none, errorStyle: const TextStyle(color: Colors.red), filled: true, labelStyle: const TextStyle(color: Colors.black)),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: const EdgeInsets
                                                                                .all(
                                                                                8.0),
                                                                            child: CupertinoButton(
                                                                                onPressed: () {
                                                                                  if (otherServiceKey.currentState!.validate()) {
                                                                                    if (!serviceOptions.contains(otherService.value.text)) {
                                                                                      serviceTags.add(otherService.value.text);
                                                                                      serviceOptions.add(otherService.value.text);
                                                                                      setState(() {});
                                                                                    }
                                                                                  }
                                                                                },
                                                                                color: Colors.indigoAccent,
                                                                                child: const Text(
                                                                                  "Add Reason",
                                                                                  style: TextStyle(color: Colors.white),
                                                                                )),
                                                                          ),
                                                                          CupertinoButton(
                                                                              color: Colors
                                                                                  .red,
                                                                              onPressed:
                                                                                  () {
                                                                                _server.collection("SportistanPartners").doc(snapshot.data!.docChanges[index].doc.id).update({
                                                                                  'isKYCPending': true,
                                                                                  'isVerified': false,
                                                                                  'kycStatus': 'Rejected',
                                                                                  'rejectReason': serviceTags
                                                                                }).then((value) async => {
                                                                                      Navigator.pop(newCtx),
                                                                                      await deleteAllPhotosInFolder(snapshot, '/groundImages'),
                                                                                      await _server.collection("DeviceTokens").where('userID', isEqualTo: snapshot.data!.docChanges[index].doc.get("userID")).get().then((v) => {
                                                                                            Navigator.pop(ctx),
                                                                                            FirebaseCloudMessaging.sendPushMessage("Your Ground KYC is Rejected Reason are Mentioned in Profile > My Grounds", "We're Sorry", v.docChanges.first.doc.get("token"))
                                                                                          })
                                                                                    });
                                                                              },
                                                                              child:
                                                                                  const Text("Reject")),
                                                                          SizedBox(height: MediaQuery.of(context).size.height/15,)
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child: const Text(
                                                              "Reject",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      "DMSans"))),
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: const Text("Take Action",
                                            style: TextStyle(
                                                fontFamily: "DMSans",
                                                color: Colors.white)),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 8.0, left: 8.0),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                snapshot
                                                    .data!.docChanges[index].doc
                                                    .get('name'),
                                                style: const TextStyle(
                                                    fontSize: 14)),
                                            IconButton(
                                              onPressed: () {
                                                FlutterPhoneDirectCaller
                                                    .callNumber(
                                                  snapshot.data!.docChanges[index].doc
                                                      .get('phoneNumber'),
                                                );
                                              },
                                              icon: const Icon(Icons.call,
                                                  color: Colors.green),
                                            )
                                          ]),
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: MaterialButton(
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                            color: Colors.orangeAccent,
                                            onPressed: () {
                                              showKYCDetails(
                                                  kycImages: snapshot.data!
                                                      .docChanges[index].doc
                                                      .get('kycImageLinks'));
                                            },
                                            child: const Text("View Documents",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: MaterialButton(
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                            color: Colors.green,
                                            onPressed: () {
                                              showGroundDetails(
                                                groundImages: snapshot
                                                    .data!.docChanges[index].doc
                                                    .get('groundImages'),
                                              );
                                            },
                                            child: const Text("Grounds Images",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        :  Center(
                            child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const Icon(Icons.verified,color: Colors.blue,),
                                Text("No Pending KYC",style: TextStyle(fontSize: 22,color: Colors.green.shade900,fontFamily: "DMSans")),
                              ],
                            ),
                          ));
              },
            )),
          ]),
        ));
  }

  Color getStatusColor({required String status}) {
    switch (status) {
      case 'Approved':
        {
          return Colors.green;
        }
      case 'Rejected':
        {
          return Colors.red;
        }
    }
    return Colors.orange;
  }

  String getStatus({required String status}) {
    switch (status) {
      case 'Approved':
        {
          return 'Approved●';
        }
      case 'Rejected':
        {
          return 'Rejected●';
        }
    }
    return 'Under Review●';
  }

  void showKYCDetails({
    required List<dynamic> kycImages,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: kycImages.length,
          itemBuilder: (context, index) => SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Image.network(
                    kycImages[index],
                    errorBuilder: (context, error, stackTrace) {
                      return const Text("Network Error");
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return const CircularProgressIndicator(strokeWidth: 1,);
                    },
                  ),
                  const Divider(
                    thickness: 5,
                    height: 5,
                    color: Colors.orangeAccent,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showGroundDetails({
    required List<dynamic> groundImages,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: groundImages.length,
          itemBuilder: (context, index) => SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    groundImages[index],
                    errorBuilder: (context, error, stackTrace) {
                      return const Text("Network Error");
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return const CircularProgressIndicator(strokeWidth: 1,);
                    },
                  ),
                ),
                const Divider(
                  thickness: 5,
                  height: 5,
                  color: Colors.green,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> deleteAllPhotosInFolder(
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
      String folderName) async {
    final Reference storageRef = FirebaseStorage.instance
        .ref()
        .child(snapshot.data!.docChanges[0].doc.get('userID') + folderName);
    try {
      ListResult result = await storageRef.listAll();
      await Future.forEach(result.items, (Reference item) async {
        await item.delete();
      });
      deleteAllPhotosInFolder(snapshot, '/kyc');
    } catch (e) {
      return;
    }
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            // color: Colors.blueGrey[50],
            child: Text(
              widget.title,
              style: const TextStyle(
                // color: Colors.blueGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Flexible(fit: FlexFit.loose, child: widget.child),
        ],
      ),
    );
  }
}
