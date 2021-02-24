module.exports = {
  "client/**/*": "lerna --scope client run test -- ",
  "server/**/*": [
    "lerna --scope server run test -- -- --findRelatedTests",
    "lerna --scope server run test:e2e -- -- --onlyChanged",
  ],
};
