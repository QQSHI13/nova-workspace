"""
Posts client for Weixia API
"""

from typing import Optional, List

from .http import HTTPClient
from .models import Post, Comment


class PostsClient:
    """Client for post-related operations."""
    
    def __init__(self, http: HTTPClient):
        self._http = http
    
    def list(
        self,
        post_type: Optional[str] = None,
        tag: Optional[str] = None,
        limit: int = 20,
        offset: int = 0,
    ) -> List[Post]:
        """Get list of posts.
        
        Args:
            post_type: Filter by post type
            tag: Filter by tag
            limit: Maximum number of results
            offset: Pagination offset
            
        Returns:
            List[Post]: List of posts
        """
        params = {
            "limit": limit,
            "offset": offset,
        }
        if post_type:
            params["type"] = post_type
        if tag:
            params["tag"] = tag
            
        response = self._http.get("/api/posts", params=params)
        return [Post.from_dict(item) for item in response]
    
    def get(self, post_id: str) -> Post:
        """Get post details.
        
        Args:
            post_id: Post ID
            
        Returns:
            Post: Post details
            
        Raises:
            WeixiaNotFoundError: If post not found
        """
        response = self._http.get(f"/api/posts/{post_id}")
        return Post.from_dict(response)
    
    def create(
        self,
        title: str,
        content: str,
        post_type: Optional[str] = None,
        tags: Optional[List[str]] = None,
    ) -> Post:
        """Create a new post.
        
        Args:
            title: Post title
            content: Post content
            post_type: Post type
            tags: List of tags
            
        Returns:
            Post: Created post
            
        Raises:
            WeixiaAuthError: If not authenticated
            WeixiaValidationError: If validation fails
        """
        data = {
            "title": title,
            "content": content,
            "type": post_type,
            "tags": tags or [],
        }
        # Remove None values
        data = {k: v for k, v in data.items() if v is not None}
        
        response = self._http.post("/api/posts", json_data=data)
        return Post.from_dict(response)
    
    def like(self, post_id: str) -> None:
        """Like a post.
        
        Args:
            post_id: Post ID
            
        Raises:
            WeixiaAuthError: If not authenticated
            WeixiaNotFoundError: If post not found
        """
        self._http.post(f"/api/posts/{post_id}/like")
    
    def comment(self, post_id: str, content: str) -> Comment:
        """Comment on a post.
        
        Args:
            post_id: Post ID
            content: Comment content
            
        Returns:
            Comment: Created comment
            
        Raises:
            WeixiaAuthError: If not authenticated
            WeixiaNotFoundError: If post not found
            WeixiaValidationError: If validation fails
        """
        response = self._http.post(
            f"/api/posts/{post_id}/comment",
            json_data={"content": content}
        )
        return Comment.from_dict(response)
    
    def get_comments(
        self,
        post_id: str,
        limit: int = 20,
        offset: int = 0,
    ) -> List[Comment]:
        """Get comments on a post.
        
        Args:
            post_id: Post ID
            limit: Maximum number of results
            offset: Pagination offset
            
        Returns:
            List[Comment]: List of comments
            
        Raises:
            WeixiaNotFoundError: If post not found
        """
        response = self._http.get(
            f"/api/posts/{post_id}/comments",
            params={"limit": limit, "offset": offset}
        )
        return [Comment.from_dict(item) for item in response]
