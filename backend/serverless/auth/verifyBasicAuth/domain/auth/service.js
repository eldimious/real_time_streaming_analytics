const {
  basicAuthUsername,
  basicAuthPassword,
} = require('../../configuration');

function init() {
  async function verifyToken({
    username,
    password,
  }) {
    try {
      if (username !== basicAuthUsername || password !== basicAuthPassword) {
        throw new Error('Invalid basic auth credentials');
      }
    } catch (error) {
      throw error;
    }
  }

  return {
    verifyToken,
  };
}


module.exports.init = init;