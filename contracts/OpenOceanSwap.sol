// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OpenOceanSwap is Ownable {
    address private openOceanContractAddress = 0xe9a9B6CE6ae2141Ed7393a61E6CaaDC481780f77;
    address private constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    event TokensSwapped(address indexed fromToken, address indexed toToken, uint256 fromAmount, uint256 toAmount);

    constructor() {
        // Setting the OpenOcean contract address.
        openOceanContractAddress = 0xe9a9B6CE6ae2141Ed7393a61E6CaaDC481780f77;
    }

    function swapTokens(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minReturnAmount,
        bytes32[] memory pools
    ) external payable {
        require(fromAmount > 0, "Invalid amount");
        
        // If the source token is ETH, ensure the sent value matches the fromAmount.
        if (fromToken == ETH_ADDRESS) {
            require(msg.value == fromAmount, "Incorrect ETH value sent");
        } else {
            // Transfer the tokens to this contract.
            IERC20(fromToken).transferFrom(msg.sender, address(this), fromAmount);
        }

        // Prepare data for OpenOcean swap function.
        bytes memory data = abi.encodeWithSignature(
            "swap(address,address,uint256,uint256,bytes32[])",
            fromToken,
            toToken,
            fromAmount,
            minReturnAmount,
            pools
        );

        // Call OpenOcean's swap function.
        (bool success, ) = openOceanContractAddress.call{value: msg.value}(data);
        require(success, "OpenOcean swap failed");

        // Check the balance of the destination token and transfer it to the user.
        uint256 toAmount = getBalance(toToken);
        require(toAmount >= minReturnAmount, "Received less than expected");
        transferToken(toToken, msg.sender, toAmount);

        emit TokensSwapped(fromToken, toToken, fromAmount, toAmount);
    }

    function getBalance(address token) public view returns (uint256) {
        if (token == ETH_ADDRESS) {
            return address(this).balance;
        } else {
            return IERC20(token).balanceOf(address(this));
        }
    }

    function transferToken(address token, address to, uint256 amount) internal {
        if (token == ETH_ADDRESS) {
            payable(to).transfer(amount);
        } else {
            IERC20(token).transfer(to, amount);
        }
    }

    // Owner can withdraw any tokens or ETH that may be stuck in this contract.
    function rescueTokens(address token, uint256 amount) external onlyOwner {
        require(token != address(0), "Invalid token address");
        require(amount > 0, "Invalid amount");

        transferToken(token, owner(), amount);
    }

    // Owner can update the OpenOcean contract address if needed.
    function setOpenOceanContract(address _openOceanContractAddress) external onlyOwner {
        require(_openOceanContractAddress != address(0), "Invalid contract address");
        openOceanContractAddress = _openOceanContractAddress;
    }

    // Fallback function to receive ETH sent directly to this contract.
    receive() external payable {
        // Accept ETH sent to this contract.
    }
}
