const crypto = require('crypto');
const fetch = require('node-fetch');

const createId = string => {
	const sanitisedString = string.toLowerCase();
	return crypto.createHash('sha1').update(sanitisedString).digest('hex')
}

const getIdFromBandcampUrl = (url) => {
	const { pathname } = new URL(url);
	const split = pathname.split('/')
	const match = split.find(string => string.startsWith('track=') || string.startsWith('album=')).split('=')
	return match[1]
}

const getIdFromSpotifyUrl = (url) => {
	const { pathname } = new URL(url);
	const split = pathname.split('/')
	return split[split.length - 1]
}

const getIdFromYoutubeUrl = (url) => {
	const parsedUrl = url.split(/(vi\/|v=|\/v\/|youtu\.be\/|\/embed\/)/);
	return (parsedUrl[2] !== undefined) ? parsedUrl[2].split(/[^0-9a-z_-]/i)[0] : parsedUrl[0];
}

const fetchQl = async ({ query, variables }) => {
	try {
		const response = await fetch('http://77.172.153.23:5000/graphql', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
				'Accept': 'application/json',
			},
			body: JSON.stringify({
				query,
				variables,
			})
		})
		return await response.json();
	} catch (error) {
		console.error('ERROR (handled):', error);
		throw error;
	}
}

const pause = timeout => new Promise((resolve) => setTimeout(resolve, timeout));

module.exports = {
	createId,
	fetchQl,
	getIdFromBandcampUrl,
	getIdFromSpotifyUrl,
	getIdFromYoutubeUrl,
	pause
}