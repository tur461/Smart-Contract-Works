pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "./DeepStore.sol";

contract DelegatedERC20 is ERC20 {
    bytes32 private constant _IMPL_OWNR_POS =
        keccak256("dev.rapidinnovation.implementation.owner.address.position");

    bool initialized;
    string private _Name;
    string private _Symbol;

    modifier onlyOwner() {
        require(
            DeepStore.loadAddress(_IMPL_OWNR_POS) == msg.sender,
            "Forbidden: Access Denied."
        );
        _;
    }

    constructor() ERC20("Default Name ERC20", "DEFAULT_SYMBOL") {}

    function initialize(
        string memory name_,
        string memory symbol_,
        uint256 initialSuppy_
    ) public onlyOwner {
        require(!initialized, "Already initialized.");

        initialized = true;

        _Name = name_;
        _Symbol = symbol_;

        _mint(DeepStore.loadAddress(_IMPL_OWNR_POS), initialSuppy_);
    }

    function decimals() public view virtual override returns (uint8 d) {
        d = 6;
    }

    function name() public view virtual override returns (string memory n) {
        n = _Name;
    }

    function symbol() public view virtual override returns (string memory s) {
        s = _Symbol;
    }

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    function changeOwner(address newOwn_) public onlyOwner {
        DeepStore.storeAddress(_IMPL_OWNR_POS, newOwn_);
    }

    function viewOwner() public view returns (address own) {
        own = DeepStore.loadAddress(_IMPL_OWNR_POS);
    }

    function isInitialized() public view returns (bool i) {
        i = initialized;
    }
}
