const fs = require('fs');
const { promisify } = require('util');
const {
  MAX_DEFAULT_LIMIT,
  MIN_DEFAULT_OFFSET,
} = require('./constants');

const accessAsync = promisify(fs.access);
const mkdirAsync = promisify(fs.mkdir);
const unlinkAsync = promisify(fs.unlink);

function isNumeric(num) {
  return !isNaN(num);
}

const getDefaultLimit = (limit) => {
  if (limit == null) {
    return MAX_DEFAULT_LIMIT;
  }
  if (!isNumeric(limit)) {
    return MAX_DEFAULT_LIMIT;
  }
  if (Number(limit) > MAX_DEFAULT_LIMIT) {
    return MAX_DEFAULT_LIMIT;
  }
  return limit;
};

const getDefaultOffset = (offset) => {
  if (offset == null) {
    return MIN_DEFAULT_OFFSET;
  }
  if (!isNumeric(offset)) {
    return MIN_DEFAULT_OFFSET;
  }
  return offset;
};

async function checkDirectory(directory) {
  await accessAsync(directory);
}

async function createDirectory(directory) {
  try {
    await mkdirAsync(directory);
    console.info('directory CREATED successfully');
  } catch (error) {
    console.error('directory creation error', error);
    throw error;
  }
}

async function checkDirectoryAndCreate(directory) {
  try {
    await checkDirectory(directory);
    console.info('directory FOUND');
  } catch (error) {
    if (error && error.code === 'ENOENT') {
      console.error('directory not found, lets create it');
      await createDirectory(directory);
    }
  }
}

async function unlinkFile(filePath) {
  return unlinkAsync(filePath);
}

function makeid(length) {
  let result = '';
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  const charactersLength = characters.length;
  for (let i = 0; i < length; i++ ) {
    result += characters.charAt(Math.floor(Math.random() * charactersLength));
  }
  return result;
}

const getStreamName = (appEnv, streamName) => {
  if (appEnv === 'development' || appEnv === 'staging') {
    return `${streamName}_staging`;
  }
  return `${streamName}_production`;
};

function chuckArrayIntoSmallerArrays({
  inputArr,
  perChunk = 500,
  maxUpperLimit,
}) {
  if (perChunk > maxUpperLimit) {
    // eslint-disable-next-line no-param-reassign
    perChunk = maxUpperLimit;
  }
  const result = inputArr.reduce((resultArray, item, index) => {
    const chunkIndex = Math.floor(index / perChunk);
    if (!resultArray[chunkIndex]) {
      // eslint-disable-next-line no-param-reassign
      resultArray[chunkIndex] = [];
    }
    resultArray[chunkIndex].push(item);
    return resultArray;
  }, []);
  return result;
}

function hasStreamFailedRecords(res) {
  if (res
    && res.FailedRecordCount
    && Number(res.FailedRecordCount) > 0) {
    return true;
  }
  return false;
}

module.exports = {
  getDefaultLimit,
  getDefaultOffset,
  checkDirectoryAndCreate,
  unlinkFile,
  checkDirectory,
  createDirectory,
  makeid,
  getStreamName,
  chuckArrayIntoSmallerArrays,
  hasStreamFailedRecords,
};
