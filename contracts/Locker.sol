//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./EnumerableMap.sol";

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);
}

interface IERC721 {
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transfer(address to, uint256 amount) external returns (bool);
}

contract Locker is Ownable {
    using EnumerableMap for EnumerableMap.AddressToUintMap;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _lockableERC20;
    EnumerableSet.AddressSet private _lockableERC721;

    // { "owner": { "token": amount } }
    mapping(address => EnumerableMap.AddressToUintMap) private _ftBalances;
    // { "owner": { "token": [id] } }
    mapping(address => mapping(address => EnumerableSet.UintSet)) private _nftBalances;

    function addLockableERC20(address _addr) external onlyOwner {
        if (!_lockableERC20.contains(_addr)) {
            _lockableERC20.add(_addr);
        }
    }

    function removeLockableERC20(address _addr) external onlyOwner {
        if (_lockableERC20.contains(_addr)) {
            _lockableERC20.remove(_addr);
        }
    }

    function addLockableERC721(address _addr) external onlyOwner {
        if (!_lockableERC721.contains(_addr)) {
            _lockableERC721.add(_addr);
        }
    }

    function removeLockableERC821(address _addr) external onlyOwner {
        if (_lockableERC721.contains(_addr)) {
            _lockableERC721.remove(_addr);
        }
    }

    function depositERC20(address _addr, uint256 _amount) external {
        require(_lockableERC20.contains(_addr));

        IERC20(_addr).transferFrom(_msgSender(), address(this), _amount);
        uint256 balance = 0;

        if (_ftBalances[_msgSender()].contains(_addr)) {
            balance = _ftBalances[_msgSender()].get(_addr);
        }
        _ftBalances[_msgSender()].set(_addr, balance + _amount);
    }

    function withdrawERC20(address _addr) external {
        uint256 balance = 0;
        EnumerableMap.AddressToUintMap storage balances = _ftBalances[_msgSender()];

        if (balances.contains(_addr)) {
            balance = balances.get(_addr);
        }
        balances.remove(_addr);

        IERC20(_addr).transfer(_msgSender(), balance);
    }

    function balanceERC20(address _depositor) public view returns (address[] memory, uint256[] memory) {
        EnumerableMap.AddressToUintMap storage ftBalances = _ftBalances[_depositor];

        address[] memory addresses = new address[](ftBalances.length());
        uint256[] memory balances = new uint256[](ftBalances.length());
        for (uint256 i = 0; i < ftBalances.length(); i++) {
            (address key, uint256 balance) = ftBalances.at(i);
            addresses[i] = key;
            balances[i] = balance;
        }
        return (addresses, balances);
    }

    function depositERC721(address _addr, uint256 _tokenId) external {
        require(_lockableERC721.contains(_addr));

        IERC721(_addr).transferFrom(_msgSender(), address(this), _tokenId);
        _nftBalances[_msgSender()][_addr].add(_tokenId);
    }

    function withdrawERC721(address _addr, uint256 _tokenId) external {
        EnumerableSet.UintSet storage balances = _nftBalances[_msgSender()][_addr];
        require(balances.contains(_tokenId));

        balances.remove(_tokenId);
        IERC721(_addr).transferFrom(address(this), _msgSender(), _tokenId);
    }

    function balanceERC721(address _depositor, address _addr) public view returns (uint256[] memory) {
        require(_lockableERC721.contains(_addr));

        return _nftBalances[_depositor][_addr].values();
    }
}
