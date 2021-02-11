import 'package:flutter/material.dart';
import 'package:flutterflux/config.dart';
import 'package:flutterflux/views/user_input_view.dart';
import 'package:localstorage/localstorage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterFlux',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      routes: {
        "/": (ctx) => MyHomePage(
              title: "Unread",
            ),
        "/config": (ctx) => UserInputView(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final LocalStorage storage = new LocalStorage(Config.IDENTIFIER_LOCALSTORAGE);

  @override
  Widget build(BuildContext context) {
    /// Check if the user token is set.
    /// If that's not the case, redirect to the corresponding page
    void checkToken() {
      String token = storage.getItem(Config.IDENTIFIER_API_KEY);
      if (token == null || token.isEmpty) {
        Navigator.pushNamed(context, "/config");
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[MaterialButton(onPressed: checkToken)],
        ),
      ),
    );
  }
}
