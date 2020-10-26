const fetch = require('node-fetch');
const { createApolloFetch } = require('apollo-fetch');

const fetchQL = createApolloFetch({
  uri: 'http://77.172.153.23:5000/graphql',
});

// TODO: Lowercase and alias matching
const fetchArtistDetails = async (snap) => {
	const { searchName } = snap ? snap.data() : { name: 'Radiohead' };

	let response;
	try {
		response = await fetchQL({
			query: `query getArtistByName($name: String) {
				artists(condition: {name: $name}){
					nodes {
						gid,
						id,
						name,
					}
				}
			}`,
			variables: { name: searchName }
		})
	} catch (error) {
		console.error('ERROR (handled):', error);
		return fetchArtistDetails(snap, context);
	}

	const results = response.data.artists.nodes;

	if (!results || results.length < 1) {
		console.error('Unable to find an artist on MusicBrainz!', searchName)
		return null;
	}

	const { id, gid: mbid, name } = results[0];

	const detailsObject = {
		id,
		mbid,
		name,
	}

	if (name.toLowerCase() === searchName.toLowerCase()) {
		return snap.ref.update(detailsObject);
	}

	console.error('Unable to find an artist or alias on MusicBrainz!', searchName, name)
}

module.exports = {
	fetchArtistDetails,
}