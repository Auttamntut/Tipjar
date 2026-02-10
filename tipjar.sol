// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SmartTipJar {

    /* =========================
        STATE VARIABLES
    ========================== */
    address public owner;

    /* =========================
        CONSTRUCTOR
    ========================== */
    constructor() {
        owner = msg.sender;
    }

    /* =========================
        MODIFIER
    ========================== */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    /* =========================
        STEP 1 : THE VAULT
    ========================== */

    // Accept tips (ETH)
    function addTips() public payable {}

    // View total tips in contract
    function viewTips() public view returns (uint256) {
        return address(this).balance;
    }

    /* =========================
        STEP 2 : THE STAFF
    ========================== */

    struct Waitress {
        address payable walletAddress;
        string name;
        uint256 percent; // percentage share
    }

    Waitress[] public waitress;

    function viewWaitress() public view returns (Waitress[] memory) {
        return waitress;
    }

    /* =========================
        STEP 3 : THE MANAGER
    ========================== */

    function addWaitress(
        address payable _walletAddress,
        string memory _name,
        uint256 _percent
    ) public onlyOwner {

        require(_percent > 0, "Percent must be greater than 0");

        bool waitressExist = false;

        for (uint i = 0; i < waitress.length; i++) {
            if (waitress[i].walletAddress == _walletAddress) {
                waitressExist = true;
                break;
            }
        }

        if (!waitressExist) {
            waitress.push(Waitress(_walletAddress, _name, _percent));
        }
    }

    /* =========================
        STEP 4 : REMOVE STAFF
    ========================== */

    function removeWaitress(address _walletAddress) public onlyOwner {

        for (uint i = 0; i < waitress.length; i++) {
            if (waitress[i].walletAddress == _walletAddress) {

                // Shift array left
                for (uint j = i; j < waitress.length - 1; j++) {
                    waitress[j] = waitress[j + 1];
                }

                waitress.pop();
                break;
            }
        }
    }

    /* =========================
        INTERNAL TRANSFER FUNCTION
    ========================== */

    function _transferFunds(
        address payable _to,
        uint256 _amount
    ) internal {
        require(_amount > 0, "Amount must be greater than 0");
        _to.transfer(_amount);
    }

    /* =========================
        STEP 5 : PAYDAY
    ========================== */

    function distributeBalance() public onlyOwner {

        require(address(this).balance > 0, "No money to distribute");
        require(waitress.length > 0, "No staff found");

        uint256 totalAmount = address(this).balance;

        for (uint i = 0; i < waitress.length; i++) {

            uint256 distributeAmount =
                (totalAmount * waitress[i].percent) / 100;

            _transferFunds(waitress[i].walletAddress, distributeAmount);
        }
    }
}
