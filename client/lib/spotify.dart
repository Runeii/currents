import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

Future<void> connectToSpotifyRemote() async {
  bool loading = false;
  try {
    loading = true;
    print(DotEnv().env['SPOTIFY_CLIENT_ID'].toString());
    print(DotEnv().env['SPOTIFY_REDIRECT_URL'].toString());
    var result = await SpotifySdk.connectToSpotifyRemote(
        clientId: DotEnv().env['SPOTIFY_CLIENT_ID'].toString(),
        redirectUrl: DotEnv().env['SPOTIFY_REDIRECT_URL'].toString());
    print(
        result ? 'connect to spotify successful' : 'connect to spotify failed');
  } on PlatformException catch (e) {
    print("${e.code}, ${e.message}");
  } on MissingPluginException {
    print('not implemented');
  }
  loading = false;
}
