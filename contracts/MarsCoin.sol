// SPDX-License-Identifier specifies the license type (MIT in this case)
// SPDX-License-Identifier: MIT
// Solidity version declaration
pragma solidity ^0.8.0;

/**
 * @title MarsCoin
 * @dev A simple ERC-20 token on PulseChain with a 1% burn on every transfer.
 *
 * By gazing at the stars, we imagine a future where humanity unites and ventures
 * forth to Mars—pioneering discoveries, fostering innovation, and inspiring
 * generations to come. This token represents that pioneering spirit on the
 * blockchain: a fun, deflationary meme coin with big dreams and a cosmic vision.
 *
 * Tokenomics:
 * - 1 trillion total supply (1,000,000,000,000)
 * - 1% burned on every transaction
 * - All tokens initially assigned to the deployer
 * - Burn address is set to 0x000000000000000000000000000000000000dEaD, which no one controls
 *
 * Embrace the journey, hold MARS, and look to the stars for a better future!
 */

// Importing OpenZeppelin contracts for ERC-20 standard functionality
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// Importing OpenZeppelin contracts for ERC-20 standard functionality
import "@openzeppelin/contracts/utils/Context.sol";
// Importing OpenZeppelin contracts for ERC-20 standard functionality
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

// Main MarsCoin contract, implementing ERC-20 token mechanics
contract MarsCoin is Context, IERC20, IERC20Metadata {
    // Token details
// Token metadata (name, symbol, decimals)
    string private _name = "MarsCoin";
    string private _symbol = "MARS";
    uint8 private _decimals = 18;

    // 1 trillion supply, with 18 decimals
// Total token supply initialized at contract deployment
    uint256 private _totalSupply = 1000000000000 * (10 ** uint256(_decimals));

    // Balances and allowances mapping
// Mappings to track token balances and allowances (for ERC-20 approvals)
    mapping(address => uint256) private _balances;
// Mappings to track token balances and allowances (for ERC-20 approvals)
    mapping(address => mapping(address => uint256)) private _allowances;

    // The burn address is a common "dead" address with no private key.
// Burn address: Tokens sent here are permanently removed from circulation
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    // Burn rate: 1% = 100 basis points if 10000 = 100%
    uint256 public burnRate = 100; // i.e., 1%

    /**
     * @dev Constructor: Assigns entire supply to the contract deployer.
     */
// Constructor assigns all tokens to the deployer
    constructor() {
        _balances[_msgSender()] = _totalSupply;
// Emitting Transfer event for transparency on the blockchain
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     */
    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     * 1% of every transfer is burned (removed from total supply and sent to the
     * burn address).
     */
// Standard ERC-20 transfer function with burn mechanism
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     */
// Standard ERC-20 transfer function with burn mechanism
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");

        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    /**
     * @dev Internal transfer function with burn logic.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from zero address");
        require(recipient != address(0), "ERC20: transfer to zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer exceeds balance");

        // Calculate burn amount (1%)
        uint256 burnAmount = (amount * burnRate) / 10000; 
        uint256 netAmount = amount - burnAmount;

        // Update balances
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += netAmount;
        _balances[BURN_ADDRESS] += burnAmount;

        // Deflate total supply
        _totalSupply -= burnAmount;

        // Emit events
// Emitting Transfer event for transparency on the blockchain
        emit Transfer(sender, recipient, netAmount);
        if (burnAmount > 0) {
// Emitting Transfer event for transparency on the blockchain
            emit Transfer(sender, BURN_ADDRESS, burnAmount);
        }
    }

    /**
     * @dev Internal function to set allowance.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from zero address");
        require(spender != address(0), "ERC20: approve to zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
