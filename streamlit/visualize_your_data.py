# Make sure to add all requirements to Streamlit in Snowflake via the package selection!
# snowflake-ml-python, plotly, matplotlib, seaborn, snowflake.core
# Import necessary packages for the Streamlit app and Snowflake integration
import streamlit as st
import re
from snowflake.snowpark import functions as F
from snowflake.core import Root
from snowflake.cortex import Complete
from snowflake.snowpark.context import get_active_session

# Set global options and page configuration for Streamlit
st.set_option('deprecation.showPyplotGlobalUse', False)
st.set_page_config(layout="wide") # Set the layout of the page to wide mode

# Initialize session from Snowflake to perform database operations
session = get_active_session()

# Streamlit application title
st.title("Visualize your data! :brain:")

# Create DataFrame and retrieve column names
with st.sidebar:
    # SQL query to list databases and select one through a dropdown
    databases = session.sql("SHOW DATABASES in ACCOUNT").select('"name"')
    database = st.selectbox('Select Database:', databases)
    # SQL query to list schemas in the selected database and select one, excluding 'INFORMATION_SCHEMA'
    schemas = session.sql(f"SHOW SCHEMAS in DATABASE {database}").select('"name"').filter(F.col('"name"') != 'INFORMATION_SCHEMA')
    schema = st.selectbox('Select Schema:', schemas)
    # SQL query to list views in the selected schema and database, and select one through a dropdown
    views = session.sql(f"SHOW VIEWS in SCHEMA {database}.{schema}").select('"name"')
    table = st.selectbox('Select VIEW:', views)
    rows_to_plot = st.number_input('Rows to plot', min_value=1, max_value=10000, value=1000)

df = session.table(f'{database}.{schema}.{table}').limit(rows_to_plot).to_pandas()
column_specifications = [col_name for col_name in df.columns]

# Plot DataFrame
st.subheader('Data:')
st.dataframe(df.head())
    
# Defining the library & prompt
library = st.selectbox('Library', ['matplotlib','seaborn','plotly','wordcloud'])
ll_prompt = st.text_area('What do you want to visualize?')

# Function that extracts the actual Python code returned by mistral
def extract_python_code(text):
    # Regular expression pattern to extract content between triple backticks with 'python' as language identifier
    pattern = r"```python(.*?)```"

    # re.DOTALL allows the dot (.) to match newlines as well
    match = re.search(pattern, text, re.DOTALL)
    
    if match:
        # Return the matched group, stripping any leading or trailing whitespace
        return match.group(1).strip()
    else:
        return "No Python code found in the input string."

if st.button('Visualize'):
    user_prompt = f'You are a python developer that writes code using {library} and streamlit to visualize data. \
    Your data input is a pandas dataframe that you can access with df. \
    The pandas dataframe has the following columns: {column_specifications}.\
    {ll_prompt}\
    If you are asked to return a list, create a dataframe and use st.dataframe() to display the dataframe.'
    with st.spinner("Waiting for LLM"):
        code = Complete('mistral-large',user_prompt)
    execution_code = extract_python_code(code)
    col1, col2 = st.columns(2)
    with col1:
        try:
            st.subheader('This is the executed code:')
            st.code(execution_code, language="python", line_numbers=False)
        except:
            st.subheader("Please reformulate the question or choose other lib to plot it")
    with col2:
        try: 
            with st.spinner("Plotting ..."):
                exec(execution_code)
        except:
            st.subheader("Please reformulate the question or choose other lib to plot it")