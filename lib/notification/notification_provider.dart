import 'package:bmsce/user_profile/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tuple/tuple.dart';

//TODO: add  sertverTs to FieldValue

class NotiProvider {
  static const String ENCRYPTED = "m";
  static const String DECRYPTED = "s";
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  init(User user) async {
    _firebaseMessaging
        .subscribeToTopic(["college", DECRYPTED, "bmsce"].join("_D_"));
    _firebaseMessaging.subscribeToTopic(
        ["email", ENCRYPTED, encrypt(user.email)].join("_D_"));
    if (user.dept != null)
      _firebaseMessaging
          .subscribeToTopic(["dept", DECRYPTED, user.dept].join("_D_"));
    if (user.semester != null)
      _firebaseMessaging
          .subscribeToTopic(["semester", DECRYPTED, user.semester].join("_D_"));
    if (user.usn != null)
      _firebaseMessaging
          .subscribeToTopic(["usn", DECRYPTED, user.usn].join("_D_"));
    if (user.section != null)
      _firebaseMessaging
          .subscribeToTopic(["section", DECRYPTED, user.section].join("_D_"));
    if ([Role.HOD_ADMIN, Role.TEACHER].contains(user.whoAmI))
      _firebaseMessaging
          .subscribeToTopic(["user", DECRYPTED, "faculty"].join("_D_"));
    if ([Role.STUDENT, Role.SUPER_STUDENT].contains(user.whoAmI))
      _firebaseMessaging
          .subscribeToTopic(["user", DECRYPTED, "student"].join("_D_"));
  }

  Future deleteAll() async {}

  dispose() {}

  static String encrypt(String topic) => topic.codeUnits.join("_");

  Tuple2 _decrypt(String encryptedTopic) {
    //FIXME: only string with pattern `[a-zA-Z0-9-_.~%]+_D_[0-9_]+` can be decrypted
    // final regex = RegExp(r'^[a-zA-Z0-9-_.~%]+_D_[0-9_]+$');
    final topicParts = encryptedTopic.split("_D_");
    if (topicParts[1] == DECRYPTED) {
      return Tuple2(topicParts.first, topicParts.last);
    }

    final topicCodeUnits = topicParts.last.split("_").map((codeUnit) {
      return int.parse(codeUnit);
    });
    final topic = String.fromCharCodes(topicCodeUnits);
    return Tuple2(topicParts.first, topic);
  }

  static sendRoleNoti(String email, String role) {
    final newRole = role ?? "Default";
    final myNoti = MyNotification(
      title: 'Your role changed to $newRole',
      topic: encrypt(email),
      subtitle: "by ${User.instance.displayName}",
      data: {
        "title": 'Your role changed to $newRole',
        "message":
            'Your role changed to $newRole. Please sign out and sign in again.',
        "type": NotificationType.DEFAULT.toString(),
        "senderEmail": User.instance.email,
        "senderName": User.instance.displayName,
        "senderDept": User.instance.dept,
        "serverTimestamp": DateTime.now().millisecondsSinceEpoch.toString(),
        "click_action": "FLUTTER_NOTIFICATION_CLICK"
      },
    );
    myNoti.publish();
  }
}

class MyNotification {
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  final String title;
  final String topic;
  final String condition;
  final String subtitle;

  ///main keys are `message`, `link`, `senderEmail`, `senderName`, `serverTimestamp`, `senderDept` and `type`(NotificationType)
  final Map<String, String> data;

  MyNotification(
      {this.title, this.topic, this.subtitle, this.data, this.condition})
      : assert(
            (condition != null && topic == null) ||
                (condition == null && topic != null),
            "Specify either topic or condition. Not both");

  Future<Tuple2> publish() async {
    final notiMap = this._toMap();
    final status = await Firestore.instance
        .collection('notifications')
        .add(notiMap)
        .then((onValue) {
      return Tuple2(true, "Success");
    }).catchError((err) {
      if (err.toString().contains('PERMISSION'))
        return Tuple2(true, "Permission denied");
      else
        return Tuple2(false, "Failed");
    });
    return status;
  }

  Map<String, dynamic> _toMap() {
    return {
      'title': title,
      'topic': topic,
      "condition": condition,
      'subtitle': subtitle,
      'data': data,
    };
  }
}

class NotiBuilder {
  NotificationType notificationType;
  String topic;
  String condition;
  String title;
  String body;
  String link;
  String userType;
  String deptType;
  String deptValue;
  String semesterType;
  String semesterValue;
  String sectionType;
  String sectionValue;

  MyNotification getMyNotificationObj() {
    _setTopic();
    return MyNotification(
      title: title,
      topic: topic,
      subtitle: "A message from ${User.instance.displayName}",
      condition: condition,
      data: {
        "title": title,
        "message": body,
        "link": link,
        "type": notificationType.toString(),
        "senderEmail": User.instance.email,
        "senderName": User.instance.displayName,
        "senderDept": User.instance.dept,
        "serverTimestamp": DateTime.now().millisecondsSinceEpoch.toString(),
        "click_action": "FLUTTER_NOTIFICATION_CLICK"
      },
    );
  }

  _setTopic() {
    if (this.notificationType == NotificationType.PORTION) {
      this.topic = ["portion", NotiProvider.DECRYPTED, this.topic].join("_D_");
      return;
    }
    final List<String> arrTopics = [];
    if (this.deptType != "none") {
      arrTopics.add('dept_D_${NotiProvider.DECRYPTED}_D_${this.deptValue}');
    }
    if (this.userType != "none") {
      arrTopics.add('user_D_${NotiProvider.DECRYPTED}_D_${this.userType}');
    }
    if (this.userType == "student" && this.semesterType != "none") {
      arrTopics
          .add('semester_D_${NotiProvider.DECRYPTED}_D_${this.semesterValue}');
    }

    if (userType == "student" &&
        deptType == "department" &&
        semesterType == "semester" &&
        sectionType != "none") {
      arrTopics
          .add('section_D_${NotiProvider.DECRYPTED}_D_${this.sectionValue}');
    }
    if (arrTopics.isEmpty || arrTopics.length == 1) {
      this.topic = arrTopics.isEmpty
          ? "college_D_${NotiProvider.DECRYPTED}_D_bmsce"
          : arrTopics.first;
      this.condition = null;
      return;
    }

    StringBuffer conditionBuff =
        StringBuffer("'${arrTopics.first}' in topics && (");

    for (int i = 1; i < arrTopics.length; i++) {
      conditionBuff.write(" '${arrTopics[i]}' in topics ");
      if (i != arrTopics.length - 1) {
        conditionBuff.write(" && ");
      }
    }
    conditionBuff.write(")");
    this.condition = conditionBuff.toString();
    this.topic = null;
  }
}

enum NotificationType {
  DEFAULT,
  ACADEMIC_MARKS,
  SYLLABUS_UPDATE,
  PORTION,
}
