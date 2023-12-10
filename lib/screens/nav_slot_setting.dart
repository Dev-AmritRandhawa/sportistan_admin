import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../widgets/errors.dart';
import 'book_a_slot.dart';


class NavSlotSettings extends StatefulWidget {
  final String day;
  final String refID;
  final int onwards;

  const NavSlotSettings(
      {super.key,
        required this.day,
        required this.refID,
        required this.onwards});

  @override
  State<NavSlotSettings> createState() => _NavSlotSettingsState();
}

class _NavSlotSettingsState extends State<NavSlotSettings> {
  var nameTECs = <int, TextEditingController>{};
  var nameTECs2 = <int, TextEditingController>{};
  var mailTECs = <int, TextEditingController>{};

  var item = <int, Widget>{};

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late Map<String, dynamic> slotsElements;
  final _server = FirebaseFirestore.instance;
  List<Entry> allSlots = [];

  ValueNotifier<bool> listLoad = ValueNotifier<bool>(true);

  late num onwards;

  List<num> onwardsList = [];

  TextEditingController entireDayController = TextEditingController();
  GlobalKey<FormState> entireDayControllerKey2 = GlobalKey<FormState>();

  @override
  void initState() {
    onwards = widget.onwards;
    onwardsList.add(widget.onwards);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ondDone() async {
    DataSave.entries.clear();
    for (int i = 0; i <= nameTECs.keys.last; i++) {
      var name = nameTECs[i]?.value.text;
      var name2 = nameTECs2[i]?.value.text;
      var mail = mailTECs[i]?.value.text;
      if (name != null && mail != null) {
        DataSave.entries.add(Entry(
            name: name.toString(),
            name2: name2.toString(),
            email: mail.toString()));
      }
    }
    await setSlot();
  }

  newMethod(
      BuildContext context,
      int index,
      ) {
    var nameController = TextEditingController();
    var nameController2 = TextEditingController();
    var mailController = TextEditingController();
    nameTECs.addAll({index: nameController});
    nameTECs2.addAll({index: nameController2});
    mailTECs.addAll({index: mailController});
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("SLOT : ${index + 1}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontFamily: "DMSans")),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: TextFormField(
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? tod = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (tod != null) {
                        nameController.text = formatTimeOfDay(tod);
                      }
                    },
                    controller: nameController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Set Slot Time";
                      } else {
                        return null;
                      }
                    },
                    decoration: const InputDecoration(
                      prefixIcon:
                      Icon(Icons.access_time_outlined, color: Colors.green),
                      fillColor: Colors.white,
                      border: InputBorder.none,
                      filled: true,
                      hintText: "Start Time",
                      hintStyle:
                      TextStyle(color: Colors.black, fontFamily: "DMSans"),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: TextFormField(
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? tod = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                            DateTime.now().add(const Duration(hours: 2))),
                      );
                      if (tod != null) {
                        nameController2.text = formatTimeOfDay(tod);
                      }
                    },
                    controller: nameController2,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Set Slot Time";
                      } else {
                        return null;
                      }
                    },
                    decoration: const InputDecoration(
                      prefixIcon:
                      Icon(Icons.access_time_outlined, color: Colors.amber),
                      fillColor: Colors.white,
                      border: InputBorder.none,
                      filled: true,
                      hintText: "End Time",
                      hintStyle:
                      TextStyle(color: Colors.black, fontFamily: "DMSans"),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
                controller: mailController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Set Slot Price";
                  } else {
                    return null;
                  }
                },
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined,
                      color: Colors.green),
                  suffixIcon: Text("Change",
                      style: TextStyle(
                          color: Colors.black54, fontFamily: "DMSans")),
                  fillColor: Colors.white,
                  border: InputBorder.none,
                  filled: true,
                  hintText: "Set Slot Price",
                  hintStyle:
                  TextStyle(color: Colors.black, fontFamily: "DMSans"),
                )),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 8.0, left: 8.0),
            child: Divider(
              color: Colors.black38,
              height: 1,
            ),
          ),
          MaterialButton(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
            color: Colors.red,
            onPressed: () {
              setState(() {
                item.removeWhere((key, value) => key == index);
                nameTECs.removeWhere((key, value) => key == index);
                nameTECs2.removeWhere((key, value) => key == index);
                mailTECs.removeWhere((key, value) => key == index);
              });
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            foregroundColor: Colors.black87,
            backgroundColor: Colors.white,
            centerTitle: true,
            title: Text(
              widget.day,
              style:
              const TextStyle(fontFamily: "DMSans", color: Colors.black54),
            )),
        bottomNavigationBar: item.isNotEmpty
            ? CupertinoButton(
          borderRadius: const BorderRadius.all(Radius.zero),
          color: Colors.green.shade800,
          onPressed: () {
            if (formKey.currentState!.validate() &
            entireDayControllerKey2.currentState!.validate()) {
              ondDone();
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Icon(Icons.save),
              Text("Save Slots for ${widget.day}"),
            ],
          ),
        )
            : CupertinoButton(
          borderRadius: const BorderRadius.all(Radius.zero),
          color: Colors.indigo,
          onPressed: () {
            setState(() {
              item.addAll({0: newMethod(context, 0)});
            });
          },
          child: const Text("Add Slot",
              style: TextStyle(fontFamily: "DMSans")),
        ),
        body: ValueListenableBuilder(
          valueListenable: listLoad,
          builder: (context, value, child) {
            return listLoad.value
                ? const Center(
              child: CircularProgressIndicator(strokeWidth: 1),
            )
                : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Form(
                    key: entireDayControllerKey2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        validator: (input) {
                          if (input!.isEmpty) {
                            return "Price is Missing";
                          } else {
                            return null;
                          }
                        },
                        style: const TextStyle(
                            color: Colors.black87),
                        controller: entireDayController,
                        keyboardType: TextInputType.name,
                        inputFormatters: [
                          FilteringTextInputFormatter
                              .digitsOnly
                        ],
                        decoration: InputDecoration(
                            label: const Text("Entire Day Amount"),
                            errorStyle: const TextStyle(
                                color: Colors.red),
                            hintText:
                            "Enter Entire Day Amount for ${widget.day} ?",
                            hintStyle: TextStyle(
                                fontSize:
                                MediaQuery.of(context)
                                    .size
                                    .height /
                                    50,
                                color: Colors.black87,
                                fontFamily: "Nunito"),
                            fillColor: Colors.grey.shade200,
                            filled: true,
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            )),
                      ),
                    ),
                  ),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: item.length,
                            itemBuilder: (context, index) {
                              return item.values.elementAt(index);
                            }),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                color: Colors.green,
                                elevation: 0,
                                onPressed: () {
                                  setState(() {
                                    if (item.isNotEmpty) {
                                      item.addAll({
                                        item.keys.last + 1: newMethod(
                                            context, item.keys.last + 1)
                                      });
                                    } else {
                                      item.addAll({0: newMethod(context, 0)});
                                    }
                                  });
                                },
                                child: const Text('Add Slot + ',
                                    style: TextStyle(
                                        fontFamily: "DMSans",
                                        color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ));
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  Future<void> setSlot() async {
    for (int i = 0; i < DataSave.entries.length; i++) {
      onwardsList.add(int.parse(DataSave.entries[i].email));
    }
    await _server.collection("SportistanPartners").doc(widget.refID).update({
      widget.day: [
        for (int i = 0; i < DataSave.entries.length; i++)
          {
            'time': DataSave.entries[i].name,
            'timeEnd': DataSave.entries[i].name2,
            'price': int.parse(DataSave.entries[i].email),
            'slotID': UniqueID.generateRandomString(),
          }
      ]
    }).then((value) async => {
      await _server
          .collection("SportistanPartners")
          .doc(widget.refID)
          .update({
        '${widget.day}EntireDay': int.parse(entireDayController.value.text)
      }).then((value) => {
        DataSave.isDataSave = true,
        saveOnwards(),
        Alert.flushBarAlert(
            message: "Slot is Successfully Updated",
            context: context,
            title: "${widget.day} Slot Saved"),
      })
    });
  }

  void getSlots() async {
    var daySlots = [];
    try {
      var collection = _server.collection('SportistanPartners');
      var docSnapshot = await collection.doc(widget.refID).get();
      Map<String, dynamic> data = docSnapshot.data()!;
      slotsElements = data;

      daySlots = data[widget.day];

      await addSlots(daySlots.length - 1);

      for (int i = 0; i < daySlots.length; i++) {
        nameTECs[i]?.text = slotsElements[widget.day][i]['time'];
        nameTECs2[i]?.text = slotsElements[widget.day][i]['timeEnd'];
        mailTECs[i]?.text = slotsElements[widget.day][i]['price'].toString();

      }
      entireDayController.text = slotsElements['${widget.day}EntireDay'].toString();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Something Went Wrong")));
      }
    }
    listLoad.value = false;
  }

  Future<void> addSlots(int daySlots) async {
    for (int i = 0; i <= daySlots; i++) {
      item.addAll({i: newMethod(context, i)});
    }
    setState(() {});
  }

  saveOnwards() async {
    for (int j = 0; j < onwardsList.length; j++) {
      if (onwardsList[j] < widget.onwards) {
        await _server
            .collection("SportistanPartners")
            .doc(widget.refID)
            .update({'onwards': onwardsList[j]});
      }
    }
  }
}
class DataSave {
  static bool isDataSave = false;
  static List<Entry> entries = [];
}
class Entry {
  final String name;
  final String name2;
  final String email;

  Entry({required this.name, required this.name2, required this.email});
}
