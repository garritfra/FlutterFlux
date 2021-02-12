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

enum RequestMethod {
  get,
  post,
  put,
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

  // TODO: Make DRY
  Future<Response> request(
      {RequestMethod method, String path, body: String}) async {
    if (serverUrl == null ||
        serverUrl.isEmpty ||
        apiKey == null ||
        apiKey.isEmpty) {
      // TODO: Proper handling
      return null;
    }

    switch (method) {
      // GET is default
      case RequestMethod.get:
        break;
      case RequestMethod.post:
        return await http
            .post("$serverUrl/v1$path", headers: {"X-Auth-Token": apiKey});
        break;
      case RequestMethod.put:
        return await http.put("$serverUrl/v1$path",
            headers: {"X-Auth-Token": apiKey}, body: body);
        break;
    }

    return await http
        .get("$serverUrl/v1$path", headers: {"X-Auth-Token": apiKey});
  }

  Future<List<FeedEntry>> getUnreadPosts() async {
    await storage.ready;

    Response response = await request(
        method: RequestMethod.get, path: "/entries?status=unread");
    Map<String, dynamic> body = json.decode(response.body);
    List<dynamic> rawEntries = body["entries"];

    // TODO: Why the heck does rawEntries.map(...) not work here?
    List<FeedEntry> feedEntries = [];
    for (var entry in rawEntries) feedEntries.add(FeedEntry.fromJson(entry));
    return feedEntries;
  }

  Future markAsRead(int id) async {
    var body = {
      "entry_ids": [id],
      "status": "read"
    };
    String encodedBody = json.encode(body);
    Response res = await request(
        body: encodedBody, method: RequestMethod.put, path: "/entries");
    return res;
  }
}
