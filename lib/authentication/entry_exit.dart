import 'package:bmsce/map/college_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

setEntryUserData(Map<String, dynamic> userMap, String email) {
  SharedPreferences.getInstance().then((pref) async {
    userMap.forEach((key, value) {
      if (value is String) {
        pref.setString("user_property_" + key, value);
      }
    });
    await Firestore.instance
        .collection('roles')
        .document(userMap['dept'])
        .get()
        .then((doc) {
      if (doc.exists && doc.data.containsKey(userMap['email'])) {
        pref.setString(
            'user_property_role', doc.data[userMap['email']]['role']);
      }
      print(
          "ROLE MANAGEMENT ${doc.exists} , ${userMap['email']} ${doc.data.containsKey(userMap['email'])}");
    }).catchError((err) {
      print("ROLE MANAGEMENT false $err");
    });
  });
  CollegeMapState.getSearchNames(fromOnline: true);
}
