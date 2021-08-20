const ethers = require("ethers");
const strToB32 = ethers.utils.formatBytes32String;
const parseB32Str = ethers.utils.parseBytes32String;

module.exports = {
    stringToBytes32: function (input) {
      return Array.isArray(input) ? input.map(strToB32) : strToB32(input);
    },

    bytes32ToString: function (input) {
      return Array.isArray(input) ? input.map(parseB32Str) : parseB32Str(input);
    }
}
