// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

library EventBroadcasterContractEventsRegistration {

    struct ContractEvents {
        mapping( bytes32 => string) enventBroadcasterAdapterFunctionSignature;
    }
}