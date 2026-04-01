"""
HTTP client for Weixia API
"""

from typing import Optional, Dict, Any, TypeVar, Type
import httpx

from .exceptions import (
    WeixiaAPIError,
    WeixiaAuthError,
    WeixiaValidationError,
    WeixiaNotFoundError,
    WeixiaRateLimitError,
)

T = TypeVar("T")

DEFAULT_BASE_URL = "https://api.weixia.chat"
DEFAULT_TIMEOUT = 30.0


class HTTPClient:
    """HTTP client for making API requests."""
    
    def __init__(
        self,
        base_url: str = DEFAULT_BASE_URL,
        timeout: float = DEFAULT_TIMEOUT,
        api_key: Optional[str] = None,
        access_token: Optional[str] = None,
    ):
        self.base_url = base_url.rstrip("/")
        self.timeout = timeout
        self.api_key = api_key
        self.access_token = access_token
        self._client: Optional[httpx.Client] = None
    
    @property
    def client(self) -> httpx.Client:
        """Get or create httpx client."""
        if self._client is None:
            self._client = httpx.Client(timeout=self.timeout)
        return self._client
    
    def _get_headers(self) -> Dict[str, str]:
        """Build request headers."""
        headers = {
            "Content-Type": "application/json",
            "Accept": "application/json",
        }
        
        if self.access_token:
            headers["Authorization"] = f"Bearer {self.access_token}"
        elif self.api_key:
            headers["X-API-Key"] = self.api_key
            
        return headers
    
    def _handle_error(self, response: httpx.Response) -> None:
        """Handle error responses."""
        try:
            data = response.json()
        except Exception:
            data = None
        
        if response.status_code == 401 or response.status_code == 403:
            raise WeixiaAuthError(
                message=data.get("detail", "Authentication failed") if data else "Authentication failed",
                status_code=response.status_code,
                response=data,
            )
        elif response.status_code == 404:
            raise WeixiaNotFoundError(
                message=data.get("detail", "Resource not found") if data else "Resource not found",
                response=data,
            )
        elif response.status_code == 422:
            raise WeixiaValidationError(
                message=data.get("detail", "Validation error") if data else "Validation error",
                status_code=422,
                response=data,
                errors=data.get("detail") if isinstance(data.get("detail"), list) else None,
            )
        elif response.status_code == 429:
            retry_after = response.headers.get("Retry-After")
            raise WeixiaRateLimitError(
                message=data.get("detail", "Rate limit exceeded") if data else "Rate limit exceeded",
                response=data,
                retry_after=int(retry_after) if retry_after else None,
            )
        else:
            raise WeixiaAPIError(
                message=data.get("detail", f"API error: {response.status_code}") if data else f"API error: {response.status_code}",
                status_code=response.status_code,
                response=data,
            )
    
    def request(
        self,
        method: str,
        path: str,
        params: Optional[Dict[str, Any]] = None,
        json_data: Optional[Dict[str, Any]] = None,
    ) -> Dict[str, Any]:
        """Make an HTTP request."""
        url = f"{self.base_url}{path}"
        headers = self._get_headers()
        
        response = self.client.request(
            method=method,
            url=url,
            headers=headers,
            params=params,
            json=json_data,
        )
        
        if response.status_code >= 400:
            self._handle_error(response)
        
        # Handle empty responses
        if response.status_code == 204 or not response.content:
            return {}
        
        return response.json()
    
    def get(
        self,
        path: str,
        params: Optional[Dict[str, Any]] = None,
    ) -> Dict[str, Any]:
        """Make a GET request."""
        return self.request("GET", path, params=params)
    
    def post(
        self,
        path: str,
        json_data: Optional[Dict[str, Any]] = None,
        params: Optional[Dict[str, Any]] = None,
    ) -> Dict[str, Any]:
        """Make a POST request."""
        return self.request("POST", path, params=params, json_data=json_data)
    
    def put(
        self,
        path: str,
        json_data: Optional[Dict[str, Any]] = None,
    ) -> Dict[str, Any]:
        """Make a PUT request."""
        return self.request("PUT", path, json_data=json_data)
    
    def delete(
        self,
        path: str,
    ) -> Dict[str, Any]:
        """Make a DELETE request."""
        return self.request("DELETE", path)
    
    def close(self) -> None:
        """Close the HTTP client."""
        if self._client:
            self._client.close()
            self._client = None
    
    def __enter__(self) -> "HTTPClient":
        return self
    
    def __exit__(self, *args) -> None:
        self.close()
