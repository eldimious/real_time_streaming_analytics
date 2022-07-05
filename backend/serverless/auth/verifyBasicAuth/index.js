const authenticationMiddlewareFactory = require('./presentation/middleware/authentication');
const authServiceFactory = require('./domain/auth/service');

const authenticationMiddleware = authenticationMiddlewareFactory.init();
const authService = authServiceFactory.init();

const generateResponse = (isAuthorized, event) => {
  // return {
  //   isAuthorized,
  //   context,
  // };
  if (!isAuthorized) throw Error('Unauthorized');
  return {
    principalId: 'basic_auth',
    policyDocument: {
      Version: '2012-10-17',
      Statement: [
        {
          Action: 'execute-api:Invoke',
          Effect: 'Allow',
          Resource: event.methodArn,
        },
      ],
    },
  };
};

exports.handler = async function verifyBasicAuth(event, context) {
  console.log(`Handler of verifyBasicAuth EVENT: \n ${JSON.stringify(event, null, 2)}`);
  try {
    const [username, password] = authenticationMiddleware.getBasicAuthCredentialsFromHeader(event);
    await authService.verifyToken({
      username,
      password,
    })
    return generateResponse(true, event);
  } catch (error) {
    return generateResponse(false, event);
  }
};
