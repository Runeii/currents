const functions = require('firebase-functions');
const admin = require('firebase-admin');

const { fetchArtistDetails } = require('./artist');
const { extractMediaDetails, updatePostsDatabase } = require('./posts');

admin.initializeApp();
const db = admin.firestore();

exports.createArtist = functions.firestore.document('artists/{id}').onCreate(snap => fetchArtistDetails(snap));
exports.extractMedia = functions.firestore.document('posts/{id}').onCreate(snap => extractMediaDetails(snap, db));
exports.updatePosts = functions.pubsub.schedule('every 30 minutes').onRun(() => updatePostsDatabase(db));

// TEST ENDPOINTS
exports.extractMediaTest = functions.https.onRequest(async (req, res) => {
	const dummySnap = {
		data: () => ({ url: 'https://pitchfork.com/reviews/tracks/tyler-childers-long-violent-history/' }),
		ref: {
			set: payload => console.log('Would update with', payload)
		}
	}
	await extractMediaDetails(dummySnap, db);
	res.status(200).end();
});

exports.createArtistTest = functions.https.onRequest(async (req, res) => {
	const dummySnap = {
		data: () => ({ name: 'Radiohead' }),
		ref: {
			update: payload => console.log('Would update with', payload)
		}
	}
	await fetchArtistDetails(dummySnap);
	res.status(200).end();
});

exports.updatePostsTest = functions.https.onRequest(async (req, res) => {
	await updatePostsDatabase(db);
	res.status(200).end();
});