import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutterflux/config.dart';
import 'package:flutterflux/miniflux.dart';
import 'package:flutterflux/views/user_input_view.dart';
import 'package:localstorage/localstorage.dart';
import 'package:url_launcher/url_launcher.dart';

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
  List<FeedEntry> unreadPosts = [];

  /// Check if the user token is set.
  /// If that's not the case, redirect to the config page
  Future<bool> checkConfig() async {
    await storage.ready;
    dynamic token = await storage.getItem(Config.IDENTIFIER_API_KEY);

    if (token == null || token.isEmpty) {
      Navigator.pushNamed(context, "/config");
      return false;
    }
    return true;
  }

  void _initUnreadPosts() async {
    var posts = await MinifluxApi().getUnreadPosts();
    setState(() {
      unreadPosts = posts;
    });
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    checkConfig().then((success) {
      if (success) {
        _initUnreadPosts();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          key: UniqueKey(),
          child: ListView.builder(
            itemCount: unreadPosts.length,
            key: UniqueKey(),
            itemBuilder: (BuildContext context, int index) {
              FeedEntry entry = unreadPosts[index];
              return InkWell(
                child: Card(
                  child: ListTile(
                    key: UniqueKey(),
                    title: Text(entry.title),
                  ),
                ),
                onTap: () => _launchURL(entry.url),
              );
            },
          )),
    );
  }
}
