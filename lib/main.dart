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

  /// Check if the user token is set.
  /// If that's not the case, redirect to the config page
  void checkConfig() async {
    await storage.ready;
    dynamic token = await storage.getItem(Config.IDENTIFIER_API_KEY);
    if (token == null || token.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamed(context, "/config");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    checkConfig();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[],
        ),
      ),
    );
  }
}
