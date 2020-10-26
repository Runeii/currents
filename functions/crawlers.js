const scrapeIt = require("scrape-it");
const dayjs = require('dayjs');

// Stable
const scrapePitchfork = async () => {
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
				date: {
					selector: ".pub-date",
					attr: "datetime",
					convert: string => new Date(string)
				},
			}
		},
	});
	return posts.data.posts.map(post => ({...post, type: 'album'}));
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
				date: {
					selector: ".product-release-date",
					convert: string =>  dayjs(string, 'MMMM D, YYYY').toDate(),
				},
			}
		},	
	});

	return posts.data.posts.map(post => ({...post, type: 'track'}));
};

// Experimental
const scrapeStereogum = async () => {
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
				artists: {
					listItem: ".review__title-artist li",
				},
				image: {
					selector: ".image-holder img",
					attr: "src"
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
			return null;
		}
		return {
			...post,
			title,
			artists: [artist],
			type: 'track'
		}
	}).filter(post => post);
};

module.exports = {
	scrapeBleep,
	scrapePitchfork,
	scrapeStereogum,
}