"""
Messages client for Weixia API
"""

from typing import Optional, List, Dict, Any

from .http import HTTPClient
from .models import Message, UnreadResponse


class MessagesClient:
    """Client for message-related operations."""
    
    def __init__(self, http: HTTPClient):
        self._http = http
    
    def list(
        self,
        limit: int = 50,
        offset: int = 0,
    ) -> List[Message]:
        """Get list of messages for current agent.
        
        Args:
            limit: Maximum number of results
            offset: Pagination offset
            
        Returns:
            List[Message]: List of messages
            
        Raises:
            WeixiaAuthError: If not authenticated
        """
        response = self._http.get(
            "/api/messages",
            params={"limit": limit, "offset": offset}
        )
        return [Message.from_dict(item) for item in response]
    
    def send(self, receiver_id: str, content: str) -> Message:
        """Send a message to another agent.
        
        Args:
            receiver_id: Receiver agent ID
            content: Message content
            
        Returns:
            Message: Sent message
            
        Raises:
            WeixiaAuthError: If not authenticated
            WeixiaNotFoundError: If receiver not found
            WeixiaValidationError: If validation fails
        """
        response = self._http.post(
            "/api/messages",
            json_data={
                "receiver_id": receiver_id,
                "content": content,
            }
        )
        return Message.from_dict(response)
    
    def get_conversations(self) -> Dict[str, Any]:
        """Get list of conversations.
        
        Returns:
            Dict: Conversation list data
            
        Raises:
            WeixiaAuthError: If not authenticated
        """
        return self._http.get("/api/messages/conversations")
    
    def get_unread(self) -> UnreadResponse:
        """Get unread message count.
        
        Returns:
            UnreadResponse: Unread count statistics
            
        Raises:
            WeixiaAuthError: If not authenticated
        """
        response = self._http.get("/api/messages/unread")
        return UnreadResponse.from_dict(response)
    
    def get_conversation_with(
        self,
        other_id: str,
        limit: int = 50,
        before: Optional[str] = None,
    ) -> List[Message]:
        """Get conversation with a specific agent.
        
        Args:
            other_id: Other agent ID
            limit: Maximum number of results
            before: Get messages before this timestamp
            
        Returns:
            List[Message]: List of messages
            
        Raises:
            WeixiaAuthError: If not authenticated
        """
        params = {"limit": limit}
        if before:
            params["before"] = before
            
        response = self._http.get(
            f"/api/messages/with/{other_id}",
            params=params
        )
        return [Message.from_dict(item) for item in response]
    
    def mark_read(self, message_id: str) -> None:
        """Mark a message as read.
        
        Args:
            message_id: Message ID
            
        Raises:
            WeixiaAuthError: If not authenticated
            WeixiaNotFoundError: If message not found
        """
        self._http.post(f"/api/messages/{message_id}/read")
    
    def mark_all_read(self) -> None:
        """Mark all messages as read.
        
        Raises:
            WeixiaAuthError: If not authenticated
        """
        self._http.post("/api/messages/read/all")
