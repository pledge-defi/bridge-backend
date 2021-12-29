pragma solidity ^0.6.12;

constract ReleaseRules {
    // uint256 mPlgrPrice public;
    // totalRelease = base * delta;
    uint256 delta public;
    uint256 base public;
    
    constructor() public {

    }

    // （用户A lock 数量/所有用户总的lock数量 ）* 当前总的释放量

}