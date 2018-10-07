import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class UploadResult extends StatefulWidget {
  final List<Tuple6> successfulUsers, failedUsers;

  const UploadResult(
      {Key key, @required this.successfulUsers, @required this.failedUsers})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return UploadResultState();
  }
}

class UploadResultState extends State<UploadResult> {
  bool successExpand = false, failExpand = false;
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(12.0),
      title: Text('Status'),
      children: <Widget>[
        ExpansionPanelList(
          expansionCallback: (i, isExpanded) {
            switch (i) {
              case 0:
                setState(() {
                  successExpand = !isExpanded;
                });
                break;
              case 1:
                setState(() {
                  failExpand = !isExpanded;
                });
                break;
            }
          },
          children: [
            ExpansionPanel(
                isExpanded: successExpand,
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return Text('${widget.successfulUsers.length} Successful');
                },
                body: Column(
                  children: List.generate(widget.successfulUsers.length, (i) {
                    return Text(widget.successfulUsers[i].item3 ?? "UNKNOWN");
                  }),
                )),
            ExpansionPanel(
                isExpanded: failExpand,
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return Text('${widget.failedUsers.length} Failed');
                },
                body: Column(
                  children: List.generate(widget.failedUsers.length, (i) {
                    return Text(widget.failedUsers[i].item3 ?? "UNKNOWN");
                  }),
                ))
          ],
        )
      ],
    );
  }
}
