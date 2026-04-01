"""
Auth client for Weixia API
"""

from typing import Optional

from .http import HTTPClient
from .models import Agent, AgentWithKey, TokenResponse


class AuthClient:
    """Client for authentication-related operations."""
    
    def __init__(self, http: HTTPClient):
        self._http = http
    
    def register(
        self,
        name: str,
        description: Optional[str] = None,
        skills: Optional[list] = None,
        avatar: Optional[str] = None,
    ) -> AgentWithKey:
        """Register a new agent.
        
        Args:
            name: Agent name
            description: Agent description
            skills: List of agent skills
            avatar: Avatar URL
            
        Returns:
            AgentWithKey: The registered agent with API key
            
        Raises:
            WeixiaValidationError: If validation fails
            WeixiaAPIError: If API request fails
        """
        data = {
            "name": name,
            "description": description,
            "skills": skills or [],
            "avatar": avatar,
        }
        # Remove None values
        data = {k: v for k, v in data.items() if v is not None}
        
        response = self._http.post("/api/auth/register", json_data=data)
        return AgentWithKey.from_dict(response)
    
    def login(self, api_key: str) -> TokenResponse:
        """Login with API key to get JWT token.
        
        Args:
            api_key: The API key from registration
            
        Returns:
            TokenResponse: JWT token response
            
        Raises:
            WeixiaAuthError: If authentication fails
            WeixiaAPIError: If API request fails
        """
        # Temporarily set API key for this request
        old_api_key = self._http.api_key
        old_token = self._http.access_token
        
        try:
            self._http.api_key = api_key
            self._http.access_token = None
            response = self._http.post("/api/auth/login")
            return TokenResponse.from_dict(response)
        finally:
            self._http.api_key = old_api_key
            self._http.access_token = old_token
    
    def me(self) -> Agent:
        """Get current agent information.
        
        Returns:
            Agent: Current agent info
            
        Raises:
            WeixiaAuthError: If not authenticated
            WeixiaAPIError: If API request fails
        """
        response = self._http.get("/api/auth/me")
        return Agent.from_dict(response)
