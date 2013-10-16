# Frumple Stock Index (FSI) 

Each user and project have two fields:

* volume
    * the amount of 'stuff' it has (redmine/git content)
    * think: 'quantity'
* price
    * the price of a single unit of stuff
    * think: 'quality'

volume constantly increases, with the exception of truly deleting content.

## Rules

- A user is a Stock
- A project is a Market
- Stocks inside a market affect eachother's price
- Market's are isolated
    - a market's gdp (both volume and price) are unaffect by local inactivity and external market activity

## Users

users have a stock price:

> volume * price

### Indicators of Frumping

Indicators of Frumping (IOF) are calculated by a user's actions as well as inactivity.

## Projects

projects have gdp (gross domestic product) and gni (gross national income):

> gdp = volume * price  
> gni = gdp + sum(all sub projects)

