// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SimpleDEX is Ownable {
    IERC20 public tokenA;
    IERC20 public tokenB;
    uint256 public liquidTokenA;
    uint256 public liquidTokenB;

    // Eventos
    event LiquidityAdded(address provider, uint256 amountA, uint256 amountB);
    event LiquidityRemoved(address provider, uint256 amountA, uint256 amountB);
    event TokensSwapped(address swapper, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);

    constructor(address _tokenA, address _tokenB) Ownable(msg.sender) {
        require(_tokenA != address(0) && _tokenB != address(0));
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    function addLiquidity(uint256 _amountA, uint256 _amountB)
        external
        onlyOwner
    {
        require(_amountA != 0 && _amountB != 0);
        tokenA.transferFrom(msg.sender, address(this), _amountA);
        tokenB.transferFrom(msg.sender, address(this), _amountB);

        liquidTokenA += _amountA;
        liquidTokenB += _amountB;

        emit LiquidityAdded(msg.sender, _amountA, _amountB);
    }

    function removeLiquidity(uint256 _amountA, uint256 _amountB)
        external
        onlyOwner
    {
        require(_amountA > 0 && _amountB > 0);

        tokenA.transfer(msg.sender, _amountA);
        tokenB.transfer(msg.sender, _amountB);

        liquidTokenA -= _amountA;
        liquidTokenB -= _amountB;

        emit LiquidityRemoved(msg.sender, _amountA, _amountB);
    }

    function swapAforB(uint256 _amountA) external {
        require(_amountA > 0);
        uint256 _amountBout = getSwapAmount(liquidTokenA, liquidTokenB, _amountA);
        require(_amountBout <= liquidTokenB);
        //TRANSFERENCIAS
        tokenA.transferFrom(msg.sender, address(this), _amountA);
        tokenB.transfer(msg.sender, _amountBout);
        //MODIFICO LIQUIDEZ
        liquidTokenA += _amountA;
        liquidTokenB -= _amountBout; 

        emit TokensSwapped(msg.sender, address(tokenA), address(tokenB), _amountA, _amountBout);
    }

    function swapBforA(uint256 _amountB) external {
        require(_amountB > 0);
        uint256 _amountAout = getSwapAmount(liquidTokenB, liquidTokenA, _amountB);
        require(_amountAout <= liquidTokenA);
        //TRANSFERENCIAS
        tokenB.transferFrom(msg.sender, address(this), _amountB);
        tokenA.transfer(msg.sender, _amountAout);
        //MODIFICO LIQUIDEZ
        liquidTokenB += _amountB;
        liquidTokenA -= _amountAout; 

        emit TokensSwapped(msg.sender, address(tokenB), address(tokenA), _amountB, _amountAout);
    }

    function getPrice(address _token) external view returns (uint256) {
        require(
            _token == address(tokenA) || _token == address(tokenB),
            "Token incorrecto"
        );

        if (_token == address(tokenA)) {
            return (liquidTokenB * 1e18) / liquidTokenA;
        } else {
            return (liquidTokenA * 1e18) / liquidTokenB;
        }
    }
    //CALCULO PRODUCTO CONSTANTE
    function getSwapAmount(uint256 x,uint256 y, uint256 dx) internal pure returns (uint256) {
        uint256 newX = x + dx;
        uint256 newY =  (x * y) / newX;
        return y - newY;
    }
}
