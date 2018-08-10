import 'package:flutter/material.dart';
import 'package:bmsce/dataClasses/Notes.dart' as dataNotes;

class Notes extends StatefulWidget{
  NotesState createState()=>NotesState();
}

class NotesState extends State<Notes>{

  List<dataNotes.Notes> notes;
  @override
  void initState(){
    super.initState();
    notes = dataNotes.notes;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: List.generate(notes.length, (index){
        return ListTile(
          leading: Icon(Icons.attach_file,),
          title: Text(notes[index].courseName,softWrap: false,overflow: TextOverflow.fade,),
          subtitle: Text(notes[index].description,maxLines: 2,overflow: TextOverflow.ellipsis,),
        );
      })..add(ListTile()),
    );
  }

}