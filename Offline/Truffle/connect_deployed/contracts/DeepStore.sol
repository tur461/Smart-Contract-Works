pragma solidity ^0.8.0;

library DeepStore {
    function loadAddress(bytes32 slot) internal view returns (address ad) {
        assembly {
            ad := sload(slot)
        }
    }

    function storeAddress(bytes32 slot, address address_) internal {
        assembly {
            sstore(slot, address_)
        }
    }
}
