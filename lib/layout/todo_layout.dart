// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/extra/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:todo_tasks_with_alert/layout/todo_layoutcontroller.dart';
import 'package:todo_tasks_with_alert/model/event.dart';
import 'package:todo_tasks_with_alert/modules/add_event_screen/add_event_screen.dart';
import 'package:todo_tasks_with_alert/modules/clear_data/clear_data.dart';
import 'package:todo_tasks_with_alert/modules/search_events/search_events.dart';
import 'package:todo_tasks_with_alert/shared/componets/componets.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:todo_tasks_with_alert/shared/network/local/notification.dart';
import 'package:todo_tasks_with_alert/shared/styles/styles.dart';
import 'package:todo_tasks_with_alert/shared/styles/thems.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../login.dart';


class TodoLayout extends StatelessWidget {
  bool isLogin = false;
  GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  TodoLayout({super.key});

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TodoLayoutController>(
      init: Get.find<TodoLayoutController>(),
      builder: (todocontroller) => Scaffold(
        drawer: _drawer(context),
        key: _scaffoldkey,
        // NOTE App Bar
        appBar: _appbar(todocontroller, context),
        
        
        //NOTE Body
        body: Obx(
          () => todocontroller.isloading.value
              ? Center(child: CircularProgressIndicator())
              : Container(
                  margin: EdgeInsets.only(top: 5, left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat.yMMMMd('fr').format(DateTime.parse(todocontroller.currentSelectedDate)),
                                style: subHeaderStyle,
                              ),
                              SizedBox(
                                height: 2,
                              ),
                            ],
                          ),
                          defaultButton(
                              text: "Ajouter un événement",
                              width: 100,
                              onpress: () {
                                Get.to(() => AddEventScreen());
                              },
                              gradient: orangeGradient,
                              radius: 15),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      //NOTE timeline datepicker -------------
                      Container(
                        child: DatePicker(
                          DateTime.now(),                      
                          height: 80,
                          width: 60,
                          initialSelectedDate: DateTime.now(),
                          selectionColor: defaultLightColor,
                          selectedTextColor: Colors.white,
                          dayTextStyle: TextStyle(
                            color: Get.isDarkMode ? Colors.white : Colors.black,
                          ),
                          dateTextStyle: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                          monthTextStyle: TextStyle(
                            color: Get.isDarkMode ? Colors.white : Colors.black,
                          ),
                          onDateChange: (value) {
                            var selecteddate = value.toString().split(' ');
                            print(selecteddate[0]);
                            todocontroller.onchangeselectedate(selecteddate[0]);
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      // NOTE list Of Tasks
                      Expanded(
                          child: todocontroller
                              .screens[todocontroller.currentIndex]),
                    ],
                  ),
                ),
        ),

        //NOTE bottom navigation
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: todocontroller.currentIndex,
          onTap: (index) {
            todocontroller.onchangeIndex(index);
          },
          items: todocontroller.bottomItems,
        ),
      ),
    );
  }

  _appbar(TodoLayoutController todocontroller, BuildContext context) => AppBar(
    //     backgroundColor: 
    //   Colors.deepOrange,
    //   Colors.deepOrange.shade400,
    //   Colors.deepOrange.shade300,
    // ],
        title: Text(
          todocontroller.appbar_title[todocontroller.currentIndex],
          style: Theme.of(context).textTheme.headline5,
        ),
        actions: [
          IconButton(
            onPressed: () {
              //TODO: search screen
              Get.to(() => SearchEvents());
              //NotificationApi.shownotification();
            },
            icon: Icon(
              Get.isDarkMode ? Icons.search : Icons.search,
              size: 30,
            ),
          ),
          IconButton(
            onPressed: () {
              todocontroller.onchangeThem();
            },
            icon: Icon(
              Get.isDarkMode ? Icons.wb_sunny : Icons.mode_night,
              size: 30,
            ),
          ),
          SizedBox(
            width: 20,
          )
        ],
      );

  _drawer(BuildContext context) => Drawer(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(gradient: orangeGradient),
              padding: EdgeInsets.only(left: 15, right: 15, top: 40),
              height: 160,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Row(
                      children: [
                        CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/default profile.png')),
                        SizedBox(
                          width: 10,
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.cloud),
                          color: Colors.grey.shade200,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    title: Text(isLogin ?"Connecté" : "Connectez vous",
                      style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
                    
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              onTap: () {
                Get.to(ClearData());
              },
              leading: Icon(Icons.delete),
              title: Text("Effacer les données"),
            ),
            Divider(),
            ListTile(
              onTap: () {Get.to(() => SearchEvents());},
              leading: Icon(Icons.search),
              title: Text("Rechercher"),
            ),
            Visibility(
              visible: isLogin ? true : true ,
              child:
                ListTile(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                },
                leading: Icon(Icons.logout),
                title: Text('Déconnexion', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: Get.isDarkMode ? Colors.white : Colors.black,)),
              ),
            )
          ],
        ),
      );
}
