const { DataTypes } = require('sequelize');

module.exports.init = (sequelize) => {
  const AnomalyTransaction = sequelize.define('anomaly_transactions', {
    trx_id: {
      type: DataTypes.UUID,
      unique: true,
      allowNull: false,
    },
    sender_id: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    receiver_id: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    sender_iban: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    receiver_iban: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    sender_bank_id: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    receiver_bank_id: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    amount: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    transaction_date: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    created_at: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
    updated_at: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
  }, {
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    freezeTableName: true,
  });

  return AnomalyTransaction;
};
