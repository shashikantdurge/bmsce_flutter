import 'package:bmsce/user_profile/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuple/tuple.dart';

//TODO: add click_action to data, sertverTs to FieldValue
class MyNotification {
  final String title;
  final String topic;
  final String condition;
  final String subtitle;

  ///main keys are `message`, `link`, `senderEmail`, `senderName`, `serverTimestamp`, `senderDept` and `type`(NotificationType)
  final Map<String, dynamic> data;

  MyNotification(
      {this.title, this.topic, this.subtitle, this.data, this.condition})
      : assert(
            (condition != null && topic == null) ||
                (condition == null && topic != null),
            "Specify either topic or condition. Not both");

  Future<Tuple2> publish() async {
    if (topic == null || topic.isEmpty)
      return Tuple2(false, "topic cannot be empty");
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
      condition: condition,
      data: {
        "message": body,
        "link": link,
        "type": notificationType.toString(),
        "senderEmail": User.instance.email,
        "senderName": User.instance.displayName,
        "senderDept": User.instance.dept,
        "serverTimestamp": DateTime.now()
        // "cl"
      },
    );
  }

  _setTopic() {
    final List<String> arrTopics = [];
    if (this.deptType != "none") {
      arrTopics.add('department_${this.deptValue}');
    }
    if (this.userType != "none") {
      arrTopics.add('user_${this.userType}');
    }
    if (this.userType == "student" && this.semesterType != "none") {
      arrTopics.add('semester_${this.semesterValue}');
    }
    if (userType == "student" &&
        deptType == "department" &&
        semesterType == "semester" &&
        sectionType != "none") {
      arrTopics.add('section_${this.sectionValue}');
    }
    if (arrTopics.isEmpty || arrTopics.length == 1) {
      this.topic = arrTopics.isEmpty ? "bmsce" : arrTopics.first;
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
