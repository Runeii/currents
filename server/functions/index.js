const functions = require('firebase-functions');
const admin = require('firebase-admin');

const { fetchArtistDetails } = require('./artist');
const { extractAdditionalMeta, updatePostsDatabase } = require('./posts');

admin.initializeApp();
const db = admin.firestore();

exports.createArtist = functions.firestore.document('artists/{id}').onCreate(snap => fetchArtistDetails(snap));
exports.extractAdditionalMeta = functions.firestore.document('posts/{id}').onCreate(snap => extractAdditionalMeta(snap, db));
exports.updatePosts = functions.pubsub.schedule('every 60 minutes').onRun(() => updatePostsDatabase(db));

// TEST ENDPOINTS
exports.extractAdditionalMetaTest = functions.https.onRequest(async (req, res) => {
	const dummySnap = {
		data: () => ({
			url: 'https://www.gorillavsbear.net/sufjan-stevens-america/',
			source: 'gvb'
		}),
		ref: {
			set: payload => console.log('Would set with', payload),
			update: payload => console.log('Would update with', payload)
		}
	}
	await extractAdditionalMeta(dummySnap, db);
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