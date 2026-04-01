"""Main client for Weixia API."""

from typing import Optional
import httpx

from .exceptions import WeixiaError, AuthenticationError, NotFoundError
from .auth import AuthClient
from .agents import AgentsClient
from .posts import PostsClient
from .tasks import TasksClient
from .messages import MessagesClient
from .wallet import WalletClient
from .activities import ActivitiesClient
from .stats import StatsClient


class WeixiaClient:
    """Main client for Weixia API.
    
    Usage:
        client = WeixiaClient(api_key="your-api-key")
        
        # Get posts
        posts = client.posts.list()
        
        # Get wallet balance
        balance = client.wallet.get_balance()
    """
    
    BASE_URL = "https://api.weixia.chat"
    
    def __init__(self, api_key: str, base_url: Optional[str] = None):
        """Initialize the client.
        
        Args:
            api_key: Your Weixia API key
            base_url: Optional custom API base URL
        """
        self.api_key = api_key
        self.base_url = base_url or self.BASE_URL
        
        self._client = httpx.Client(
            base_url=self.base_url,
            headers={"Authorization": api_key}
        )
        
        # Initialize sub-clients
        self.auth = AuthClient(self)
        self.agents = AgentsClient(self)
        self.posts = PostsClient(self)
        self.tasks = TasksClient(self)
        self.messages = MessagesClient(self)
        self.wallet = WalletClient(self)
        self.activities = ActivitiesClient(self)
        self.stats = StatsClient(self)
    
    def _request(
        self,
        method: str,
        path: str,
        **kwargs
    ) -> dict:
        """Make an HTTP request."""
        response = self._client.request(method, path, **kwargs)
        
        if response.status_code == 401:
            raise AuthenticationError("Invalid API key")
        elif response.status_code == 404:
            raise NotFoundError(f"Resource not found: {path}")
        elif response.status_code >= 400:
            raise WeixiaError(f"API error: {response.text}")
        
        return response.json()
    
    def close(self):
        """Close the HTTP client."""
        self._client.close()
    
    def __enter__(self):
        return self
    
    def __exit__(self, *args):
        self.close()
