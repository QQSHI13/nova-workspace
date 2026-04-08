#!/usr/bin/env python3
"""Base64 Converter - Encode/Decode base64 strings and files"""

import base64
import sys
import argparse

def decode_base64(data: str) -> bytes:
    """Decode base64 string to bytes"""
    # Remove whitespace and newlines
    data = data.strip().replace('\n', '').replace('\r', '').replace(' ', '')
    return base64.b64decode(data)

def encode_base64(data: bytes) -> str:
    """Encode bytes to base64 string"""
    return base64.b64encode(data).decode('utf-8')

def decode_to_text(data: str) -> str:
    """Decode base64 to text (UTF-8)"""
    decoded = decode_base64(data)
    try:
        return decoded.decode('utf-8')
    except UnicodeDecodeError:
        return f"[Binary data - {len(decoded)} bytes]"

def decode_to_file(data: str, output_path: str):
    """Decode base64 to file"""
    decoded = decode_base64(data)
    with open(output_path, 'wb') as f:
        f.write(decoded)
    return f"Saved {len(decoded)} bytes to {output_path}"

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Base64 Converter')
    parser.add_argument('action', choices=['decode', 'encode'], help='Action to perform')
    parser.add_argument('input', help='Input string or file path (use - for stdin)')
    parser.add_argument('-o', '--output', help='Output file path')
    parser.add_argument('-f', '--file', action='store_true', help='Treat input as file path')
    
    args = parser.parse_args()
    
    # Read input
    if args.input == '-':
        input_data = sys.stdin.read()
    elif args.file:
        with open(args.input, 'rb') as f:
            input_data = f.read()
    else:
        input_data = args.input
    
    # Perform action
    if args.action == 'decode':
        if isinstance(input_data, bytes):
            input_data = input_data.decode('utf-8', errors='ignore')
        result = decode_base64(input_data)
        if args.output:
            with open(args.output, 'wb') as f:
                f.write(result)
            print(f"Decoded {len(result)} bytes to {args.output}")
        else:
            # Try to print as text
            try:
                print(result.decode('utf-8'))
            except:
                print(f"[Binary data - {len(result)} bytes]")
                print(f"First 100 bytes (hex): {result[:100].hex()}")
    
    elif args.action == 'encode':
        if isinstance(input_data, str):
            input_data = input_data.encode('utf-8')
        result = encode_base64(input_data)
        if args.output:
            with open(args.output, 'w') as f:
                f.write(result)
            print(f"Encoded to {args.output}")
        else:
            print(result)
