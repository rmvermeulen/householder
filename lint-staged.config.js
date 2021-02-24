module.exports = {
  "client/**/*": "lerna --scope client run test -- ",
  "server/**/*": [
    // run only tests related to the changed files
    "lerna --scope server run test -- -- --findRelatedTests",
    (_) =>
      // ignore files, just run all e2e tests
      "lerna --scope server run test:e2e",
  ],
};
