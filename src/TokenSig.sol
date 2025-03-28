// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "oz/token/ERC20/ERC20.sol";
import "oz/utils/cryptography/ECDSA.sol";

contract TOKENSIGNER is ERC20 {

    function mintWithSignature(address y, uint256 amount, bytes memory signature) public {
        cverify(y, amount, signature);
        _mint(y, amount);
    }

    function cverify(address x, uint256 y, bytes memory sig) internal view {
        bytes32 h = keccak256(abi.encodePacked(x, y));
        h = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", h)
        );
        if (ECDSA.recover(h, sig) != x) revert("NOMINT");
    }
}