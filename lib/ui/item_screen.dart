import 'package:flutter/material.dart';
import 'package:feeds2imap_mobile/model/item.dart';
import 'package:feeds2imap_mobile/util/database_helper.dart';
import 'package:flutter_html_view/flutter_html_view.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemScreen extends StatefulWidget {
  final Item item;

  ItemScreen(this.item);

  @override
  State<StatefulWidget> createState() => new _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  DatabaseHelper db = new DatabaseHelper();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item.title),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.launch),
          onPressed: _launchUrl,
        ),
      ],),
      body: Container(
        margin: EdgeInsets.all(15.0),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text(widget.item.title),
              Text(widget.item.author == null ? '' : 'By ${widget.item.author}'),
              Padding(padding: new EdgeInsets.all(5.0)),
              HtmlView(
                  data: widget.item.description,
                  baseURL: " ",
                  onLaunchFail: (url) => print("launching url $url failed")),
            ],
          ),
        ),
      ),
    );
  }

  void _launchUrl() async {
    if (await canLaunch(widget.item.link)) {
      await launch(widget.item.link);
    } else {
      throw 'Could not launch ${widget.item.link}';
    }
  }
}
