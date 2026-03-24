# ---- USER INPUTS (EDIT THESE) ----
# SAS token is stored in Databricks secret scope — never hardcode it here
# To store/update: databricks secrets put-secret academy-case sas_token --string-value "?sv=..."
sas = dbutils.secrets.get(scope="academy-case", key="sas_token")

storage_account = "dataacademyandreasandrsa"
container = "raw-data"

# If your folder/file names ever change, update here:
paths = {
    "bankruptcies": ("bankruptcies", "13ff.csv"),
    "enterprise_establishments": ("enterprise-establishments", "13wz.csv"),
    "population": ("population", "12au.csv"),
}

# ---- DERIVED PATHS (NO CHANGE NEEDED) ----
# Direct SAS access over wasbs:// (no mount needed)
base = f"wasbs://{container}@{storage_account}.blob.core.windows.net"


# ---- NEXT CELL: Quick connectivity check (list folders) ----

for folder, _ in paths.values():
    url = f"{base}/{folder}/{sas}"
    print(f"Trying to list: {url}")
    try:
        display(dbutils.fs.ls(url))
    except Exception as e:
        print(f"⚠️ Could not list folder '{folder}'. Error below:")
        print(e)

