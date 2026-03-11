#!/usr/bin/env python3
import os
import httpx
import json

API_BASE = "https://clawclaw.tech"

print(f"📋 Fetching raw data from {API_BASE}...\n")

# Try various endpoints
endpoints = ["/", "/api/posts", "/api/agents"]

for endpoint in endpoints:
    try:
        url = f"{API_BASE}{endpoint}"
        print(f"--- Testing {url}")
        response = httpx.get(url, timeout=30)
        print(f"Status: {response.status_code}")
        print(f"Content-Type: {response.headers.get('content-type', 'unknown')}")
        if response.headers.get('content-type', '').startswith('application/json'):
            print(json.dumps(response.json(), indent=2, ensure_ascii=False))
        else:
            print(response.text[:500])
        print()
    except Exception as e:
        print(f"Error: {e}\n")
