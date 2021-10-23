pragma solidity ^0.8.0;

// deploy after implementation contract.
contract DelagatorContract {
    bytes32 private constant _IMPL_POS = keccak256("dev.rapidinnovation.delegate.address.position");

    bytes32 private constant _OWNR_POS = keccak256("dev.rapidinnovation.owner.address.position");
    
    constructor(address dc_) {
        address owner = msg.sender;
        bytes32 impPos = _IMPL_POS;
        bytes32 ownPos = _OWNR_POS;
        
        assembly {
            sstore(impPos, dc_)
            sstore(ownPos, owner)
        }
    }
    
    function changeDelegate(address newDc_) public onlyOwner {
        bytes32 impPos = _IMPL_POS;
        assembly {
            sstore(impPos, newDc_)
        }
    }
    
    function changeOwner(address newOwn_) public onlyOwner {
        bytes32 ownPos = _OWNR_POS;
        assembly {
            sstore(ownPos, newOwn_)
        }
    }
    
    function viewDelegate() public view returns (address dc) {
        bytes32 impPos = _IMPL_POS;
        assembly {
            dc := sload(impPos)
        }
    }
    
    
    function viewOwner() public view returns (address own) {
        bytes32 ownPos = _OWNR_POS;
        assembly {
            own := sload(ownPos)
        }
    }
    
    modifier onlyOwner {
        bytes32 ownPos = _OWNR_POS;
        address sender = msg.sender;
        assembly {
            let own := sload(ownPos)
            if or(gt(own, sender), lt(own, sender)) { revert(0, 0) }
        }
        _;
    }
    
    fallback() external {
        bytes32 impPos = _IMPL_POS;
        assembly {
            let dc := sload(impPos)
            calldatacopy(0x0, 0x0, calldatasize())
            let result := delegatecall(gas(), dc, 0x0, calldatasize(), 0x0, 0)
            returndatacopy(0x0, 0x0, returndatasize())
            switch result case 0 {revert(0, 0)} default {return (0, returndatasize())}
        }
    }
}