import 'dart:convert';

import 'package:http/http.dart';
import 'package:localstorage/localstorage.dart';
import 'config.dart';
import 'package:http/http.dart' as http;

class FeedEntry {
  int id;
  String status;
  String title;
  String url;

  FeedEntry({this.id, this.status, this.title, this.url});

  factory FeedEntry.fromJson(Map<String, dynamic> json) {
    return FeedEntry(
        id: json["id"],
        status: json["status"],
        title: json["title"],
        url: json["url"]);
  }
}

class MinifluxApi {
  final storage = new LocalStorage(Config.IDENTIFIER_LOCALSTORAGE);
  String serverUrl;
  String apiKey;

  MinifluxApi._() {
    serverUrl = storage.getItem(Config.IDENTIFIER_SERVER_URL);
    apiKey = storage.getItem(Config.IDENTIFIER_API_KEY);
  }

  static final MinifluxApi instance = MinifluxApi._();

  Future<Response> getRequest(String path) async {
    if (serverUrl == null ||
        serverUrl.isEmpty ||
        apiKey == null ||
        apiKey.isEmpty) {
      // TODO: Proper handling
      return null;
    }

    return await http.get("$serverUrl/v1$path",
        headers: {"X-Auth-Token": apiKey});
  }

  Future<List<FeedEntry>> getUnreadPosts() async {
    await storage.ready;

    Response response = await getRequest("/entries?status=unread");
    Map<String, dynamic> body = json.decode(response.body);
    List<dynamic> rawEntries = body["entries"];

    // TODO: Why the heck does rawEntries.map(...) not work here?
    List<FeedEntry> feedEntries = [];
    for (var entry in rawEntries) feedEntries.add(FeedEntry.fromJson(entry));
    return feedEntries;
  }
}
