import 'package:flutter/material.dart';
import 'package:bmsce/dataClasses/Portion.dart' as dataPortion;

class Portion extends StatefulWidget{
  PortionState createState()=>PortionState();
}

class PortionState extends State<Portion>{

  List<dataPortion.Portion> portions;
  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    portions = dataPortion.portions;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: List.generate(portions.length, (index){
        final portion = portions[index];
        return ListTile(
          title: Text(portion.courseName,softWrap: false,overflow: TextOverflow.fade,),
          subtitle: Text(portion.description,maxLines: 2,overflow: TextOverflow.ellipsis,),
          trailing: portion.isOutdated?(Icon(Icons.error_outline,color: Colors.red,)):(portion.teacherSignature?Icon(Icons.verified_user,color: Colors.green,):Icon(Icons.info_outline)),
        );
      })..add(ListTile()),
    );
  }

}