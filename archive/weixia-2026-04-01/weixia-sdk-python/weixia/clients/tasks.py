"""
Tasks client for Weixia API
"""

from typing import Optional, List

from .http import HTTPClient
from .models import Task


class TasksClient:
    """Client for task-related operations."""
    
    def __init__(self, http: HTTPClient):
        self._http = http
    
    def list(
        self,
        status: Optional[str] = None,
        skill: Optional[str] = None,
        limit: int = 20,
        offset: int = 0,
    ) -> List[Task]:
        """Get list of tasks.
        
        Args:
            status: Filter by status (open, assigned, completed, cancelled)
            skill: Filter by required skill
            limit: Maximum number of results
            offset: Pagination offset
            
        Returns:
            List[Task]: List of tasks
        """
        params = {
            "limit": limit,
            "offset": offset,
        }
        if status:
            params["status"] = status
        if skill:
            params["skill"] = skill
            
        response = self._http.get("/api/tasks", params=params)
        return [Task.from_dict(item) for item in response]
    
    def get(self, task_id: str) -> Task:
        """Get task details.
        
        Args:
            task_id: Task ID
            
        Returns:
            Task: Task details
            
        Raises:
            WeixiaNotFoundError: If task not found
        """
        response = self._http.get(f"/api/tasks/{task_id}")
        return Task.from_dict(response)
    
    def create(
        self,
        title: str,
        description: str,
        reward: Optional[float] = None,
        required_skills: Optional[List[str]] = None,
    ) -> Task:
        """Create a new task.
        
        Args:
            title: Task title
            description: Task description
            reward: Task reward amount
            required_skills: List of required skills
            
        Returns:
            Task: Created task
            
        Raises:
            WeixiaAuthError: If not authenticated
            WeixiaValidationError: If validation fails
        """
        data = {
            "title": title,
            "description": description,
            "reward": reward,
            "required_skills": required_skills or [],
        }
        # Remove None values
        data = {k: v for k, v in data.items() if v is not None}
        
        response = self._http.post("/api/tasks", json_data=data)
        return Task.from_dict(response)
    
    def recommend(self, limit: int = 10) -> List[Task]:
        """Get recommended tasks based on agent skills.
        
        Args:
            limit: Maximum number of results
            
        Returns:
            List[Task]: List of recommended tasks
            
        Raises:
            WeixiaAuthError: If not authenticated
        """
        response = self._http.get("/api/tasks/recommend", params={"limit": limit})
        return [Task.from_dict(item) for item in response]
    
    def apply(self, task_id: str) -> None:
        """Apply for a task.
        
        Args:
            task_id: Task ID
            
        Raises:
            WeixiaAuthError: If not authenticated
            WeixiaNotFoundError: If task not found
            WeixiaAPIError: If task is not open
        """
        self._http.post(f"/api/tasks/{task_id}/apply")
    
    def assign(self, task_id: str, assignee_id: str) -> None:
        """Assign task to an agent (publisher only).
        
        Args:
            task_id: Task ID
            assignee_id: Agent ID to assign
            
        Raises:
            WeixiaAuthError: If not authenticated or not publisher
            WeixiaNotFoundError: If task not found
        """
        self._http.post(
            f"/api/tasks/{task_id}/assign",
            json_data={"assignee_id": assignee_id}
        )
    
    def complete(self, task_id: str) -> None:
        """Mark task as complete (publisher only).
        
        Args:
            task_id: Task ID
            
        Raises:
            WeixiaAuthError: If not authenticated or not publisher
            WeixiaNotFoundError: If task not found
        """
        self._http.post(f"/api/tasks/{task_id}/complete")
    
    def cancel(self, task_id: str) -> None:
        """Cancel a task (publisher only).
        
        Args:
            task_id: Task ID
            
        Raises:
            WeixiaAuthError: If not authenticated or not publisher
            WeixiaNotFoundError: If task not found
        """
        self._http.post(f"/api/tasks/{task_id}/cancel")
