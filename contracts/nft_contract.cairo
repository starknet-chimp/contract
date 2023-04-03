// SPDX-License-Identifier: Apache 2.0
// Immutable Cairo Contracts v0.3.0 (token/erc721/presets/ERC721_Full.cairo)

// ERC721_Full.cairo has behaviour:
// - ERC721, TokenMetadata, ContractMetadata, AccessControl, Royalty, Bridgeable

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.uint256 import (
    uint256_add,
    uint256_mul,
    uint256_eq,
    uint256_le,
)
from starkware.cairo.common.bool import TRUE
from starkware.starknet.common.syscalls import (
    get_caller_address,
    get_contract_address,
)

from openzeppelin.introspection.erc165.library import ERC165
from openzeppelin.access.accesscontrol.library import AccessControl

from immutablex.starknet.token.erc721.library import ERC721
from immutablex.starknet.token.erc721_token_metadata.library import ERC721_Token_Metadata
from immutablex.starknet.token.erc721_contract_metadata.library import ERC721_Contract_Metadata
from immutablex.starknet.auxiliary.erc2981.unidirectional_mutable import (
    ERC2981_UniDirectional_Mutable,
)

//
// Constants
//

const MINTER_ROLE = 'MINTER_ROLE';
const BURNER_ROLE = 'BURNER_ROLE';
const DEFAULT_ADMIN_ROLE = 0x00;

//
// View (ERC165)
//

@view
func supportsInterface{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    interfaceId: felt
) -> (success: felt) {
    let (success) = ERC165.supports_interface(interfaceId);
    return (success,);
}

//
// View (ERC721)
//

@view
func name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (name: felt) {
    let (name) = ERC721.name();
    return (name,);
}

@view
func symbol{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (symbol: felt) {
    let (symbol) = ERC721.symbol();
    return (symbol,);
}

@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner: felt) -> (
    balance: Uint256
) {
    let (balance: Uint256) = ERC721.balance_of(owner);
    return (balance,);
}

@view
func ownerOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(tokenId: Uint256) -> (
    owner: felt
) {
    let (owner: felt) = ERC721.owner_of(tokenId);
    return (owner,);
}

@view
func getApproved{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenId: Uint256
) -> (approved: felt) {
    let (approved: felt) = ERC721.get_approved(tokenId);
    return (approved,);
}

@view
func isApprovedForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner: felt, operator: felt
) -> (isApproved: felt) {
    let (isApproved: felt) = ERC721.is_approved_for_all(owner, operator);
    return (isApproved,);
}

//
// View (contract metadata)
//

@view
func contractURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    contract_uri_len: felt, contract_uri: felt*
) {
    let (contract_uri_len, contract_uri) = ERC721_Contract_Metadata.contract_uri();
    return (contract_uri_len, contract_uri);
}

//
// View (token metadata)
//

@view
func tokenURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenId: Uint256
) -> (tokenURI_len: felt, tokenURI: felt*) {
    let (tokenURI_len, tokenURI) = ERC721_Token_Metadata.token_uri(tokenId);
    return (tokenURI_len, tokenURI);
}

//
// View (royalties)
//

@view
func royaltyInfo{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenId: Uint256, salePrice: Uint256
) -> (receiver: felt, royaltyAmount: Uint256) {
    let (exists) = ERC721._exists(tokenId);
    with_attr error_message("ERC721: token ID does not exist") {
        assert exists = TRUE;
    }
    let (receiver: felt, royaltyAmount: Uint256) = ERC2981_UniDirectional_Mutable.royalty_info(
        tokenId, salePrice
    );
    return (receiver, royaltyAmount);
}

// This function should not be used to calculate the royalty amount and simply exposes royalty info for display purposes.
// Use royaltyInfo to calculate royalty fee amounts for orders as per EIP2981.
@view
func getDefaultRoyalty{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}() -> (
    receiver: felt, feeBasisPoints: felt
) {
    let (receiver, fee_basis_points) = ERC2981_UniDirectional_Mutable.get_default_royalty();
    return (receiver, fee_basis_points);
}

//
// View (access control)
//

@view
func hasRole{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    role: felt, account: felt
) -> (res: felt) {
    let (res) = AccessControl.has_role(role, account);
    return (res,);
}

@view
func getRoleAdmin{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(role: felt) -> (
    role_admin: felt
) {
    let (role_admin) = AccessControl.get_role_admin(role);
    return (role_admin,);
}

@view
func getMinterRole{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    res: felt
) {
    return (MINTER_ROLE,);
}

@view
func getBurnerRole{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    res: felt
) {
    return (BURNER_ROLE,);
}

//
// Externals (ERC721)
//

@external
func approve{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    to: felt, tokenId: Uint256
) {
    ERC721.approve(to, tokenId);
    return ();
}

@external
func setApprovalForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    operator: felt, approved: felt
) {
    ERC721.set_approval_for_all(operator, approved);
    return ();
}

@external
func transferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    from_: felt, to: felt, tokenId: Uint256
) {
    ERC721.transfer_from(from_, to, tokenId);
    return ();
}

@external
func safeTransferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    from_: felt, to: felt, tokenId: Uint256, data_len: felt, data: felt*
) {
    ERC721.safe_transfer_from(from_, to, tokenId, data_len, data);
    return ();
}

//
// External (token metadata)
//

@external
func setBaseURI{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    base_token_uri_len: felt, base_token_uri: felt*
) {
    AccessControl.assert_only_role(DEFAULT_ADMIN_ROLE);
    ERC721_Token_Metadata.set_base_token_uri(base_token_uri_len, base_token_uri);
    return ();
}

@external
func setTokenURI{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    tokenId: Uint256, tokenURI_len: felt, tokenURI: felt*
) {
    AccessControl.assert_only_role(DEFAULT_ADMIN_ROLE);
    ERC721_Token_Metadata.set_token_uri(tokenId, tokenURI_len, tokenURI);
    return ();
}

@external
func resetTokenURI{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    tokenId: Uint256
) {
    AccessControl.assert_only_role(DEFAULT_ADMIN_ROLE);
    ERC721_Token_Metadata.reset_token_uri(tokenId);
    return ();
}

//
// External (contract metadata)
//

@external
func setContractURI{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    contract_uri_len: felt, contract_uri: felt*
) {
    AccessControl.assert_only_role(DEFAULT_ADMIN_ROLE);
    ERC721_Contract_Metadata.set_contract_uri(contract_uri_len, contract_uri);
    return ();
}

//
// External (royalties)
//

@external
func setDefaultRoyalty{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    receiver: felt, feeBasisPoints: felt
) {
    AccessControl.assert_only_role(DEFAULT_ADMIN_ROLE);
    ERC2981_UniDirectional_Mutable.set_default_royalty(receiver, feeBasisPoints);
    return ();
}

@external
func setTokenRoyalty{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    tokenId: Uint256, receiver: felt, feeBasisPoints: felt
) {
    AccessControl.assert_only_role(DEFAULT_ADMIN_ROLE);
    let (exists) = ERC721._exists(tokenId);
    with_attr error_message("ERC721: token ID does not exist") {
        assert exists = TRUE;
    }
    ERC2981_UniDirectional_Mutable.set_token_royalty(tokenId, receiver, feeBasisPoints);
    return ();
}

@external
func resetDefaultRoyalty{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}() {
    AccessControl.assert_only_role(DEFAULT_ADMIN_ROLE);
    ERC2981_UniDirectional_Mutable.reset_default_royalty();
    return ();
}

@external
func resetTokenRoyalty{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    tokenId: Uint256
) {
    AccessControl.assert_only_role(DEFAULT_ADMIN_ROLE);
    let (exists) = ERC721._exists(tokenId);
    with_attr error_message("ERC721: token ID does not exist") {
        assert exists = TRUE;
    }
    ERC2981_UniDirectional_Mutable.reset_token_royalty(tokenId);
    return ();
}

//
// External (bridgeable)
//

@external
func permissionedMint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    account: felt, tokenId: Uint256
) {
    alloc_locals;
    let (currentTokenIdValue) = currentTokenId.read();
    let (tokenId, _) = uint256_add(currentTokenIdValue, Uint256(low=1,high=0));
    let (maxTokenAmountValue) = maxTokenAmount.read();

    AccessControl.assert_only_role(MINTER_ROLE);
    ERC721._mint(account, tokenId);

    currentTokenId.write(tokenId);

    return ();
}

@external
func permissionedBurn{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    tokenId: Uint256
) {
    AccessControl.assert_only_role(BURNER_ROLE);
    ERC721._burn(tokenId);
    ERC2981_UniDirectional_Mutable.reset_token_royalty(tokenId);
    return ();
}

//
// External (access control)
//

@external
func grantRole{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    role: felt, account: felt
) {
    AccessControl.grant_role(role, account);
    return ();
}

@external
func revokeRole{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    role: felt, account: felt
) {
    AccessControl.revoke_role(role, account);
    return ();
}

@external
func renounceRole{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    role: felt, account: felt
) {
    AccessControl.renounce_role(role, account);
    return ();
}


// Custom functions

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    name: felt,
    symbol: felt,
    owner: felt,
    default_royalty_receiver: felt,
    default_royalty_fee_basis_points: felt,
) {
    ERC721.initializer(name, symbol);
    ERC721_Token_Metadata.initializer();
    ERC2981_UniDirectional_Mutable.initializer(
        default_royalty_receiver, default_royalty_fee_basis_points
    );
    AccessControl.initializer();
    AccessControl._grant_role(DEFAULT_ADMIN_ROLE, owner);

    maxTokenAmount.write(Uint256(low=10000,high=0));
    currentTokenId.write(Uint256(low=0,high=0));

    openOgMint.write(Uint256(low=0,high=0));
    ogMintFee.write(Uint256(low=10000000000000000,high=0));

    openWhitelistMint.write(Uint256(low=0,high=0));
    whitelistMintFee.write(Uint256(low=20000000000000000,high=0));

    openPublishMint.write(Uint256(low=0,high=0));
    publishMintFee.write(Uint256(low=20000000000000000,high=0));

    return ();
}

// General 

@storage_var
func currentTokenId() -> (res : Uint256) {
}

@storage_var
func maxTokenAmount() -> (res : Uint256) {
}

@view
func getMaxTokenAmount{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: Uint256) {
    let (maxTokenAmountValue) = maxTokenAmount.read();
    return (maxTokenAmountValue, );
}

@external
func setMaxTokenAmount{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    amount: Uint256
) {
    alloc_locals;

    AccessControl.assert_only_role(DEFAULT_ADMIN_ROLE);

    maxTokenAmount.write(amount);

    return ();
}

@contract_interface
namespace IERC20 {
    func name() -> (name: felt){
    }

    func symbol() -> (symbol: felt){
    }

    func decimals() -> (decimals: felt){
    }

    func totalSupply() -> (totalSupply: Uint256){
    }

    func balanceOf(account: felt) -> (balance: Uint256){
    }

    func allowance(owner: felt, spender: felt) -> (remaining: Uint256){
    }

    func transfer(recipient: felt, amount: Uint256) -> (success: felt){
    }

    func transferFrom(
            sender: felt,
            recipient: felt,
            amount: Uint256
        ) -> (success: felt){
        }

    func approve(spender: felt, amount: Uint256) -> (success: felt){
    }
}

const ETH_ADDRESS = 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7;
func transferEth{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    sender: felt, recipient: felt, amount: Uint256
) {
    IERC20.transferFrom(
        contract_address=ETH_ADDRESS,
        sender=sender,
        recipient=recipient, 
        amount=amount
    );
    return ();
}

@external
func approveEth{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    spender: felt, amount: Uint256
) {
    AccessControl.assert_only_role(DEFAULT_ADMIN_ROLE);
    
    IERC20.approve(
        contract_address=ETH_ADDRESS,
        spender=spender,
        amount=amount
    );
    return ();
}

//
// Og mint
//
@storage_var
func openOgMint() -> (res : Uint256) {
}

@view
func getOpenOgMint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: Uint256) {
    let (openOgMintValue) = openOgMint.read();
    return (openOgMintValue, );
}

@external
func setOpenOgMint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    active: Uint256
) {
    alloc_locals;

    AccessControl.assert_only_role(DEFAULT_ADMIN_ROLE);

    openOgMint.write(active);

    return ();
}

@storage_var
func ogMintFee() -> (res : Uint256) {
}

@view
func getOgMintFee{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: Uint256) {
    let (ogMintFeeValue) = ogMintFee.read();
    return (ogMintFeeValue, );
}

@external
func setOgMintFee{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    fee: Uint256
) {
    alloc_locals;

    AccessControl.assert_only_role(DEFAULT_ADMIN_ROLE);

    ogMintFee.write(fee);

    return ();
}

@storage_var
func ogWhitelistWallets(account : felt) -> (res : Uint256) {
}

@external
func setOgWhitelistWallets{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    account: felt, value: Uint256
) {
    alloc_locals;

    AccessControl.assert_only_role(DEFAULT_ADMIN_ROLE);

    ogWhitelistWallets.write(account, value);

    return ();
}

@external
func mintOG{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    account: felt
) {
    alloc_locals;
    let (caller: felt) = get_caller_address();
    let (contract: felt) = get_contract_address();

    // Check open mint
    let (openOgMintValue) = openOgMint.read();
    let (openOgMintCorrect) = uint256_eq(openOgMintValue, Uint256(low=1,high=0));
    with_attr error_message("Trading not enabled yet") {
        assert openOgMintCorrect = 1;
    }

    let (currentTokenIdValue) = currentTokenId.read();
    let (tokenId, _) = uint256_add(currentTokenIdValue, Uint256(low=1,high=0));
    let (maxTokenAmountValue) = maxTokenAmount.read();
    
    // Check max amount
    let (maxTokenCorrect) = uint256_le(tokenId, maxTokenAmountValue);
    with_attr error_message("Max Token Amount") {
        assert maxTokenCorrect = 1;
    }

    // Check whitelist
    let (isWhitelist) = ogWhitelistWallets.read(caller);
    let (isWhitelistCorrect) = uint256_eq(isWhitelist, Uint256(low=1,high=0));
    with_attr error_message("Whitelist invalid") {
        assert isWhitelistCorrect = 1;
    }

    // Transfer ETH
    let (fee) = ogMintFee.read();
    transferEth(caller, contract, fee);

    currentTokenId.write(tokenId);

    ogWhitelistWallets.write(caller, Uint256(low=0,high=0));

    ERC721._mint(account, tokenId);
    return ();
}

//
// Whitelist mint
//
@storage_var
func openWhitelistMint() -> (res : Uint256) {
}

@view
func getOpenWhitelistMint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: Uint256) {
    let (openWhitelistMintValue) = openWhitelistMint.read();
    return (openWhitelistMintValue, );
}

@external
func setOpenWhitelistMint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    active: Uint256
) {
    alloc_locals;

    AccessControl.assert_only_role(DEFAULT_ADMIN_ROLE);

    openWhitelistMint.write(active);

    return ();
}

@storage_var
func whitelistMintFee() -> (res : Uint256) {
}

@view
func getWhitelistMintFee{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: Uint256) {
    let (whitelistMintFeeValue) = whitelistMintFee.read();
    return (whitelistMintFeeValue, );
}

@external
func setWhitelistMintFee{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    fee: Uint256
) {
    alloc_locals;

    AccessControl.assert_only_role(DEFAULT_ADMIN_ROLE);

    whitelistMintFee.write(fee);

    return ();
}

@storage_var
func whitelistWhitelistWallets(account : felt) -> (res : Uint256) {
}

@external
func setWhitelistWhitelistWallets{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    account: felt, value: Uint256
) {
    alloc_locals;

    AccessControl.assert_only_role(DEFAULT_ADMIN_ROLE);

    whitelistWhitelistWallets.write(account, value);

    return ();
}

@external
func mintWhitelist{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    account: felt
) {
    alloc_locals;
    let (caller: felt) = get_caller_address();
    let (contract: felt) = get_contract_address();

    // Check open mint
    let (openWhitelistMintValue) = openWhitelistMint.read();
    let (openWhitelistMintCorrect) = uint256_eq(openWhitelistMintValue, Uint256(low=1,high=0));
    with_attr error_message("Trading not enabled yet") {
        assert openWhitelistMintCorrect = 1;
    }

    let (currentTokenIdValue) = currentTokenId.read();
    let (tokenId, _) = uint256_add(currentTokenIdValue, Uint256(low=1,high=0));
    let (maxTokenAmountValue) = maxTokenAmount.read();
    
    // Check max amount
    let (maxTokenCorrect) = uint256_le(tokenId, maxTokenAmountValue);
    with_attr error_message("Max Token Amount") {
        assert maxTokenCorrect = 1;
    }

    // Check whitelist
    let (isWhitelist) = whitelistWhitelistWallets.read(caller);
    let (isWhitelistCorrect) = uint256_eq(isWhitelist, Uint256(low=1,high=0));
    with_attr error_message("Whitelist invalid") {
        assert isWhitelistCorrect = 1;
    }

    // Transfer ETH
    let (fee) = whitelistMintFee.read();
    transferEth(caller, contract, fee);

    currentTokenId.write(tokenId);

    ERC721._mint(account, tokenId);
    return ();
}


//
// Publish mint
//
@storage_var
func openPublishMint() -> (res : Uint256) {
}

@view
func getOpenPublishMint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: Uint256) {
    let (openPublishMintValue) = openPublishMint.read();
    return (openPublishMintValue, );
}

@external
func setOpenPublishMint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    active: Uint256
) {
    alloc_locals;

    AccessControl.assert_only_role(DEFAULT_ADMIN_ROLE);

    openPublishMint.write(active);

    return ();
}

@storage_var
func publishMintFee() -> (res : Uint256) {
}

@view
func getPublishMintFee{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: Uint256) {
    let (publishMintFeeValue) = publishMintFee.read();
    return (publishMintFeeValue, );
}

@external
func setPublishMintFee{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    fee: Uint256
) {
    alloc_locals;

    AccessControl.assert_only_role(DEFAULT_ADMIN_ROLE);

    publishMintFee.write(fee);

    return ();
}

@external
func mintPublish{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    account: felt
) {
    alloc_locals;
    let (caller: felt) = get_caller_address();
    let (contract: felt) = get_contract_address();

    // Check open mint
    let (openPublishMintValue) = openPublishMint.read();
    let (openPublishMintCorrect) = uint256_eq(openPublishMintValue, Uint256(low=1,high=0));
    with_attr error_message("Trading not enabled yet") {
        assert openPublishMintCorrect = 1;
    }

    let (currentTokenIdValue) = currentTokenId.read();
    let (tokenId, _) = uint256_add(currentTokenIdValue, Uint256(low=1,high=0));
    let (maxTokenAmountValue) = maxTokenAmount.read();
    
    // Check max amount
    let (maxTokenCorrect) = uint256_le(tokenId, maxTokenAmountValue);
    with_attr error_message("Max Token Amount") {
        assert maxTokenCorrect = 1;
    }

    // Transfer ETH
    let (fee) = publishMintFee.read();
    transferEth(caller, contract, fee);

    currentTokenId.write(tokenId);

    ERC721._mint(account, tokenId);
    return ();
}

@external
func withdrawFees{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    devWallet: felt,
    amount: Uint256
) {
    alloc_locals;

    AccessControl.assert_only_role(DEFAULT_ADMIN_ROLE);

    let (contract: felt) = get_contract_address();

    transferEth(contract, devWallet, amount);

    return ();
}
