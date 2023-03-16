import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_tasks_with_alert/layout/todo_layoutcontroller.dart';
import 'package:todo_tasks_with_alert/model/event.dart';
import 'package:todo_tasks_with_alert/shared/componets/componets.dart';
import 'package:todo_tasks_with_alert/shared/network/local/notification.dart';
import 'package:todo_tasks_with_alert/shared/styles/styles.dart';
import 'package:todo_tasks_with_alert/shared/styles/thems.dart';

class AddEventScreen extends StatelessWidget {
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  var titlecontroller = TextEditingController();
  var datecontroller = TextEditingController();
  var starttimecontroller = TextEditingController();
  var endtimecontroller = TextEditingController();
  var remindcontroller = TextEditingController();
  var status = "new";
  List<int> remindList = [5, 10, 15, 20];

  TodoLayoutController todocontroller = Get.find<TodoLayoutController>();


  @override
  Widget build(BuildContext context) {

    // Future<void> AddEventScreen() {
    //   // Call the user's CollectionReference to add a new user
    //   return note
    //       .add({
    //         'title': titlecontroller.text, 
    //         'date': datecontroller.text,
    //         'starttime': starttimecontroller,
    //         'endtime': endtimecontroller,
    //         'status': "new",
    //       })
    //       .then((value) => print("Événements ajouté"))
    //       .catchError((error) => print("Failed to add événements: $error"));
    // }

    return Scaffold(
      appBar: _appbar(),
      body: _buildFromAddTask(context),
    );
  }

  _buildFromAddTask(BuildContext context) => SingleChildScrollView(
        reverse: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ajouter un événement',
                style: headerStyle,
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: Form(
                  key: _formkey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      defaultTextFormField(
                          controller: titlecontroller,
                          inputtype: TextInputType.text,
                          ontap: () {},
                          onvalidate: (value) {
                            if (value!.isEmpty) {
                              return "Le titre ne doit pas être vide";
                            }
                          },
                          text: "Titre"),
                      SizedBox(
                        height: 10,
                      ),
                      defaultTextFormField(
                          readonly: true,
                          controller: datecontroller,
                          inputtype: TextInputType.datetime,
                          prefixIcon: Icon(Icons.date_range),
                          ontap: () {
                            showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.parse('2010-01-01'),
                                    lastDate: DateTime.parse('2030-01-01'))
                                .then((value) {
                              var tdate = value.toString().split(' ');
                              datecontroller.text = tdate[0];
                            });
                          },
                          onvalidate: (value) {
                            if (value!.isEmpty) {
                              return "La date ne doit pas être vide";
                            }
                          },
                          text: "Date"),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: defaultTextFormField(
                                readonly: true,
                                controller: starttimecontroller,
                                inputtype: TextInputType.number,
                                prefixIcon: Icon(Icons.watch_later_outlined),
                                ontap: () {
                                  showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now())
                                      .then((value) {
                                    starttimecontroller.text =
                                        value!.format(context).toString();
                                    print(starttimecontroller.text);
                                  });
                                },
                                onvalidate: (value) {
                                  if (value!.isEmpty) {
                                    return "Veuillez remplir la case";
                                  }
                                },
                                text: "De"),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: defaultTextFormField(
                                readonly: true,
                                controller: endtimecontroller,
                                inputtype: TextInputType.number,
                                prefixIcon: Icon(Icons.watch_later_outlined),
                                ontap: () {
                                  showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now())
                                      .then((value) {
                                    endtimecontroller.text =
                                        value!.format(context).toString();
                                  });
                                },
                                onvalidate: (value) {
                                  if (value!.isEmpty) {
                                    return "Veuillez remplir la case";
                                  }
                                },
                                text: "Jusqu'à"),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      //NOTE Remind
                      Container(
                        width: double.infinity,
                        height: 60,
                        child: DropdownButtonFormField<String>(
                          value: todocontroller.selectedRemindItem.value,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: Colors.grey),
                            ),
                          ),
                          items: remindList
                              .map((e) => DropdownMenuItem<String>(
                                    value: e.toString(),
                                    child: Text(e.toString() + " minutes plus tôt"),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            todocontroller.onchangeremindlist(value);
                            print(todocontroller.selectedRemindItem.value);
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  _appbar() {
    return AppBar(
      backgroundColor: defaultLightColor,
      leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () {
            Get.back();
          }),
      actions: [
        ElevatedButton.icon(
          onPressed: () async { 
            AddEventScreen;
            if (_formkey.currentState!.validate()) {
              //NOTE  am pm to 24 hours
              DateTime date2start = DateFormat("hh:mm")
                  .parse(starttimecontroller.text.toString());
              DateTime date2end = DateFormat("hh:mm")
                  .parse(endtimecontroller.text.toString());
              String starttime =
                  DateFormat("HH:mm").format(date2start).toString();
              String endtime = DateFormat("HH:mm").format(date2end).toString();

              //NOTE compare two time
              var format = DateFormat("HH:mm");
              var start = format.parse(starttime);
              var end = format.parse(endtime);
              if (start.isBefore(end)) {
                await todocontroller
                    .inserteventByModel(
                        model: new Event(
                            title: titlecontroller.text,
                            date: datecontroller.text,
                            starttime: starttime,
                            endtime: endtime,
                            status: "new",
                            remind: int.parse(
                                todocontroller.selectedRemindItem.value)))
                    .then((eventId) {
                  print("eventId " + eventId.toString());

                      // CollectionReference note = FirebaseFirestore.instance.collection('note');
                  final FirebaseFirestore db = FirebaseFirestore.instance;

                  Map<String, dynamic> note = {
                  'title': titlecontroller.text,
                  'date': datecontroller.text,
                  'starttime': starttime,
                  'endtime': endtime,
                  'status': "new",
                  'remind': int.parse(todocontroller.selectedRemindItem.value)
                  };

                  db.collection('note').add(note)
                  .then((documentReference) {
                    print('Document added with ID: ${documentReference.id}');
                  });

                  db.collection('note').doc('note_id').set(note)
                  .then((value) => print("Note ajouté"))
                  .catchError((error) => print("Failed to add user: $error"));
                  
                  //NOTE set Notification for event
                  NotificationApi.scheduleNotification(
                      DateTime.parse(
                              datecontroller.text + " " + starttime.toString())
                          .subtract(Duration(
                              minutes: int.parse(
                                  todocontroller.selectedRemindItem.value))),
                      eventId,
                      titlecontroller.text,
                      starttimecontroller.text);
                  // NotificationApi.createNotification(
                  //     titlecontroller.text,
                  //     DateTime.parse(
                  //             datecontroller.text + " " + starttime.toString())
                  //         .subtract(Duration(
                  //             minutes: int.parse(
                  //                 todocontroller.selectedRemindItem.value))),
                  //     starttimecontroller.text);
                  titlecontroller.text = "";
                  datecontroller.text = "";
                  starttimecontroller.text = "";

                  Get.back();
                });
              } else {
                Get.snackbar('Une erreur est survenue',
                    '"De" doit commencer plus tôt que "Jusqu\'à"',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: defaultLightColor,
                    colorText: Colors.white);
              }
            }
          },
          icon: Icon(
            Icons.done,
            color: Colors.white,
          ),
          label: Text("Enregistrer"),
        )
      ],
    );
  }
}
