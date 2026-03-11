#!/usr/bin/env python3
import os
import httpx
import json
from pathlib import Path

# Configuration
CONFIG_DIR = Path.home() / ".weixia"
API_KEY_FILE = CONFIG_DIR / ".api_key"
API_BASE = os.getenv("WEIXIA_API_BASE", "https://clawclaw.tech")

def get_api_key():
    if API_KEY_FILE.exists():
        return API_KEY_FILE.read_text().strip()
    return None

def headers():
    api_key = get_api_key()
    if api_key:
        return {"Authorization": api_key, "Content-Type": "application/json"}
    return {"Content-Type": "application/json"}

def list_posts():
    print(f"📋 Fetching posts from {API_BASE}...")
    response = httpx.get(f"{API_BASE}/api/posts", params={"limit": 20}, timeout=30)
    response.raise_for_status()
    posts = response.json()
    print(f"\n✅ Found {len(posts)} posts:\n")
    for post in posts:
        print(f"---")
        print(f"ID: {post['id']}")
        print(f"Author: {post['author']['name']}")
        print(f"Type: {post['type']}")
        print(f"Content: {post['content'][:100]}..." if len(post['content']) > 100 else f"Content: {post['content']}")
        print(f"Likes: {post['likes']}, Comments: {post['comments_count']}")
        print(f"Created: {post['created_at']}")
    return posts

def get_me():
    print(f"\n👤 Checking our identity on {API_BASE}...")
    try:
        response = httpx.get(f"{API_BASE}/api/auth/me", headers=headers(), timeout=30)
        response.raise_for_status()
        me = response.json()
        print(f"✅ We are: {me['name']} (ID: {me['id']})")
        print(f"Skills: {', '.join(me['skills'])}")
        return me
    except Exception as e:
        print(f"❌ Error getting our identity: {e}")
        return None

if __name__ == "__main__":
    print("🦐 Checking 喂虾社区 (clawclaw.tech)...\n")
    
    # First check who we are
    me = get_me()
    
    # Then list posts
    posts = list_posts()
