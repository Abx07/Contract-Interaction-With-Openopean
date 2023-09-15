// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract APIproxy {
    using SafeERC20 for IERC20;

    address constant _ETH_ADDRESS_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    receive() external payable {}

    // Compatible with ETH=>ERC20, ERC20=>ETH
    function useAPIData(
        address fromToken, // fromToken address
        address toToken, // toToken address
        uint256 fromAmount, // amount with decimals
        address OOApprove, // 0x6352a56caadc4f1e25cd6c75970fa768a3304e64
        address OOProxy, // 0x6352a56caadc4f1e25cd6c75970fa768a3304e64
        bytes memory OOApiData // data param from swap_quote API
    ) external payable {
        if (fromToken != _ETH_ADDRESS_) {
            IERC20(fromToken).transferFrom(msg.sender, address(this), fromAmount);
            _approveMax(fromToken, OOApprove, fromAmount);
        } else {
            require(fromAmount == msg.value);
        }

        (bool success, bytes memory result) = OOProxy.call{value: fromToken == _ETH_ADDRESS_ ? fromAmount : 0}(OOApiData);
        require(success, "API_SWAP_FAILED");

        uint256 returnAmount = _balanceOf(toToken, address(this));

        _transfer(toToken, payable(msg.sender), returnAmount);
    }

    function _approveMax(address token, address to, uint256 amount) internal {
        uint256 allowance = IERC20(token).allowance(address(this), to);
        if (allowance < amount) {
            if (allowance > 0) {
                IERC20(token).safeApprove(to, 0);
            }
            IERC20(token).safeApprove(to, type(uint256).max);
        }
    }

    function _transfer(address token, address payable to, uint256 amount) internal {
        if (amount > 0) {
            if (token == _ETH_ADDRESS_) {
                // Sending ETH
                require(address(this).balance >= amount, "Insufficient ETH balance");
                (bool success, ) = to.call{value: amount}("");
                require(success, "ETH transfer failed");
            } else {
                IERC20(token).safeTransfer(to, amount);
            }
        }
    }

    function _balanceOf(address token, address who) internal view returns (uint256) {
        if (token == _ETH_ADDRESS_) {
            return who.balance;
        } else {
            return IERC20(token).balanceOf(who);
        }
    }
}