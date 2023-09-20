// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interfaces and libraries
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

interface IOpenOceanCaller {
    struct CallDescription {
        uint256 target;
        uint256 gasLimit;
        uint256 value;
        bytes data;
    }
    function makeCall(CallDescription memory desc) external;
    function makeCalls(CallDescription[] memory desc) external payable;
}

struct SwapDescription {
        IERC20 srcToken;
        IERC20 dstToken;
        address srcReceiver;
        address dstReceiver;
        uint256 amount;
        uint256 minReturnAmount;
        uint256 guaranteedAmount;
        uint256 flags;
        address referrer;
        bytes permit;
    }

// Interface for the IOpenOceanCaller contract
interface IOpenOceanCallerSwap {
    function swap(
        IOpenOceanCaller caller,
        SwapDescription calldata desc,
        IOpenOceanCaller.CallDescription[] calldata calls
    ) external payable returns (uint256 returnAmount);
}

// Integrating OpenOcean's swap function
contract MyOpenOceanIntegration {
    // Define state variables and constructor
    address public openOceanAddress; // Address of the OpenOceanExchange contract

    constructor(address _openOceanAddress) {
        openOceanAddress = _openOceanAddress;
    }

    // Function to perform a swap using OpenOcean's swap function
    function performSwap(
        IOpenOceanCaller caller,
        SwapDescription calldata desc,
        IOpenOceanCaller.CallDescription[] calldata calls
    ) external payable returns(uint256) {
        IOpenOceanCaller caller = IOpenOceanCaller(msg.sender);
        SwapDescription memory desc = SwapDescription(
            IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE),                 // Source token contract address
            IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F),                 // Destination token contract address
            msg.sender,                       // Source token receiver (user's address)
            address(this),                    // Destination token receiver (this contract's address)
            100 ether,                        // Amount of source tokens to swap
            0,                                // Minimum return amount (0 means no minimum)
            0,                                // Guaranteed amount (0 means no guarantee)
            0,                                // Flags (set to 0)
            address(0),                       // Referrer (set to 0x0)
            new bytes(0)                      // Permit (empty bytes array)
        );

        // Define call descriptions
        IOpenOceanCaller.CallDescription[] memory calls;
        // Calling the OpenOcean swap function
        // uint256 returnAmount = caller.swap{value: msg.value}(desc, calls);
        uint256 returnAmount = IOpenOceanCallerSwap(openOceanAddress).swap(caller, desc, calls);
        console.log("returnAmount");
        console.log(returnAmount);
        return 0;
    }
}
