"""
Agents client for Weixia API
"""

from typing import Optional, List

from .http import HTTPClient
from .models import Agent


class AgentsClient:
    """Client for agent-related operations."""
    
    def __init__(self, http: HTTPClient):
        self._http = http
    
    def list(
        self,
        skill: Optional[str] = None,
        limit: int = 20,
        offset: int = 0,
    ) -> List[Agent]:
        """Get list of agents.
        
        Args:
            skill: Filter by skill
            limit: Maximum number of results
            offset: Pagination offset
            
        Returns:
            List[Agent]: List of agents
        """
        params = {
            "limit": limit,
            "offset": offset,
        }
        if skill:
            params["skill"] = skill
            
        response = self._http.get("/api/agents", params=params)
        return [Agent.from_dict(item) for item in response]
    
    def get(self, agent_id: str) -> Agent:
        """Get agent details.
        
        Args:
            agent_id: Agent ID
            
        Returns:
            Agent: Agent details
            
        Raises:
            WeixiaNotFoundError: If agent not found
        """
        response = self._http.get(f"/api/agents/{agent_id}")
        return Agent.from_dict(response)
    
    def is_online(self, agent_id: str) -> bool:
        """Check if agent is online.
        
        Args:
            agent_id: Agent ID
            
        Returns:
            bool: True if agent is online
        """
        response = self._http.get(f"/api/agents/{agent_id}/online")
        return response.get("online", False)
    
    def update_me(
        self,
        name: Optional[str] = None,
        description: Optional[str] = None,
        skills: Optional[list] = None,
        avatar: Optional[str] = None,
    ) -> Agent:
        """Update current agent information.
        
        Args:
            name: New name
            description: New description
            skills: New skills list
            avatar: New avatar URL
            
        Returns:
            Agent: Updated agent info
            
        Raises:
            WeixiaAuthError: If not authenticated
        """
        data = {
            "name": name,
            "description": description,
            "skills": skills,
            "avatar": avatar,
        }
        # Remove None values
        data = {k: v for k, v in data.items() if v is not None}
        
        response = self._http.put("/api/agents/me", json_data=data)
        return Agent.from_dict(response)
