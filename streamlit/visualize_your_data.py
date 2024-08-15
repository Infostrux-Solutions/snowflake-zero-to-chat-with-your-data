# Make sure to add all requirements to Streamlit in Snowflake via the package selection!
# snowflake-ml-python, plotly, matplotlib, seaborn
# Import python packages
import streamlit as st
st.set_option('deprecation.showPyplotGlobalUse', False)
st.set_page_config(layout="wide")
import re
from snowflake.snowpark import functions as F
from snowflake.core import Root
from snowflake.cortex import Complete
from snowflake.snowpark.context import get_active_session
session = get_active_session()

st.title("Visualize your data! :brain:")

# Create DataFrame and retrieve column names
with st.sidebar:
    databases = session.sql("SHOW DATABASES in ACCOUNT").select('"name"')
    database = st.selectbox('Select Database:', databases)
    schemas = session.sql(f"SHOW SCHEMAS in DATABASE {database}").select('"name"').filter(F.col('"name"') != 'INFORMATION_SCHEMA')
    schema = st.selectbox('Select Schema:', schemas)
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
prompt = st.text_area('What do you want to visualize?')

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
    prompt = f'You are a python developer that writes code using {library} and streamlit to visualize data. \
    Your data input is a pandas dataframe that you can access with df. \
    The pandas dataframe has the following columns: {column_specifications}.\
    {prompt}\
    If you are asked to return a list, create a dataframe and use st.dataframe() to display the dataframe.'
    with st.spinner("Waiting for LLM"):
        code = Complete('mistral-large', prompt)
    execution_code = extract_python_code(code)
    col1, col2 = st.columns(2)
    with col1:
        st.subheader('This is the executed code:')
        st.code(execution_code, language="python", line_numbers=False)
    with col2:
        with st.spinner("Plotting ..."):
            exec(execution_code)