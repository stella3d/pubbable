import { Bytes, BytesLike, ethers } from "ethers";
const strToB32 = ethers.utils.formatBytes32String;
const parseB32Str = ethers.utils.parseBytes32String;

export function stringToBytes32(input: string): string;
export function stringToBytes32(input: string[]): string[];
export function stringToBytes32 (input: string | string[]): string | string[] {
  return Array.isArray(input) ? input.map(strToB32) : strToB32(input);
}

export function bytes32ToString (input: string | Bytes | BytesLike[])
: string | string[] {
  return Array.isArray(input) ? input.map(parseB32Str) : parseB32Str(input);
}

export function printArgs(args: any[]): void {
  args.forEach(e => {
      console.log(e._isBigNumber ? e.toNumber() : e);
  });
}