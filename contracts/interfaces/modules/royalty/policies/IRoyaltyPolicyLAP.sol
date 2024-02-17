// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { IRoyaltyPolicy } from "../../../../interfaces/modules/royalty/policies/IRoyaltyPolicy.sol";

/// @title RoyaltyPolicy interface
interface IRoyaltyPolicyLAP is IRoyaltyPolicy {
    struct InitParams {
        address[] targetAncestors; // the expected ancestors of an ipId
        uint32[] targetRoyaltyAmount; // the expected royalties of each of the ancestors for an ipId
        address[] parentAncestors1; // all the ancestors of the first parent
        address[] parentAncestors2; // all the ancestors of the second parent
        uint32[] parentAncestorsRoyalties1; // the royalties of each of the ancestors for the first parent
        uint32[] parentAncestorsRoyalties2; // the royalties of each of the ancestors for the second parent
    }

    /// @notice Event emitted when a policy is initialized
    /// @param ipId The ID of the IP asset that the policy is being initialized for
    /// @param splitClone The split clone address
    /// @param ancestorsVault The ancestors vault address
    /// @param royaltyStack The royalty stack
    /// @param targetAncestors The ip ancestors array
    /// @param targetRoyaltyAmount The ip royalty amount array
    event PolicyInitialized(
        address ipId,
        address splitClone,
        address ancestorsVault,
        uint32 royaltyStack,
        address[] targetAncestors,
        uint32[] targetRoyaltyAmount
    );

    /// @notice Returns the royalty data for a given IP asset
    /// @param ipId The ID of the IP asset
    /// @return isUnlinkable Indicates if the ipId is unlinkable
    /// @return splitClone The split clone address
    /// @return ancestorsVault The ancestors vault address
    /// @return royaltyStack The royalty stack
    /// @return ancestorsHash The unique ancestors hash
    function royaltyData(
        address ipId
    )
        external
        view
        returns (
            bool isUnlinkable,
            address splitClone,
            address ancestorsVault,
            uint32 royaltyStack,
            bytes32 ancestorsHash
        );

    /// @notice Returns the percentage scale - 1000 rnfts represents 100%
    function TOTAL_RNFT_SUPPLY() external view returns (uint32);

    /// @notice Returns the maximum number of parents
    function MAX_PARENTS() external view returns (uint256);

    /// @notice Returns the maximum number of total ancestors.
    /// @dev The IP derivative tree is limited to 14 ancestors, which represents 3 levels of a binary tree 14 = 2+4+8
    function MAX_ANCESTORS() external view returns (uint256);

    /// @notice Returns the RoyaltyModule address
    function ROYALTY_MODULE() external view returns (address);

    /// @notice Returns the LicensingModule address
    function LICENSING_MODULE() external view returns (address);

    /// @notice Returns the 0xSplits LiquidSplitFactory address
    function LIQUID_SPLIT_FACTORY() external view returns (address);

    /// @notice Returns the 0xSplits LiquidSplitMain address
    function LIQUID_SPLIT_MAIN() external view returns (address);

    /// @notice Returns the Ancestors Vault Implementation address
    function ANCESTORS_VAULT_IMPL() external view returns (address);

    /// @notice Distributes funds internally so that accounts holding the royalty nfts at distribution moment can
    /// claim afterwards
    /// @param ipId The ipId
    /// @param token The token to distribute
    /// @param accounts The accounts to distribute to
    /// @param distributorAddress The distributor address
    function distributeIpPoolFunds(
        address ipId,
        address token,
        address[] calldata accounts,
        address distributorAddress
    ) external;

    /// @notice Claims the available royalties for a given address
    /// @param account The account to claim for
    /// @param withdrawETH The amount of ETH to withdraw
    /// @param tokens The tokens to withdraw
    function claimFromIpPool(address account, uint256 withdrawETH, ERC20[] calldata tokens) external;

    /// @notice Claims the available royalties for a given address that holds all the royalty nfts of an ipId
    /// @param ipId The ipId
    /// @param withdrawETH The amount of ETH to withdraw
    /// @param token The token to withdraw
    function claimFromIpPoolAsTotalRnftOwner(address ipId, uint256 withdrawETH, address token) external;

    /// @notice Claims all available royalty nfts and accrued royalties for an ancestor of a given ipId
    /// @param ipId The ipId
    /// @param claimerIpId The claimer ipId
    /// @param ancestors The ancestors of the IP
    /// @param ancestorsRoyalties The royalties of the ancestors
    /// @param withdrawETH Indicates if the claimer wants to withdraw ETH
    /// @param tokens The ERC20 tokens to withdraw
    function claimFromAncestorsVault(
        address ipId,
        address claimerIpId,
        address[] calldata ancestors,
        uint32[] calldata ancestorsRoyalties,
        bool withdrawETH,
        ERC20[] calldata tokens
    ) external;
}
