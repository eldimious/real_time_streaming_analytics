function getBasicAuthCredentialsFromHeader(event) {
  if (!event.headers.authorization || event.headers.authorization.indexOf('Basic ') === -1) {
    throw new Error('Missing Authorization Header');
  }
  // verify auth credentials
  const base64Credentials =  event.headers.authorization.split(' ')[1];
  const credentials = Buffer.from(base64Credentials, 'base64').toString('ascii');
  return credentials.split(':');
}

module.exports.init = function authenticationMiddleware() {
  return {
    getBasicAuthCredentialsFromHeader,
  };
};
  