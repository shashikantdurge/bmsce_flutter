import 'package:bmsce/map/place.dart';
import 'package:bmsce/user_profile/user.dart';
import 'package:flutter/material.dart';

class SuggestAnEditDialog extends StatelessWidget {
  final String name;
  final User user;
  final Place place;

  const SuggestAnEditDialog(
      {Key key, @required this.name, @required this.user, @required this.place})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Suggest an edit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(name),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Change name or other details'),
            subtitle: Text('Edit name, location etc'),
            onTap: () {
              Navigator.of(context).pop('edit');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.location_off),
            title: Text('Remove this place'),
            subtitle: Text('Mark as closed, non-existent or duplicate'),
            onTap: (){
              Navigator.of(context).pop('close');
            },
          ),
          Divider()
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
