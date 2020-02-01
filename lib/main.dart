import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase real time db sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Chat Sample'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _mainReference = FirebaseDatabase.instance.reference().child('db-top');
  final _textEditController = TextEditingController();
  final _nameEditingController = TextEditingController(text: 'noName');

  List<ChatEntry> entries = List<ChatEntry>();

  @override
  void initState() {
    super.initState();
    _mainReference.onChildAdded.listen(_onEntryAdded);
    _mainReference.onChildRemoved.listen(_onEntryDelete);
  }

  void _onEntryAdded(Event event) {
    setState(() {
      entries.add(ChatEntry.fromSnapShot(event.snapshot));
    });
  }

  void _onEntryDelete(Event event){
    setState(() {
      print('entries remove ${event.snapshot.key}');
      entries.removeWhere((entry) => entry.key == event.snapshot.key);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (BuildContext context, int index) {
                return _buildRow(index);
              },
              itemCount: entries.length,
            ),
          ),
          Divider(height: 4.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: TextField(
                decoration: InputDecoration(labelText: '名前'),
                controller: _nameEditingController,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildInputArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(int index) {
    return Card(
      child: ListTile(
        title: Text(entries[index].title),
        subtitle: Text(entries[index].content),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            print('${entries[index].key} delete');
            _mainReference.child(entries[index].key).remove();
            setState(() {
            });
          },
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 16.0,
        ),
        Expanded(
          child: TextField(
            controller: _textEditController,
          ),
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: () {
            _mainReference.push().set(
                ChatEntry(_nameEditingController.text, _textEditController.text)
                    .toJson());
            _textEditController.clear();

            FocusScope.of(context).requestFocus(FocusNode());
          },
        ),
      ],
    );
  }
}

class ChatEntry {
  String key;
  String title;
  String content;

  ChatEntry(this.title, this.content);

  ChatEntry.fromSnapShot(DataSnapshot snapshot)
      : key = snapshot.key,
        title = snapshot.value['title'],
        content = snapshot.value['content'];

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
    };
  }
}
