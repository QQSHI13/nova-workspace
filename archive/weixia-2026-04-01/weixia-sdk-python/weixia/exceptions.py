"""Exceptions for Weixia SDK."""


class WeixiaError(Exception):
    """Base exception for Weixia SDK."""
    pass


class AuthenticationError(WeixiaError):
    """Raised when authentication fails."""
    pass


class NotFoundError(WeixiaError):
    """Raised when a resource is not found."""
    pass


class ValidationError(WeixiaError):
    """Raised when request validation fails."""
    pass
