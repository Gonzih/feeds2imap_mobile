class Item {
  int _itemID;
  String _title;
  String _description;
  String _guid;
  String _link;
  int urlID;
  bool read;
  bool archived;
  String _author;
  int _publishedAt;
  String _feedTitle;

  Item(this._title, this._description, this._guid, this._link, this.urlID,
      this.read, this.archived, this._author, this._publishedAt, this._feedTitle);

  Item.map(dynamic obj) {
    this._itemID = obj['item_id'];
    this._title = obj['title'];
    this._description = obj['description'];
    this._guid = obj['guid'];
    this._link = obj['link'];
    this.urlID = obj['url_id'];
    this.read = obj['read'];
    this.archived = obj['archived'];
    this._author = obj['author'];
    this._publishedAt = obj['published_at'];
    this._feedTitle = obj['feed_title'];
  }

  int get itemID => _itemID;

  String get title => _title;

  String get description => _description;

  String get guid => _guid;

  String get link => _link;

  String get author => _author;

  int get publishedAt => _publishedAt;

  String get feedTitle => _feedTitle;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_itemID != null) {
      map['item_id'] = _itemID;
    }
    map['title'] = _title;
    map['description'] = _description;
    map['url_id'] = urlID;
    map['guid'] = _guid;
    map['link'] = _link;
    map['read'] = read ? 1 : 0;
    map['archived'] = archived ? 1 : 0;
    map['author'] = _author;
    map['published_at'] = _publishedAt;
    map['feed_title'] = _feedTitle;

    return map;
  }

  Item.fromMap(Map<String, dynamic> map) {
    this._itemID = map['item_id'];
    this._title = map['title'];
    this._description = map['description'];
    this._guid = map['guid'];
    this._link = map['link'];
    this.urlID = map['url_id'];
    this.read = map['read'] == 1;
    this.archived = map['archived'] == 1;
    this._author = map['author'];
    this._publishedAt = map['published_at'];
    this._feedTitle = map['feed_title'];
  }
}
