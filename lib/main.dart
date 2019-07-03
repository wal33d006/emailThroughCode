import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Error logging example', storage: CounterStorage(),),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.storage}) : super(key: key);

  final CounterStorage storage;
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _controller = TextEditingController();

  void sendEmail() async {
    widget.storage.writeCounter(_controller.text);
    final path = await widget.storage._localPath;

    print(await widget.storage.readCounter());


    final Email email = Email(
      body: 'Sending email from code',
      subject: 'Sending email from code',
      recipients: ['example@example.com'],
      attachmentPath: '$path/counter.txt'
    );

    await FlutterEmailSender.send(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: TextFormField(
                  controller: _controller,
                    decoration: InputDecoration(
//                      contentPadding: EdgeInsets.all(8.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                      ),
                      fillColor: Colors.white,
                      labelText: 'Enter text',
                    ),
                  ),
                ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: sendEmail,
        icon: Icon(Icons.error_outline),
        label: Text('Send log'),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class CounterStorage {
  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<String> readCounter() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      return "";
    }
  }

  Future<File> writeCounter(String text) async {
    final file = await _localFile;
    return file.writeAsString('$text');
  }
}
