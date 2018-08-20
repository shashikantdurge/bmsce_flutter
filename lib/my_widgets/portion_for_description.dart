import 'package:flutter/material.dart';

const PORTION_FOR_SUGGESTIONS = [
  '1st Internal',
  '2nd Internal',
  '3rd Internal',
  '1st Quiz',
  '2st Quiz',
  'Other...', //this is referenced in syllabus_tabs so don't change it's name
];

class PortionDescriptionDialog extends StatelessWidget {
  final TextEditingController textEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(12.0),
      title: Text('Portion for...'),
      children: <Widget>[
        Form(
          key: _formKey,
          autovalidate: true,
          child: TextFormField(
            autofocus: true,
            controller: textEditingController,
            autovalidate: true,
            decoration: InputDecoration(
                labelStyle: TextStyle(color: Colors.black),
                labelText: 'Description'),
            validator: (description) {
              return description.trim().isEmpty
                  ? 'Description cannot be Empty'
                  : null;
            },
            onFieldSubmitted: (description) {
              if (_formKey.currentState.validate()) {
                print('Valid');
                Navigator.of(context).pop(textEditingController.text);
              } else {
                print('InValid');
              }
            },
          ),
        ),
        ButtonBar(
          children: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Proceed'),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  print('Valid');
                  Navigator.of(context).pop(textEditingController.text);
                } else {
                  print('InValid');
                }
              },
            ),
          ],
        )
      ],
    );
  }
}

class PortionDescriptionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: List.generate(PORTION_FOR_SUGGESTIONS.length, (index) {
        return ListTile(
          title: Text(PORTION_FOR_SUGGESTIONS[index]),
          onTap: () {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop(PORTION_FOR_SUGGESTIONS[index]);
            }
          },
        );
      }),
    );
  }
}
