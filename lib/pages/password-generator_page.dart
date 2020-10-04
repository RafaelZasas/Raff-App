import 'package:Raffs_App/utils/text_styles.dart';
import 'package:Raffs_App/utils/ui_helpers.dart';
import 'package:flutter/material.dart';

class MyPasswordGenPage extends StatefulWidget {
  @override
  _MyPasswordGenPageState createState() => _MyPasswordGenPageState();
}

class _MyPasswordGenPageState extends State<MyPasswordGenPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: invertInvertColorsStrong(context),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: 60.0,
                bottom: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Still under construction!',
                    style: isThemeCurrentlyDark(context)
                        ? TitleStylesDefault.white
                        : TitleStylesDefault.black,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
