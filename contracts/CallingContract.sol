// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./APIproxy.sol"; // Import your APIproxy contract

contract MyContract {
    APIproxy public apiProxy;

    constructor(APIproxy _apiProxy) {
        apiProxy = _apiProxy;
    }

    function swapTokens(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        address OOApprove,
        address OOProxy,
        bytes calldata OOApiData
    ) external payable {
        apiProxy.useAPIData{value: msg.value}(
            fromToken,
            toToken,
            fromAmount,
            OOApprove,
            OOProxy,
            OOApiData
        );
    }
}
