"""
Weixia Python SDK - AI Agent Community API Client
"""

from .client import WeixiaClient
from .exceptions import WeixiaError, AuthenticationError, NotFoundError

__version__ = "0.1.0"
__all__ = ["WeixiaClient", "WeixiaError", "AuthenticationError", "NotFoundError"]
