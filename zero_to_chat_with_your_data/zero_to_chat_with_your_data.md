# Zero to Chat with Your Snowflake Data in 120 Minutes #

## Introduction ##

> Based on the [Zero to Snowflake Quickstart](https://github.com/Snowflake-Labs/sfquickstarts/blob/master/site/sfguides/src/getting_started_with_snowflake/getting_started_with_snowflake.md) with an LLM twist.

This entry-level lab, designed for database and data warehouse administrators and architects, will give you a brief introduction to Snowflake and will walk you through creating a Cortex AI-powered LLM Chatbot in Streamlit.

### Prerequisites ###
- Basic knowledge of SQL, database concepts, and objects
- Familiarity with CSV (comma-delimited) files and JSON semi-structured data

## What You'll Learn ###
We will use a Snowflake Enterprise edition account for this lab which has been pre-configured with databases, virtual warehouses and some additional objects to give us enough time to dig into the Streamlit Chatbot component of the lab. The lab will focus on:

- How to create stages, tables and views.
- How to load structured and semi-structured data.
- How to consume Cybersyn data from the [Snowflake Data Marketplace](https://app.snowflake.com/marketplace/listing/GZTSZAS2KF7/).
- How to perform analytical queries on data in Snowflake, including joins between tables.
- How to clone objects.
- How to undo user errors using Time Travel.
- How to use Cortex AI to ask questions about your data
- How to use Cortex AI to summarize your data
- How to create a Streamlit app
- How to leverage Cortex AI queries to create your own Chatbot in Streamlit

>  SCREENSHOTS, SAMPLE CODE AND ENVIRONMENTS:
Screenshots in this lab depict examples; results may vary slightly from what you see when you complete the exercises.


### Data You'll Use: ###
**Cybersyn** is a next generation data company creating a real-time view of the world's economy with analytics-ready data exclusively on Snowflake Marketplace. Initially focused on consumer insights, Cybersyn enables you to access external data directly in your Snowflake instance — no ETL required.

This lab will use the following Cybersyn datasets:
- Daily stock price data
- SEC 10-K & 10-Q filings
- Company metadata

Check out Cybersyn's [Consumer Spending product](https://app.snowflake.com/marketplace/listing/GZTSZ290BUX62/) and [explore all 60+ public sources](https://app.cybersyn.com/data_catalog/?utm_source=Snowflake+Quickstart&utm_medium=organic&utm_campaign=Snowflake+Quickstart) Cybersyn offers on the [Snowflake Marketplace](https://app.snowflake.com/marketplace/providers/GZTSZAS2KCS/Cybersyn).


## Lab Environment Access ##
Each of you should have received a number when you arrived to allow you to access your your own workspace in Snowflake.

Open a browser window and enter the URL:

> https://app.snowflake.com/umnxxyz/infostrux_hol_ai_data_chat

> IMPORTANT: As soon as you log in, you will be prompted to change your password. Your new password must be at least 8 characters long and contain at least 1 number, 1 uppercase and 1 lowercase letter.
> 
> PLEASE NOTE DOWN THE NEW PASSWORD AS YOU WILL NEED IT LATER!

![login screen](assets/3UIStory_1.png)

Log in with these credentials (replace the `<NUMBER>` with the number you were assigned):
```text
Username: LAB_USER_<NUMBER>
Password: LAB123
```

> When you login, you will be prompted to setup multifactor authentication. While this is a best practice and it is strongly recommended that you do that, we will be skipping it for the purposes of the lab, so just click on the `Not now` at the bottom left of the prompt.

## The Snowflake User Interface ##

Duration: 8

### Navigating the Snowflake UI ###

Let's get you acquainted with Snowflake! This section covers the basic components of the user interface.

### Projects > Worksheets ###


Under **Projects** on the left-hand panel, select the ​**Worksheets​** tab.

![snowflake navbar](assets/3UIStory_2.png)

This provides an interface for submitting SQL queries, performing DDL and DML operations, and viewing results as your queries or operations complete. A new worksheet is created by clicking **`+`** on the top right.

![worksheets tab main](assets/3UIStory_3.png)

### Worksheet Structure  ###

![worksheets tab details](assets/3UIStory_4.png)

The top left corner contains the following:
- **Snowflake** icon: Use this to get back to the main console/close the worksheet.
- **Worksheet_name** drop-down: The default name is the timestamp when the worksheet was created. Click the timestamp to edit the worksheet name. The drop-down also displays additional actions you can perform for the worksheet.
- **Filters** button: Custom filters are special keywords that resolve as a subquery or list of values.

The top right corner contains the following:
- **Context** box: This lets Snowflake know which role and warehouse to use during this session. It can be changed via the UI or SQL commands.
- **Share** button: Open the sharing menu to share to other users or copy the link to the worksheet.
- **Play/Run** button: Run the SQL statement where the cursor currently is or multiple selected statements.

The middle pane contains the following:
- Drop-down at the top for setting the database/schema/object context for the worksheet.
- General working area where you enter and execute queries and other SQL statements. 

The middle-left panel contains the following:
- **Worksheets** tab: Use this tab to quickly select and jump between different worksheets
- **Databases** tab: Use this tab to view all of the database objects available to the current role
- **Search** bar: database objects browser which enables you to explore all databases, schemas, tables, and views accessible by the role currently in use for the worksheet. 

The bottom pane displays the results of queries and other operations. Also includes 4 options (**Object**, **Query**, **Result**, **Chart**) that open/close their respective panels on the UI. **Chart** opens a visualization panel for the returned results. More on this later.

The various panes on this page can be resized by adjusting their sliders. If you need more room in the worksheet, collapse the database objects browser in the left panel. Many of the screenshots in this guide keep this panel closed.

### Projects > Notebooks ###

Typically, a lot of SQL work happens in Snowflake's **Worksheets**. However, for this exercise we will use the Snowflake **Notebooks** interface. The **Notebooks** are Snowflake's implementation of Jupyter Notebooks, a powerful tool for data science that allow us to create a sequential mix of Markdown, SQL and Python cells to walk us through a complete data exploration or manipulation process.

Under **Projects** on the left-hand panel, select the **Notebooks** tab.

![notebooks tab main](assets/3UIStory_3.Notebooks.png)

### Notebooks Structure

>  **Notebooks vs. the UI**
Most of the exercises in this lab are executed using pre-written SQL within the notebook to save time. These tasks can also be done via the UI, but would require navigating back-and-forth between multiple UI tabs.

> 🚧 UNDER CONSTRUCTION: Provide a description of the Notebooks UI.

### Projects > Dashboards ###

Under **Projects** on the left-hand panel, select the ​**Dashboards​** tab. This tab allows you to create flexible displays of one or more charts (in the form of tiles, which can be rearranged). Tiles and widgets are produced by executing SQL queries that return results in a worksheet. Dashboards work at a variety of sizes with minimal configuration.

![dashboards tab](assets/3UIStory_5.png)

### Data > Databases ###

Under **Data**, the **Databases**​ tab shows information about the databases you have created or have permission to access. You can create, clone, drop, or transfer ownership of databases, as well as load data in the UI. Notice that a database already exists in your environment.

![databases tab](assets/3UIStory_6.png)

### Data Products > Marketplace ###

The **Marketplace** tab is where any Snowflake customer can browse and consume data sets made available by providers. There are two types of shared data: Public and Personalized. Public data is free data sets available for querying instantaneously. Personalized data requires reaching out to the provider of data for approval of sharing data.

![marketplace tab](assets/3UIStory_8.png)

### Data Products > Private Sharing ###

Under **Data Products**, the **Private Sharing** tab is where data sharing can be configured to easily and securely share Snowflake tables among separate Snowflake accounts or external users, without having to create a copy of the data.

![shared data tab](assets/3UIStory_7.png)

### Monitoring > Query History ###

Under **Monitoring** there are multiple tabs for tracking your usage of your Snowflake account:

- **Query History** is where previous queries are shown, along with filters that can be used to hone results (user, warehouse, status, query tag, etc.). View the details of all queries executed in the last 14 days from your Snowflake account. Click a query ID to drill into it for more information.
- **Copy History** shows the status of copy commands run to ingest data into Snowflake.
- **Task History** allows you to see the execution history for tasks and tasks graphs. (Tasks let you schedule the execution of SQL code. It is associated with a specific database and schema.)
- **Dynamic Tables** is where you can use Snowsight to monitor dynamic table refreshes and examine dynamic tables and dynamic table graphs.
- **Governance** tracks row- and column-level security, object tagging, data classification, access history, and more.

![history tab](assets/3UIStory_9.png)

### Admin > Warehouses ###

Under **Admin**, the **​Warehouses​** tab is where you set up and manage compute resources known as virtual warehouses to load or query data in Snowflake. A warehouse called `LAB_USER_WAREHOUSE` already exists in your environment.

![warehouses tab](assets/3UIStory_10.png)

### Admin > Cost Management ###

Under **Admin**, the **Cost Management** tab shows an overview of account consumption and budgets. It also includes details on all the resource monitors that have been created to control the number of credits that virtual warehouses consume. For each resource monitor, it shows the credit quota, type of monitoring, schedule, and actions performed when the virtual warehouse reaches its credit limit.

![resource monitors tab](assets/3UIStory_11.png)

### Admin > Users & Roles ###

The **Roles** sub-tab of the **Users & Roles** tab shows a list of the roles and their hierarchies. Roles can be created, reorganized, and granted to users in this tab. The roles can also be displayed in tabular/list format by selecting the **Table** sub-tab.

![roles tab](assets/3UIStory_12.png)

### Users ###

The **Users** sub-tab of the **Users & Roles** tab shows a list of users in the account, default roles, and owner of the users. For a new account, no records are shown because no additional roles have been created. Permissions granted through your current role determine the information shown for this tab. To see all the information available on the tab, switch your role to `ACCOUNTADMIN`.

![users tab](assets/3UIStory_13.png)

Clicking on your username in the bottom right of the UI allows you to change your password, roles, and preferences. Snowflake has several system defined roles. You are currently in the default role of `LAB_USER_ROLE_<NUMBER>` (replace the `<NUMBER>` with the number you were assigned).

![user preferences dropdown](assets/Lab_Image_01.png)

## Data Lab: Stock Price & SEC Filings Data ##

Duration: 2

### The Lab Story
You work at a grocery retailer. You want to understand the performance of major consumer goods (CPG) companies in the US that supply your store. This lab takes a look at daily stock price data and quarterly and annual Securities Exchange Commission (SEC) company filings to understand the performance of the CPG landscape. Public companies are required to submit a quarterly and annual report to the SEC detailing their financial data.

We will start by collecting data from three different sources:
1. Load company metadata `.csv` file.
2. Load SEC filings from a semi-structured JSON format.
3. Use the Snowflake Marketplace to find free stock price data from Cybersyn.

<!-- ------------------------ -->

## Loading Structured Data into Snowflake: CSVs ##

Duration: 8

Let's start by preparing to load structured `.csv` data into Snowflake.

We are using company metadata developed from the Securities and Exchange Commission (SEC) that details the consumer packaged goods (CPG) companies we want to evaluate. The data has been exported and pre-staged for you in an Amazon AWS S3 bucket in the US-EAST region. It is in comma-delimited format with a single header line and double quotes enclosing all string values, including the field headings in the header line. This will be important when we configure the Snowflake table to store this data.

> **Free Datasets from Cybersyn direct to your Snowflake instance:** The full dataset is available [**for free**](https://app.snowflake.com/marketplace/listing/GZTSZAS2KF7) in Snowflake Marketplace from Cybersyn -- no ETL required. For the purposes of this demo, we will focus on working with a subset of the data, staged in a csv file to learn how to load structured data into Snowflake.

**Getting Data into Snowflake**
Data can be ingested into Snowflake from many locations by using the `COPY` command, Snowpipe auto-ingestion, external connectors, or third-party ETL/ELT solutions. For more information on getting data into Snowflake, see the [Snowflake documentation](https://docs.snowflake.net/manuals/user-guide-data-load.html). For the purposes of this lab, we use the `COPY` command and AWS S3 storage to load data manually. In a real-world scenario, you would more likely use an ETL solution or grab data directly from the Snowflake Marketplace!

### Preparing to Run the Lab Queries ###
Now navigate to the **Notebooks** screen. The queries we will be using have been prepared in a Snowflake Worksheet named `ZERO_TO_CHAT_WITH_YOUR_DATA`. This is the "master" worksheet owned by the lab admin. We will create a copy of that worksheet and use our individual copies.

![Worksheet image](assets/Lab_Image_0.png)

Now, let's create a copy of the worksheet:
* Navigate to `Projects` > `Worsheets` and open the `ZERO_TO_CHAT_WITH_YOUR_DATA` worksheet
* Click on three dots `...` which appear to the right of the worksheet name and select `Duplicate`, then close the original Worksheet.

We need to set the context appropriately within the new Worksheet. In the upper right corner of the worksheet, click the box to the left of the **Share** button to show the context menu. Here we control the elements you can see and run from each worksheet. We are using the UI here to set the context. Later in the lab, we will accomplish the same thing via SQL commands within the worksheet.

Select the following context settings:

**Role:** `LAB_USER_<number>`
**Warehouse:** `LAB_USER_WAREHOUSE`

![context role and warehouse settings](assets/Lab_Image_02.png)

Finally, we need to select the database and schema context of our worksheet:
  * Highlight the group of queries at the top of the worksheet and click the "Play" ▶️ button at the top right of the worksheet.
  * The header of the worksheet should show the selected database and schema like `CHAT_WITH_YOUR_DATA.WORKSPACE_<number>`

### Create Our First Table
>  **Data Definition Language (DDL) operations are free!**
All the DDL operations we have done so far do not require compute resources, so we can create all our objects for free.

To make working in the worksheet easier, let's rename it. In the top left corner, double-click the worksheet name, which is the timestamp when the worksheet was created, and change it to `ZERO_TO_CHAT_WITH_YOUR_DATA_WITH_CYBERSYN`.

Next we create a table called `COMPANY_METADATA` to use for loading the comma-delimited data. Instead of using the UI, we use the worksheet to run the DDL that creates the table:

```SQL
CREATE OR REPLACE TABLE company_metadata
(cybersyn_company_id string,
company_name string,
permid_security_id string,
primary_ticker string,
security_name string,
asset_class string,
primary_exchange_code string,
primary_exchange_name string,
security_status string,
global_tickers variant,
exchange_code variant,
permid_quote_id variant);
```

>  **Many Options to Run Commands.**
SQL commands can be executed through the UI, via the **Worksheets** tab, using our SnowSQL command line tool, with a SQL editor of your choice via ODBC/JDBC, or through our other connectors (Python, Spark, etc.).
As mentioned earlier, to save time, we are performing most of the operations in this lab via pre-written SQL executed in the worksheet as opposed to using the UI.

Run the query by placing your cursor anywhere in the SQL text and clicking the blue **Play/Run** button in the top right of the worksheet. Or use the keyboard shortcut [Ctrl]/[Cmd]+[Enter].

Verify your `COMPANY_METADATA` table has been created. At the bottom of the worksheet, you should see a Results section displaying a `"Table COMPANY_METADATA successfully created"` message.

![TRIPS confirmation message](assets/Lab_Image_00.png)

Navigate to the **Databases** tab by clicking the **HOME** icon in the upper left corner of the worksheet. Then click **Data** > **Databases**. In the list of databases, click `CHAT_WITH_YOUR_DATA` > `WORKSPACE_<number>` > **TABLES** to see your newly created `COMPANY_METADATA` table. If you don't see any databases on the left, expand your browser because they may be hidden.

![TRIPS table](assets/Lab_Image_table1.png)

Click `COMPANY_METADATA` and the **Columns** tab to see the table structure you just created.

![TRIPS table structure](assets/Lab_Image_table2.png)

### Create an External Stage

We are working with structured, comma-delimited data that has already been staged in a public, external S3 bucket. Before we can use this data, we first need to create a _stage_ that specifies the location of our external bucket.

>  For this lab, we are using an AWS-East bucket. To prevent data egress/transfer costs in the future, you should select a staging location from the same cloud provider and region as your Snowflake account.

Create the stage by executing the following SQL statement:

```SQL
CREATE OR REPLACE  STAGE cybersyn_company_metadata
    URL = 's3://sfquickstarts/zero_to_snowflake/cybersyn-consumer-company-metadata-csv/';
```

>  The S3 bucket for this lab is public so you can leave the credentials options in the statement empty. In a real-world scenario, the bucket used for an external stage would likely require key information.

Now let's take a look at the contents of the `cybersyn_company_metadata` stage. Add the following SQL statement below the previous code and then execute:

```SQL
LIST @cybersyn_company_metadata;
```

In the results in the bottom pane, you should see the list of files in the stage:

![worksheet result](assets/Lab_Image_03.png)

### Create a File Format

Before we can load the data into Snowflake, we have to create a file format that matches the data structure. In the worksheet, again add the following command below the rest and execute to create the file format:

```SQL
CREATE OR REPLACE FILE FORMAT csv
    TYPE = 'CSV'
    COMPRESSION = 'AUTO'  -- Automatically determines the compression of files
    FIELD_DELIMITER = ','  -- Specifies comma as the field delimiter
    RECORD_DELIMITER = '\n'  -- Specifies newline as the record delimiter
    SKIP_HEADER = 1  -- Skip the first line
    FIELD_OPTIONALLY_ENCLOSED_BY = '\042'  -- Fields are optionally enclosed by double quotes (ASCII code 34)
    TRIM_SPACE = FALSE  -- Spaces are not trimmed from fields
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE  -- Does not raise an error if the number of fields in the data file varies
    ESCAPE = 'NONE'  -- No escape character for special character escaping
    ESCAPE_UNENCLOSED_FIELD = '\134'  -- Backslash is the escape character for unenclosed fields
    DATE_FORMAT = 'AUTO'  -- Automatically detects the date format
    TIMESTAMP_FORMAT = 'AUTO'  -- Automatically detects the timestamp format
    NULL_IF = ('')  -- Treats empty strings as NULL values
    COMMENT = 'File format for ingesting data for zero to snowflake';
```

![create file format](assets/Lab_Image_04.png)

Verify the file format has been created with the correct settings by executing the following command:

```SQL
SHOW FILE FORMATS;
```

The file format created should be listed in the result:
![create file format settings](assets/Lab_Image_05.png)


> 🚧 **TODO** -- Validate whether to keep this paragraph or remove it.
>
>  aside negative
>
>  **Snowflake Compute vs Other Data Warehouses**
Many of the virtual warehouse and compute capabilities we just covered, such as the ability to create, scale up, scale out, and auto-suspend/resume virtual warehouses are easy to use in Snowflake and can be done in seconds. For on-premise data warehouses, these capabilities are much more difficult, if not impossible, as they require significant physical hardware, over-provisioning of hardware for workload spikes, and significant configuration work, as well as additional challenges. Even other cloud-based data warehouses cannot scale up and out like Snowflake without significantly more configuration work and time.
>
> ---------------------

### Load the Data

Now we can run a COPY command to load the data into the `COMPANY_METADATA` table we created earlier.

Navigate back to the `ZERO_TO_CHAT_WITH_YOUR_DATA_WITH_CYBERSYN` worksheet in the **Worksheets** tab. Make sure the worksheet context is correctly set:

**Role:** `LAB_USER_<number>`
**Warehouse:** `LAB_USER_WAREHOUSE`
**Database:** `CHAT_WITH_YOUR_DATA`
**Schema:** `WORKSPACE_<NUMBER>`

![worksheet context](assets/Lab_Image_06.png)

Execute the following statements in the worksheet to load the staged data into the table. This may take up to 30 seconds.

```SQL
COPY INTO company_metadata FROM @cybersyn_company_metadata file_format=csv PATTERN = '.*csv.*' ON_ERROR = 'CONTINUE';
```

In the result pane, you should see the status of each file that was loaded. Once the load is done, in the **Query Details** pane on the bottom right, you can scroll through the various statuses, error statistics, and visualizations for the last statement executed.

Next, navigate to the **Query History** tab by clicking the **Home** icon and then **Activity** > **Query History**. Select the query at the top of the list, which should be the COPY INTO statement that was last executed. Select the **Query Profile** tab and note the steps taken by the query to execute, query details, most expensive nodes, and additional statistics.

![history and duration](assets/Lab_Image_07.png)

<!-- ------------------------ -->

## Loading Semi-Structured Data into Snowflake: JSONs

Duration: 16

> aside positive
> 
>  This section requires loading additional data and, therefore, provides a review of data loading while also introducing loading semi-structured data.

Going back to the lab's example, our company's analytics team wants to evaluate the performance of CPG companies through the lens of their reported metrics in SEC filings. To do this, in this section, we will:

- Load SEC filing data in semi-structured JSON format held in a public S3 bucket.
- Create a view and query the JSON data using SQL dot notation.

The JSON data consists of SEC filings provided by *Cybersyn*, detailing the historical performance of consumer-packaged goods companies from 2019-2023. It is also staged on AWS S3. If viewed in a text editor, the raw JSON in the GZ files looks like:

![raw JSON sample](assets/7SemiStruct_1_1.png)

_(The full dataset available [**for free**](https://app.snowflake.com/marketplace/listing/GZTSZAS2KH9/) in Snowflake Marketplace from Cybersyn -- no ETL required. For the purposes of this demo, we will focus on working with the semi-structured JSON file to learn how to load structured data into Snowflake.)_

> aside negative
> 
>  **SEMI-STRUCTURED DATA**
Snowflake can easily load and query semi-structured data such as JSON, Parquet, or Avro without transformation. This is a key Snowflake feature because an increasing amount of business-relevant data being generated today is semi-structured, and many traditional data warehouses cannot easily load and query such data. Snowflake makes it easy!

### Create New Tables for the Data

> aside positive
> 
>  **Executing Multiple Commands** Remember that you need to execute each command individually. However, you can execute them in sequence together by selecting all of the commands and then clicking the **Play/Run** button (or using the keyboard shortcut).

Next, let's create two tables, `SEC_FILINGS_INDEX` and `SEC_FILINGS_ATTRIBUTES` to use for loading JSON data. In the worksheet, execute the following `CREATE TABLE` commands:

```SQL
CREATE TABLE sec_filings_index (v variant);

CREATE TABLE sec_filings_attributes (v variant);
```

Note that Snowflake has a special data type called `VARIANT` that allows storing the entire JSON object as a single row and querying the object directly.

> aside negative
> 
>  **Semi-Structured Data Magic**
The `VARIANT` data type allows Snowflake to ingest semi-structured data without having to predefine the schema.

In the results pane at the bottom of the worksheet, verify that your tables, `SEC_FILINGS_INDEX` and `SEC_FILINGS_ATTRIBUTES`, were created:

![success message](assets/Lab_Image_07_1.png)

### Create Another External Stage

In the `ZERO_TO_CHAT_WITH_YOUR_DATA_WITH_CYBERSYN` worksheet, use the following command to create a stage that points to the bucket where the semi-structured JSON data is stored on AWS S3:

```SQL
CREATE STAGE cybersyn_sec_filings
url = 's3://sfquickstarts/zero_to_snowflake/cybersyn_cpg_sec_filings/';
```

Now let's take a look at the contents of the `cybersyn_sec_filings` stage. Execute the following `LIST` command to display the list of files:

```SQL
LIST @cybersyn_sec_filings;
```

In the results pane, you should see a list of `.gz` files from S3:
![results output](assets/7SemiStruct_3_1.png)

### Load and Verify the Semi-structured Data

We will now use a warehouse to load the data from an S3 bucket into the tables we created earlier. In the `ZERO_TO_SNOWFLAKE_WITH_CYBERSYN` worksheet, execute the `COPY` command below to load the data.

Note that you can specify a `FILE FORMAT` object inline in the command. In the previous section where we loaded structured data in CSV format, we had to define a file format to support the CSV structure. Because the JSON data here is well-formed, we are able to simply specify the JSON type and use all the default settings:

```SQL
COPY INTO sec_filings_index
FROM @cybersyn_sec_filings/cybersyn_sec_report_index.json.gz
    file_format = (type = json strip_outer_array = true);

COPY INTO sec_filings_attributes
FROM @cybersyn_sec_filings/cybersyn_sec_report_attributes.json.gz
    file_format = (type = json strip_outer_array = true);
```

Verify that each file has a status of `LOADED`:
![query result](assets/Lab_Image_08.png)

Now, let's take a look at the data that was loaded:
```SQL
SELECT * FROM sec_filings_index LIMIT 10;
SELECT * FROM sec_filings_attributes LIMIT 10;
```

Click any of the rows to display the formatted JSON in the right panel:

![JSON data snippet](assets/7SemiStruct_5_1.png)

To close the display in the panel and display the query details again, click the **X** (Close) button that appears when you hover your mouse in the right corner of the panel.

### Create a View and Query Semi-Structured Data

Next, let's look at how Snowflake allows us to create a view and also query the JSON data directly using SQL.

> aside negative
> 
>  **Views & Materialized Views**
A view allows the result of a query to be accessed as if it were a table. Views can help present data to end users in a cleaner manner, limit what end users can view in a source table, and write more modular SQL.

Snowflake also supports materialized views in which the query results are stored as though the results are a table. This allows faster access, but requires storage space. Materialized views can be created and queried if you are using Snowflake Enterprise Edition (or higher).

Run the following command to create a columnar view of the semi-structured JSON SEC filing data, so it is easier for analysts to understand and query. The CIK corresponds to the Central Index Key, or unique identifier that SEC gives to each filing entity. The ADSH is the document number for any filing submitted to the SEC.

```SQL
CREATE OR REPLACE VIEW sec_filings_index_view AS
SELECT
    v:CIK::string                   AS cik,
    v:COMPANY_NAME::string          AS company_name,
    v:EIN::int                      AS ein,
    v:ADSH::string                  AS adsh,
    v:TIMESTAMP_ACCEPTED::timestamp AS timestamp_accepted,
    v:FILED_DATE::date              AS filed_date,
    v:FORM_TYPE::string             AS form_type,
    v:FISCAL_PERIOD::string         AS fiscal_period,
    v:FISCAL_YEAR::string           AS fiscal_year
FROM sec_filings_index;

CREATE OR REPLACE VIEW sec_filings_attributes_view AS
SELECT
    v:VARIABLE::string            AS variable,
    v:CIK::string                 AS cik,
    v:ADSH::string                AS adsh,
    v:MEASURE_DESCRIPTION::string AS measure_description,
    v:TAG::string                 AS tag,
    v:TAG_VERSION::string         AS tag_version,
    v:UNIT_OF_MEASURE::string     AS unit_of_measure,
    v:VALUE::string               AS value,
    v:REPORT::int                 AS report,
    v:STATEMENT::string           AS statement,
    v:PERIOD_START_DATE::date     AS period_start_date,
    v:PERIOD_END_DATE::date       AS period_end_date,
    v:COVERED_QTRS::int           AS covered_qtrs,
    TRY_PARSE_JSON(v:METADATA)    AS metadata
FROM sec_filings_attributes;
```

SQL dot notation `v:VARIABLE` is used in this command to pull out values at lower levels within the JSON object hierarchy. This allows us to treat each field as if it were a column in a relational table.

The new view should appear as `SEC_FILINGS_INDEX_VIEW` under `CHAT_WITH_YOUR_DATA` > `WORKSPACE_<NUMBER>` > **Views** in the object browser on the left. You may need to expand or refresh the objects browser in order to see it.

![JSON_WEATHER_DATA _VIEW in dropdown](assets/Lab_Image_09.png)

Notice the results look just like a regular structured data source: 

```SQL
SELECT *
FROM sec_filings_index_view
LIMIT 20;
```
<!-- ------------------------ -->

## Getting Data from Snowflake Marketplace

Duration: 5

### Snowflake Data Marketplace

> **Note**: For this lab, we are going to use the FINANCIAL__ECONOMIC_ESSENTIALS database that is already pre-installed; however, here are the step-by-step instructions to get the database from the marketplace.

Make sure you're using the `ACCOUNTADMIN` role and, navigate to **Data Products** > **Marketplace**:

![data marketplace tab](assets/10Share_7.png)

#### Find a listing

Type `stock prices` in the search box at the top, scroll through the results, and select [**Financial & Economic Essentials**](https://app.snowflake.com/marketplace/listing/GZTSZAS2KF7/) (provided by Cybersyn).

![health tab](assets/10Share_8.png)  

In the **Cybersyn Financial & Economic Essentials** page, you can learn more about the contents of the data listing, explore data dictionaries, and see some sample queries. You will also see links to documentation and the dataset's cloud region availability. When you're ready, click the **Get** button to make this information available within your Snowflake account:

![get data fields](assets/10Share_cybersyn_get_data.png)

Review the information in the dialog and click **Get** again:

![get data fields](assets/10Share_cybersyn_get_data2.png)

You can now click **Done** or choose to run the sample queries provided by Cybersyn:

![get data fields](assets/10Share_cybersyn_query_data.png)

That's it! You have now successfully subscribed to the Financial & Economic Essentials datasets from Cybersyn, which are updated daily with global financial data. Notice we didn't have to create databases, tables, views, or an ETL process. We simply searched for and accessed shared data from the Snowflake Data Marketplace.

> aside positive
> 
> To learn more about how to use the new worksheet interface, go to the [Snowsight Docs](https://docs.snowflake.com/en/user-guide/ui-snowsight.html#using-snowsight).

<!-- ------------------------ -->

## Querying, the Results Cache, & Cloning

### Execute Some Queries

Go to the **ZERO_TO_CHAT_WITH_YOUR_DATA_WITH_CYBERSYN** worksheet and change the warehouse to use the new warehouse you created in the last section. Your worksheet context should be the following:

**Role:** `LAB_USER_ROLE_<NUMBER>`
**Warehouse:** `LAB_USER_WAREHOUSE`
**Database:** `CHAT_WITH_YOUR_DATA`
**Schema:** `WORKSPACE_<NUMBER>`

![sample data query results](assets/Lab_Image_10.png)

Now, let's look at the performance of these companies in the stock market. Run the queries below in the worksheet. 

**Closing Price Statistics:** First, calculate the daily return of a stock (the percent change in the stock price from the close of the previous day to the close of the current day) and 5-day moving average from closing prices (which helps smooth out daily price fluctuations to identify trends).

```SQL
SELECT
    meta.primary_ticker,
    meta.company_name,
    ts.date,
    ts.value AS post_market_close,
    (ts.value / LAG(ts.value, 1) OVER (PARTITION BY meta.primary_ticker ORDER BY ts.date))::DOUBLE AS daily_return,
    AVG(ts.value) OVER (PARTITION BY meta.primary_ticker ORDER BY ts.date ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS five_day_moving_avg_price
FROM Financial__Economic_Essentials.cybersyn.stock_price_timeseries ts
INNER JOIN company_metadata meta
ON ts.ticker = meta.primary_ticker
WHERE ts.variable_name = 'Post-Market Close';
```

![post-market close query results](assets/6Query_3.png)

> aside positive
> 
>  If you have defined a particular database in the worksheet and want to use a table from a different database, you must fully qualify the reference to the other table by providing its database and schema name.

**Trading Volume Statistics:** Then, calculate the trading volume change from one day to the next to see if there's an increase or decrease in trading activity. This can be a sign of increasing or decreasing interest in a stock.

```SQL
SELECT
    meta.primary_ticker,
    meta.company_name,
    ts.date,
    ts.value AS nasdaq_volume,
    (ts.value / LAG(ts.value, 1) OVER (PARTITION BY meta.primary_ticker ORDER BY ts.date))::DOUBLE AS volume_change
FROM cybersyn.stock_price_timeseries ts
INNER JOIN company_metadata meta
ON ts.ticker = meta.primary_ticker
WHERE ts.variable_name = 'Nasdaq Volume';
```

![volume query results](assets/6Query_3b.png)

### Use the Result Cache

Snowflake has a result cache that holds the results of every query executed in the past 24 hours. These are available across warehouses, so query results returned to one user are available to any other user on the system who executes the same query, provided the underlying data has not changed. Not only do these repeated queries return extremely fast, but they also use no compute credits.

Let's see the result cache in action by running the exact same query again.

```SQL
SELECT
    meta.primary_ticker,
    meta.company_name,
    ts.date,
    ts.value AS post_market_close,
    (ts.value / LAG(ts.value, 1) OVER (PARTITION BY primary_ticker ORDER BY ts.date))::DOUBLE AS daily_return,
    AVG(ts.value) OVER (PARTITION BY primary_ticker ORDER BY date ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS five_day_moving_avg_price
FROM cybersyn.stock_price_timeseries ts
INNER JOIN company_metadata meta
ON ts.ticker = meta.primary_ticker
WHERE variable_name = 'Post-Market Close';
```

In the **Query Details** pane on the right, note that the query runs significantly faster because the results have been cached.
![cached query duration](assets/6Query_4.png)

### Clone a Table

Snowflake allows you to create clones, also known as "zero-copy clones" of tables, schemas, and databases in seconds. When a clone is created, Snowflake takes a snapshot of data present in the source object and makes it available to the cloned object. The cloned object is writable and independent of the clone source. Therefore, changes made to either the source object or the clone object are not included in the other.

_A popular use case for zero-copy cloning is to clone a production environment for use by Development & Testing teams to test and experiment without adversely impacting the production environment and eliminating the need to set up and manage two separate environments._

> aside negative
> 
>  **Zero-Copy Cloning**
A massive benefit of zero-copy cloning is that the underlying data is not copied. Only the metadata and pointers to the underlying data change. Hence, clones are “zero-copy" and storage requirements are not doubled when the data is cloned. Most data warehouses cannot do this, but for Snowflake it is easy!

Run the following command in the worksheet to create a development (dev) table clone of the `company_metadata` table:

```SQL
CREATE TABLE company_metadata_dev CLONE company_metadata;
```

Click the three dots (**...**) in the left pane and select **Refresh**. Expand the object tree under the `CHAT_WITH_YOUR_DATA` database and verify that you see a new table named `company_metadata_dev`. Your Development team now can do whatever they want with this table, including updating or deleting it, without impacting the `company_metadata` table or any other object.

![trips_dev table](assets/Lab_Image_11.png)

### Joining Tables

We will now join the JSON SEC filing datasets together to investigate the revenue of one CPG company, Kraft Heinz. Run the query below to join `SEC_FILINGS_INDEX` to `SEC_FILINGS_ATTRIBUTES` to see how Kraft Heinz (KHC) business segments have performed over time:

```SQL
WITH data_prep AS (
    SELECT 
        idx.cik,
        idx.company_name,
        idx.adsh,
        idx.form_type,
        att.measure_description,
        CAST(att.value AS DOUBLE) AS value,
        att.period_start_date,
        att.period_end_date,
        att.covered_qtrs,
        TRIM(att.metadata:"ProductOrService"::STRING) AS product
    FROM sec_filings_attributes_view att
    JOIN sec_filings_index_view idx
        ON idx.cik = att.cik AND idx.adsh = att.adsh
    WHERE idx.cik = '0001637459'
        AND idx.form_type IN ('10-K', '10-Q')
        AND LOWER(att.measure_description) = 'net sales'
        AND (att.metadata IS NULL OR OBJECT_KEYS(att.metadata) = ARRAY_CONSTRUCT('ProductOrService'))
        AND att.covered_qtrs IN (1, 4)
        AND value > 0
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY idx.cik, idx.company_name, att.measure_description, att.period_start_date, att.period_end_date, att.covered_qtrs, product
        ORDER BY idx.filed_date DESC
    ) = 1
)

SELECT
    company_name,
    measure_description,
    product,
    period_end_date,
    CASE
        WHEN covered_qtrs = 1 THEN value
        WHEN covered_qtrs = 4 THEN value - SUM(value) OVER (
            PARTITION BY cik, measure_description, product, YEAR(period_end_date)
            ORDER BY period_end_date
            ROWS BETWEEN 4 PRECEDING AND 1 PRECEDING
        )
    END AS quarterly_value
FROM data_prep
ORDER BY product, period_end_date;
```
![weather results](assets/7SemiStruct_8_1.png)

<!-- ------------------------ -->

## Using Time Travel

Duration: 6

Snowflake's powerful Time Travel feature enables accessing historical data, as well as the objects storing the data, at any point within a period of time. The default window is 24 hours and, if you are using Snowflake Enterprise Edition, can be increased up to 90 days. Most data warehouses cannot offer this functionality, but - you guessed it - Snowflake makes it easy!

Some useful applications include:

- Restoring data-related objects such as tables, schemas, and databases that may have been deleted.
- Duplicating and backing up data from key points in the past.
- Analyzing data usage and manipulation over specified periods of time.

### Drop and Undrop a Table

First let's see how we can restore data objects that have been accidentally or intentionally deleted.

In the `ZERO_TO_CHAT_WITH_YOUR_DATA_WITH_CYBERSYN` worksheet, run the following DROP command to remove the `SEC_FILINGS_INDEX` table:

```SQL
DROP TABLE sec_filings_index;

-- Run a query on the table:
SELECT * FROM sec_filings_index LIMIT 10;
```

In the results pane at the bottom, you should see an error because the underlying table has been dropped:
![table dropped error](assets/8Time_1.png)

Now, restore the table:
```SQL
UNDROP TABLE sec_filings_index;
```

The SEC filing index table should be restored. Verify by running the following query:

```SQL 
SELECT * FROM sec_filings_index LIMIT 10;
```

![restored table result](assets/8Time_2.png)

### Roll Back a Table

Let's roll back the `COMPANY_METADATA` table in the `CHAT_WITH_YOUR_DATA` database to a previous state to fix an unintentional DML error that replaces all the company names in the table with the word "oops".

Run the following command to replace all of the company names in the table with the word "oops":

```SQL
UPDATE company_metadata SET company_name = 'oops';
```

Now, run a query that returns the companies. Notice that the company names are all the same:

```SQL
SELECT *
FROM company_metadata;
```

![one row result](assets/8Time_3.png)

Normally we would need to scramble and hope we have a backup lying around. In Snowflake, we can simply run a command to find the query ID of the last `UPDATE` command and store it in a variable named `$QUERY_ID`.

Use Time Travel to recreate the table with the correct company names and verify the company names have been restored:
```SQL
-- Set the session variable for the query_id
SET query_id = (
  SELECT query_id
  FROM TABLE(information_schema.query_history_by_session(result_limit=>5))
  WHERE query_text LIKE 'UPDATE%'
  ORDER BY start_time DESC
  LIMIT 1
);

-- Use the session variable with the identifier syntax (e.g., $query_id)
CREATE OR REPLACE TABLE company_metadata AS
SELECT *
FROM company_metadata
BEFORE (STATEMENT => $query_id);

-- Verify the company names have been restored
SELECT *
FROM company_metadata;
```

![restored names result](assets/8Time_4.png)

<!-- ------------------------ -->

## Working with Account Admin, & Account Usage

Duration: 8

#### Admin > Cost Management

![account usage](assets/9Role_5.png)

The **Cost Management** tab shows your usage of Snowflake credits, with filters by account and consumption types:
- **Organization**: Credit usage across all the accounts in your organization.
- **Compute**: Credits consumed by the virtual warehouses in the current account.
- **Storage**: Average amount of data stored in all databases, internal stages, and Snowflake Failsafe in the current account for the past month.
- **Data Transfer**: Average amount of data transferred out of the region (for the current account) into other regions for the past month.

#### Admin > Security

![account usage](assets/9Role_6.png)

The **Security** tab contains network policies created for the Snowflake account. New network policies can be created by selecting “+ Network Policy” at the top right hand side of the page.

#### Admin > Billing & Terms

The **Billing & Terms** tab contains the payment method for the account:
- If you are a Snowflake contract customer, the tab shows the name associated with your contract information.
- If you are an on-demand Snowflake customer, the tab shows the credit card used to pay month-to-month, if one has been entered. If no credit card is on file, you can add one to continue using Snowflake when your trial ends.


<!-- ------------------------ -->

## Conclusion & Next Steps

Duration: 2

Congratulations on completing this introductory lab exercise! You've mastered the Snowflake basics and are ready to apply these fundamentals to your own data. Be sure to reference this guide if you ever need a refresher.

We encourage you to continue with your free trial by loading your own sample or production data and by using some of the more advanced capabilities of Snowflake not covered in this lab.

### Additional Resources:

- Learn more about the [Snowsight](https://docs.snowflake.com/en/user-guide/ui-snowsight.html#using-snowsight) docs.
- Read the [Definitive Guide to Maximizing Your Free Trial](https://www.snowflake.com/test-driving-snowflake-the-definitive-guide-to-maximizing-your-free-trial/) document.
- Attend a [Snowflake virtual or in-person event](https://www.snowflake.com/about/events/) to learn more about our capabilities and customers.
- Join the [Snowflake Community](https://community.snowflake.com/s/topic/0TO0Z000000wmFQWAY/getting-started-with-snowflake).
- Sign up for [Snowflake University](https://community.snowflake.com/s/article/Getting-Access-to-Snowflake-University).
- Contact our [Sales Team](https://www.snowflake.com/free-trial-contact-sales/) to learn more.
- Access Cybersyn's analytics-ready data on [Snowflake Marketplace](https://app.snowflake.com/marketplace/providers/GZTSZAS2KCS/Cybersyn).
- Explore the [60+ public domain sources](https://app.cybersyn.com/data_catalog/?utm_source=Snowflake+Quickstart&utm_medium=organic&utm_campaign=Snowflake+Quickstart) Cybersyn makes available on Snowflake Marketplace.

### What we've covered:

- How to create stages, databases, tables, views, and virtual warehouses.
- How to load structured and semi-structured data.
- How to consume Cybersyn data from the [Snowflake Data Marketplace](https://app.snowflake.com/marketplace/listing/GZTSZAS2KF7/).
- How to perform analytical queries on data in Snowflake, including joins between tables.
- How to clone objects.
- How to undo user errors using Time Travel.