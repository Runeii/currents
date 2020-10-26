const functions = require('firebase-functions');
const admin = require('firebase-admin');

const { fetchArtistDetails } = require('./artist');
const { createId } = require('./utils');
const { scrapeBleep, scrapeStereogum, scrapePitchfork } = require('./crawlers');

admin.initializeApp();
const db = admin.firestore();

exports.createArtist = functions.firestore.document('artists/{id}').onCreate((snap, context) => fetchArtistDetails(snap, context, db));

exports.createArtistTest = functions.https.onRequest(async (req, res) => {
	fetchArtistDetails()
});

exports.updatePosts = functions.https.onRequest(async (req, res) => {
	const submitResults = results => {
		const batch = db.batch();

		results.map(posts => {
			posts.map(post => {
				const { artists, title, type } = post;
				const ref = db.collection('posts').doc();
				
				const isAlbum = type === 'album';
				const isTrack = type === 'track';

				const workRef = db.collection(isAlbum ? 'albums' : 'tracks').doc(createId(`${artists.join('-')}-${title}`));
				batch.set(workRef, { name: title }, { merge: true });

				const artistRefs = artists.map(artist => {
					const artistRef = db.collection('artists').doc(createId(artist))
					batch.set(artistRef, { name: artist }, { merge: true });

					batch.update(artistRef, {
						[isAlbum ? 'albums' : 'tracks']: admin.firestore.FieldValue.arrayUnion(workRef)
					})
					
					batch.update(workRef, { artists: admin.firestore.FieldValue.arrayUnion(artistRef) }, { merge: true });

					return artistRef;
				});

				batch.set(ref, {
					...post,
					artists: artistRefs,
					...(isAlbum ? {
						album: workRef,
					} : {
						track: workRef,
					}),
				});
			})
		})

		batch.commit();
	}
	const scraperPromises = [scrapeBleep(), scrapeStereogum(), scrapePitchfork()];
	const results = await Promise.all(scraperPromises)
	submitResults(results);
});

//exports.updatePosts = functions.pubsub.schedule('every 5 minutes').onRun((context) => {
//	return null;
//});
