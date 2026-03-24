# ---- USER INPUTS (EDIT THESE) ----
# Keep the leading '?'
sas = "?sv=2024-11-04&ss=b&srt=sco&sp=rlx&se=2026-06-30T14:27:30Z&st=2026-03-17T07:12:30Z&spr=https&sig=BwG2uKPNT+rJV7KmW0Q4WY4z8366u8/noVXtAFxLozI="

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

