import 'package:Raffs_App/utils/text_styles.dart';
import 'package:Raffs_App/utils/ui_helpers.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toggle_switch/toggle_switch.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class MyPasswordGenPage extends StatefulWidget {
  @override
  _MyPasswordGenPageState createState() => _MyPasswordGenPageState();
}

class _MyPasswordGenPageState extends State<MyPasswordGenPage> {
  String password;

  bool isLoading = false; // var to store loading state
  bool useSymbols;
  int passwordLength = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
              child: TextFormField(
                //todo: fix overflow issue

                // allow only digits to be entered
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: "Enter Password Length",
                  labelStyle: isThemeCurrentlyDark(context)
                      ? TextStyle(color: Colors.white, fontSize: 20)
                      : TextStyle(color: Colors.black, fontSize: 20),
                ),
                onChanged: (String len) {
                  // updates as user types
                  passwordLength = int.tryParse(len);
                },
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
                      onToggle: (index) async {
                        print('switched to: $index');
                        index == 0 ? useSymbols = true : useSymbols = false;
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

                            // button click for password generation
                            onPressed: () async {
                              setState(() {
                                isLoading = true; // show loading indicator
                              });

                              // define callable cloud function instance
                              final HttpsCallable callable = CloudFunctions
                                  .instance
                                  .getHttpsCallable(
                                      functionName: 'getRandomPassword')
                                    ..timeout = const Duration(seconds: 30);

                              try {
                                // allow for exception handling

                                dynamic result =
                                    await callable.call(<String, dynamic>{
                                  'pwLength': passwordLength,
                                  'useSymbols': useSymbols,
                                  //await the result before continue
                                });

                                setState(() {
                                  // update the values post click
                                  // convert hashmap to list and get first val
                                  password = result.data.values.toList()[0];
                                  isLoading = false; // remove loading indicator
                                  useSymbols = true; // due to the toggle reset
                                });
                              } on CloudFunctionsException catch (e) {
                                print('caught firebase functions exception');
                                print(
                                    'Code: ${e.code}\nmessage: ${e.message}\ndetails: ${e.details}');
                              } catch (e) {
                                print('caught generic exception');
                                print(e);
                              }

                              showDialog(
                                  context: context,
                                  builder: (context) =>
                                      DisplayPassword(password));
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                  isLoading // is the sys waiting for the password?
                      ? SpinKitCircle(
                          // if so display loading indicator
                          color: Colors.lightBlue,
                          size: 50,
                        )
                      : Container(), // if not display nothing
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DisplayPassword extends StatelessWidget {
  var password; // check if null
  DisplayPassword(this.password); // constructor

  @override
  Widget build(BuildContext context) {
    // make sure null value isn't being passed to alert dialog widget
    if (password == null) {
      password = 'null value error';
    }

    return AlertDialog(
      title: Center(child: Text(password)),
      content: IconButton(
          onPressed: () {
            copyPassword();
            // dismiss alert dialog
            Navigator.of(context, rootNavigator: true).pop('dialog');

            // place snack bar onto scaffold
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('Copied'),
              duration: const Duration(seconds: 2),
            ));
          },
          icon: Icon(FontAwesomeIcons.clipboard)),
    );
  }

  copyPassword() {
    // save text to clipboard
    Clipboard.setData(new ClipboardData(text: password));
  }
}
