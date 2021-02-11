import 'dart:convert';

import 'package:http/http.dart';
import 'package:localstorage/localstorage.dart';
import 'config.dart';
import 'package:http/http.dart' as http;

class FeedEntry {
  int id;
  String status;
  String title;

  FeedEntry({this.id, this.status, this.title});

  factory FeedEntry.fromJson(Map<String, dynamic> json) {
    return FeedEntry(
      id: json["id"],
      status: json["status"],
      title: json["title"],
    );
  }
}

class MinifluxApi {
  Future<List<FeedEntry>> getUnreadPosts() async {
    final storage = new LocalStorage(Config.IDENTIFIER_LOCALSTORAGE);
    await storage.ready;

    String serverUrl = storage.getItem(Config.IDENTIFIER_SERVER_URL);
    String apiKey = storage.getItem(Config.IDENTIFIER_API_KEY);

    if (serverUrl == null ||
        serverUrl.isEmpty ||
        apiKey == null ||
        apiKey.isEmpty) {
      return [];
    }
    Response response = await http.get("$serverUrl/v1/entries?status=unread",
        headers: {"X-Auth-Token": apiKey});
    Map<String, dynamic> body = json.decode(response.body);
    List<dynamic> rawEntries = body["entries"];

    // TODO: Why the heck does rawEntries.map(...) not work here?
    List<FeedEntry> feedEntries = [];
    for (var entry in rawEntries) feedEntries.add(FeedEntry.fromJson(entry));
    return feedEntries;
  }
}
