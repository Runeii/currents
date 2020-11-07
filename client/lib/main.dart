import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:currents/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'database.dart';

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
      body: Column(
        children: [
          Expanded(
            child: PostsList(),
          ),
          Container(
            child: PlayerWidget(),
          ),
        ],
      ),
    );
  }
}

class PostsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: database.posts(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        final ordered = List.from(snapshot.data.docs);
        ordered.sort((a, b) => (b.data()['date'] != ''
                ? b.data()['date']
                : Timestamp.now())
            .compareTo(
                (a.data()['date'] != '' ? a.data()['date'] : Timestamp.now())));
        return new ListView.builder(
          shrinkWrap: true,
          itemCount: ordered.length,
          itemBuilder: (BuildContext context, int index) =>
              PostRow(ordered[index]),
        );
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
      onTap: () async {
        final data = post.data();
        final doc = await post['media'].get();
        if (!doc.exists) {
          print('Failed to find mediaRef');
        }
        final media = await doc.data();
        print(media);
        final track = new Track(
          artist: 'None',
          title: data['title'],
          src: media['url'],
          image: data['image'],
        );
        globalPlayer.play(track);
      },
      child: Container(
        child: Row(
          children: [
            Column(
              children: [
                Text(post['title']),
                FutureBuilder(
                    future: database.artist(post['artists'][0]),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      return (snapshot.data != null &&
                              snapshot.data['name'] != null)
                          ? Text(snapshot.data['name'])
                          : Text('');
                    }),
                Text(post['date'].toString()),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ],
        ),
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
