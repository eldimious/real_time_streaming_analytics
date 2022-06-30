const express = require('express');
const asyncWrapper = require('@dimosbotsaris/express-async-handler');
const authenticationMiddleware = require('../../middleware/authentication');
const logging = require('../../../../../common/logging');

const authentication = authenticationMiddleware();

const router = express.Router({ mergeParams: true });

function init({
  collectorService,
}) {
  router.post(
    '/',
    // (...args) => isValidTrackingReferralCode(...args),
    asyncWrapper(async (req, res) => {
      logging.info('Enter handler to store transactions via stream');
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
