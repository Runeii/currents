import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currents/player.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(CurrentsApp());
}

class CurrentsApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currents App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: IndexPage(title: 'Currents Index'),
    );
  }
}

class IndexPage extends StatefulWidget {
  IndexPage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PostsList(),
    );
  }
}

class PostsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('media')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        return new ListView.builder(
            itemCount: snapshot.data.size,
            itemBuilder: (BuildContext context, int index) =>
                PostRow(snapshot.data.docs[index]));
      },
    );
  }
}

class PostRow extends StatelessWidget {
  PostRow(this.post);
  final QueryDocumentSnapshot post;

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        globalPlayer.playMediaRef(post['media']);
      },
      child: Container(
        child: Row(children: [
          Image.network(
            post['image'],
            width: 90,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
          ),
          Column(
            children: [
              Text(post['title']),
              Text(post['title']),
            ],
          ),
        ]),
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
