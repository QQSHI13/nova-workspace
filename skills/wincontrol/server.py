#!/usr/bin/env python3
"""
WinControl - Frame Capture + Actions API
Captures on POST request, returns file location
Port 8767: Actions (HTTP API for control)
"""

import json
import os
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse

import win32api
import win32con
import mss
from PIL import Image

# Config
QUALITY = 90      # High quality for clear UI text
ACTION_PORT = 8767
FRAME_DIR = r'\\wsl.localhost\Ubuntu\tmp\wincontrol'  # WSL path from Windows

# Ensure frame directory exists
os.makedirs(FRAME_DIR, exist_ok=True)

# Screen dimensions
screen_w = win32api.GetSystemMetrics(0)
screen_h = win32api.GetSystemMetrics(1)

# Frame counter
frame_count = 0

def capture():
    """Capture screen and save to /tmp/wincontrol/"""
    global frame_count
    try:
        with mss.mss() as sct:
            img = sct.grab(sct.monitors[1])
            im = Image.frombytes("RGB", img.size, img.bgra, "raw", "BGRX")
            
            frame_count += 1
            frame_path = os.path.join(FRAME_DIR, f"frame_{frame_count:06d}.jpg")
            
            im.save(frame_path, format='JPEG', quality=QUALITY, optimize=True)
            
            return {"ok": True, "frame": frame_count, "path": frame_path}
    except Exception as e:
        print(f"Capture error: {e}")
        return {"ok": False, "error": str(e)}

# ========== ACTION HANDLERS ==========

def handle_click(x, y, button="left"):
    """Click at screen coordinates"""
    try:
        nx = int(x * 65535 / screen_w)
        ny = int(y * 65535 / screen_h)
        flags = win32con.MOUSEEVENTF_ABSOLUTE | win32con.MOUSEEVENTF_MOVE
        
        if button == "left":
            win32api.mouse_event(flags | win32con.MOUSEEVENTF_LEFTDOWN, nx, ny, 0, 0)
            win32api.mouse_event(win32con.MOUSEEVENTF_LEFTUP, nx, ny, 0, 0)
        elif button == "right":
            win32api.mouse_event(flags | win32con.MOUSEEVENTF_RIGHTDOWN, nx, ny, 0, 0)
            win32api.mouse_event(win32con.MOUSEEVENTF_RIGHTUP, nx, ny, 0, 0)
        return {"ok": True}
    except Exception as e:
        return {"ok": False, "error": str(e)}

def handle_drag(x1, y1, x2, y2, button="left"):
    """Drag from (x1,y1) to (x2,y2)"""
    try:
        nx1 = int(x1 * 65535 / screen_w)
        ny1 = int(y1 * 65535 / screen_h)
        nx2 = int(x2 * 65535 / screen_w)
        ny2 = int(y2 * 65535 / screen_h)
        
        down_flag = win32con.MOUSEEVENTF_LEFTDOWN if button == "left" else win32con.MOUSEEVENTF_RIGHTDOWN
        up_flag = win32con.MOUSEEVENTF_LEFTUP if button == "left" else win32con.MOUSEEVENTF_RIGHTUP
        
        win32api.mouse_event(win32con.MOUSEEVENTF_ABSOLUTE | win32con.MOUSEEVENTF_MOVE, nx1, ny1, 0, 0)
        win32api.mouse_event(down_flag, nx1, ny1, 0, 0)
        win32api.mouse_event(win32con.MOUSEEVENTF_ABSOLUTE | win32con.MOUSEEVENTF_MOVE, nx2, ny2, 0, 0)
        win32api.mouse_event(up_flag, nx2, ny2, 0, 0)
        return {"ok": True}
    except Exception as e:
        return {"ok": False, "error": str(e)}

def handle_scroll(x, y, direction="down", amount=3):
    """Scroll at position"""
    try:
        nx = int(x * 65535 / screen_w)
        ny = int(y * 65535 / screen_h)
        win32api.mouse_event(win32con.MOUSEEVENTF_ABSOLUTE | win32con.MOUSEEVENTF_MOVE, nx, ny, 0, 0)
        wheel_delta = -120 * amount if direction == "down" else 120 * amount
        win32api.mouse_event(win32con.MOUSEEVENTF_WHEEL, 0, 0, wheel_delta, 0)
        return {"ok": True}
    except Exception as e:
        return {"ok": False, "error": str(e)}

def handle_type(text):
    """Type a string of text"""
    try:
        for char in text:
            if char == ' ':
                vk = 0x20
                win32api.keybd_event(vk, 0, 0, 0)
                win32api.keybd_event(vk, 0, win32con.KEYEVENTF_KEYUP, 0)
            elif char.isupper():
                vk = win32api.VkKeyScan(char) & 0xFF
                win32api.keybd_event(win32con.VK_SHIFT, 0, 0, 0)
                win32api.keybd_event(vk, 0, 0, 0)
                win32api.keybd_event(vk, 0, win32con.KEYEVENTF_KEYUP, 0)
                win32api.keybd_event(win32con.VK_SHIFT, 0, win32con.KEYEVENTF_KEYUP, 0)
            else:
                vk = win32api.VkKeyScan(char) & 0xFF if char.isalpha() else ord(char)
                win32api.keybd_event(vk, 0, 0, 0)
                win32api.keybd_event(vk, 0, win32con.KEYEVENTF_KEYUP, 0)
        return {"ok": True, "typed": text}
    except Exception as e:
        return {"ok": False, "error": str(e)}

def handle_key(key):
    """Press a single special key"""
    try:
        keys = {
            'Enter': 0x0D, 'Return': 0x0D, 'Escape': 0x1B, 'Esc': 0x1B,
            'Backspace': 0x08, 'Tab': 0x09, 'Space': 0x20,
            'Delete': 0x2E, 'Del': 0x2E,
            'Up': 0x26, 'Down': 0x28, 'Left': 0x25, 'Right': 0x27,
            'Home': 0x24, 'End': 0x23, 'PageUp': 0x21, 'PageDown': 0x22,
            'F1': 0x70, 'F2': 0x71, 'F3': 0x72, 'F4': 0x73,
            'F5': 0x74, 'F6': 0x75, 'F7': 0x76, 'F8': 0x77,
            'F9': 0x78, 'F10': 0x79, 'F11': 0x7A, 'F12': 0x7B,
        }
        vk = keys.get(key, ord(key) if len(key) == 1 else 0)
        if vk:
            win32api.keybd_event(vk, 0, 0, 0)
            win32api.keybd_event(vk, 0, win32con.KEYEVENTF_KEYUP, 0)
        return {"ok": True, "key": key}
    except Exception as e:
        return {"ok": False, "error": str(e)}

def handle_combo(keys):
    """Press key combination like ['Ctrl', 'C']"""
    try:
        modifiers = {
            'Ctrl': win32con.VK_CONTROL,
            'Control': win32con.VK_CONTROL,
            'Alt': win32con.VK_MENU,
            'Shift': win32con.VK_SHIFT,
            'Win': win32con.VK_LWIN,
            'Windows': win32con.VK_LWIN,
        }
        special = {
            'Enter': 0x0D, 'Return': 0x0D, 'Escape': 0x1B, 'Esc': 0x1B,
            'Backspace': 0x08, 'Tab': 0x09, 'Space': 0x20,
            'Delete': 0x2E, 'Del': 0x2E,
            'C': 0x43, 'V': 0x56, 'X': 0x58, 'A': 0x41, 'Z': 0x5A,
            'S': 0x53, 'F': 0x46, 'N': 0x4E, 'T': 0x54, 'W': 0x57,
            'E': 0x45, 'R': 0x52, 'D': 0x44, 'F4': 0x73,
        }
        
        vks = []
        for k in keys:
            if k in modifiers:
                vks.append(modifiers[k])
            elif k in special:
                vks.append(special[k])
            elif len(k) == 1:
                vks.append(win32api.VkKeyScan(k) & 0xFF)
        
        for vk in vks:
            win32api.keybd_event(vk, 0, 0, 0)
        for vk in reversed(vks):
            win32api.keybd_event(vk, 0, win32con.KEYEVENTF_KEYUP, 0)
        
        return {"ok": True, "combo": keys}
    except Exception as e:
        return {"ok": False, "error": str(e)}

# ========== ACTION SERVER ==========

class ActionHandler(BaseHTTPRequestHandler):
    def _send_json(self, data):
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
    
    def do_POST(self):
        path = urlparse(self.path).path
        content_len = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_len).decode() if content_len > 0 else '{}'
        
        try:
            data = json.loads(body) if body else {}
        except:
            data = {}
        
        result = {"ok": False, "error": "Unknown endpoint"}
        
        if path == '/capture':
            # Trigger a capture and return file path + screen info
            cap_result = capture()
            if cap_result.get("ok"):
                # Convert Windows path to WSL path for response
                wsl_path = "/tmp/wincontrol/" + os.path.basename(cap_result["path"])
                result = {
                    "ok": True,
                    "path": wsl_path,
                    "frame": cap_result["frame"],
                    "screen": {"width": screen_w, "height": screen_h}
                }
            else:
                result = cap_result
        elif path == '/click':
            result = handle_click(data.get('x', 0), data.get('y', 0), data.get('button', 'left'))
        elif path == '/drag':
            result = handle_drag(data.get('x1', 0), data.get('y1', 0), 
                                data.get('x2', 0), data.get('y2', 0),
                                data.get('button', 'left'))
        elif path == '/scroll':
            result = handle_scroll(data.get('x', 0), data.get('y', 0),
                                  data.get('direction', 'down'), data.get('amount', 3))
        elif path == '/type':
            result = handle_type(data.get('text', ''))
        elif path == '/key':
            result = handle_key(data.get('key', ''))
        elif path == '/combo':
            result = handle_combo(data.get('keys', []))
        
        self._send_json(result)
    
    def do_GET(self):
        path = urlparse(self.path).path
        
        if path == '/ping':
            self._send_json({"ok": True})
        else:
            self._send_json({"endpoints": [
                "POST /capture     - Capture screen, returns {path, frame, screen}",
                "POST /click       - {x, y, button?}",
                "POST /drag        - {x1, y1, x2, y2, button?}",
                "POST /scroll      - {x, y, direction?, amount?}",
                "POST /type        - {text}",
                "POST /key         - {key}",
                "POST /combo       - {keys: []}",
                "GET  /ping        - Health check"
            ]})
    
    def log_message(self, *args): pass

def action_server():
    server = HTTPServer(('localhost', ACTION_PORT), ActionHandler)
    print(f"Action API: http://localhost:{ACTION_PORT}")
    server.serve_forever()

# ========== MAIN ==========

if __name__ == "__main__":
    print(f"WinControl Server")
    print(f"Screen: {screen_w}x{screen_h} @ {QUALITY}% quality")
    print(f"Frames: {FRAME_DIR}")
    print("")
    
    action_server()
