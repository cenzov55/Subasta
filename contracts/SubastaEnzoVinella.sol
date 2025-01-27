// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SubastaEnzoVinella {
    address public owner;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public duration;
    uint256 public highestBid;
    bool isActive;
    address highestBidder;
    uint256 private startingPrice;

    //PARA mostrarOfertas()
    address[] private bidders;
    uint256[] private montosBids;
    //PARA mostrarOfertas()

    event NuevaOferta(address sender, uint256 amount);
    event SubastaIniciada(address sender, uint256 amount);
    event SubastaFinalizada(address sender, uint256 amount);

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public bids;

    modifier IsActive() {
        finalizarSubastaInterna();
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
        owner = msg.sender;
        duration = _duration;
        highestBid = _startingPrice;
        startingPrice = _startingPrice;
    }

    function iniciarSubasta() external OnlyOwner {
        require(!isActive, "La subasta ya esta activa.");
        startTime = block.timestamp;
        isActive = true;
        endTime = block.timestamp + duration;
        emit SubastaIniciada(owner, highestBid);
    }

    function bid() external payable IsActive {
        require(
            msg.value > highestBid + (highestBid * 5) / 100,
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
            endTime = block.timestamp + 10 minutes;
        }

        emit NuevaOferta(msg.sender, msg.value);
    }

    function hacerReembolsoParcial() external IsActive {
        require(deposits[msg.sender] > 0, "No tiene dinero para retirar.");
        uint256 _exceso = deposits[msg.sender] - bids[msg.sender];
        require(_exceso > 0, "No tiene dinero disponible para retirar.");
        deposits[msg.sender] = 0;
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
        finalizarSubastaInterna(); 
        require(!isActive, "La subasta sigue activa.");
        for (uint256 i = 0; i < bidders.length; i++) {
             //LO HAGO PAYABLE PARA TRANSFERIRLES
            address payable _bidder = payable(bidders[i]);
            //SI NO ES EL QUE GANO, LE DEVUELVO EL DEPOSITO MENOS COMISION
            if (_bidder != highestBidder) {
                uint256 _monto = (deposits[_bidder] * 98) / 100;
                //SI NO HAY MONTO PARA DEVOLVER NO LE TRANSFIERO! IMPORTANTE
                if (_monto > 0) {
                    deposits[_bidder] = 0;
                    _bidder.transfer(_monto);
                }
            }
        }
         //EL RESTO TODO PARA EL OWNER
        payable(owner).transfer(address(this).balance);
    }

    function finalizarSubasta() external OnlyOwner IsActive {}   //LOGICA en IsActive NO FUNCIONA??

    // Función interna para finalizar la subasta si el tiempo ha pasado
    function finalizarSubastaInterna() internal {
        if (block.timestamp >= endTime && isActive) {
            isActive = false;
            emit SubastaFinalizada(highestBidder, highestBid);
        }
    }
}
