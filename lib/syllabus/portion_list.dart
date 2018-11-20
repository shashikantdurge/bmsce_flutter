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
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Opacity(
                          opacity: 0.4,
                          child: Image.asset('assets/images/minion_sad.png')),
                      Text(
                        'No portions ',
                        style: TextStyle(
                            fontFamily: 'Ubuntu',
                            color: Theme.of(context).textTheme.caption.color,
                            fontSize:
                                Theme.of(context).textTheme.subhead.fontSize),
                      )
                    ]),
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
          trailing: PopupMenuButton(
            onSelected: (item) {
              if (item == "remove")
                PortionProvider()
                    .remove(portion.courseCode, portion.codeVersion,
                        portion.createdOn, portion.createdBy)
                    .then((onValue) {
                  setState(() {});
                });
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Text('Remove'),
                  value: 'remove',
                )
              ];
            },
          ),
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
