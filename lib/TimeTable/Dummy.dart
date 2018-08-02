import 'package:flutter/material.dart';
import 'package:bmsce/HomePageTabs.dart';
class DummyTabs extends StatefulWidget{
  DummyTabsState createState()=> DummyTabsState();
}

class DummyTabsState extends State<DummyTabs> with HomeTabs{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Time Table'),
      ),
    );
  }

}