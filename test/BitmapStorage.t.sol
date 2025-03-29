// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BitmapStorage.sol";

contract BitmapStorageTest is Test {
    BitmapStorage bitmap;

    function setUp() public {
        bitmap = new BitmapStorage();
    }

    function test_InitialState() public view {
        uint8[] memory values = bitmap.getAllValues();
        for (uint8 i = 0; i < 32; i++) {
            assertEq(values[i], 0, "All slots should be initialized to 0");
        }
    }

    function test_StoreAndGetValue() public {
        // Store value 5 in slot 2
        bitmap.storeValue(2, 5);
        assertEq(bitmap.getValue(2), 5, "Value in slot 2 should be 5");
    }

    function test_StoreMaximumValue() public {
        // Store maximum value (255) in slot 0
        bitmap.storeValue(0, 255);
        assertEq(bitmap.getValue(0), 255, "Value in slot 0 should be 255");
    }

    function test_StoreZeroValue() public {
        // Store zero value in slot 1
        bitmap.storeValue(1, 0);
        assertEq(bitmap.getValue(1), 0, "Value in slot 1 should be 0");
    }

    function test_StoreMultipleValues() public {
        // Store different values in different slots
        bitmap.storeValue(0, 1);
        bitmap.storeValue(1, 2);
        bitmap.storeValue(2, 3);
        
        assertEq(bitmap.getValue(0), 1, "Value in slot 0 should be 1");
        assertEq(bitmap.getValue(1), 2, "Value in slot 1 should be 2");
        assertEq(bitmap.getValue(2), 3, "Value in slot 2 should be 3");
    }

    function test_OverwriteValue() public {
        // Store initial value
        bitmap.storeValue(0, 1);
        assertEq(bitmap.getValue(0), 1, "Initial value should be 1");
        
        // Overwrite with new value
        bitmap.storeValue(0, 2);
        assertEq(bitmap.getValue(0), 2, "Value should be overwritten to 2");
    }

    function test_StoreInAllSlots() public {
        // Store values in all slots
        for (uint8 i = 0; i < 32; i++) {
            bitmap.storeValue(i, i + 1);
        }
        
        // Verify all values
        uint8[] memory values = bitmap.getAllValues();
        for (uint8 i = 0; i < 32; i++) {
            assertEq(values[i], i + 1, "Value in slot should match stored value");
        }
    }

    function test_GetAllValues() public {
        // Store some test values
        bitmap.storeValue(0, 1);
        bitmap.storeValue(1, 2);
        bitmap.storeValue(2, 3);
        
        uint8[] memory values = bitmap.getAllValues();
        
        assertEq(values[0], 1, "Value in slot 0 should be 1");
        assertEq(values[1], 2, "Value in slot 1 should be 2");
        assertEq(values[2], 3, "Value in slot 2 should be 3");
        
        // Check that other slots are 0
        for (uint8 i = 3; i < 32; i++) {
            assertEq(values[i], 0, "Empty slots should be 0");
        }
    }

    function test_RevertWhen_ValueOutOfRange() public {
        // Try to store value 256 (out of range)
        vm.expectRevert("Value must be between 0 and 255");
        bitmap.storeValue(0, 256);
    }

    function test_RevertWhen_InvalidSlot() public {
        // Try to store in slot 32 (out of range)
        vm.expectRevert("Slot must be between 0 and 31");
        bitmap.storeValue(32, 1);
    }

    function test_RevertWhen_GetValueInvalidSlot() public {
        // Try to get value from slot 32 (out of range)
        vm.expectRevert("Slot must be between 0 and 31");
        bitmap.getValue(32);
    }

    function test_StoreAndGetEdgeCases() public {
        // Test first slot
        bitmap.storeValue(0, 255);
        assertEq(bitmap.getValue(0), 255, "First slot should store max value");
        
        // Test last slot
        bitmap.storeValue(31, 255);
        assertEq(bitmap.getValue(31), 255, "Last slot should store max value");
        
        // Test middle slot
        bitmap.storeValue(15, 255);
        assertEq(bitmap.getValue(15), 255, "Middle slot should store max value");
    }
} 