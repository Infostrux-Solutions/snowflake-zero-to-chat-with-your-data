# Snowflake Hands-on Lab - Zero to Chat with Your Data in 120 Minutes #

## Admin Setup ##
* Log in to https://app.snowflake.com/umnxxyz/chat_with_your_data
* Run `worksheets/SETUP_BASE` SQL script
* Run `worksheets/SETUP_USERS` SQL script
* Switch role to `LAB_ADMIN`
* Open the `ZERO_TO_CHAT_WITH_YOUR_DATA` worksheet
* Click `SHARE` and add the lab attendants with a `View results` permission
* Make the Cybersyn data shares available to lab users:
  * In Snowflake, navigate to `Data Products > Marketplace`
  * Type `stock prices` in the search box at the top, scroll through the results, and select [Financial & Economic Essentials](https://app.snowflake.com/marketplace/listing/GZTSZAS2KF7/) (provided by Cybersyn).
  * Click `Get` and enter your contact information in the prompt window
  * In the next window
    * leave the default database name as-is: `FINANCIAL__ECONOMIC_ESSENTIALS`
    * choose to make the data available to the `PUBLIC` role, then click `Get`. 

## Testing ##
Test lab user password: `jn4rjQ2zsja8y9XCh7QG9zCTLCMYe`


## Teardown ##
* Run `worksheets/TEARDOWN_USERS` SQL script

## WIPE ALL DATA ##
* Run `worksheets/WIPEOUT` SQL script

## Fetching Quickstart Directories ##
cd /tmp
git clone --no-checkout --depth=1 --no-tags git@github.com:Snowflake-Labs/sfquickstarts.git
cd sfquickstarts
git restore --staged site/sfguides/src/frosty_llm_chatbot_on_streamlit_snowflake
git checkout site/sfguides/src/frosty_llm_chatbot_on_streamlit_snowflake