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
  Future<List<Map<String, QueryDocumentSnapshot>>> _getSupportingData(
      List posts) async {
    final mediaRefs = posts.map((post) => post.data()['media']).toList();
    final artistRefs = posts.map((post) => post.data()['artists'][0]).toList();
    final mediaSnapshots = await database.mediaByRefs(mediaRefs);
    final artistSnapshots = await database.artistsByRefs(artistRefs);
    final orderedMedia = Map.fromIterable(mediaSnapshots,
        key: (doc) => doc.id as String,
        value: (doc) => doc as QueryDocumentSnapshot);
    final orderedArtists = Map.fromIterable(artistSnapshots,
        key: (doc) => doc.id as String,
        value: (doc) => doc as QueryDocumentSnapshot);
    return [orderedMedia, orderedArtists];
  }

  postsOrderedByData(snapshot) {
    List ordered = List.from(snapshot.data.docs);
    ordered.sort((a, b) =>
        (b.data()['date'] != '' ? b.data()['date'] : Timestamp.now()).compareTo(
            (a.data()['date'] != '' ? a.data()['date'] : Timestamp.now())));
    return ordered;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: database.posts(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        final ordered = postsOrderedByData(snapshot);
        return new FutureBuilder(
            future: _getSupportingData(ordered),
            builder: (BuildContext futureBuildContext,
                AsyncSnapshot<List<Map>> supportingData) {
              if (!supportingData.hasData)
                return new Text('Loading supporting data...');
              return Container(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: ordered.length,
                  itemBuilder: (BuildContext context, int index) => PostRow(
                    artists: supportingData.data[1],
                    media: supportingData.data[0],
                    post: ordered[index],
                  ),
                ),
              );
            });
      },
    );
  }
}

class PostRow extends StatelessWidget {
  PostRow({this.post, this.artists, this.media});
  final QueryDocumentSnapshot post;
  final Map<String, QueryDocumentSnapshot> artists;
  final Map<String, QueryDocumentSnapshot> media;

  artistDetails() {
    if (post['artists'] == null || post['artists'][0] == null) {
      return {
        "name": 'Unknown Artist',
      };
    }
    DocumentReference ref = post['artists'][0];
    return artists[ref.id].data() ?? null;
  }

  mediaDetails() =>
      media[post['media'].id].data() ?? {"type": 'None', "isDummy": true};

  handleTap() async {
    final data = post.data();
    final media = this.mediaDetails();

    if (media['isDummy']) {
      print('Failed to find mediaRef');
      return;
    }

    final track = new Track(
      artist: this.artistDetails()['name'],
      title: data['title'],
      src: media['url'],
      image: data['image'],
    );

    globalPlayer.play(track);
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: handleTap,
      child: Container(
        child: Row(
          children: [
            Column(
              children: [
                Text(post['title']),
                Text(this.artistDetails()['name']),
                Text("${this.mediaDetails()['type']} via ${post['source']}"),
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
