import pandas as pd
import plotly.express as px
import streamlit as st

url = "https://docs.google.com/spreadsheets/d/1dP5N30A0kqHuMq4Mb1lFitUD4ZpmIO9Mu1FyjUJfDLY/gviz/tq?tqx=out:csv"
df = pd.read_csv(url)

df.columns = df.columns.str.strip()  # Clean up column names
df['FY24 All'] = df['FY24 All'].replace(',', '', regex=True).astype(int)
df['FY24 change'] = df['FY24 change'].replace(',', '', regex=True).astype(int)

# Streamlit App Layout
st.title("PBS Dashboard")

# Slicers (Filters)
st.sidebar.header("Filters")
medication_type = st.sidebar.selectbox("Select Medication Type:", ["All"] + list(df['Medication_Type'].unique()))
gccsa_name = st.sidebar.selectbox("Select GCCSA Name:", ["All"] + list(df['GCCSA_NAME_2021'].unique()))
state = st.sidebar.selectbox("Select State:", ["All"] + list(df['State'].unique()))
lga_name = st.sidebar.selectbox("Select LGA:", ["All"] + list(df['LGA_Name'].unique()))

# Filter data based on selections
filtered_df = df.copy()
if medication_type != "All":
    filtered_df = filtered_df[filtered_df['Medication_Type'] == medication_type]
if gccsa_name != "All":
    filtered_df = filtered_df[filtered_df['GCCSA_NAME_2021'] == gccsa_name]
if state != "All":
    filtered_df = filtered_df[filtered_df['State'] == state]
if lga_name != "All":
    filtered_df = filtered_df[filtered_df['LGA_Name'] == lga_name]

# Create plots
def create_bar_chart(data, x, y, title):
    """Helper function to create bar charts with custom styling."""
    fig = px.bar(
        data, x=x, y=y, title=title, text=y,
        color_discrete_sequence=["#000035"]
    )
    fig.update_traces(marker=dict(line=dict(width=0.5, color='rgba(0,0,0,0.5)')))
    fig.update_layout(
        xaxis_title=x, yaxis_title=y,
        font=dict(size=10), plot_bgcolor='white', paper_bgcolor='white',
        showlegend=False
    )
    return fig

# Total PBS Scripts by GCCSA
data1 = filtered_df.groupby('GCCSA_NAME_2021')['FY24 All'].sum().reset_index().sort_values(by='FY24 All', ascending=False)
fig1 = create_bar_chart(data1, x='GCCSA_NAME_2021', y='FY24 All', title="Total PBS Scripts by GCCSA")

# Change in PBS Scripts by GCCSA
data2 = filtered_df.groupby('GCCSA_NAME_2021')['FY24 change'].sum().reset_index().sort_values(by='FY24 change', ascending=False)
fig2 = create_bar_chart(data2, x='GCCSA_NAME_2021', y='FY24 change', title="Change in PBS Scripts by GCCSA")

# Display GCCSA charts side by side
col1, col2 = st.columns(2)
col1.plotly_chart(fig1, use_container_width=True)
col2.plotly_chart(fig2, use_container_width=True)

# Total PBS Scripts by Medication Type
data3 = filtered_df.groupby('Medication_Type')['FY24 All'].sum().reset_index().sort_values(by='FY24 All', ascending=False)
fig3 = create_bar_chart(data3, x='Medication_Type', y='FY24 All', title="Total PBS Scripts by Medication Type")

# Change in PBS Scripts by Medication Type
data4 = filtered_df.groupby('Medication_Type')['FY24 change'].sum().reset_index().sort_values(by='FY24 change', ascending=False)
fig4 = create_bar_chart(data4, x='Medication_Type', y='FY24 change', title="Change in PBS Scripts by Medication Type")

# Display Medication Type charts side by side
col3, col4 = st.columns(2)
col3.plotly_chart(fig3, use_container_width=True)
col4.plotly_chart(fig4, use_container_width=True)

# Total PBS Scripts by LGA
data5 = filtered_df.groupby('LGA_Name')['FY24 All'].sum().reset_index().sort_values(by='FY24 All', ascending=False)
fig5 = create_bar_chart(data5, x='LGA_Name', y='FY24 All', title="Total PBS Scripts by LGA")

# Change in PBS Scripts by LGA
data6 = filtered_df.groupby('LGA_Name')['FY24 change'].sum().reset_index().sort_values(by='FY24 change', ascending=False)
fig6 = create_bar_chart(data6, x='LGA_Name', y='FY24 change', title="Change in PBS Scripts by LGA")

# Display LGA charts in full width
st.plotly_chart(fig5, use_container_width=True)
st.plotly_chart(fig6, use_container_width=True)
