const BlueBird = require('bluebird');
const logging = require('../../common/logging');
const {
  makeid,
  hasStreamFailedRecords,
  chuckArrayIntoSmallerArrays,
} = require('../../common/utils');

function init({
  streamingRepository,
}) {
  const RECORDS_PER_BATCH = 50;
  const MAX_LIMIT_PUT_RECORDS_ARRAY = 500;
  const CONCURRENCY_LIMIT = 1;

  function generateTransactionEvent(transaction) {
    return JSON.stringify({
      ...transaction,
    });
  }

  async function handleTransactionsStream(transactions) {
    await streamingRepository.isAbleToWriteToStream({
      streamName: 'TRANSACTIONS_STREAM',
    });
    const trasactionsIntoArrays = chuckArrayIntoSmallerArrays({
      inputArr: transactions,
      perChunk: RECORDS_PER_BATCH,
      maxUpperLimit: MAX_LIMIT_PUT_RECORDS_ARRAY,
    });
    return BlueBird.map(trasactionsIntoArrays, async (arr) => {
      const records = [];
      // eslint-disable-next-line no-plusplus
      for (let i = 0; i < arr.length; i++) {
        const record = {
          // eslint-disable-next-line prefer-template
          Data: generateTransactionEvent(arr[i]) + '\n',
          PartitionKey: makeid(10), // uuidv4(),
        };
        records.push(record);
      }
      const res = await streamingRepository.putRecordsToStream({
        Records: records,
        StreamName: 'TRANSACTIONS_STREAM',
      }).catch((error) => {
        logging.error('Error when put transactions records to kinesis', error);
        return undefined;
      });
      if (hasStreamFailedRecords(res)) {
        logging.log('hasStreamFailedRecords accel', res.FailedRecordCount);
        // const msg = `FailedRecordCount for transactions is: ${res.FailedRecordCount}`;
      }
      // console.log('accel res', res);
      return res;
    }, { concurrency: CONCURRENCY_LIMIT });
  }

  async function collectEvents(data) {
    switch (data.type) {
      case 'transactions': {
        const results = await handleTransactionsStream(data.transaction)
          // .then((res) => {
          //   console.log(`Res when put transactions to kinesis`, res);
          // })
          .catch((error) => {
            logging.error('Generic error when put transactions records to kinesis', error);
            return undefined;
          });
        return results;
      }
      default:
        throw new Error('device not supported');
    }
  }

  return {
    collectEvents,
  };
}

module.exports.init = init;
