const hre = require("hardhat");
const web3 = hre.web3;

module.exports = {
    stringToBytes32: function stringToBytes32(str) {
        var hexStr = web3.utils.asciiToHex(str);
        //console.log("string:", str, "as hex:", hexStr, "hex length:", hexStr.length);
        if(hexStr.length > 64)
          throw new Exception("maximum length of hex string is 64, but " + str + "has length " + hexStr.length);
      
        return web3.utils.padLeft(hexStr, 64);
      }
}
