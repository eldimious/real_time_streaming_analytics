module.exports = {
  "extends": "airbnb",
  "rules": {
  	"camelcase": [2, {"properties": "never", "ignoreDestructuring": true}],
    "no-underscore-dangle": [2, { "allowAfterThis": true }],
    "class-methods-use-this": 0,
    "strict": 0,
    "max-len": 0,
    "new-cap": ["error", { "newIsCapExceptionPattern": "^errors\.." }]
  }
};
