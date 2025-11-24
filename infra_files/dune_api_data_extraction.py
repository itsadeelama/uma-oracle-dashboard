import requests
import time
import pandas as pd

DUNE_API_KEY = "ENTER KEY HERE"
QUERY_ID = 6246697

headers = {
    "x-dune-api-key": DUNE_API_KEY,
    "Content-Type": "application/json"
}

def run_query():
    url = f"https://api.dune.com/api/v1/query/{QUERY_ID}/execute"
    r = requests.post(url, headers=headers).json()
    return r["execution_id"]

def get_results(execution_id):
    url = f"https://api.dune.com/api/v1/execution/{execution_id}/results"
    while True:
        r = requests.get(url, headers=headers).json()
        state = r.get("state")
        if state == "QUERY_STATE_COMPLETED":
            return pd.DataFrame(r["result"]["rows"])
        if state in ["QUERY_STATE_FAILED", "QUERY_STATE_CANCELLED"]:
            raise Exception(f"Query failed: {state}")
        time.sleep(2)

exec_id = run_query()
df = get_results(exec_id)

df.to_csv("uma_oo_v3_results.csv", index=False)

print("Rows:", len(df))
print(df.head())
