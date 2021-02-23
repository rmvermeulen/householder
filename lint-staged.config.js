module.exports = {
  "client/*": "lerna run test --scope client",
  "server/*": "lerna run test --scope server",
};
