# Snowflake Hands-on Lab - Zero to Chat with Your Data in 120 Minutes #

## License
This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Lab Setup ##
* Log in to https://app.snowflake.com/umnxxyz/lab_data_chat
* Run `worksheets/SETUP_BASE` SQL script
* Set the initial password for the lab participants in `worksheets/SETUP_USERS`
* Run `worksheets/SETUP_USERS` SQL script
* Make the Cybersyn data shares available to everyone in the account:
  * Switch role to `ACCOUNTADMIN`
  * Navigate to `Data Products > Marketplace`
  * Type `stock prices` in the search box at the top, scroll through the results, and select [Financial & Economic Essentials](https://app.snowflake.com/marketplace/listing/GZTSZAS2KF7/) (provided by Cybersyn).
  * Click `Get` and enter your contact information in the prompt window
  * In the next window
  * leave the default database name as-is: `FINANCIAL__ECONOMIC_ESSENTIALS`
  * choose to make the data available to the `PUBLIC` role, then click `Get`.

## Lab Presentation ##
* Go through introductory presentation
* Open the [Lab Walkthrough](https://github.com/Infostrux-Solutions/snowflake-hol-zero-to-chat-with-your-data/blob/main/zero_to_chat_with_your_data/zero_to_chat_with_your_data.md)
* Start the lab walkthrough
* When you reach the point of users running queries
  * In a separate browser window, login as admin to Snowflake https://app.snowflake.com/umnxxyz/lab_data_chat
  * Direct lab users to log into Snowflake at https://app.snowflake.com/umnxxyz/lab_data_chat
    * User should change their password and record the new one
    * Initial login credentials
      * Username `LAB_USER_<NUMBER>`
      * Password `******`
  * Share workshop assets
    * Switch role to `LAB_ADMIN`
    * Open the `ZERO_TO_CHAT_WITH_YOUR_DATA` worksheet
      * Click `SHARE` and add all the lab users with a `View results` permission
      >   NOTE: You will not be able to share a worksheet with a lab user who has not logged in
* When you reach the point of presenting a Streamlit app, share it to the `PUBLIC` role
  * Switch role to `LAB_ADMIN`
  * Open the Streamlit app
    * Click `SHARE` and it with the `PUBLIC` role with `View only` permission

## Teardown ##
* Run `worksheets/TEARDOWN_USERS` SQL script

## WIPE ALL DATA ##
* Run `worksheets/WIPEOUT` SQL script

## Tips ##

### Fetching Quickstart Directories ###
Example:
```shell
cd /tmp
git clone --no-checkout --depth=1 --no-tags git@github.com:Snowflake-Labs/sfquickstarts.git
cd sfquickstarts
git restore --staged site/sfguides/src/frosty_llm_chatbot_on_streamlit_snowflake
git checkout site/sfguides/src/frosty_llm_chatbot_on_streamlit_snowflake
```
