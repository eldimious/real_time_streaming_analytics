const express = require('express');
const asyncWrapper = require('@dimosbotsaris/express-async-handler');
const authenticationMiddleware = require('../../middleware/authentication');
const {
  accelInputValidationRules,
  validate,
  isValidTrackingReferralCode,
} = require('../../middleware/endpointValidator');
const logging = require('../../../../../common/logging');

const authentication = authenticationMiddleware();

const router = express.Router({ mergeParams: true });

function init({
  collectorService,
}) {
  router.post(
    '/',
    accelInputValidationRules(),
    validate,
    (...args) => isValidTrackingReferralCode(...args),
    asyncWrapper(async (req, res) => {
      logging.info('Enter watch handler to store transactions via stream');
      const data = {
        transactions: req.body || [],
        type: 'transactions',
      };
      const result = await collectorService.collectEvents(data);
      return res.status(200).send({
        data: result,
      });
    }),
  );

  return router;
}

module.exports.init = init;
