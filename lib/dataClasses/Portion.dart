class Portion{
  String courseCode,courseName,description,signature;
  double version;
  bool isOutdated;
  bool teacherSignature;
  List<FrmTo> frmTos;
  Portion({this.courseName,this.description,this.isOutdated:false,this.signature,this.teacherSignature:false});
}

class FrmTo{
  int begin,end;
}

final portions=[
  Portion(courseName: 'Data Structures',description: '1st Internal',signature: 'shashikant'),
  Portion(courseName: 'Data Structures',description: '1st Internal',signature: 'shashikant'),
  Portion(courseName: 'Data Structures',description: '1st Internal',signature: 'shashikant',teacherSignature: true),
  Portion(courseName: 'Data Structures',description: '1st Internal',signature: 'shashikant',isOutdated: true),
  Portion(courseName: 'Data Structures',description: '1st Internal',signature: 'shashikant',isOutdated: true,teacherSignature: true),
  Portion(courseName: 'Data Structures',description: '1st Internal',signature: 'shashikant'),
  Portion(courseName: 'Data Structures',description: '1st Internal',signature: 'shashikant'),
];