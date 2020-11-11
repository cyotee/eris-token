// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

interface IWETH {
    function balanceOf( address owner ) external returns ( uint );
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}