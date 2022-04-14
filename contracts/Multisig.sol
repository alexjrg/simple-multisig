// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

contract Multisig {

    mapping(address => bool) private signers;
    uint256 public confirmationThreshold;

    Transaction[] public transactions;
    mapping(uint => mapping(address => bool)) public hasConfirmed;

    struct Transaction {
        uint256 txId;
        address to;
        uint256 value;
        bool isExecuted;
        uint256 confirmCount;
    }

    event Deposited(address from, uint value, uint256 balance);
    event TransactionSubmited(address indexed signer, uint256 indexed txId, address to, uint256 value);
    event ConfirmationSubmited(address indexed signer, uint256 indexed txId);
    event TxExecuted(address indexed signer, uint256 indexed txId);


    modifier onlySigners(){
        require(signers[msg.sender], "You're not an signer");
        _;
    }

    constructor(address[] memory _signers, uint256 _confirmationThreshold){
        require(_signers.length > 0, "Signers required");
        require(_confirmationThreshold > 0 && _confirmationThreshold <= _signers.length, "Confirmations threshold invalid");

        for(uint i = 0; i < _signers.length; i++){
            address signer = _signers[i];
            require(signer != address(0), "Invalid signer address");
            require(!signers[signer], "Addresses must be unique");
            signers[signer] = true;
        }

        confirmationThreshold = _confirmationThreshold;
    }

    receive() external payable{
        if (msg.value > 0){
            emit Deposited(msg.sender, msg.value, address(this).balance);
        }
    }

    fallback() external payable{
        if (msg.value > 0){
            emit Deposited(msg.sender, msg.value, address(this).balance);
        }
    }

    /// @dev For test purpose ONLY
    function deposit() public payable {
        require(msg.value > 0, "You need to send some ETH");
        signers[msg.sender] = true;
    }

    /// @dev For test purpose ONLY
    function changeConfirmationThreshold(uint256 _newThreshold) public onlySigners {
        confirmationThreshold = _newThreshold;
    }

    function getConfirmationThreshold() public view returns (uint256){
        return confirmationThreshold;
    }

    function proposeTx (address _to, uint _value) public onlySigners {
        uint256 txId = transactions.length;

        require(_to != address(0), "Invalid address");
        require(_value > 0, "Invalid value");
        require(address(this).balance > _value, "Not enough ETH in contract");

        Transaction memory transaction;
        transaction.txId = txId;
        transaction.to = _to;
        transaction.value = _value;
        transaction.isExecuted = false;
        transaction.confirmCount = 0;
        transactions.push(transaction);

        emit TransactionSubmited(msg.sender, txId, _to, _value);
    }

    function confirmTx(uint256 _txId) public onlySigners {
        require(_txId < transactions.length, "Tx does not exist");
        require(!transactions[_txId].isExecuted, "Tx already executed");
        require(!hasConfirmed[_txId][msg.sender], "You've already confirmed the tx");

        Transaction storage transaction = transactions[_txId];
        transaction.confirmCount += 1;
        hasConfirmed[_txId][msg.sender] = true;

        emit ConfirmationSubmited(msg.sender, _txId);
    }

    function execute(uint256 _txId) external onlySigners {
        require(_txId < transactions.length, "Tx does not exist");
        require(!transactions[_txId].isExecuted, "Tx already executed");

        Transaction storage transaction = transactions[_txId];

        require(transaction.confirmCount >= confirmationThreshold, "Not enough confirmations");

        transaction.isExecuted = true;

        (bool success, ) = transaction.to.call{value: transaction.value}("");
        require(success, "Transaction failed");

        emit TxExecuted(msg.sender, _txId);
    }


    function getTransactions() public view returns (Transaction[] memory){
        return transactions;
    }

    function getTransaction(uint256 _txId) public view returns (Transaction memory) { 
        return transactions[_txId];
    }
    
}