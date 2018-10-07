List<String> testPoints = [
  "PG_D_G_D_50X0_D_25Y0",
  "PG_D_1_D_50X0_D_25Y0",
  "PG_D_G_D_40X0_D_25Y0",
  "PG_D_1_D_50X0_D_35Y0",
];

const Map<Block, String> BlockIdPrefixMap = {
  Block.PG: "PG",
  Block.CR: "CR",
  Block.CS: "CS",
  Block.ME: "ME",
  Block.AS: "AS",
  Block.NB: "NB",
};

const Map<Block, String> BlockNameMap = {
  Block.PG: "PG Block",
  Block.CR: "Classroom Block",
  Block.CS: "CSE Block",
  Block.ME: "Mech Block",
  Block.AS: "Account Section Block",
  Block.NB: "Platinum Jubilee Block"
};

const Map<Block, List<String>> BlockFloors = {
  Block.PG: ["7", "6", "5", "4", "3", "2", "1", "G"],
  Block.CR: ["3", "2", "1", "G"],
  Block.CS: ["3", "2", "1", "G"],
  Block.ME: ["4", "3", "2", "1", "G"],
  Block.AS: ["1", "G"],
  Block.NB: ["7", "6", "5", "4", "3", "2", "1", "G", "UB", "LB"],
};

//CS_D_1_D_33X0402_D_25Y5597 (example)

const Map<String, String> FloorNameMap = {
  "7": "7th Floor",
  "6": "6th Floor",
  "5": "5th Floor",
  "4": "4th Floor",
  "3": "3rd Floor",
  "2": "2nd Floor",
  "1": "1st Floor",
  "G": "Ground Floor",
  "UB": "Upper Basement",
  "LB": "Lower Basement"
};

const Map<Block, double> BlockHeightMap = {
  Block.PG: 42.0,
  Block.CR: 68.0,
  Block.CS: 59.0,
  Block.ME: 68.0,
  Block.AS: 42.0,
  Block.NB: 86.0,
};

const Map<Block, double> BlockAspectRatioMap = {
  Block.PG: 2.09,
  Block.CR: 0.176,
  Block.CS: 0.847,
  Block.ME: 0.471,
  Block.AS: 0.643,
  Block.NB: 0.708,
};

enum Block { PG, CS, CR, ME, AS, NB }

String meghanaDept, meghanaCategory, meghanaFloor;
Block meghanablock;
double meghanaZoom;
