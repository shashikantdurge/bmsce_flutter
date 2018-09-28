import 'package:meta/meta.dart';

abstract class Place {
  final String searchName;
  final String placeCat;
  final String location;
  final String addedBy;
  Place(
      {@required this.searchName,
      this.placeCat,
      @required this.location,
      @required this.addedBy});

  factory Place.fromMap(Map<String, dynamic> mapObj) {
    switch (mapObj["placeCat"]) {
      case "Lab":
        return Lab(
            name: mapObj["name"],
            dept: mapObj["dept"],
            location: mapObj["location"],
            addedBy: mapObj["addedBy"],
            capacity: mapObj["capacity"]);
      case "Faculty Cabin":
        return FacultyCabin(
            name: mapObj["name"],
            designation: mapObj["designation"],
            dept: mapObj["dept"],
            email: mapObj["email"],
            location: mapObj["location"],
            detailsLink: mapObj["detailsLink"],
            addedBy: mapObj["addedBy"],
            profilePictureLink: mapObj["profilePictureLink"]);
      case "Class Room":
        return ClassRoom(
          name: mapObj["name"],
          blockName: mapObj["blockName"],
          dept: mapObj["dept"],
          capacity: mapObj["capacity"],
          addedBy: mapObj["addedBy"],
          location: mapObj["location"],
        );

      default:
        return Other(
            addedBy: mapObj["addedBy"],
            searchName: mapObj["searchName"],
            location: mapObj["location"]);
    }
  }
}

class FacultyCabin extends Place {
  final String name;
  final String designation;
  final String dept; //opt
  final String email; //opt
  final String detailsLink; //opt
  final String profilePictureLink; //opt
  FacultyCabin(
      {@required this.name,
      this.designation,
      this.dept,
      this.email,
      this.detailsLink,
      this.profilePictureLink,
      @required String location,
      @required String addedBy})
      : super(
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
  final String name;
  final String dept; //opt
  final String blockName;
  final int capacity; //opt

  ClassRoom(
      {@required this.name,
      @required this.blockName,
      this.dept,
      this.capacity,
      @required String location,
      @required String addedBy})
      : super(
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
  final String name;
  final String dept;
  final int capacity;
  Lab(
      {@required this.name,
      @required this.dept,
      this.capacity,
      @required String location,
      @required String addedBy})
      : super(
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
  final String dept;
  Other(
      {@required String searchName,
      this.dept,
      @required String location,
      @required String addedBy})
      : super(
            searchName:
                "$searchName${dept == null ? "" : ", " + dept + " Dept"}",
            placeCat: "Other",
            addedBy: addedBy,
            location: location);

  Map<String, dynamic> toMap() {
    return {
      "searchName": this.searchName,
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
