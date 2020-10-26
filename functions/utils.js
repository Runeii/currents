const crypto = require('crypto');

const createId = string => {
	const sanitisedString = string.toLowerCase();
	return crypto.createHash('sha1').update(sanitisedString).digest('hex')
}

const pause = timeout => new Promise((resolve) => setTimeout(resolve, timeout));

module.exports = {
	createId,
	pause
}