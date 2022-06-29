const errors = require('../../../../common/errors');
const {
  apiKey,
} = require('../../../../configuration');

module.exports = function authenticateEndpoint() {
  return {
    checkApiKey(req, res, next) {
      try {
        if (!req.headers
          || !req.headers['api-key']
          || req.headers['api-key'] !== apiKey) {
          throw new errors.Unauthorized('API key not provided. Make sure you have a "api-key" as header.', 'INVALID_API_KEY');
        }
        return next();
      } catch (error) {
        return next(error);
      }
    },
  };
};
