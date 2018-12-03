import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import 'package:feeds2imap_mobile/model/item.dart';
import 'package:feeds2imap_mobile/util/database_helper.dart';
import 'package:intl/intl.dart';

class FeedUrlHelper {
  String url;
  int urlID;

  DatabaseHelper _db = new DatabaseHelper();

  FeedUrlHelper(this.url, this.urlID);

  Future<List<Item>> load() async {
    return http.read(url).then((content) => _fromContent(content, urlID));
  }

  List<Item> _fromContent(String content, int urlID) {
    try {
      return _fromAtom(content, urlID);
    } catch (e) {
      print("Erro while parsing feed as an atom feed: $e");
      return _fromRss(content, urlID);
    }
  }

  int _parseDate(String input) {
    input = input.trim();

    var formats = <String>[
      'E, d MMM y HH:mm:ss Z',
    ];

    try {
      return DateTime.parse(input).millisecondsSinceEpoch;
    } catch (e) {
      for (var format in formats) {
        try {
          var dateFormat = DateFormat(format);
          return dateFormat.parse(input).millisecondsSinceEpoch;
        } catch (e) {
          print('Was unable to use format "$format" to parse "$input": "$e"');
        }
      }

      print('========> Could not parse input "$input"');
      return 0;
    }
  }

  List<Item> _fromAtom(String content, int urlID) {
    var feed = AtomFeed.parse(content);

    return feed.items
        .map((item) => Item(
            item.title,
            item.content,
            item.id,
            item.links.first.href,
            urlID,
            false,
            false,
            item.authors.first.toString(),
            _parseDate(item.published),
            feed.title != null ? feed.title : feed.subtitle))
        .toList();
  }

  List<Item> _fromRss(String content, int urlID) {
    var feed = RssFeed.parse(content);

    return feed.items
        .map((item) => Item(
            item.title,
            item.description,
            item.guid,
            item.link,
            urlID,
            false,
            false,
            item.author,
            _parseDate(item.pubDate),
            feed.title != null ? feed.title : feed.description))
        .toList();
  }

  Future saveNewItems() {
    return load().then((items) async {
      await Future.wait(items.map(_db.saveItemIfNotExists));
    });
  }
}

class FeedHelper {
  DatabaseHelper _db = new DatabaseHelper();

  Future refreshAll() async {
    var urls = await _db.getAllUrls();
    var fs = urls.map((u) {
      print('Trying to update items for ${u.url}');
      var feedHelper = FeedUrlHelper(u.url, u.urlID);
      return feedHelper.saveNewItems();
    });

    return Future.wait(fs);
  }
}
