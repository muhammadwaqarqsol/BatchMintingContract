// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract USDTToken is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("usdt", "USDT") Ownable(msg.sender) {}
    
    /**
     * @notice Enable to mint new USDT tokens
     * @param to  to address you want to mint tokens
     * @param amount token amount you want to mint
     *
     * Can be mint by anyone to any address
     */
    function mint(address to, uint256 amount) public {
        _mint(to, amount * 10 ** 6);
    }
}