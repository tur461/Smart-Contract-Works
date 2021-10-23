const Addresses = {
    FISTContract: '0x316a1a5c7a8335Cb2DdeF9CA3E0edB0db54d80A0',
    FSContract: '0x00b07C95f509296758bf2A5b6702C55Dc4829784',
    FISTCOwner: '0xF19250A3320bE69B80daf65D057aE05Bb12F0919',
    FSCOwner: '0xF19250A3320bE69B80daf65D057aE05Bb12F0919',
};

const clArgs = {
    BALANCE: '--bl',
    ADDRESS: '--ad', // index of address
    LIST_ADDRESS: '--la',
    GAS_ESTIMATE: '--ge',
    GAS_PRICE: '--gp',
    CONTRACT_GE: '--cg', // gas estimate for contract function
    METHOD_NAME: '--mn',
    METHOD_PARAM: '--mp',
    ABI_FILE_NAME: '--abi'
};

const ABIPaths = {
    FISTContract: './abi/FurnishingToken.abi.json',
    FSContract: './abi/FISTSellingContract.abi.json',
};

module.exports = {
    clArgs,
    ABIPaths,
    Addresses,
};
