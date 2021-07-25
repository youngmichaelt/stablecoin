pragma solidity ^0.8.6;

import "./lib/SafeMathInt.sol";
import "./lib/UInt256Lib.sol";


contract Stablecoin {
    // using SafeMath for uint256;
    using SafeMathInt for int256;
    using UInt256Lib for uint256;
    
    mapping(address => uint) public balances;
    mapping(address => uint256) public shareBalances;
    
    mapping(address => mapping(address => uint)) public allowance;
    
    address[] public holders;
    mapping (address => uint) index;
    
    uint public totalSupply = 100000 * 10 ** 18;
    string public name = "stabletest";
    string public symbol = "STBL";
    uint public decimals = 18;
    
    uint public totalShares;
    uint public sharesPer;
    
    event Transfer(address indexed from, address indexed to, uint value);
    
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor(){
        balances[msg.sender] = totalSupply-1000;
        
        holders.push(msg.sender);
        index[msg.sender] = holders.length;
        totalShares = totalSupply;
        sharesPer = totalShares/totalSupply;
        shareBalances[msg.sender] = totalShares;
        
        balances[0xfC2782122A7870811bd5864Ea9C5c67F1d48e863] = 1000;
        holders.push(0xfC2782122A7870811bd5864Ea9C5c67F1d48e863);
        index[0xfC2782122A7870811bd5864Ea9C5c67F1d48e863] = holders.length;
    }
    
    function balanceOf(address owner) public view returns(uint){
        
        return balances[owner];
        
    }
    
    function transfer(address to, uint value) public returns(bool){
        
        require(balanceOf(msg.sender)>=value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
        
        uint shareValue = value * sharesPer;
        shareBalances[msg.sender] = shareBalances[msg.sender] - shareValue;
        shareBalances[to] = shareBalances[to] + shareValue;
        
        if (!inArray(to)) {
            // Append
            index[to] = holders.length;
            holders.push(to);
        }
        
        
        
        emit Transfer(msg.sender, to, value);
        return true;
        
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
        
        if (!inArray(who)) {
            // Append
            index[who] = holders.length;
            holders.push(who);
        }
        
        return true;
    }
    
    function countAddress() public view returns (uint){
        return holders.length;
    }
    
    function split() public returns (bool){
        for (uint i = 0; i < holders.length; i++) {
            balances[holders[i]] -= 100; 
        }
        return true;
    }
    
    function inArray(address who) public view returns (bool) {
        // address 0x0 is not valid if pos is 0 is not in the array
        if (index[who] > 0) {
            return true;
        }
        return false;
    }
    
    function deltaChange(uint targetPrice, uint marketPrice, uint value) public returns (int){
        
        int change = (int(marketPrice) - int(targetPrice)) * 1000;
        // change = change / int(targetPrice);
        change = (change / int(targetPrice)) *int(value); 
        
        change = change / 1000;
        
        // change *= int(value);
        return change;
        
        
        
        // return (int(x) / 1000) * -500;
    }
    
    
    
    function rebaseTest() public returns (bool){
        

        
        // uint256 change = 1;
        uint256 supplyDelta;
        uint256 targetPrice = 3;
        uint256 marketPrice = 20;
        
        //Computes total supply adjustment needed
       // uint256 change = (marketPrice - targetPrice) /  targetPrice;
       
    //   supplyDelta = deltaChange(targetPrice, marketPrice);
        int256 change;


        bool neg = false;
        
        
        
        
        //Split or merge sharesPer
        for (uint i = 0; i < holders.length; i++) {
            
            // uint supplyDelta = balances[holders[i]] * uint256(change);
            //supplyDelta = uint256((deltaChange(balances[holders[i]])).abs());
            change = deltaChange(targetPrice, marketPrice,balances[holders[i]]);
            
            if (change < 0) {
            change = change * -1;
            neg = true;
            
            

            }
            supplyDelta = uint256(change.abs());
       
            //rebase user supply
            if (neg == true){
                balances[holders[i]] = balances[holders[i]] - supplyDelta;
            } else{
                balances[holders[i]] = balances[holders[i]] + supplyDelta;
            }
            
        }
        return true;
    }
    
    function abs(int256 a)
        internal
        pure
        returns (int256)
    {
        return a < 0 ? -a : a;
    }
    function div(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
        // Prevent overflow when dividing MIN_INT256 by -1
        // require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }
    
    
    function rebase() public returns (bool){

        uint256 supplyDelta;
        uint256 targetPrice = 1;
        uint256 marketPrice = 2;
        
        //Computes total supply adjustment needed
        uint256 change = (marketPrice - targetPrice) /  targetPrice;
        supplyDelta = totalSupply * change;
        
        if (supplyDelta == 0){
            //No change needed
            return true;
        }
        
        //rebase total supply
        if (supplyDelta < 0){
            // totalSupply = totalSupply - (abs(int256(supplyDelta)));
            totalSupply = totalSupply + supplyDelta;
        } else{
            totalSupply = totalSupply + supplyDelta;
        }
        
        sharesPer = totalShares / totalSupply;
        
        
        
        //Split or merge sharesPer
        for (uint i = 0; i < holders.length; i++) {
            
            //uint shareValue = sharesPer * balances[holders[i]]
            
            supplyDelta = balances[holders[i]] * change;
            //rebase user supply
            if (supplyDelta < 0){
                // balances[holders[i]] = balances[holders[i]] - (abs(int256(supplyDelta)));
                balances[holders[i]] = balances[holders[i]] + supplyDelta;
            } else{
                balances[holders[i]] = balances[holders[i]] + supplyDelta;
            }
            
            
            
            //balances[holders[i]] -= 100; 
        }
        
        
        
        
        
        
        
        return true;
    }
    // function abs(int a) public returns (uint){
    //     return a >= 0 ? uint(a) : uint(0-a);
    // }
    
    // function sharesOf(address user)
    //     public
    //     view
    //     returns (uint256)
    // {
    //     return _shareBalances[user];
    // }
    
    
    
    
    
}