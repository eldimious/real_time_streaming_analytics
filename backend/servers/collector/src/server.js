const config = require('./configuration');
const streamingRepositoryContainer = require('./data/repositories/streamingRepository');
const collectorServiceContainer = require('./domain/collector/service');
const appContainer = require('./presentation/http/router/app');

const streamingRepository = streamingRepositoryContainer.init();

const collectorService = collectorServiceContainer.init({
  streamingRepository,
});

const app = appContainer.init({
  collectorService,
});

const port = process.env.PORT || config.httpPort;

app.listen(port, () => {
  console.info(`Listening on *:${port}`);
});
