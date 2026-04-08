#!/usr/bin/env python3
"""
WinControl Server - Display + Actions Separation
Port 8766: Display (HTTP view only)
Port 8767: Actions (HTTP API for control)
"""

import asyncio
import json
import base64
import io
import threading
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import parse_qs, urlparse

import win32api
import win32con
import mss
from PIL import Image

# Config
QUALITY = 90      # High quality for clear UI text
FPS = 5           # Low FPS is fine for AI control
DISPLAY_PORT = 8766
ACTION_PORT = 8767

# Screen dimensions
screen_w = win32api.GetSystemMetrics(0)
screen_h = win32api.GetSystemMetrics(1)

def capture():
    """Capture screen as JPEG bytes"""
    try:
        with mss.mss() as sct:
            img = sct.grab(sct.monitors[1])
            im = Image.frombytes("RGB", img.size, img.bgra, "raw", "BGRX")
            buf = io.BytesIO()
            im.save(buf, format='JPEG', quality=QUALITY, optimize=True)
            return buf.getvalue()
    except Exception as e:
        print(f"Capture error: {e}")
        return None

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
        
        # Move to start, press, drag to end, release
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
                vk = 0x20  # Space
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
        
        # Press all
        for vk in vks:
            win32api.keybd_event(vk, 0, 0, 0)
        # Release all
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
        
        if path == '/click':
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
        
        if path == '/screen':
            # Return screen dimensions
            self._send_json({"width": screen_w, "height": screen_h})
        elif path == '/ping':
            self._send_json({"ok": True})
        else:
            self._send_json({"endpoints": ["/click", "/drag", "/scroll", "/type", "/key", "/combo", "/screen", "/ping"]})
    
    def log_message(self, *args): pass

def action_server():
    server = HTTPServer(('localhost', ACTION_PORT), ActionHandler)
    print(f"Action API: http://localhost:{ACTION_PORT}")
    server.serve_forever()

# ========== DISPLAY SERVER ==========

# Global frame cache
latest_frame = None

def capture_loop():
    """Continuously capture screen in background"""
    global latest_frame
    import time
    while True:
        latest_frame = capture()
        time.sleep(1 / FPS)

DISPLAY_HTML = '''<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>WinControl Display</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { width: 100%; height: 100%; overflow: hidden; background: #000; }
        #desktop { 
            display: block; width: 100%; height: 100%; object-fit: contain;
        }
        #info {
            position: fixed; bottom: 10px; right: 10px;
            background: rgba(0,0,0,0.7); color: #888;
            padding: 5px 10px; border-radius: 4px;
            font-family: monospace; font-size: 11px;
        }
    </style>
</head>
<body>
    <img id="desktop" alt="Desktop" />
    <div id="info">Loading...</div>
    
    <script>
        const img = document.getElementById('desktop');
        const info = document.getElementById('info');
        let lastFrame = 0;
        
        function update() {
            // Add timestamp to prevent caching
            img.src = '/frame?t=' + Date.now();
            lastFrame++;
            info.textContent = 'Frame: ' + lastFrame;
        }
        
        // Update at FPS rate
        setInterval(update, 1000 / 5);  // 5 FPS
        update();  // Initial frame
    </script>
</body>
</html>'''

class DisplayHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        path = urlparse(self.path).path
        
        if path in ('/', '/index.html'):
            self.send_response(200)
            self.send_header('Content-Type', 'text/html')
            self.end_headers()
            self.wfile.write(DISPLAY_HTML.encode())
        
        elif path == '/frame':
            if latest_frame:
                self.send_response(200)
                self.send_header('Content-Type', 'image/jpeg')
                self.send_header('Cache-Control', 'no-cache')
                self.end_headers()
                self.wfile.write(latest_frame)
            else:
                self.send_error(503, "Frame not ready")
        
        else:
            self.send_error(404)
    
    def log_message(self, *args): pass

def display_server():
    server = HTTPServer(('localhost', DISPLAY_PORT), DisplayHandler)
    print(f"Display: http://localhost:{DISPLAY_PORT}")
    server.serve_forever()

# ========== MAIN ==========

if __name__ == "__main__":
    print(f"WinControl Server")
    print(f"Screen: {screen_w}x{screen_h} @ {QUALITY}% quality, {FPS} FPS")
    print("")
    
    # Start capture thread
    threading.Thread(target=capture_loop, daemon=True).start()
    
    # Start action server thread
    threading.Thread(target=action_server, daemon=True).start()
    
    # Start display server (blocking)
    display_server()
