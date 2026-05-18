import os
import sys
import requests
import json

# This script is a placeholder for actual ZenTao API integration
# You should set these secrets in Gitea Repo Settings > Actions > Secrets
ZENTAO_URL = os.getenv('ZENTAO_URL', 'http://192.168.0.165:80')
ZENTAO_TOKEN = os.getenv('ZENTAO_TOKEN')
REPO_NAME = os.getenv('GITEA_REPO_NAME', 'xuan-common')
JOB_NAME = os.getenv('GITEA_JOB_NAME', 'CI Pipeline')

def report_failure():
    print(f"Reporting failure for {REPO_NAME} to ZenTao...")
    # In a real scenario, you would call:
    # POST /api.php?m=bug&f=create&productID=1
    # For now, we simulate the logic:
    if not ZENTAO_TOKEN:
        print("Error: ZENTAO_TOKEN not set. Skipping real API call.")
        return

    payload = {
        "title": f"[CI FAILURE] {REPO_NAME} - {JOB_NAME}",
        "content": f"The CI pipeline failed. View details at: {os.getenv('GITEA_EXTERNAL_URL')}",
        "openedBuild": "trunk"
    }
    print(f"Would send to ZenTao: {json.dumps(payload)}")

if __name__ == "__main__":
    report_failure()
