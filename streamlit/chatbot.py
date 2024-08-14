# Tom Christian's original code https://medium.com/snowflake/pick-your-fighter-easy-model-comparisons-with-streamlit-cortex-244530a2d3bf

# Import python packages
import streamlit as st
from snowflake.snowpark.context import get_active_session


# Write directly to the app
st.set_page_config(layout="wide")
st.title("Cortex Data Chatbot")
st.write("""[docs.streamlit.io](https://docs.streamlit.io)""")

# Get the current credentials
session = get_active_session()

@st.cache_data #don't issue a new query if nothing else changes
def cortex_query(model, prompt, temp):
    prompt = prompt.replace("'","\\'") #account for pesky quotes

    q = """SELECT SNOWFLAKE.CORTEX.COMPLETE('%s',
    [{'role': 'user',
    'content': '%s'}],
    {'temperature': %d}) as resp,
    TRIM(GET(resp:choices,0):messages,'" ') as response,
    resp:usage:total_tokens::string as total_tokens
    ;""" % (model, prompt, temp)

    exc_q = session.sql(q).to_pandas()
    return exc_q

form = st.form("prompt_compare")

prompt = form.text_area("Enter your prompt:")
submitted = form.form_submit_button("Submit")

col1, col2, spc, col3, col4 = st.columns([2,2, 1, 2,2])

model1 = col1.selectbox("Select the first model:",("mistral-large","reka-flash","mixtral-8x7b","mistral-7b","Gemma-7b","llama2-70b-chat"))
temp1 = col2.slider("Select temp:",0.0,1.0,0.2)

model2 = col3.selectbox("Select the second model:",("reka-flash","mistral-large","mixtral-8x7b","mistral-7b","Gemma-7b","llama2-70b-chat"))
temp2 = col4.slider("Select temp:",0.0,1.0,0.3)

chat1,spc2,chat2 = st.columns([4,1,4])

with chat1:
    if submitted:
        with st.chat_message("1"):
            reply1 = cortex_query(model1,prompt,temp1)
            st.markdown(reply1['RESPONSE'][0])
            st.info('Total tokens: ' + reply1['TOTAL_TOKENS'][0])

with chat2:
    if submitted:
        with st.chat_message("2"):
            reply2 = cortex_query(model2,prompt,temp2)
            st.write(reply2['RESPONSE'][0])
            st.info('Total tokens: ' + reply2['TOTAL_TOKENS'][0])
