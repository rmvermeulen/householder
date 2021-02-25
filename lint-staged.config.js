module.exports = {
  "client/**/.elm": "lerna --scope client run test -- ",
  "server/**/*.{js,ts,json}": [
    "lerna --scope server run test -- -- --findRelatedTests",
    "lerna --scope server run test:e2e -- -- --findRelatedTests",
  ],
};
