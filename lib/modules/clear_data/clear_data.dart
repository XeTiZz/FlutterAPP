import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_tasks_with_alert/layout/todo_layout.dart';
import 'package:todo_tasks_with_alert/layout/todo_layoutcontroller.dart';
import 'package:todo_tasks_with_alert/login.dart';
import 'package:todo_tasks_with_alert/shared/componets/componets.dart';
import 'package:todo_tasks_with_alert/shared/styles/thems.dart';

class ClearData extends StatefulWidget {
  @override
  State<ClearData> createState() => _ClearDataState();
}

class _ClearDataState extends State<ClearData> {
  var datecontroller = TextEditingController();
  var todocontroller = Get.find<TodoLayoutController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Effacer les données"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: Colors.red,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Supprimer toutes les données avant cette date",
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
            SizedBox(
              height: 15,
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
                    //Todo: handle date to string
                    //print(DateFormat.yMMMd().format(value!));
                    datecontroller.text = value.toString().split(' ').first;
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
            Column(children: [
                defaultButton(
                text: "Supprimé",
                background: Colors.red,
                onpress: () async {
                  if (datecontroller.text.isEmpty ||
                      datecontroller.text.toString() == 'null') {
                    Get.snackbar('Une erreur est survenue', 'La date ne doit pas être vide',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: defaultLightColor,
                        colorText: Colors.white);
                  } else {
                    await todocontroller
                        .deleteAllEventBefor(DateTime.parse(datecontroller.text.toString()))
                        .then((value) {
                      Get.back();
                      Get.snackbar('Données éffacées correctement',
                          'Tous les événements avant ${datecontroller.text} ont été supprimés',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green.shade600,
                          colorText: Colors.white);
                    });
                    
                  final FirebaseFirestore db = FirebaseFirestore.instance;
                  final User? _user = FirebaseAuth.instance.currentUser;

                  if (_user != null) {
                    Map<String, dynamic> note = {
                    'idUser': _user.uid,
                    'date':datecontroller,
                    '__name__':'TEST',
                    };

                    db.collection('note')
                    .where('idUser', isEqualTo: _user.uid)
                    .where('date', isEqualTo: datecontroller.text)
                    .get(GetOptions(source: Source.serverAndCache))
                    .then((snapshot) {
                        for (DocumentSnapshot doc in snapshot.docs) {
                          doc.reference.delete();
                        }
                      });
                    }
                  }
                }
              ),
              SizedBox(height: 16),
              defaultButton(
                text: "Tout supprimé",
                background: Colors.red,
                onpress: () async {
                  await todocontroller
                      .deleteAllEventBefor(DateTime.parse('2960-03-20'))
                      .then((value) {
                    Get.back();
                    Get.snackbar('Données éffacées correctement',
                        'Tous les événements ont été supprimés',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green.shade600,
                        colorText: Colors.white);
                  });

                if(connected == true){
                final FirebaseFirestore db = FirebaseFirestore.instance;
                final User? _user = FirebaseAuth.instance.currentUser;

                if (_user != null) {
                  Map<String, dynamic> note = {
                  'idUser': _user.uid,
                  '__name__':'TEST',
                  };

                  db.collection('note')
                  .where('idUser', isEqualTo: _user.uid)
                  .get(GetOptions(source: Source.serverAndCache))
                  .then((snapshot) {
                      for (DocumentSnapshot doc in snapshot.docs) {
                        doc.reference.delete();
                      }
                    });
                    }  
                  }
                }
              ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
