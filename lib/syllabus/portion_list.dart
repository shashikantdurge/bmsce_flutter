import 'package:bmsce/portion/portion_provider_sqf.dart';
import 'package:flutter/material.dart';

import 'portion_view.dart';

class PortionList extends StatefulWidget {
  PortionState createState() => PortionState();
}

class PortionState extends State<PortionList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Portion>>(
        future: PortionProvider().getPortionsList(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return Center(
                child: Text('Loading...'),
              );
              break;
            case ConnectionState.done:
              if (snapshot.hasData) {
                if (snapshot.data.isNotEmpty) {
                  return getPortionListView(snapshot.data);
                } else if (snapshot.data.isEmpty) {
                  return Center(
                    child: Text('Chill!!!'),
                  );
                }
              } else {
                return Center(
                  child: Text('Something is wrong? ${snapshot.hasError}'),
                );
              }
          }
        });
  }

  Widget getPortionListView(List<Portion> portions) {
    return ListView(
      children: List.generate(portions.length, (index) {
        final portion = portions[index];
        return ListTile(
          title: Text(
            portion.courseName,
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
          subtitle: Text(
            portion.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: portion.isOutdated == 1
              ? (Icon(
                  Icons.error_outline,
                  color: Colors.red,
                ))
              : (portion.isTeacherSignature == 1
                  ? Icon(
                      Icons.verified_user,
                      color: Colors.green,
                    )
                  : Icon(Icons.info_outline)),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return PortionView(
                courseName: portion.courseName,
                createdBy: portion.createdBy,
                createdOn: portion.createdOn,
                description: portion.description,
              );
            }));
          },
        );
      })
        ..add(ListTile()),
    );
  }
}
