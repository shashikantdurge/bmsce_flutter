import 'package:flutter/material.dart';

class CardHeader extends StatelessWidget{
  final String text;
  final bool paddingAround;
  final TextStyle textStyle =
  TextStyle(fontSize: 16.0, wordSpacing: 2.0, letterSpacing: 1.4);

  CardHeader(this.text,{Key key, this.paddingAround=false, }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: paddingAround?EdgeInsets.all(8.0):EdgeInsets.all(0.0),
      child: Container(
        width: double.maxFinite,
        padding: EdgeInsets.all(8.0),
        color: Colors.grey[200],
        child: Text(
          text,
          style: textStyle,
        ),
      ),
    );
  }

}