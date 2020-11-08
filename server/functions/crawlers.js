const scrapeIt = require("scrape-it");
const dayjs = require('dayjs');

// Stable
const scrapePitchforkAlbums = async () => {
	const posts = await scrapeIt('https://pitchfork.com/reviews/albums/', {
		posts: {
			listItem: '.review',
			data: {
				id: {
					selector: '.review__link',
					attr: 'href',
					convert: string => {
						const split = string.split('/');
						return `${split[2]}-${split[3]}`;
					}
				},
				title: ".review__title-album",
				artists: {
					listItem: ".review__title-artist li",
				},
				image: {
					selector: ".review__artwork img",
					attr: "src"
				},
				url: {
					selector: '.review__link',
					attr: 'href',
					convert: string =>  `https://pitchfork.com${string}`,
				},
				date: {
					selector: ".pub-date",
					attr: "datetime",
					convert: string => new Date(string)
				},
			}
		},
	});
	return posts.data.posts.map(post => ({...post, source: 'pitchfork', type: 'album'}));
};

const scrapePitchforkTracks = async () => {
	const posts = await scrapeIt('https://pitchfork.com/reviews/tracks/', {
		posts: {
			listItem: '.track-collection-item',
			data: {
				id: {
					selector: '.track-collection-item__track-link',
					attr: 'href',
					convert: string => {
						const split = string.split('/');
						return `${split[2]}-${split[3]}`;
					}
				},
				title: {
					selector: ".track-collection-item__title",
					convert: string => string.slice(1, -1),
				},
				artists: {
					listItem: ".artist-list li",
				},
				image: {
					selector: ".track-collection-item__img",
					attr: "src"
				},
				url: {
					selector: '.track-collection-item__track-link',
					attr: 'href',
					convert: string =>  `https://pitchfork.com${string}`,
				},
				date: {
					selector: ".pub-date",
					attr: "datetime",
					convert: string => new Date(string)
				},
			}
		},
	});

	return posts.data.posts.map(post => ({...post, source: 'pitchfork', type: 'track'}));
};

const scrapeBleep = async () => {
	const posts = await scrapeIt('https://bleep.com/stream/recommended/', {
		posts: {
			listItem: '.product.release',
			data: {
				id: {
					selector: '.product-tile',
					closest: 'li',
					attr: 'data-id',
				},
				title: ".release-title a",
				artists: {
					listItem: ".artist a",
				},
				image: {
					selector: ".product-image-box img",
					attr: "src"
				},
				url: {
					selector: '.main-product-image',
					attr: 'href',
					convert: string =>  `https://bleep.com${string}`,
				},
				date: {
					selector: ".product-release-date",
					convert: string =>  dayjs(string, 'MMMM D, YYYY').toDate(),
				},
			}
		},	
	});

	return posts.data.posts.map(post => ({...post, source: 'bleep', type: 'track'}));
};

// Experimental
const scrapeStereogum = async () => {
	console.log('Scraping Stereogum...');
	const posts = await scrapeIt('https://www.stereogum.com/music/', {
		posts: {
			listItem: '.post.row',
			data: {
				id: {
					selector: '.preview-holder > a',
					attr: 'href',
					convert: string => string.replace('https://', '').split('/')[1],
				},
				title: "h2",
				image: {
					selector: ".image-holder img",
					attr: "src"
				},
				url: {
					selector: '.image-holder a',
					attr: 'href',
				},
				date: {
					selector: ".date",
					convert: string =>  dayjs(string.replace(' - ', ' '), 'MMMM D, YYYY H:mm a').toDate(),
				},
			}
		},
	});

	return posts.data.posts.map(post => {
		const matches = post.title.match(/(?<artist>.*) – “(?<title>.*)”/);
		const { title, artist } = matches && matches.groups ? matches.groups : {};
		if (!title || !artist) {
			console.log('Failed:', post.title, artist, title);
			return null;
		}
		return {
			...post,
			title,
			artists: [artist],
			source: 'stereogum',
			type: 'track'
		}
	}).filter(post => post);
};

// @TODO: Fix dates
const scrapeGvb = async () => {
	const posts = await scrapeIt('https://www.gorillavsbear.net/', {
		posts: {
			listItem: '.main-content .blogroll-inner article',
			data: {
				id: {
					selector: '.title',
					attr: 'href',
					convert: string => string.replace('//', '').split('/')[1],
				},
				title: ".title",
				image: {
					selector: "figure a",
					attr: "data-image",
					convert: string =>  `https:${string}`,
				},
				url: {
					selector: '.title',
					attr: 'href',
					convert: string =>  `https:${string}`,
				},
			}
		},	
	});

	return posts.data.posts.map(post => {
		const matches = post.title.replace('video: ', '').replace('premiere: ', '').match(/(?<artist>.*) – (?<title>.*)/);
		const { title, artist } = matches && matches.groups ? matches.groups : {};

		if (!title || !artist) {
			return null;
		}

		return {
			...post,
			title,
			artists: [artist],
			source: 'gvb',
			type: 'track'
		}
	}).filter(post => post);
};

module.exports = {
	scrapeBleep,
	scrapeGvb,
	scrapePitchforkAlbums,
	scrapePitchforkTracks,
	scrapeStereogum,
}