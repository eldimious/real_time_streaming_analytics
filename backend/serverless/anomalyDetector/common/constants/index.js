// generic
const PRODUCTION_ENV = 'production';

// logging
const VERBOSE_LOGGING_LVL = 'verbose';
const INFO_LOGGING_LVL = 'info';

// pagination
const DEFAULT_PAGINATION_LIMIT = 25;
const MAX_PAGINATION_LIMIT = 100;
const DEFAULT_PAGINATION_PAGE = 1;

const SHORTCODE_REGEX = '^[0-9a-zA-Z_]{4,}$';

const SHORTCODE_IN_USE_ERROR_MSG = 'Url shortcode is unique and already in use!';
const URL_ADDRESS_IN_USE_ERROR_MSG = 'Url is unique and already in use!';
const URL_ADDRESS_VALIDATION_ERROR_MSG = 'Url address must be valid';
const URL_ADDRESS_NOT_FOUND_ERROR = 'Shortcode not found in the system';

module.exports = {
  PRODUCTION_ENV,
  VERBOSE_LOGGING_LVL,
  INFO_LOGGING_LVL,
  DEFAULT_PAGINATION_LIMIT,
  MAX_PAGINATION_LIMIT,
  DEFAULT_PAGINATION_PAGE,
  SHORTCODE_REGEX,
  SHORTCODE_IN_USE_ERROR_MSG,
  URL_ADDRESS_IN_USE_ERROR_MSG,
  URL_ADDRESS_VALIDATION_ERROR_MSG,
  URL_ADDRESS_NOT_FOUND_ERROR,
};
