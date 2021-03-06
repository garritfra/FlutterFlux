import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:localstorage/localstorage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../miniflux.dart';

class UnreadView extends StatefulWidget {
  UnreadView({Key key}) : super(key: key);

  @override
  _UnreadViewState createState() => _UnreadViewState();
}

class _UnreadViewState extends State<UnreadView> {
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
    var posts = await MinifluxApi.instance.getUnreadPosts();
    setState(() {
      unreadPosts = posts;
    });
  }

  void _readArticle(FeedEntry entry) async {
    if (await canLaunch(entry.url)) {
      MinifluxApi.instance.markAsRead(entry.id);
      launch(entry.url);
      setState(() {
        unreadPosts.remove(entry);
      });
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

  @override
  Widget build(BuildContext context) {
    if (unreadPosts.isEmpty) {
      return Container(
        child: Center(
          child: Text("All done!"),
        ),
      );
    }
    return Container(
        key: UniqueKey(),
        child: Center(
          child: ListView.builder(
            itemCount: unreadPosts.length,
            key: UniqueKey(),
            itemBuilder: (BuildContext context, int index) {
              FeedEntry entry = unreadPosts[index];
              return Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.horizontal,
                onDismissed: (direction) {
                  setState(() {
                    unreadPosts.removeAt(index);
                  });
                  MinifluxApi.instance.markAsRead(entry.id);
                },
                child: Card(
                  child: ListTile(
                    key: UniqueKey(),
                    title: Text(entry.title),
                    subtitle: Text(entry.feed.title),
                    onTap: () => _readArticle(entry),
                  ),
                ),
              );
            },
          ),
        ));
  }
}
