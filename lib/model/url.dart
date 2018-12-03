class Url {
  int _urlID;
  String _url;
  int _folderID;

  Url(this._url, this._folderID);

  Url.map(dynamic obj) {
    this._urlID = obj['url_id'];
    this._url = obj['url'];
    this._folderID = obj['folder_id'];
  }

  int get urlID => _urlID;

  String get url => _url;

  int get folderID => _folderID;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_urlID != null) {
      map['url_id'] = _urlID;
    }
    map['url'] = _url;
    map['folder_id'] = _folderID;

    return map;
  }

  Url.fromMap(Map<String, dynamic> map) {
    this._urlID = map['url_id'];
    this._url = map['url'];
    this._folderID = map['folder_id'];
  }
}
