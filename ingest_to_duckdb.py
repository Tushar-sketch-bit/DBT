import dlt
import requests

# 1. Fetch the data from the API
def fetch_mock_users():
    url = "https://typicode.com"
    response = requests.get(url)
    response.raise_for_status()
    return response.json()

# 2. Configure the pipeline (credentials argument removed from here)
pipeline = dlt.pipeline(
    pipeline_name="local_api_pipeline",
    destination="duckdb",
    dataset_name="raw_staging"
)

# 3. Fire the ingestion and pass the file path as credentials here!
load_info = pipeline.run(
    fetch_mock_users(), 
    table_name="api_users",
    credentials="dev.duckdb"  # Moving it here fixes the TypeError
)

# 4. Print the log
print(load_info)


