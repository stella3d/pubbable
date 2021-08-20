const hre = require("hardhat");
const web3 = hre.web3;

module.exports = {
    stringToBytes32: function (str) {
      var hexStr = web3.utils.asciiToHex(str);
      //console.log("string:", str, "as hex:", hexStr, "hex length:", hexStr.length);
      if(hexStr.length > 64)
        throw new Exception("maximum length of hex string is 64, but " + str + "has length " + hexStr.length);
    
      return web3.utils.padLeft(hexStr, 64);
    },

    stringArrayToBytes32: function (strArray) {
      let b32Arr = new Array(strArray.length)
      strArray.forEach((str, i) => {
        b32Arr[i] = this.stringToBytes32(str);
      });
      return b32Arr;
    }
}
