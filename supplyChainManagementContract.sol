//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SupplyChain{

    // ################ GLOBAL VARIABLES ##################

    address payable owner;
    address[] listOfManufacturers;

    // Struct for the details of the manufacturers
    struct Manufacturers {
        string name;
        string description;
        bool ethStakted;
    }
    Manufacturers public manufacturers;
    mapping (address => Manufacturers) public detailsOfManufacturers;



    // Struct for the details of the item/products
    struct ITEM{
        string name;
        uint price;
        string description;
        address owner;
        bytes32 unqProductID; 
        address manufacturer;
    }
    ITEM public products;
    mapping (uint => ITEM) public productDetails; // mapping to store product details with its id
    uint public productID = 1;

    mapping (bytes32 => address) public prevOwners; //It will store all the previous owver to a product and we can se using it's uniqProductID
    


    // ################ CONSTRUCTOR ##################

    constructor (){
        owner = payable(msg.sender);
    }
    

    // ################ MODIFIERS ##################

    modifier onlyOwner() {
        require(msg.sender == owner, "ONLY OWNER CAN ACESS THIS FUNCTION");
        _;
    }

    modifier onlyManufacturer(){
        require(detailsOfManufacturers[msg.sender].ethStakted == true, "ONLY MANUFACTURER CAN ACESS THIS FUNCTION");
        _;
    }


    // ################ FUNCTIONS ##################

    // BECOME MANUFACTURER FUNCITON
    function becomeManufacturer(string memory _name, string memory _description) public payable
    {
        require(msg.value == 10 ether,"Please Stake 10 Ether to become a manufacturer");
        listOfManufacturers.push(msg.sender);
        Manufacturers memory _manufacturer = Manufacturers(_name, _description, true); 
        detailsOfManufacturers[msg.sender] = _manufacturer;
    }
        
    // ADD PRODUCT FUNCTION
    function addProduct(string memory _name , uint _price, string memory _description)  public onlyManufacturer {
        // sha256(abi.encodePacked(block.timestamp, _name, productID));

        productDetails[productID] = ITEM(_name, _price, _description, address(0) ,  sha256(abi.encodePacked(block.timestamp, _name, productID)) , msg.sender);
        productID++;

    }

    // BUY FUNCTION
    function buyProduct(uint _id) public payable {
        require (productDetails[_id].price == msg.value, "Please pay right amount");
        address payable _manufacturer = payable(productDetails[_id].manufacturer);
        _manufacturer.transfer(msg.value); // this will transfer the value of the product to its manufacturer 
        productDetails[_id].owner = msg.sender; // this will set the new owner for the product
        prevOwners[productDetails[_id].unqProductID] = msg.sender; // this will store the owners of that product 
    }


    // Owner get the money of maintaining and veryfying all the details of the manufacturers
    function withdrawRevenue() public payable onlyOwner
    {
        uint totalRevenue = address(this).balance;
        owner.transfer(totalRevenue);
    }
}