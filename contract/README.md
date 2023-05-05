# olfactory contract

# Setup 
1. Install [foundry](https://book.getfoundry.sh/getting-started/installation)
2. Install the required libraries:

``` sh
forge install vectorized/solady
forge install chiru-labs/erc721a
```

## TODO
- Change the `mint` function to allow the user to select which item they want.
    - Change contract to `ERC-1155` to allow multiple editions of a fragrance?
- Add a mint window to only allow purchases during operational hours.
- Try out Merkle Tree (maybe even zkSnark) w/ front-end? Determine if too frivolous.
