import 'package:flutter/material.dart';
import 'package:feeds2imap_mobile/model/folder.dart';
import 'package:feeds2imap_mobile/util/database_helper.dart';

class AddFolderScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _AddFolderScreenState();
}

class _AddFolderScreenState extends State<AddFolderScreen> {
  DatabaseHelper _db = new DatabaseHelper();
  TextEditingController _folderController;

  @override
  void initState() {
    super.initState();
    _folderController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AddFolder')),
      body: Container(
        child: Column(
          children: <Widget>[
            TextField(
              controller: _folderController,
              decoration: InputDecoration(labelText: 'Folder name'),
            ),
            Padding(padding: new EdgeInsets.all(5.0)),
            RaisedButton(
                child: Text('Add'),
                onPressed: () {
                  var folder = Folder(_folderController.text);
                  _db.saveFolder(folder).then((_) {
                    Navigator.pop(context, 'added');
                  });
                }),
          ],
        ),
      ),
    );
  }
}
