import 'package:Raffs_App/utils/text_styles.dart';
import 'package:Raffs_App/utils/ui_helpers.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toggle_switch/toggle_switch.dart';

class MyPasswordGenPage extends StatefulWidget {
  @override
  _MyPasswordGenPageState createState() => _MyPasswordGenPageState();
}

class _MyPasswordGenPageState extends State<MyPasswordGenPage> {
  String password;

  bool isLoading = false; // var to store loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: invertInvertColorsStrong(context),
      body: Container(
        child: Column(
          // main app column
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                left: 10.0,
                top: 50.0,
              ),
              child: Row(
                // navigation row
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    icon: Icon(EvaIcons.arrowIosBack),
                    tooltip: 'Go back',
                    color: invertColorsStrong(context),
                    iconSize: 26.0,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Material(
                    // title
                    color: Colors.transparent,
                    child: Text(
                      'Password Generator',
                      style: isThemeCurrentlyDark(context)
                          ? TitleStylesDefault.white
                          : TitleStylesDefault.black,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              // project info
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
                top: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'This triggers a Google Cloud Function which hits a '
                      'Python API, built using FastAPI',
                      style: isThemeCurrentlyDark(context)
                          ? TextStyle(color: Colors.white, fontSize: 18)
                          : TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              // pw length input
              padding: EdgeInsets.only(
                top: 30.0,
                bottom: 10.0,
                left: 10,
                right: 15,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Password Length:',
                    style: isThemeCurrentlyDark(context)
                        ? TextStyle(color: Colors.white, fontSize: 20)
                        : TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ],
              ),
            ),
            Container(
              // use symbols input
              padding: EdgeInsets.only(
                top: 30.0,
                bottom: 10.0,
                left: 10,
                right: 15,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Use Symbols?',
                    style: isThemeCurrentlyDark(context)
                        ? TextStyle(color: Colors.white, fontSize: 20)
                        : TextStyle(color: Colors.black, fontSize: 20),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: ToggleSwitch(
                      minWidth: 90.0,
                      cornerRadius: 20.0,
                      activeBgColor: Colors.cyan,
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.grey,
                      inactiveFgColor: Colors.white,
                      labels: ['YES', 'NO'],
                      icons: [FontAwesomeIcons.check, FontAwesomeIcons.times],
                      onToggle: (index) {
                        print('switched to: $index');
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                top: 10,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ButtonBar(
                        children: <Widget>[
                          RaisedButton(
                            child: Text(
                              'Generate Password',
                              style: isThemeCurrentlyDark(context)
                                  ? TextStyle(color: Colors.black, fontSize: 20)
                                  // text black when background black and button white
                                  : TextStyle(
                                      color: Colors.white, fontSize: 20),
                              // text white when background white and button black
                            ),
                            color: isThemeCurrentlyDark(context)
                                ? Colors.lightBlueAccent
                                // background color lightBlueAccent
                                : Colors.black26, // background color black
                            onPressed: () async {
                              setState(() {
                                isLoading = true; // display indicator
                              });
                              // call cloud function & use set state to store pw
                              await getPassword().then((String result) {
                                setState(() {
                                  password = result;
                                  isLoading = false; // set loading indicator
                                });
                              });
                              showDialog(
                                  context: context,
                                  builder: (context) => DisplayPassword());
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                  isLoading
                      ? SpinKitCircle(
                          color: Colors.lightBlue,
                          size: 50,
                        )
                      : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String> getPassword() async {
  var pw;
  final HttpsCallable callable = new CloudFunctions()
      .getHttpsCallable(functionName: 'getRandomPassword')
        ..timeout = const Duration(seconds: 30);

  try {
    await callable.call(
      <String, dynamic>{
        'pwLength': 10,
        'useSymbols': true,
      },
    ).then((value) {
      print(value.data);
      print(value.data.runtimeType);
      pw = value.data;
      return pw;
    });
  } on CloudFunctionsException catch (e) {
    print('caught firebase functions exception');
    print('Code: ${e.code}\nmessage: ${e.message}\ndetails: ${e.details}');

    return '${e.details}';
  } catch (e) {
    print('caught generic exception');
    print(e);
    return 'caught generic exception\n$e';
  }
}

class DisplayPassword extends StatelessWidget {
  final String pw = (_MyPasswordGenPageState().password == null)
      ? 'null value error'
      : _MyPasswordGenPageState().password;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(pw),
    );
  }
}
