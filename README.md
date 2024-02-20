# Randolio: Moneywash (Rewrite) - 20/02/2024

A script that cleans dirty money. Config options are in the server file for enabling fees and percentage cuts, along with multi ped location support.

- QB: Finds all the marked bills in your inventory, calculates the total worth, removes the bills and exchanges for cash.

- ESX: Counts your total 'black_money' and turns it into cash.

**Note**: For QB, qb-inventory uses info.worth for the marked bills worth. I assume that ox_inventory conversion would use metadata.worth for marked bills. This was tested and worked fine. 

## Requirements

* [ox_lib](https://github.com/overextended/ox_lib/releases/tag/v3.16.2)
