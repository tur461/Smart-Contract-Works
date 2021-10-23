pragma solidity ^0.8.0;


contract UProxy {
    bytes32 private constant _IMPL_ADDRESS_POSITION = keccak256("org.zeppelinos.proxy.implementation");
    bytes32 private constant _PROXY_OWNER_ADDRESS_POSITION = keccak256("dev.rapidinnovation.proxy.owner");

    event ProxyOwnershipTransferred(address previousOwner, address newOwner);
    event Upgraded(address indexed implementation);
  
    constructor() public {
        setUpgradeabilityOwner(msg.sender);
    }

    modifier onlyProxyOwner() {
        require(msg.sender == proxyOwner());
        _;
    }

    function proxyOwner() public view returns (address owner) {
        bytes32 pos = _PROXY_OWNER_ADDRESS_POSITION;
        assembly {
        owner := sload(pos)
        }
    }

    function getImplementationAddress() public view returns (address impl) {
        bytes32 pos = _IMPL_ADDRESS_POSITION;
        assembly {
          impl := sload(pos)
        }
    }
    
    function setImplementation(address newImplAddress_) internal {
        bytes32 pos = _IMPL_ADDRESS_POSITION;
        assembly {
          sstore(pos, newImplAddress_)
        }
    }
    
    function setUpgradeabilityOwner(address newProxyOwnerAddress_) internal {
        bytes32 pos = _PROXY_OWNER_ADDRESS_POSITION;
        assembly {
            sstore(pos, newProxyOwnerAddress_)
        }
    }

    function transferProxyOwnership(address newOwnerAddress_) public onlyProxyOwner {
        require(newOwnerAddress_ != address(0));
        emit ProxyOwnershipTransferred(proxyOwner(), newOwnerAddress_);
        setUpgradeabilityOwner(newOwnerAddress_);
    }
    
    function _upgradeTo(address newImplAddress_) internal {
        require(getImplementationAddress() != newImplAddress_);
        setImplementation(newImplAddress_);
        emit Upgraded(newImplAddress_);
    }

    function upgradeTo(address implAddress_) public onlyProxyOwner {
        _upgradeTo(implAddress_);
    }

    function upgradeToAndCall(address implAddress_, bytes memory data_) payable public onlyProxyOwner {
        upgradeTo(implAddress_);
        (bool b, bytes memory c) = address(this).call{value:msg.value}(data_);
        require(b);
    }
    
    fallback() external {
        address _impl = getImplementationAddress();
        require(_impl != address(0));
    
        assembly {
          let ptr := mload(0x40)
          let csize := calldatasize()
          calldatacopy(ptr, 0, csize)
          let result := delegatecall(gas(), _impl, ptr, csize, 0, 0)
          let rsize := returndatasize()
          returndatacopy(ptr, 0, rsize)
    
          switch result
          case 0 { revert(ptr, rsize) }
          default { return(ptr, rsize) }
        }
    }
    
}