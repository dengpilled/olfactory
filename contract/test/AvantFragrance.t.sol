// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../src/AvantFragrance.sol";

contract PFPPLUS is ERC721A {
    constructor() ERC721A("PFP+", "PFP+") {

    }

    function mint() external {
        _safeMint(msg.sender, 1);
    }
}

contract CounterTest is Test {
    using stdStorage for StdStorage;

    AvantFragrance private avant_fragrance;

    address public contractAddress;
    address public owner = address(0x6699);
    address public paul = address(0x1337);
    address public peter = address(0x7331);

    function setUp() public {
        avant_fragrance = new AvantFragrance("https://localhost:8000/",0x48a69bd2e9464f79a2a6f0c0d10e595fe4e8806a1adfb1f90575051ff4a64f6b);

        uint256 ownerslot = stdstore
            .target(address(avant_fragrance))
            .sig(avant_fragrance.owner.selector)
            .find();

        vm.store(address(avant_fragrance), bytes32(ownerslot), bytes32(abi.encode(owner)));
        vm.warp(1683304844);

        hoax(address(owner));
        avant_fragrance.flipSaleState();
        address[] memory addy = new address[](1);
        addy[0] = paul;
        hoax(address(owner));
        avant_fragrance.addWhitelist(addy);
    }

    function test_mint() public {
        hoax(address(paul));
        avant_fragrance.mint{value: 0.1 ether}(1);
        assertEq(avant_fragrance.totalMinted(), 1);
    }

    function test_tenmint() public {
        hoax(address(paul));
        avant_fragrance.mint{value: 1 ether}(10);
        assertEq(avant_fragrance.totalMinted(), 10);
    }

    function test_reservemint() public {
        hoax(address(owner));
        avant_fragrance.reserveMint(20);
        assertEq(avant_fragrance.totalMinted(), 20);
    }

    function test_freemint() public {
        hoax(address(paul));
        avant_fragrance.freeMint();
    }

    function testFail_unauthorizedfreemint() public {
        hoax(address(peter));
        avant_fragrance.freeMint();
    }

    function testFail_multifreemint() public {
        hoax(address(paul));
        avant_fragrance.freeMint();
        avant_fragrance.freeMint();
    }

    function testFail_afterBusinessHours() public {
        vm.warp(1683294001);
        hoax(address(paul));
        avant_fragrance.mint{value: 0.1 ether}(1);
        assertEq(avant_fragrance.totalMinted(), 1);
    }

    function testFail_afterBusinessHoursFreeMint() public {
        vm.warp(1683294001);
        hoax(address(paul));
        avant_fragrance.freeMint();
    }

    function testFail_noPayment() public {
        hoax(address(paul));
        avant_fragrance.mint(1);
    }

    function testFail_unauthorizedSaleState() public {
        hoax(address(paul));
        avant_fragrance.flipSaleState();
    }

    function testFail_unauthorizedReserveMint() public {
        hoax(address(paul));
        avant_fragrance.reserveMint(1);
    }

    function testFail_unauthorizedFreeMint() public {
        hoax(address(paul));
        avant_fragrance.reserveMint(1);
    }
}
