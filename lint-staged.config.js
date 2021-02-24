module.exports = {
  "client/**/*": "lerna --scope client run test -- ",
  "server/**/*": "lerna --scope server run test -- ",
};
