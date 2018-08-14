import 'package:flutter/material.dart';
import 'package:bmsce/home_page_tabs.dart';
class DummyTabs extends StatefulWidget{
  DummyTabsState createState()=> DummyTabsState();
}

class DummyTabsState extends State<DummyTabs> with HomeTabs{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
    );
  }

}