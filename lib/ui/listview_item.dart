import 'package:flutter/material.dart';
import 'package:feeds2imap_mobile/model/item.dart';
import 'package:feeds2imap_mobile/model/folder.dart';
import 'package:feeds2imap_mobile/util/database_helper.dart';
import 'package:feeds2imap_mobile/ui/item_screen.dart';
import 'package:feeds2imap_mobile/ui/folders_screen.dart';
import 'package:feeds2imap_mobile/feed/feed.dart';

class ListViewItem extends StatefulWidget {
  @override
  _ListViewItemState createState() => new _ListViewItemState();
}

class _ListViewItemState extends State<ListViewItem> {
  List<Item> _items = new List();
  DatabaseHelper _db = new DatabaseHelper();
  Folder _activeFolder;

  @override
  void initState() {
    super.initState();

    _refreshState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSA ListView Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text(_activeFolder != null ? _activeFolder.name : 'All items'),
          centerTitle: true,
          backgroundColor: Colors.blue,
          actions: <Widget>[
            _renderUnselectButton(),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _updateAll,
            ),
            IconButton(
              icon: const Icon(Icons.folder),
              onPressed: () => _navigateToFolders(context),
            ),
          ],
        ),
        body: Center(
          child: ListView.builder(
              itemCount: _items.length,
              padding: const EdgeInsets.all(1.0),
              itemBuilder: (context, position) {
                var item = _items[position];

                return Container(
                  child: Column(
                    children: <Widget>[
                      Divider(height: 0.1),
                      ListTile(
                        title: Text(
                          '${item.title}',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight:
                                item.read ? FontWeight.normal : FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          '${item.feedTitle}',
                        ),
                        onTap: () => _navigateToItem(context, item, position),
                      ),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }

  void _navigateToFolders(BuildContext context) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FoldersScreen()),
    );

    if (result is Folder) {
      setState(() {
        _activeFolder = result;
      });
      _refreshState();
    } else {
      _updateAll();
    }
  }

  void _navigateToItem(BuildContext context, Item item, int position) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ItemScreen(item)),
    );

    _db.markItemAsRead(item);

    setState(() {
      _items[position].read = true;
    });
  }

  void _updateAll() async {
    await FeedHelper().refreshAll();
    _refreshState();
  }

  void _refreshState() {
    var itemsFuture = _activeFolder == null
        ? _db.getAllItems()
        : _db.getItemsForAFolder(_activeFolder.folderID);
    itemsFuture.then((items) {
      setState(() {
        _items.clear();
        items.forEach(_items.add);
      });
    });
  }

  void _unselectFolder() {
    setState(() {
      _activeFolder = null;
    });
    _refreshState();
  }

  Widget _renderUnselectButton() {
    return _activeFolder == null
        ? Container()
        : IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _unselectFolder,
          );
  }
}
