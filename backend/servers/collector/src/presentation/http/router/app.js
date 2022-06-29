const http = require('http');
const express = require('express');
const cors = require('cors');
const compress = require('compression')();
const bodyParser = require('body-parser');
const helmet = require('helmet');
const path = require('path');
const { errorHandler } = require('@dimosbotsaris/express-error-handler');
const transactionsRouter = require('./routes/transactions');
const logging = require('../../../common/logging');

const app = express();
// The request handler must be the first middleware on the app
app.disable('x-powered-by');
app.use(helmet());
app.use(bodyParser.urlencoded({ extended: false, limit: '5mb', parameterLimit: 50000 }));
app.use(bodyParser.json({ limit: '5mb' }));
app.use(compress);
app.use(cors());

module.exports.init = (services) => {
  app.use(logging.requestLogger);
  app.use(express.static(path.join(__dirname, 'public')));
  app.get('/collector/healthCheck', ((req, res) => res.status(200).send('OK')));
  app.use('/collector/transactions', transactionsRouter.init(services));
  app.use(logging.errorLogger);
  app.use(errorHandler({ trace: true }));
  const httpServer = http.createServer(app);
  return httpServer;
};
