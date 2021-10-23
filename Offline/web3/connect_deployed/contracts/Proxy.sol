pragma solidity ^0.8.0;

import "./DeepStore.sol";

contract DelagatorContract {
    bytes32 private constant _IMPL_POS =
        keccak256("dev.rapidinnovation.implementation.address.position");

    bytes32 private constant _PROXY_OWNR_POS =
        keccak256("dev.rapidinnovation.proxy.owner.address.position");

    bytes32 private constant _IMPL_OWNR_POS =
        keccak256("dev.rapidinnovation.implementation.owner.address.position");

    modifier onlyProxyOwner() {
        require(
            DeepStore.loadAddress(_PROXY_OWNR_POS) == msg.sender,
            "Forbidden: Access Denied."
        );
        _;
    }

    modifier onlyProxyOrImplOwner() {
        require(
            DeepStore.loadAddress(_PROXY_OWNR_POS) == msg.sender ||
                DeepStore.loadAddress(_IMPL_OWNR_POS) == msg.sender,
            "Forbidden: Access Denied."
        );
        _;
    }

    constructor(address dc_) {
        DeepStore.storeAddress(_IMPL_POS, dc_);
        DeepStore.storeAddress(_PROXY_OWNR_POS, msg.sender);
        DeepStore.storeAddress(_IMPL_OWNR_POS, msg.sender);
    }

    function upgradeDelegate(address newDc_) public onlyProxyOwner {
        DeepStore.storeAddress(_IMPL_POS, newDc_);
    }

    function changeProxyOwner(address newOwn_) public onlyProxyOwner {
        DeepStore.storeAddress(_PROXY_OWNR_POS, newOwn_);
    }

    function changeImplementationOwner(address newOwn_)
        public
        onlyProxyOrImplOwner
    {
        DeepStore.storeAddress(_IMPL_OWNR_POS, newOwn_);
    }

    function viewImplementation() public view returns (address dc) {
        dc = DeepStore.loadAddress(_IMPL_POS);
    }

    function viewProxyOwner() public view returns (address own) {
        own = DeepStore.loadAddress(_PROXY_OWNR_POS);
    }

    function viewImplementationOwner() public view returns (address own) {
        own = DeepStore.loadAddress(_IMPL_OWNR_POS);
    }

    // proxied calls handled here!
    fallback() external {
        _delegateToImpl(DeepStore.loadAddress(_IMPL_POS));
    }

    function _delegateToImpl(address impl_) internal {
        assembly {
            calldatacopy(0x0, 0x0, calldatasize())
            let result := delegatecall(
                gas(),
                impl_,
                0x0,
                calldatasize(),
                0x0,
                0
            )
            returndatacopy(0x0, 0x0, returndatasize())
            switch result
            case 0 {
                revert(0, 0)
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}
