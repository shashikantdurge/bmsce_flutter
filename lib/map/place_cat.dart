import 'package:meta/meta.dart';

abstract class Place {
  final String searchName;
  final String name;
  final String placeCat;
  final String location;
  final String addedBy;
  final String dept;

  Place(
      {@required this.name,
      @required this.searchName,
      this.placeCat,
      @required this.location,
      @required this.addedBy,
      @required this.dept});

  factory Place.fromMap(Map<String, dynamic> mapObj) {
    switch (mapObj["placeCat"]) {
      case "Lab":
        return Lab(
            name: mapObj["name"] ?? mapObj['searchName'],
            dept: mapObj["dept"],
            location: mapObj["location"],
            addedBy: mapObj["addedBy"],
            capacity: mapObj["capacity"]);
      case "Faculty Cabin":
        return FacultyCabin(
            name: mapObj["name"] ?? mapObj['searchName'],
            designation: mapObj["designation"],
            dept: mapObj["dept"],
            email: mapObj["email"],
            location: mapObj["location"],
            detailsLink: mapObj["detailsLink"],
            addedBy: mapObj["addedBy"],
            profilePictureLink: mapObj["profilePictureLink"]);
      case "Class Room":
        return ClassRoom(
          name: mapObj["name"] ?? mapObj['searchName'],
          blockName: mapObj["blockName"],
          dept: mapObj["dept"],
          capacity: mapObj["capacity"],
          addedBy: mapObj["addedBy"],
          location: mapObj["location"],
        );

      default:
        return Other(
            addedBy: mapObj["addedBy"],
            name: mapObj["name"] ?? mapObj['searchName'] ?? 'Not Found',
            location: mapObj["location"]);
    }
  }
}

class FacultyCabin extends Place {
  final String designation;
  final String email; //opt
  final String detailsLink; //opt
  final String profilePictureLink; //opt
  FacultyCabin(
      {String name,
      this.designation,
      String dept,
      this.email,
      this.detailsLink,
      this.profilePictureLink,
      @required String location,
      @required String addedBy})
      : super(
            name: name,
            dept: dept,
            searchName:
                "$name${designation == null ? "" : ", " + designation}${dept == null ? "" : ", " + dept + " Dept"}",
            placeCat: "Faculty Cabin",
            addedBy: addedBy,
            location: location);

  Map<String, dynamic> toMap() {
    return {
      "searchName": this.searchName,
      "placeCat": this.placeCat,
      "location": this.location,
      "name": this.name,
      "designation": this.designation,
      "dept": this.dept,
      "email": this.email,
      "detailsLink": this.detailsLink,
      "profilePictureLink": this.profilePictureLink,
      "addedBy": this.addedBy
    };
  }
}

class ClassRoom extends Place {
  final String blockName;
  final int capacity; //opt

  ClassRoom(
      {String name,
      @required this.blockName,
      String dept,
      this.capacity,
      @required String location,
      @required String addedBy})
      : super(
            dept: dept,
            name: name,
            searchName: "$name, $blockName",
            placeCat: "Class Room",
            addedBy: addedBy,
            location: location);

  Map<String, dynamic> toMap() {
    return {
      "searchName": this.searchName,
      "placeCat": this.placeCat,
      "location": this.location,
      "name": this.name,
      "blockName": this.blockName,
      "dept": this.dept,
      "capacity": this.capacity,
      "addedBy": this.addedBy
    };
  }
}

class Lab extends Place {
  final int capacity;
  Lab(
      {String name,
      @required String dept,
      this.capacity,
      @required String location,
      @required String addedBy})
      : super(
            name: name,
            dept: dept,
            searchName: "$name, $dept Dept",
            placeCat: "Lab",
            addedBy: addedBy,
            location: location);

  Map<String, dynamic> toMap() {
    return {
      "name": this.name,
      "dept": this.dept,
      "capacity": this.capacity,
      "searchName": this.searchName,
      "placeCat": this.placeCat,
      "location": this.location,
      "addedBy": this.addedBy
    };
  }
}

class Other extends Place {
  Other(
      {String name,
      String dept,
      @required String location,
      @required String addedBy})
      : super(
            name: name,
            dept: dept,
            searchName: "$name${dept == null ? "" : ", " + dept + " Dept"}",
            placeCat: "Other",
            addedBy: addedBy,
            location: location);

  Map<String, dynamic> toMap() {
    return {
      "searchName": this.searchName,
      "name": this.name,
      "placeCat": this.placeCat,
      "location": this.location,
      "addedBy": this.addedBy
    };
  }
}

const PlaceCategoryMap = {
  //#List items are refernced in other places DO NOT Change the names
  PlaceCategory.FACULTY_CABIN: "Faculty Cabin",
  PlaceCategory.CLASS_ROOM: "Class Room",
  PlaceCategory.LAB: "Lab",
  PlaceCategory.OTHER: "Other"
};

enum PlaceCategory { FACULTY_CABIN, CLASS_ROOM, LAB, OTHER }

const Designation = [
  "Lecturer",
  "Assistant Prof",
  "Associate Prof",
  "Prof",
  "HOD",
  "COE",
  "Dean",
  "Vice Pricipal",
  "Pricipal",
  "Other"
];
