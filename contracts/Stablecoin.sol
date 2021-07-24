pragma solidity ^0.8.6;

contract Stablecoin {
    
    mapping(address => uint) public balances;
    
    mapping(address => mapping(address => uint)) public allowance;
    
    address[] public holders;
    
    uint public totalSupply = 100000 * 10 ** 18;
    string public name = "stabletest";
    string public symbol = "STBL";
    uint public decimals = 18;
    
    event Transfer(address indexed from, address indexed to, uint value);
    
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor(){
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address owner) public view returns(uint){
        
        return balances[owner];
        
    }
    
    function transfer(address to, uint value) public returns(bool){
        
        require(balanceOf(msg.sender)>=value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
        
        // if (!inArray(to)){
        //     balances[to] = holders.length;
        //     holders.push(to);
        // }
        
        holders.push(to);
        
        emit Transfer(msg.sender, to, value);
        return true;
        
    }
    function inArray(address who) public view returns (bool) {
        // address 0x0 is not valid if pos is 0 is not in the array
        if (balances[who] > 0) {
            return true;
        }
        return false;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool){
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }
    
    function approve(address spender, uint value) public returns(bool){
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function allAddress() public returns (address[] memory){
        return holders;
    }
    
    function addAddress(address who) public returns (bool){
        holders.push(who);
        return true;
    }
    
    function addressNum() public view returns (uint){
        return holders.length;
    }
    
    function split() public returns (bool){
        for (uint i = 0; i < holders.length; i++) {
            balances[holders[i]] -= 100; 
        }
        return true;
    }
    
    
    
}