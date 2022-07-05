const sgMail = require('@sendgrid/mail');
const { sendgrid: sendgridConfig } = require('../../../configuration');

module.exports.init = () => {
  if (!sendgridConfig
    || !sendgridConfig.apiKey) {
    throw new Error('add sendgridConfig configuration');
  }
  sgMail.setApiKey(sendgridConfig.apiKey);

  const dispatcherRepository = {
    async sendEmail({
      from,
      to,
      subject,
      text,
    } = {}) {
      const msg = {
        to,
        from,
        subject,
        text,
      };
      return sgMail.send(msg);
    },
  };

  return Object.create(dispatcherRepository);
};
