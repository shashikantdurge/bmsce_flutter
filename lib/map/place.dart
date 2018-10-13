import 'package:bmsce/map/building_constants.dart';
import 'package:bmsce/map/location.dart';
import 'package:bmsce/user_profile/user.dart';

class Place {
  String name;
  String website;
  String location;
  String phoneNumber;
  String email;
  PlaceCategory placeCategory;
  String designation;
  String dept;
  String photoUrl;
  String collegeMapDocRef;
  String suggestionType;
  String suggestedByName;
  String suggestedByEmail;
  String suggestedByDept;
  String approvedByName;
  String approvedByEmail;
  String approvedByDept;
  String isApproved;
  String searchName;

  Place();

  Map<String, dynamic> toMap(User user, String suggestionType) {
    String searchName;
    if (dept == 'Other') dept = null;
    if (designation == 'Other') designation = null;
    if (placeCategory == PlaceCategory.FACULTY_CABIN) {
      searchName =
          "$name${designation == null ? "" : ", " + designation}${dept == null ? "" : ", " + dept + " Dept"}";
    } else if (placeCategory == PlaceCategory.CLASS_ROOM) {
      searchName =
          "$name, ${BlockNameMap[LocationMarker.getBlockFloorFrmLocationId(location).item1]}";
    } else {
      searchName = "$name${dept == null ? "" : ", " + dept + " Dept"}";
    }
    return {
      'name': name,
      'website': website.trim().isNotEmpty ? website.trim() : null,
      'location': location,
      'phoneNumber': phoneNumber.trim().isNotEmpty ? phoneNumber.trim() : null,
      'email': email.trim().isNotEmpty ? email.trim() : null,
      'placeCategory': placeCategory.toString(),
      'collegeMapDocRef': collegeMapDocRef,
      'designation': designation,
      "dept": dept,
      'photoUrl': photoUrl,
      'searchName': searchName,
      "suggestionType": suggestionType,
      "suggestedByName": user?.displayName,
      "suggestedByEmail": user?.email,
      "suggestedByDept": user?.dept,
      "isApproved": null,
    };
  }

  factory Place.fromMap(Map<String, dynamic> placeMapObj) {
    Place place = Place();
    place.name = placeMapObj["name"];
    place.website = placeMapObj["website"];
    place.location = placeMapObj["location"];
    place.phoneNumber = placeMapObj["phoneNumber"];
    place.email = placeMapObj["email"];
    place.placeCategory = StringToEnum[placeMapObj["placeCategory"]];
    place.designation = placeMapObj["designation"];
    place.dept = placeMapObj["dept"];
    place.photoUrl = placeMapObj["photoUrl"];
    place.collegeMapDocRef = placeMapObj["collegeMapDocRef"];
    place.suggestionType = placeMapObj["suggestionType"];
    place.suggestedByName = placeMapObj["suggestedByName"];
    place.suggestedByEmail = placeMapObj["suggestedByEmail"];
    place.suggestedByDept = placeMapObj["suggestedByDept"];
    place.approvedByName = placeMapObj["approvedByName"];
    place.approvedByEmail = placeMapObj["approvedByEmail"];
    place.approvedByDept = placeMapObj["approvedByDept"];
    place.isApproved = placeMapObj["isApproved"];
    place.searchName = placeMapObj["searchName"];
    return place;
  }
}

const PlaceCategoryMap = {
  //#List items are refernced in other places DO NOT Change the names
  PlaceCategory.FACULTY_CABIN: "Faculty Cabin",
  PlaceCategory.CLASS_ROOM: "Class Room",
  PlaceCategory.LAB: "Lab",
  PlaceCategory.OTHER: "Other"
};

const StringToEnum = {
  //#List items are refernced in other places DO NOT Change the names
  'PlaceCategory.FACULTY_CABIN': PlaceCategory.FACULTY_CABIN,
  'PlaceCategory.CLASS_ROOM': PlaceCategory.CLASS_ROOM,
  'PlaceCategory.LAB': PlaceCategory.LAB,
  'PlaceCategory.OTHER': PlaceCategory.OTHER,
};

enum PlaceCategory { FACULTY_CABIN, CLASS_ROOM, LAB, OTHER }

const designations = [
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
