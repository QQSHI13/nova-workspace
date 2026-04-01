"""
Wallet client for Weixia API
"""

from typing import Optional, List, Dict, Any

from .http import HTTPClient
from .models import WalletBalance, WalletInfo, Transaction


class WalletClient:
    """Client for wallet-related operations."""
    
    def __init__(self, http: HTTPClient):
        self._http = http
    
    def get_balance(self) -> WalletBalance:
        """Get wallet balance.
        
        Returns:
            WalletBalance: Balance information
            
        Raises:
            WeixiaAuthError: If not authenticated
        """
        response = self._http.get("/api/wallet/balance")
        return WalletBalance.from_dict(response)
    
    def get_info(self) -> WalletInfo:
        """Get detailed wallet information.
        
        Returns:
            WalletInfo: Wallet details including address
            
        Raises:
            WeixiaAuthError: If not authenticated
        """
        response = self._http.get("/api/wallet/info")
        return WalletInfo.from_dict(response)
    
    def bind_address(self, address: str, chain: Optional[str] = None) -> Dict[str, Any]:
        """Bind blockchain wallet address.
        
        Args:
            address: Blockchain address
            chain: Chain type (e.g., "ethereum", "solana")
            
        Returns:
            Dict: Response data
            
        Raises:
            WeixiaAuthError: If not authenticated
            WeixiaValidationError: If validation fails
        """
        data = {"address": address}
        if chain:
            data["chain"] = chain
            
        return self._http.post("/api/wallet/bind-address", json_data=data)
    
    def transfer(
        self,
        to_agent_id: str,
        amount: float,
        memo: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Transfer tokens to another agent.
        
        Args:
            to_agent_id: Recipient agent ID
            amount: Amount to transfer
            memo: Optional memo
            
        Returns:
            Dict: Transaction data
            
        Raises:
            WeixiaAuthError: If not authenticated
            WeixiaValidationError: If validation fails
            WeixiaAPIError: If transfer fails
        """
        data = {
            "to_agent_id": to_agent_id,
            "amount": amount,
        }
        if memo:
            data["memo"] = memo
            
        return self._http.post("/api/wallet/transfer", json_data=data)
    
    def withdraw(
        self,
        amount: float,
        address: Optional[str] = None,
        chain: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Withdraw tokens to blockchain wallet.
        
        Args:
            amount: Amount to withdraw
            address: Target blockchain address (optional if already bound)
            chain: Chain type
            
        Returns:
            Dict: Withdrawal request data
            
        Raises:
            WeixiaAuthError: If not authenticated
            WeixiaValidationError: If validation fails
            WeixiaAPIError: If withdrawal fails
        """
        data = {"amount": amount}
        if address:
            data["address"] = address
        if chain:
            data["chain"] = chain
            
        return self._http.post("/api/wallet/withdraw", json_data=data)
    
    def get_history(
        self,
        limit: int = 20,
        tx_type: Optional[str] = None,
    ) -> List[Transaction]:
        """Get transaction history.
        
        Args:
            limit: Maximum number of results (1-100)
            tx_type: Filter by transaction type
            
        Returns:
            List[Transaction]: List of transactions
            
        Raises:
            WeixiaAuthError: If not authenticated
        """
        params = {"limit": limit}
        if tx_type:
            params["tx_type"] = tx_type
            
        response = self._http.get("/api/wallet/history", params=params)
        return [Transaction.from_dict(item) for item in response]
    
    def get_leaderboard(self, limit: int = 20) -> List[Dict[str, Any]]:
        """Get wallet balance leaderboard.
        
        Args:
            limit: Maximum number of results (1-100)
            
        Returns:
            List[Dict]: Leaderboard entries with agent and balance info
        """
        return self._http.get("/api/wallet/leaderboard", params={"limit": limit})
