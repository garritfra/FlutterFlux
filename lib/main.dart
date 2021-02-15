import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutterflux/config.dart';
import 'package:flutterflux/miniflux.dart';
import 'package:flutterflux/views/unread_view.dart';
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
        primaryColor: Color(0xff004e98),
        accentColor: Color(0xffff6700),
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
  int _selectedNavIndex = 0;
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

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
  }

  void _initUnreadPosts() async {
    var posts = await MinifluxApi.instance.getUnreadPosts();
    setState(() {
      unreadPosts = posts;
    });
  }

  void _readArticle(FeedEntry entry) async {
    if (await canLaunch(entry.url)) {
      MinifluxApi.instance.markAsRead(entry.id);
      launch(entry.url);
    } else {
      throw 'Could not launch ${entry.url}';
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

  static List<Widget> _widgetOptions = <Widget>[
    UnreadView(
      key: UniqueKey(),
    ),
    Container(
      color: Colors.blue,
    ),
    Container(
      color: Colors.red,
    ),
    Container(
      color: Colors.yellow,
    ),
    Container(
      color: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          foregroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.pushNamed(context, "/config");
              },
            ),
          ],
          title: Text(widget.title),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.new_releases_outlined),
              label: 'Unread',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: 'Starred',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article),
              label: 'Feeds',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categories',
            ),
          ],
          currentIndex: _selectedNavIndex,
          onTap: _onNavItemTapped,
          backgroundColor: Colors.black,
          unselectedItemColor: Theme.of(context).colorScheme.secondaryVariant,
          selectedItemColor: Theme.of(context).colorScheme.secondary,
        ),
        body: _widgetOptions[_selectedNavIndex]);
  }
}
