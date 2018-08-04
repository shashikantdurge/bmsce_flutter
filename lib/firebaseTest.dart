// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
/*import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';*/         //Analytics

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//Analytics
/*class FirebaseAnalyticsTest extends StatelessWidget {
  static FirebaseAnalytics analytics = new FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
  new FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Firebase Analytics Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: <NavigatorObserver>[observer],
      home: new MyHomePage(
        title: 'Firebase Analytics Demo',
        analytics: analytics,
        observer: observer,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.analytics, this.observer})
      : super(key: key);

  final String title;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _MyHomePageState createState() => new _MyHomePageState(analytics, observer);
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState(this.analytics, this.observer);

  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;
  String _message = '';

  void setMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  Future<Null> _sendAnalyticsEvent() async {
    await analytics.logEvent(
      name: 'test_event',
      parameters: <String, dynamic>{
        'string': 'string',
        'int': 42,
        'long': 12345678910,
        'double': 42.0,
        'bool': true,
      },
    );
    setMessage('logEvent succeeded');
  }

  Future<Null> _testSetUserId() async {
    await analytics.setUserId('some-user');
    setMessage('setUserId succeeded');
  }

  Future<Null> _testSetCurrentScreen() async {
    await analytics.setCurrentScreen(
      screenName: 'Analytics Demo',
      screenClassOverride: 'AnalyticsDemo',
    );
    setMessage('setCurrentScreen succeeded');
  }

  Future<Null> _testSetAnalyticsCollectionEnabled() async {
    await analytics.android?.setAnalyticsCollectionEnabled(false);
    await analytics.android?.setAnalyticsCollectionEnabled(true);
    setMessage('setAnalyticsCollectionEnabled succeeded');
  }

  Future<Null> _testSetMinimumSessionDuration() async {
    await analytics.android?.setMinimumSessionDuration(20000);
    setMessage('setMinimumSessionDuration succeeded');
  }

  Future<Null> _testSetSessionTimeoutDuration() async {
    await analytics.android?.setSessionTimeoutDuration(2000000);
    setMessage('setSessionTimeoutDuration succeeded');
  }

  Future<Null> _testSetUserProperty() async {
    await analytics.setUserProperty(name: 'regular', value: 'indeed');
    setMessage('setUserProperty succeeded');
  }

  Future<Null> _testAllEventTypes() async {
    await analytics.logAddPaymentInfo();
    await analytics.logAddToCart(
      currency: 'USD',
      value: 123.0,
      itemId: 'test item id',
      itemName: 'test item name',
      itemCategory: 'test item category',
      quantity: 5,
      price: 24.0,
      origin: 'test origin',
      itemLocationId: 'test location id',
      destination: 'test destination',
      startDate: '2015-09-14',
      endDate: '2015-09-17',
    );
    await analytics.logAddToWishlist(
      itemId: 'test item id',
      itemName: 'test item name',
      itemCategory: 'test item category',
      quantity: 5,
      price: 24.0,
      value: 123.0,
      currency: 'USD',
      itemLocationId: 'test location id',
    );
    await analytics.logAppOpen();
    await analytics.logBeginCheckout(
      value: 123.0,
      currency: 'USD',
      transactionId: 'test tx id',
      numberOfNights: 2,
      numberOfRooms: 3,
      numberOfPassengers: 4,
      origin: 'test origin',
      destination: 'test destination',
      startDate: '2015-09-14',
      endDate: '2015-09-17',
      travelClass: 'test travel class',
    );
    await analytics.logCampaignDetails(
      source: 'test source',
      medium: 'test medium',
      campaign: 'test campaign',
      term: 'test term',
      content: 'test content',
      aclid: 'test aclid',
      cp1: 'test cp1',
    );
    await analytics.logEarnVirtualCurrency(
      virtualCurrencyName: 'bitcoin',
      value: 345.66,
    );
    await analytics.logEcommercePurchase(
      currency: 'USD',
      value: 432.45,
      transactionId: 'test tx id',
      tax: 3.45,
      shipping: 5.67,
      coupon: 'test coupon',
      location: 'test location',
      numberOfNights: 3,
      numberOfRooms: 4,
      numberOfPassengers: 5,
      origin: 'test origin',
      destination: 'test destination',
      startDate: '2015-09-13',
      endDate: '2015-09-14',
      travelClass: 'test travel class',
    );
    await analytics.logGenerateLead(
      currency: 'USD',
      value: 123.45,
    );
    await analytics.logJoinGroup(
      groupId: 'test group id',
    );
    await analytics.logLevelUp(
      level: 5,
      character: 'witch doctor',
    );
    await analytics.logLogin();
    await analytics.logPostScore(
      score: 1000000,
      level: 70,
      character: 'tiefling cleric',
    );
    await analytics.logPresentOffer(
      itemId: 'test item id',
      itemName: 'test item name',
      itemCategory: 'test item category',
      quantity: 6,
      price: 3.45,
      value: 67.8,
      currency: 'USD',
      itemLocationId: 'test item location id',
    );
    await analytics.logPurchaseRefund(
      currency: 'USD',
      value: 45.67,
      transactionId: 'test tx id',
    );
    await analytics.logSearch(
      searchTerm: 'hotel',
      numberOfNights: 2,
      numberOfRooms: 1,
      numberOfPassengers: 3,
      origin: 'test origin',
      destination: 'test destination',
      startDate: '2015-09-14',
      endDate: '2015-09-16',
      travelClass: 'test travel class',
    );
    await analytics.logSelectContent(
      contentType: 'test content type',
      itemId: 'test item id',
    );
    await analytics.logShare(
      contentType: 'test content type',
      itemId: 'test item id',
    );
    await analytics.logSignUp(
      signUpMethod: 'test sign up method',
    );
    await analytics.logSpendVirtualCurrency(
      itemName: 'test item name',
      virtualCurrencyName: 'bitcoin',
      value: 34,
    );
    await analytics.logTutorialBegin();
    await analytics.logTutorialComplete();
    await analytics.logUnlockAchievement(id: 'all Firebase API covered');
    await analytics.logViewItem(
      itemId: 'test item id',
      itemName: 'test item name',
      itemCategory: 'test item category',
      itemLocationId: 'test item location id',
      price: 3.45,
      quantity: 6,
      currency: 'USD',
      value: 67.8,
      flightNumber: 'test flight number',
      numberOfPassengers: 3,
      numberOfRooms: 1,
      numberOfNights: 2,
      origin: 'test origin',
      destination: 'test destination',
      startDate: '2015-09-14',
      endDate: '2015-09-15',
      searchTerm: 'test search term',
      travelClass: 'test travel class',
    );
    await analytics.logViewItemList(
      itemCategory: 'test item category',
    );
    await analytics.logViewSearchResults(
      searchTerm: 'test search term',
    );
    setMessage('All standard events logged successfully');
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Column(
        children: <Widget>[
          new MaterialButton(
            child: const Text('Test logEvent'),
            onPressed: _sendAnalyticsEvent,
          ),
          new MaterialButton(
            child: const Text('Test standard event types'),
            onPressed: _testAllEventTypes,
          ),
          new MaterialButton(
            child: const Text('Test setUserId'),
            onPressed: _testSetUserId,
          ),
          new MaterialButton(
            child: const Text('Test setCurrentScreen'),
            onPressed: _testSetCurrentScreen,
          ),
          new MaterialButton(
            child: const Text('Test setAnalyticsCollectionEnabled'),
            onPressed: _testSetAnalyticsCollectionEnabled,
          ),
          new MaterialButton(
            child: const Text('Test setMinimumSessionDuration'),
            onPressed: _testSetMinimumSessionDuration,
          ),
          new MaterialButton(
            child: const Text('Test setSessionTimeoutDuration'),
            onPressed: _testSetSessionTimeoutDuration,
          ),
          new MaterialButton(
            child: const Text('Test setUserProperty'),
            onPressed: _testSetUserProperty,
          ),
          new Text(_message,
              style:
              const TextStyle(color: const Color.fromARGB(255, 0, 155, 0))),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
          child: const Icon(Icons.tab), onPressed: () {},
          *//*onPressed: () {
            Navigator.of(context).push(new MaterialPageRoute<TabsPage>(
                settings: const RouteSettings(name: TabsPage.routeName),
                builder: (BuildContext context) {
                  return new TabsPage(observer);
                }));
          }),*//*
    ));
  }
}*/


//Firestore
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


Future<void> main() async {
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'test',
    options: const FirebaseOptions(
      googleAppID: '1:79601577497:ios:5f2bcc6ba8cecddd',
      gcmSenderID: '79601577497',
      apiKey: 'AIzaSyArgmRGfB5kiQT6CunAOmKRVKEsxKmy6YI-G72PVU',
      projectID: 'flutter-firestore',
    ),
  );
  final Firestore firestore = new Firestore(app: app);

  runApp(new MaterialApp(
      title: 'Firestore Example', home: new MyFirestorePage(firestore: firestore)));
}

class MessageList extends StatelessWidget {
  MessageList({this.firestore});

  final Firestore firestore;

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('messages').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        final int messageCount = snapshot.data.documents.length;
        return new ListView.builder(
          itemCount: messageCount,
          itemBuilder: (_, int index) {
            final DocumentSnapshot document = snapshot.data.documents[index];
            return new ListTile(
              title: new Text(document['message'] ?? '<No message retrieved>'),
              subtitle: new Text('Message ${index + 1} of $messageCount'),
            );
          },
        );
      },
    );
  }
}

class MyFirestorePage extends StatelessWidget {
  MyFirestorePage({this.firestore});
  final Firestore firestore;
  CollectionReference get messages => firestore.collection('messages');

  Future<Null> _addMessage() async {
    final DocumentReference document = messages.document();
    document.setData(<String, dynamic>{
      'message': 'Hello world!',
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Firestore Example'),
      ),
      body: new MessageList(firestore: firestore),
      floatingActionButton: new FloatingActionButton(
        onPressed: _addMessage,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}