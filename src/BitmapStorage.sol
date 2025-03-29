// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract BitmapStorage {
    uint256 private bitmap;

    /**
     * @dev Store a byte value in a specific slot (0-31)
     * @param slot The slot to store the value in (0-31)
     * @param value The byte value to store (0-255)
     */
    function storeValue(uint8 slot, uint256 value) public {
        require(slot < 32, "Slot must be between 0 and 31");
        require(value <= 255, "Value must be between 0 and 255");
        
        // Clear the slot first (set to 0)
        bitmap &= ~(0xFF << (slot * 8));
        // Set the new value
        bitmap |= (value << (slot * 8));
    }

    /**
     * @dev Get all values stored in the bitmap
     * @return An array of 32 bytes representing all slots
     */
    function getAllValues() public view returns (uint8[] memory) {
        uint8[] memory values = new uint8[](32);
        for (uint8 i = 0; i < 32; i++) {
            values[i] = uint8((bitmap >> (i * 8)) & 0xFF);
        }
        return values;
    }

    /**
     * @dev Get the value stored in a specific slot
     * @param slot The slot to read (0-31)
     * @return The byte value stored in the slot
     */
    function getValue(uint8 slot) public view returns (uint8) {
        require(slot < 32, "Slot must be between 0 and 31");
        return uint8((bitmap >> (slot * 8)) & 0xFF);
    }
}