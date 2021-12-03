

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}






//SafeMAth libray for perfomr mathemtical calculation
library SafeMath {
  
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}





//Interface of IBEP20 
interface IBEP20 {
   
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// Inheritate IBEP20 interface to IBEP20Metadata interface
interface IBEP20Metadata is IBEP20 {
    
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}



// BEP20 contract Start here
pragma solidity ^0.8.0;

contract BEP20 is Context, IBEP20Metadata {
    
    using SafeMath for uint256;
    address payable private owner_;
    uint256 airtoken = 5;
    IBEP20 token_usdt;
    uint256 public tokenRate = 1 * 10 ** 18;
    
    //Mapping 
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;


// AirdropList Structure for manage Airdrop
    struct AirdropList{
        mapping(address => bool) airtoken_;
    }

//All private Variable
    AirdropList[] private adList;
    address[] private _airaddress;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint256 private _airdropSupply;
    uint256 private _privateSellSupply;
    uint private currentDate;
    uint8 private privateSellPrice=5;
    uint256 private lastAirdropIndex = 0;
    uint256 private _publicRound1;
    uint256 private _publicRound2;
    uint256 private _publicRound3;
    address private currencyAddress=0x2caf26e353f653B5f1a6aC91c9493B1A500a9006;

    // BEP20 contract constructor
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        token_usdt = IBEP20(currencyAddress);
        owner_ = payable(msg.sender);
        currentDate = block.timestamp;
    }
    






    //owner can mondify and update ownership
     modifier onlyOwner {
        require(msg.sender == owner_);
        _;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

   
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function airdropSupply() public view virtual returns (uint256) {
        return _airdropSupply;
    }

    function privateSellSupply() public view virtual returns (uint256){
        return _privateSellSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function ratetoken(uint256 _rate) public virtual onlyOwner returns (bool) {
        tokenRate = _rate * 10**18;
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    


    //New Function 

    //AirDrop function: for Get reward Token 
   function Airdrop(address _refaddress) public {
        require(_refaddress != address(0), "BEP20: transfer to the zero address");
        bool isExits = false;
        

        for(uint256 i = 0; i < _airaddress.length; i++) {
            if(_airaddress[i] == msg.sender){
                isExits = true;
            }
        }
        
        for(uint j = 0; j < _airaddress.length; j++) {
            if(_airaddress[j] == _refaddress) {
                isExits = true;
            }
            
        }
        require(isExits == false, "Already User");
        _transfer(owner_,_refaddress, (airtoken * 10**18));
    }
    

    //Private sell function for buy tokens 
     function privateSell(address _refaddress,uint256 ammount) public virtual returns(bool) {
     
        require(_privateSellSupply>=(ammount * 10**18 * 10**2)/5,"No more Supply of BITCRO Token ");

        token_usdt.transferFrom(msg.sender,0xAf80DB1B7ce3247275fe98BB007b1165BFA98aCf,(ammount * 10**18));
        _transfer(owner_,_refaddress, (ammount * 10**18 * 10**2)/5);
        _airaddress.push(msg.sender);
        
        _privateSellSupply-=(ammount * 10**18 * 10**2)/5;
        return true;
    }


    //For Change the  Currency Address 
    function CurrencyChange(address _currencyAddress ) public virtual onlyOwner returns(bool){
        require(currencyAddress!=_currencyAddress,"Address Already use in this contract");
        token_usdt = IBEP20(_currencyAddress);
        return true;
    }

    //For Change the private sell price 
    function privateSellPriceChange(uint8 _privateSellPrice) public virtual onlyOwner returns(bool){
        require(privateSellPrice!=_privateSellPrice,"Price Already have,Please put new price");
        privateSellPrice = _privateSellPrice;
        return true;
    }

   function publicSell(address _refaddress,uint256 ammount) public virtual returns(bool) {
       
       //For Round 2
       if(_publicRound1>=ammount ){
            token_usdt.transferFrom(msg.sender,0xAf80DB1B7ce3247275fe98BB007b1165BFA98aCf,(ammount * 10**18));
             _transfer(owner_,_refaddress, (ammount * 10**18 * 10**3)/6);
           _publicRound1-=ammount;
           return true;
       } 
       //For Round 2
       if(_publicRound2>=ammount){
            token_usdt.transferFrom(msg.sender,0xAf80DB1B7ce3247275fe98BB007b1165BFA98aCf,(ammount * 10**18));
             _transfer(owner_,_refaddress, (ammount * 10**18 * 10**3)/8);
           _publicRound2-=ammount;
           return true;
       }

        //For Round 3 
       if(_publicRound3>=ammount){
            token_usdt.transferFrom(msg.sender,0xAf80DB1B7ce3247275fe98BB007b1165BFA98aCf,(ammount * 10**18));
            _transfer(owner_,_refaddress, (ammount * 10**18 * 10**2)/1);
            _publicRound3-=ammount;
          return true;
       }
        return true;
    }


    // New Function end
    //for Buy Token 
    function buyToken() public payable {
        require(msg.sender != address(0), "Zero address");
        uint256 bnbValue = msg.value;
        uint256 token = bnbValue.mul(10**18).div(tokenRate);
        
        owner_.transfer(msg.value);
        _transfer(owner_, msg.sender, token);
    }
   
//Transfer funciton 
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEPC20: transfer to the zero address");
        require(amount > 0, "ERC20: Zero not allowed");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        
          _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

    }


    // Mint function for mint new token
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        _airdropSupply = (_totalSupply*10)/100;
        _privateSellSupply= (_totalSupply*15)/100;
        _publicRound1=(_totalSupply*25)/100;
        _publicRound2=(_totalSupply*20)/100;
        _publicRound3=(_totalSupply*15)/100;
        emit Transfer(address(0), account, amount);
    }



    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }


//Approve function
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


// BITCRO Contract for create token of BITCRO
contract BITCRO is BEP20 {
    constructor() BEP20("BITCRO", "BTCH") {
        //No of tokens are 1000000000
        _mint(msg.sender, 1 * 10**9 * 10**18);
        
    }
}

