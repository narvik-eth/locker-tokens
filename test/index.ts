import { expect } from 'chai';
import { BigNumber } from 'ethers';
import { ethers } from 'hardhat';

describe('FT', () => {
  it('can be deployed', async () => {
    const contract = await ethers
      .getContractFactory('FT')
      .then((factory) => factory.deploy());
    await contract.deployed();

    const signers = await ethers.getSigners();
    const signer = await signers[0].getAddress();

    const balance = await contract.balanceOf(signer);
    expect(ethers.utils.parseUnits('100', 'ether')).to.equal(balance);
  });
});

describe('NFT', () => {
  it('can be deployed', async () => {
    const contract = await ethers
      .getContractFactory('NFT')
      .then((factory) => factory.deploy());
    await contract.deployed();
  });
  it('can be minted', async () => {
    const contract = await ethers
      .getContractFactory('NFT')
      .then((factory) => factory.deploy());
    await contract.deployed();

    await contract.mint();

    const signers = await ethers.getSigners();
    const signer = await signers[0].getAddress();

    const balance = await contract.balanceOf(signer);
    expect(1).to.equal(balance);
    const owner = await contract.ownerOf(1);
    expect(signer).to.equal(owner);
  });
});

describe('Locker', () => {
  it('can be deployed', async () => {
    const locker = await ethers
      .getContractFactory('Locker')
      .then((factory) => factory.deploy());
    await locker.deployed();
  });
  it('can be added lock', async () => {
    const locker = await ethers
      .getContractFactory('Locker')
      .then((factory) => factory.deploy());
    await locker.deployed();

    const ft = await ethers
      .getContractFactory('FT')
      .then((factory) => factory.deploy());
    await ft.deployed();
    const nft = await ethers
      .getContractFactory('NFT')
      .then((factory) => factory.deploy());
    await nft.deployed();

    await locker.addLockableERC20(ft.address);
    await locker.addLockableERC721(nft.address);
  });
  it('can be deposit and withdraw (ERC20)', async () => {
    const locker = await ethers
      .getContractFactory('Locker')
      .then((factory) => factory.deploy());
    await locker.deployed();

    const ft = await ethers
      .getContractFactory('FT')
      .then((factory) => factory.deploy());
    await ft.deployed();

    await expect(locker.depositERC20(ft.address, 100)).to.be.reverted;

    await locker.addLockableERC20(ft.address);
    await expect(locker.depositERC20(ft.address, 100)).to.be.reverted;

    const signers = await ethers.getSigners();
    const signer = await signers[0].getAddress();
    const balance = await ft.balanceOf(signer);

    await ft.approve(locker.address, 100);
    await locker.depositERC20(ft.address, 100);
    expect(balance.sub(100)).to.equal(await ft.balanceOf(signer));

    const [addresses, balances] = await locker.balanceERC20(signer);
    expect(1).to.equal(addresses.length);
    expect(ft.address).to.equal(addresses[0]);
    expect(100).to.equal(balances[0]);

    await locker.withdrawERC20(ft.address);
    expect(balance).to.equal(await ft.balanceOf(signer));
  });

  it('can be deposit and withdraw (ERC721)', async () => {
    const locker = await ethers
      .getContractFactory('Locker')
      .then((factory) => factory.deploy());
    await locker.deployed();

    const nft = await ethers
      .getContractFactory('NFT')
      .then((factory) => factory.deploy());
    await nft.deployed();

    await nft.mint();
    const signers = await ethers.getSigners();
    const signer = await signers[0].getAddress();
    const balance = await nft.balanceOf(signer);
    expect(1).to.equal(balance);

    await expect(locker.depositERC721(nft.address, 1)).to.be.reverted;

    await locker.addLockableERC721(nft.address);
    await expect(locker.depositERC721(nft.address, 1)).to.be.reverted;

    await nft.approve(locker.address, 1);
    await locker.depositERC721(nft.address, 1);
    expect(balance.sub(1)).to.equal(await nft.balanceOf(signer));
    expect([BigNumber.from(1)]).to.deep.equal(
      await locker.balanceERC721(signer, nft.address),
    );

    await locker.withdrawERC721(nft.address, 1);
    expect(balance).to.equal(await nft.balanceOf(signer));
  });
});
