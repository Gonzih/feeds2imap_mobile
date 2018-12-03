import 'package:flutter/material.dart';
import 'package:feeds2imap_mobile/model/folder.dart';
import 'package:feeds2imap_mobile/model/url.dart';
import 'package:feeds2imap_mobile/util/database_helper.dart';
import 'package:feeds2imap_mobile/ui/add_url.dart';
import 'package:feeds2imap_mobile/ui/add_folder.dart';

class FolderWithUrls {
  final Folder folder;
  final List<Url> urls;

  FolderWithUrls(this.folder, this.urls);
}

class FoldersScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  DatabaseHelper _db = new DatabaseHelper();
  final List<FolderWithUrls> _data = new List();

  void _refreshState() async {
    List<FolderWithUrls> fwy = new List();

    var folders = await _db.getAllFolders();

    for (var folder in folders) {
      var urls = await _db.getUrlsForFolder(folder.folderID);
      fwy.add(FolderWithUrls(folder, urls));
    }

    setState(() {
      _data.clear();
      fwy.forEach(_data.add);
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Folders'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddFolder,
          ),
        ],
      ),
      body: ListView.builder(
          itemCount: _data.length,
          itemBuilder: (context, position) {
            var folderWithUrls = _data[position];

            return Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          child: Text('${folderWithUrls.folder.name}'),
                          onTap: () => _selectFolder(context, folderWithUrls.folder),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () =>
                              _navigateToAddUrl(folderWithUrls.folder),
                        ),
                      ],
                    ),
                    ListView.builder(
                      itemCount: folderWithUrls.urls.length,
                      itemBuilder: (context, position) {
                        var url = folderWithUrls.urls[position];
                        return Padding(
                          padding: EdgeInsets.only(top: 6.0),
                          child: Row(
                            children: <Widget>[
                              Text('${url.url}',overflow: TextOverflow.fade,),
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => _removeUrl(url),
                              ),
                            ],
                          ),
                        );
                      },
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                    ),
                  ],
                ));
          }),
    );
  }

  void _navigateToAddUrl(Folder folder) async {
    String result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddUrlScreen(folder)),
    );

    if (result == 'added') {
      _refreshState();
    }
  }

  void _navigateToAddFolder() async {
    String result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddFolderScreen()),
    );

    if (result == 'added') {
      _refreshState();
    }
  }

  void _removeUrl(Url url) async {
    await _db.deleteUrl(url.urlID);
    _refreshState();
  }

  void _selectFolder(BuildContext context, Folder folder) {
    Navigator.pop(context, folder);
  }
}
