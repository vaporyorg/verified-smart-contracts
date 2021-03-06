*2018-01-26*

# Formal Verification of OpenZeppelin ERC20 Token Contract

We present a formal verification of [OpenZeppelin ERC20][src] token contract.

The OpenZeppelin ERC20 token is a high-profile ERC20 token contract written in Solidity implemented by Zeppelin, a consulting firm for smart contracts that provides security audits.

We found that the OpenZeppelin token deviates from the [ERC20-K] (and thus [ERC20-EVM]) specification as follows:

* *Rejecting transfers to address 0*: It does not allow transferring to address 0 (for both `transfer` and `transferFrom`), throwing an exception immediately. It does not violate the [standard][ERC20], as the standard does not specify any requirement regarding it. However, it is questionable since while there are many other invalid addresses to which a transfer should not be made, it is not clear how useful rejecting the single invalid address is, at the cost of the additional gas consumption for every transfer transaction to check if the given address is zero.

## Target Smart Contract

The target contract of our formal verification is the following, where we took the Solidity source code from the Github repository,
https://github.com/OpenZeppelin/zeppelin-solidity,
commit [`c5d66183`][version]:

* [StandardToken.sol][src]

We formally verified the full functional correctness of the following ERC20 functions:

* [`totalSupply`](https://github.com/OpenZeppelin/zeppelin-solidity/blob/c5d66183abcb63a90a2528b8333b2b17067629fc/contracts/token/ERC20/BasicToken.sol#L22)
* [`balanceOf`](https://github.com/OpenZeppelin/zeppelin-solidity/blob/c5d66183abcb63a90a2528b8333b2b17067629fc/contracts/token/ERC20/BasicToken.sol#L47)
* [`allowance`](https://github.com/OpenZeppelin/zeppelin-solidity/blob/c5d66183abcb63a90a2528b8333b2b17067629fc/contracts/token/ERC20/StandardToken.sol#L59)
* [`approve`](https://github.com/OpenZeppelin/zeppelin-solidity/blob/c5d66183abcb63a90a2528b8333b2b17067629fc/contracts/token/ERC20/StandardToken.sol#L47)
* [`transfer`](https://github.com/OpenZeppelin/zeppelin-solidity/blob/c5d66183abcb63a90a2528b8333b2b17067629fc/contracts/token/ERC20/BasicToken.sol#L31)
* [`transferFrom`](https://github.com/OpenZeppelin/zeppelin-solidity/blob/c5d66183abcb63a90a2528b8333b2b17067629fc/contracts/token/ERC20/StandardToken.sol#L25)

## Verification Artifacts

### Solidity Source Code and Compiled EVM Bytecode

We took the [source code][src], inlined the [`BasicToken`], [`ERC20`], [`ERC20Basic`], and [`SafeMath`] contracts, and compiled it to the EVM bytecode using Remix Solidity IDE (of the version `soljson-v0.4.19+commit.c4cbbb05`).

The inlined source code of the contract is the following:

* [StandardToken.inlined.sol](StandardToken.inlined.sol)

The EVM (runtime) bytecode generated by the Remix Solidity compiler is the following:

* [StandardToken.inlined.bytes](StandardToken.inlined.bytes)

The Remix IDE-generated Gist link:

* StandardToken.inlined.gist: https://gist.github.com/anonymous/329a61e60ff35a75fd74865df1010fcd

The (annotated) EVM assembly disassembled from the bytecode is the following:

* [StandardToken.inlined.evm](StandardToken.inlined.evm)

### Mechanized Specifications and Proofs

Due to its deviation from [ERC20-K], we could not verify the OpenZeppelin token against the original [ERC20-EVM] specification. In order to show that it is "correct" w.r.t. ERC20-K (thus ERC20-EVM) modulo the deviation, we modified the specification to capture the deviation and successfully verified it against the modified ERC20-EVM specification. Below are the changes made to the original ERC20-EVM specification:

* To capture the rejection of transferring to address 0, we added the following additional `requires` conditions, one for the success cases:

    ```
    andBool TO_ID =/=Int 0
    ```

    and its complement for the failure cases:

    ```
    orBool TO_ID ==Int 0
    ```

The full changes made in ERC20-EVM are shown in [here](spec-diff.patch). The specifications of other functions except `transfer` and `transferFrom` are the same as the original ERC20-EVM.

We took the modified [ERC20-EVM] specification and instantiated it with the [program-specific parameters] shown below.

```
[pgm]
compiler: "Solidity"
_balances: 0
_totalSupply: 1
_allowances: 2
code: "0x60606040526004361061008e576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063095ea7b31461009357806318160ddd146100ed57806323b872dd14610116578063661884631461018f57806370a08231146101e9578063a9059cbb14610236578063d73dd62314610290578063dd62ed3e146102ea575b600080fd5b341561009e57600080fd5b6100d3600480803573ffffffffffffffffffffffffffffffffffffffff16906020019091908035906020019091905050610356565b604051808215151515815260200191505060405180910390f35b34156100f857600080fd5b610100610448565b6040518082815260200191505060405180910390f35b341561012157600080fd5b610175600480803573ffffffffffffffffffffffffffffffffffffffff1690602001909190803573ffffffffffffffffffffffffffffffffffffffff16906020019091908035906020019091905050610452565b604051808215151515815260200191505060405180910390f35b341561019a57600080fd5b6101cf600480803573ffffffffffffffffffffffffffffffffffffffff1690602001909190803590602001909190505061080c565b604051808215151515815260200191505060405180910390f35b34156101f457600080fd5b610220600480803573ffffffffffffffffffffffffffffffffffffffff16906020019091905050610a9d565b6040518082815260200191505060405180910390f35b341561024157600080fd5b610276600480803573ffffffffffffffffffffffffffffffffffffffff16906020019091908035906020019091905050610ae5565b604051808215151515815260200191505060405180910390f35b341561029b57600080fd5b6102d0600480803573ffffffffffffffffffffffffffffffffffffffff16906020019091908035906020019091905050610d04565b604051808215151515815260200191505060405180910390f35b34156102f557600080fd5b610340600480803573ffffffffffffffffffffffffffffffffffffffff1690602001909190803573ffffffffffffffffffffffffffffffffffffffff16906020019091905050610f00565b6040518082815260200191505060405180910390f35b600081600260003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020819055508273ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff167f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925846040518082815260200191505060405180910390a36001905092915050565b6000600154905090565b60008073ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff161415151561048f57600080fd5b6000808573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000205482111515156104dc57600080fd5b600260008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054821115151561056757600080fd5b6105b8826000808773ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054610f8790919063ffffffff16565b6000808673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000208190555061064b826000808673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054610fa090919063ffffffff16565b6000808573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000208190555061071c82600260008773ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054610f8790919063ffffffff16565b600260008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020819055508273ffffffffffffffffffffffffffffffffffffffff168473ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef846040518082815260200191505060405180910390a3600190509392505050565b600080600260003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000205490508083111561091d576000600260003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020819055506109b1565b6109308382610f8790919063ffffffff16565b600260003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020819055505b8373ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff167f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925600260003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008873ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020546040518082815260200191505060405180910390a3600191505092915050565b60008060008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020549050919050565b60008073ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff1614151515610b2257600080fd5b6000803373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020548211151515610b6f57600080fd5b610bc0826000803373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054610f8790919063ffffffff16565b6000803373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002081905550610c53826000808673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054610fa090919063ffffffff16565b6000808573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020819055508273ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef846040518082815260200191505060405180910390a36001905092915050565b6000610d9582600260003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054610fa090919063ffffffff16565b600260003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020819055508273ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff167f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925600260003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008773ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020546040518082815260200191505060405180910390a36001905092915050565b6000600260008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054905092915050565b6000828211151515610f9557fe5b818303905092915050565b6000808284019050838110151515610fb457fe5b80915050929150505600a165627a7a7230582058550344abe30ea80d7004da1407b11319bd56cc09cfbbc9ca9a7c80adacd5a30029"
gasCap: 100000
```

The resulting specification is the following:

* [zeppelin-erc20-spec.ini](zeppelin-erc20-spec.ini)

The specification is written in [eDSL], a domain-specific language for EVM specifications, whose good understanding is required in order to understand any of our EVM-level specification well.  Refer to [resources] for background on our technology.  The above file provides the [eDSL] specification template parameters, the full K reachability logic specification being automatically derived from a specification template by instantiating it with the template parameters.

Run the following command in the root directory of this repository, and it will generate the full specification under the directory `specs/zeppelin-erc20`:

```
$ make zeppelin-erc20
```

Run the EVM verifier to prove that the specification is satisfied by (the compiled EVM bytecode of) the target functions.
See this [instruction] for more details of running the verifier.

<!--
#### Reproducing Proofs

To prove that the specification is satisfied by (the compiled EVM bytecode of) the target functions, run the EVM verifier as follows:

```
$ ./kevm prove tests/proofs/specs/zeppelin-erc20/<func>-spec.k
```

where `<func>` is the name of the ERC20 function to verify.

The above command essentially executes the following command:

```
$ kprove zeppelin-erc20-spec.k -m VERIFICATION --z3-executable -d /path/to/evm-semantics/.build/java
```

#### Installing the EVM Verifier

The EVM verifier is part of the [KEVM] project.  The following commands will successfully install it, provided that all of the dependencies are installed.

```
$ git clone git@github.com:kframework/evm-semantics.git
$ cd evm-semantics
$ make deps
$ make
```

For detailed instructions on installing and running the EVM verifier, see [KEVM]'s [Installing/Building](https://github.com/kframework/evm-semantics/blob/master/README.md#installingbuilding) and [Example Usage](https://github.com/kframework/evm-semantics/blob/master/README.md#example-usage) pages.
-->


## [Resources](/README.md#resources)

## [Disclaimer](/README.md#disclaimer)


[KEVM]: <https://github.com/kframework/evm-semantics>
[K-framework]: <http://www.kframework.org>
[reachability logic theorem prover]: <http://fsl.cs.illinois.edu/index.php/Semantics-Based_Program_Verifiers_for_All_Languages>
[resources]: </README.md#resources>
[eDSL]: </resources/edsl.md>
[program-specific parameters]: </resources/edsl-spec.md#program-specific-parameters>
[version]: <https://github.com/OpenZeppelin/zeppelin-solidity/tree/c5d66183abcb63a90a2528b8333b2b17067629fc>
[src]: <https://github.com/OpenZeppelin/zeppelin-solidity/blob/c5d66183abcb63a90a2528b8333b2b17067629fc/contracts/token/ERC20/StandardToken.sol>
[`BasicToken`]: <https://github.com/OpenZeppelin/zeppelin-solidity/blob/c5d66183abcb63a90a2528b8333b2b17067629fc/contracts/token/ERC20/BasicToken.sol>
[`ERC20`]: <https://github.com/OpenZeppelin/zeppelin-solidity/blob/c5d66183abcb63a90a2528b8333b2b17067629fc/contracts/token/ERC20/ERC20.sol>
[`ERC20Basic`]: <https://github.com/OpenZeppelin/zeppelin-solidity/blob/c5d66183abcb63a90a2528b8333b2b17067629fc/contracts/token/ERC20/ERC20Basic.sol>
[`SafeMath`]: <https://github.com/OpenZeppelin/zeppelin-solidity/blob/c5d66183abcb63a90a2528b8333b2b17067629fc/contracts/math/SafeMath.sol>
[ERC20]: <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md>
[ERC20 standard]: <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md>
[ERC20-K]: <https://github.com/runtimeverification/erc20-semantics>
[ERC20-EVM]: </resources/erc20-evm.md>
[instruction]: </resources/instruction.md>
