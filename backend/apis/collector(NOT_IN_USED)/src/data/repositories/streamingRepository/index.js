const AWS = require('aws-sdk');
const { promisify } = require('util');
const {
  STREAM_STATE,
} = require('../../../common/constants');
const {
  aws: {
    kinesis: kinesisConfig,
    region,
    accessKeyId,
    secretAccessKey,
  },
} = require('../../../configuration');
const logging = require('../../../common/logging');

AWS.config.credentials = new AWS.SharedIniFileCredentials({ profile: 'default' });

module.exports.init = function init() {
  console.log('kinesisConfig.region', region);
  const kinesis = new AWS.Kinesis({
    region,
  });
  const putRecord = promisify(kinesis.putRecord.bind(kinesis));
  const putRecords = promisify(kinesis.putRecords.bind(kinesis));
  const describeStream = promisify(kinesis.describeStream.bind(kinesis));
  const isAbleToWriteToStream = async ({
    streamName,
  }) => {
    try {
      const params = {
        StreamName: streamName,
      };
      const data = await describeStream(params);
      if (data.StreamDescription.StreamStatus === STREAM_STATE.ACTIVE
      || data.StreamDescription.StreamStatus === STREAM_STATE.UPDATING) {
        return true;
      }
      throw new Error(`You can not write to stream with name: ${streamName} because status is ${data.StreamDescription.StreamStatus}`);
    } catch (error) {
      logging.error(`Error in isAbleToWriteToStream for stream with name: ${streamName}`, error);
      throw error;
    }
  };

  return {
    putRecordToStream: putRecord,
    putRecordsToStream: putRecords,
    describeStream,
    isAbleToWriteToStream,
  };
};
