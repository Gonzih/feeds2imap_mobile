class Folder {
  int _folderID;
  String _name;

  Folder(this._name);

  Folder.map(dynamic obj) {
    this._folderID = obj['folder_id'];
    this._name = obj['name'];
  }

  int get folderID => _folderID;

  String get name => _name;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_folderID != null) {
      map['folder_id'] = _folderID;
    }
    map['name'] = _name;

    return map;
  }

  Folder.fromMap(Map<String, dynamic> map) {
    this._folderID = map['folder_id'];
    this._name = map['name'];
  }
}
