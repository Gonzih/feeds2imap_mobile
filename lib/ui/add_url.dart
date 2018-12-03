import 'package:flutter/material.dart';
import 'package:feeds2imap_mobile/model/url.dart';
import 'package:feeds2imap_mobile/model/folder.dart';
import 'package:feeds2imap_mobile/util/database_helper.dart';

class AddUrlScreen extends StatefulWidget {
  final Folder folder;

  AddUrlScreen(this.folder);

  @override
  State<StatefulWidget> createState() => new _AddUrlScreenState();
}

class _AddUrlScreenState extends State<AddUrlScreen> {
  DatabaseHelper _db = new DatabaseHelper();
  TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AddUrl')),
      body: Container(
        child: Column(
          children: <Widget>[
            TextField(
              controller: _urlController,
              decoration: InputDecoration(labelText: 'URL'),
            ),
            Padding(padding: new EdgeInsets.all(5.0)),
            RaisedButton(
                child: Text('Add'),
                onPressed: () {
                  print(widget.folder.folderID);
                  var url = Url(_urlController.text, widget.folder.folderID);
                  _db.saveUrl(url).then((_) {
                    Navigator.pop(context, 'added');
                  });
                }),
          ],
        ),
      ),
    );
  }
}
