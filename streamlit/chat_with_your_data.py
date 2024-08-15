import streamlit as st # Import python packages
from snowflake.snowpark.context import get_active_session
session = get_active_session() # Get the current credentials

import pandas as pd
import re

pd.set_option("max_colwidth",None)

### Default Values
#model_name = 'mistral-7b' #Default but we allow user to select one
num_chunks = 3 # Num-chunks provided as context. Play with this to check how it affects your accuracy
slide_window = 7 # how many last conversations to remember. This is the slide window.
#debug = 1 #Set this to 1 if you want to see what is the text created as summary and sent to get chunks
#use_chat_history = 0 #Use the chat history by default

### Functions

def main():

    st.title(f":speech_balloon: Chat Document Assistant with Snowflake Cortex")
    st.write("This is the list of documents you already have and that will be used to answer your questions:")
    # docs_available = session.sql("ls @docs").collect()
    # list_docs = []
    # for doc in docs_available:
    #     list_docs.append(doc["name"])
    # st.dataframe(list_docs)

    config_options()
    init_messages()

    # Display chat messages from history on app rerun
    for message in st.session_state.messages:
        if message["role"] == "system":
            continue
        with st.chat_message(message["role"]):
            st.markdown(message["content"])
            if "results" in message:
                st.dataframe(message["results"])

    # Accept user input
    if question := st.chat_input("What do you want to know about your products?"):
        # Add user message to chat history
        st.session_state.messages.append({"role": "user", "content": question})
        # Display user message in chat message container
        with st.chat_message("user"):
            st.markdown(question)
        # Display assistant response in chat message container
        with st.chat_message("assistant"):
            message_placeholder = st.empty()

            question = question.replace("'","")

            with st.spinner(f"{st.session_state.model_name} thinking..."):
                response = complete(question)
                res_text = response[0].RESPONSE

                # st.markdown(response)

                # res_text = res_text.replace("'", "")
                message_placeholder.markdown(res_text)

                message = {"role": "assistant", "content": response}
                # Parse the response for a SQL query and execute if available
                sql_match = re.search(r"```sql\n(.*)\n```", res_text.replace(";", ""), re.DOTALL)
                if sql_match:
                    sql = sql_match.group(1)
                    conn = st.connection("snowflake")
                    message["results"] = session.sql(sql)
                    st.dataframe(message["results"])
                st.session_state.messages.append(message)
                st.session_state.messages.append({"role": "assistant", "content": res_text})


def config_options():
    st.sidebar.selectbox('Select your model:',(
        'mixtral-8x7b',
        'snowflake-arctic',
        'mistral-large',
        'llama3-8b',
        'llama3-70b',
        'reka-flash',
        'mistral-7b',
        'llama2-70b-chat',
        'gemma-7b'), key="model_name")

    # For educational purposes. Users can chech the difference when using memory or not
    st.sidebar.checkbox('Do you want that I remember the chat history?', key="use_chat_history", value = True)

    st.sidebar.checkbox('Debug: Click to see summary generated of previous conversation', key="debug", value = True)
    st.sidebar.button("Start Over", key="clear_conversation")
    st.sidebar.expander("Session State").write(st.session_state)


def init_messages():

    # Initialize chat history
    if st.session_state.clear_conversation or "messages" not in st.session_state:
        # st.session_state.messages = []
        st.session_state.messages = [{"role": "system", "content": get_system_prompt()}]


# def get_similar_chunks (question):

#     cmd = """
#         with results as
#         (SELECT RELATIVE_PATH,
#            VECTOR_COSINE_SIMILARITY(docs_chunks_table.chunk_vec,
#                     SNOWFLAKE.CORTEX.EMBED_TEXT_768('e5-base-v2', ?)) as similarity,
#            chunk
#         from docs_chunks_table
#         order by similarity desc
#         limit ?)
#         select chunk, relative_path from results
#     """

#     df_chunks = session.sql(cmd, params=[question, num_chunks]).to_pandas()

#     df_chunks_lenght = len(df_chunks) -1

#     similar_chunks = ""
#     for i in range (0, df_chunks_lenght):
#         similar_chunks += df_chunks._get_value(i, 'CHUNK')

#     similar_chunks = similar_chunks.replace("'", "")

#     return similar_chunks


def get_chat_history():
    #Get the history from the st.session_stage.messages according to the slide window parameter

    chat_history = []

    start_index = max(0, len(st.session_state.messages) - slide_window)
    for i in range (start_index , len(st.session_state.messages) -1):
        chat_history.append(st.session_state.messages[i])

    return chat_history


def summarize_question_with_history(chat_history, question):
    # To get the right context, use the LLM to first summarize the previous conversation
    # This will be used to get embeddings and find similar chunks in the docs for context

    prompt = f"""
        Based on the chat history below and the question, generate a query that extend the question
        with the chat history provided. The query should be in natual language. 
        Answer with only the query. Do not add any explanation.
        
        <chat_history>
        {chat_history}
        </chat_history>
        <question>
        {question}
        </question>
        """

    cmd = """
            select snowflake.cortex.complete(?, ?) as response
          """
    df_response = session.sql(cmd, params=[st.session_state.model_name, prompt]).collect()
    sumary = df_response[0].RESPONSE

    if st.session_state.debug:
        st.sidebar.text("Summary to be used to find similar chunks in the docs:")
        st.sidebar.caption(sumary)

    sumary = sumary.replace("'", "")

    return sumary

def create_prompt (myquestion):

    if st.session_state.use_chat_history:
        chat_history = get_chat_history()

        if chat_history != []: #There is chat_history, so not first question
            question_summary = summarize_question_with_history(chat_history, myquestion)
            # prompt_context =  get_similar_chunks(question_summary)
        # else:
        # prompt_context = get_similar_chunks(myquestion) #First question when using history
    else:
        # prompt_context = get_similar_chunks(myquestion)
        chat_history = ""

    # prompt = f"""
    #        You are an expert chat assistance that extracs information from the CONTEXT provided
    #        between <context> and </context> tags.
    #        You offer a chat experience considering the information included in the CHAT HISTORY
    #        provided between <chat_history> and </chat_history> tags..
    #        When ansering the question contained between <question> and </question> tags
    #        be concise and do not hallucinate.
    #        If you don´t have the information just say so.

    #        Do not mention the CONTEXT used in your answer.
    #        Do not mention the CHAT HISTORY used in your asnwer.

    #        <chat_history>
    #        {chat_history}
    #        </chat_history>
    #        <context>
    #        {prompt_context}
    #        </context>
    #        <question>
    #        {myquestion}
    #        </question>
    #        Answer:
    #        """

    # @TODO: Leverage the <context> reference below
    prompt = f"""
           You are an expert chat assistance that extracs information from the CONTEXT provided
           between <context> and </context> tags.
           You offer a chat experience considering the information included in the CHAT HISTORY
           provided between <chat_history> and </chat_history> tags..
           When ansering the question contained between <question> and </question> tags
           be concise and do not hallucinate. 
           If you don´t have the information just say so.
           
           Do not mention the CONTEXT used in your answer.
           Do not mention the CHAT HISTORY used in your asnwer.
           
           <chat_history>
           {chat_history}
           </chat_history>
           <question>  
           {myquestion}
           </question>
           Answer: 
           """

    return prompt


def complete(myquestion):

    prompt =create_prompt (myquestion)
    cmd = """
            select snowflake.cortex.complete(?, ?) as response
          """

    df_response = session.sql(cmd, params=[st.session_state.model_name, prompt]).collect()
    return df_response

SCHEMA_PATH = 'CHAT_WITH_YOUR_DATA.WORKSPACE_0'
QUALIFIED_TABLE_NAME = f"{SCHEMA_PATH}.FINANCIAL_ENTITY_ANNUAL_TIME_SERIES"
TABLE_DESCRIPTION = """
This table has various metrics for financial entities (also referred to as banks) since 1983.
The user may describe the entities interchangeably as banks, financial institutions, or financial entities.
"""
# This query is optional if running Frosty on your own table, especially a wide table.
# Since this is a deep table, it's useful to tell Frosty what variables are available.
# Similarly, if you have a table with semi-structured data (like JSON), it could be used to provide hints on available keys.
# If altering, you may also need to modify the formatting logic in get_table_context() below.
METADATA_QUERY = f"SELECT VARIABLE_NAME, DEFINITION FROM {SCHEMA_PATH}.FINANCIAL_ENTITY_ATTRIBUTES_LIMITED;"

GEN_SQL = """
You will be acting as an AI Snowflake SQL Expert named Frosty.
Your goal is to give correct, executable sql query to users.
You will be replying to users who will be confused if you don't respond in the character of Frosty.
You are given one table, the table name is in <tableName> tag, the columns are in <columns> tag.
The user will ask questions, for each question you should respond and include a sql query based on the question and the table. 

{context}

Here are 6 critical rules for the interaction you must abide:
<rules>
1. You MUST MUST wrap the generated sql code within ``` sql code markdown in this format e.g
```sql
(select 1) union (select 2)
```
2. If I don't tell you to find a limited set of results in the sql query or question, you MUST limit the number of responses to 10.
3. Text / string where clauses must be fuzzy match e.g ilike %keyword%
4. Make sure to generate a single snowflake sql code, not multiple. 
5. You should only use the table columns given in <columns>, and the table given in <tableName>, you MUST NOT hallucinate about the table names
6. DO NOT put numerical at the very front of sql variable.
</rules>

Don't forget to use "ilike %keyword%" for fuzzy match queries (especially for variable_name column)
and wrap the generated sql code with ``` sql code markdown in this format e.g:
```sql
(select 1) union (select 2)
```

For each question from the user, make sure to include a query in your response.

Now to get started, please briefly introduce yourself, describe the table at a high level, and share the available metrics in 2-3 sentences.
Then provide 3 example questions using bullet points.
"""

@st.cache_data(show_spinner="Loading Frosty's context...")
def get_table_context(table_name: str, table_description: str, metadata_query: str = None):
    table = table_name.split(".")
    columns = session.sql(f"""
        SELECT COLUMN_NAME, DATA_TYPE FROM {table[0].upper()}.INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = '{table[1].upper()}' AND TABLE_NAME = '{table[2].upper()}'
        """).to_pandas()
    columns = "\n".join(
        [
            f"- **{columns['COLUMN_NAME'][i]}**: {columns['DATA_TYPE'][i]}"
            for i in range(len(columns["COLUMN_NAME"]))
        ]
    )
    context = f"""
Here is the table name <tableName> {'.'.join(table)} </tableName>

<tableDescription>{table_description}</tableDescription>

Here are the columns of the {'.'.join(table)}

<columns>\n\n{columns}\n\n</columns>
    """
    if metadata_query:
        metadata = session.sql(metadata_query).to_pandas()
        metadata = "\n".join(
            [
                f"- **{metadata['VARIABLE_NAME'][i]}**: {metadata['DEFINITION'][i]}"
                for i in range(len(metadata["VARIABLE_NAME"]))
            ]
        )
        context = context + f"\n\nAvailable variables by VARIABLE_NAME:\n\n{metadata}"
    return context

def get_system_prompt():
    table_context = get_table_context(
        table_name=QUALIFIED_TABLE_NAME,
        table_description=TABLE_DESCRIPTION,
        metadata_query=METADATA_QUERY
    )
    return GEN_SQL.format(context=table_context)

if __name__ == "__main__":
    main()
