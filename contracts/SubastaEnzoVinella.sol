// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SubastaEnzoVinella {
    address public owner;
    uint256 startTime;
    uint256 endTime;
    uint256 duration;
    uint256 public highestBid;
    bool isActive;
    address highestBidder;
    uint256 private startingPrice;

    //PARA mostrarOfertas()
    address[] private bidders;
    uint256[] private montosBids;
    //PARA mostrarOfertas()

    event NuevaOferta(address sender, uint256 amount);
    event SubastaFinalizada(address sender, uint256 amount);

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public bids;

    modifier IsActive() {
        if (block.timestamp >= endTime && isActive) {
            isActive = false;
            emit SubastaFinalizada(highestBidder, highestBid);
        }
        require(isActive, "La subasta no esta activa.");
        _;
    }

    modifier OnlyOwner() {
        require(
            msg.sender == owner,
            "Solo el propietario puede realizar esta accion."
        );
        _;
    }

    constructor(uint256 _duration, uint256 _startingPrice) {
        startTime = block.timestamp;
        duration = _duration;
        owner = msg.sender;
        highestBid = _startingPrice * 1 ether;//CONVIERTO WEI A ETH
        startingPrice = _startingPrice * 1 ether; //CONVIERTO WEI A ETH
        isActive = true;
        highestBidder = msg.sender;
        endTime = block.timestamp + _duration;
    }

    function bid() external payable IsActive {
            require(
                msg.value > (highestBid * 105) / 100,
                "Su oferta debe ser al menos un 5% mayor que la actual"
            );
        deposits[msg.sender] += msg.value;
        bids[msg.sender] = msg.value;
        highestBid = msg.value;
        highestBidder = msg.sender;

        //PARA mostrarOfertas()
        bidders.push(msg.sender);
        montosBids.push(msg.value);
        //PARA mostrarOfertas()

        //EXTIENDO SUBASTA
        if (endTime - block.timestamp <= 10 minutes) {
            endTime += 10 minutes;
        }

        emit NuevaOferta(msg.sender, msg.value);
    }

    function hacerReembolsoParcial() external IsActive {
        require(deposits[msg.sender] > 0, "No tiene dinero para retirar.");
        uint256 _exceso = deposits[msg.sender] - bids[msg.sender];
        require(_exceso > 0, "No tiene dinero disponible para retirar.");
        deposits[msg.sender] -= _exceso;
        payable(msg.sender).transfer(_exceso);
    }

    function mostarGanador() external view returns (address, uint256) {
        require(!isActive, "La subasta sigue activa.");
        require(highestBid != startingPrice, "Aun no hay ofertas");
        return (highestBidder, highestBid);
    }

    function mostrarOfertas()
        external
        view
        returns (address[] memory, uint256[] memory)
    {
        return (bidders, montosBids);
    }

    function devolverDepositos() external OnlyOwner {
        require(!isActive, "La subasta sigue activa.");
        for (uint256 i = 0; i < bidders.length; i++) {
            //LO HAGO PAYABLE PARA TRANSFERIRLES
            address payable _bidder = payable(bidders[i]);
            //SI NO ES EL QUE GANO, LE DEVUELVO EL DEPOSITO MENOS COMISION
            if (_bidder != highestBidder) {
                uint256 _monto = (deposits[_bidder] * 98) / 100;
                deposits[_bidder] = 0;
                _bidder.transfer(_monto);
            }
        }
    }

    function cerrarSubasta() external OnlyOwner IsActive{
            isActive = false;
            emit SubastaFinalizada(highestBidder, highestBid);
    }
}
