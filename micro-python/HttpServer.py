import network
import time
import socket

import uasyncio as asyncio

http_status_codes = {
    100: "Continue",
    101: "Switching Protocols",
    102: "Processing",
    103: "Early Hints",
    200: "OK",
    201: "Created",
    202: "Accepted",
    203: "Non-Authoritative Information",
    204: "No Content",
    205: "Reset Content",
    206: "Partial Content",
    207: "Multi-Status",
    208: "Already Reported",
    226: "IM Used",
    300: "Multiple Choices",
    301: "Moved Permanently",
    302: "Found",
    303: "See Other",
    304: "Not Modified",
    307: "Temporary Redirect",
    308: "Permanent Redirect",
    400: "Bad Request",
    401: "Unauthorized",
    402: "Payment Required",
    403: "Forbidden",
    404: "Not Found",
    405: "Method Not Allowed",
    406: "Not Acceptable",
    407: "Proxy Authentication Required",
    408: "Request Timeout",
    409: "Conflict",
    410: "Gone",
    411: "Length Required",
    412: "Precondition Failed",
    413: "Payload Too Large",
    414: "URI Too Long",
    415: "Unsupported Media Type",
    416: "Range Not Satisfiable",
    417: "Expectation Failed",
    418: "I'm a teapot",
    421: "Misdirected Request",
    422: "Unprocessable Entity",
    423: "Locked",
    424: "Failed Dependency",
    425: "Too Early",
    426: "Upgrade Required",
    428: "Precondition Required",
    429: "Too Many Requests",
    431: "Request Header Fields Too Large",
    451: "Unavailable For Legal Reasons",
    500: "Internal Server Error",
    501: "Not Implemented",
    502: "Bad Gateway",
    503: "Service Unavailable",
    504: "Gateway Timeout",
    505: "HTTP Version Not Supported",
    506: "Variant Also Negotiates",
    507: "Insufficient Storage",
    508: "Loop Detected",
    510: "Not Extended",
    511: "Network Authentication Required"
}

class Request:
    headers = {}
    def __init__(self, reader):
        self.reader = reader
    
    async def read(self):
        print("Reading request line")
        request_line = await self.reader.readline()
        print("Request line is %s" % str(request_line))
        self.method, self.path, rest = str(request_line).split(' ')
        
        print("Reading request data")
        chunks = []
        while True:
            print("Reading chunk...")
            chunk = await self.reader.read(1000)
            chunks.append(chunk)
            if len(chunk) < 1000:
                break
        
        request_data = b''.join(chunks)
        request_headers_end = request_data.find(b'\r\n\r\n')
        
        header_data = request_data[0:request_headers_end]
        for header in [str(line) for line in header_data.split(b'\r\n')]:
            name, value = [val.strip() for val in header.split(":", 1)]
            self.headers[name] = value
        self.body = request_data[request_headers_end + 4:]

class Response:
    headers = {
        "Content-type": "text/html",
        }
    headers_written = False
    status_written = False
    status = 200
    
    def __init__(self, writer):
        self.writer = writer
        
    def set_header(self, name, value):
        self.headers[name] = value
    
    def set_status(self, status):
        self.status = status
    
    def write_status(self):
        if self.status_written:
            return
        reason_phrase = "UNKNOWN"
        try:
            reason_phrase = http_status_codes[self.status]
        except:
            pass
        self.writer.write("HTTP/1.0 %d %s\r\n" % (self.status, reason_phrase))
        self.status_written = True
    
    def write_headers(self):
        if self.headers_written:
            return
        self.write_status()
        for key in self.headers.keys():
            self.writer.write("%s: %s\r\n" % (key, self.headers[key]))
        self.writer.write('\r\n')
        self.headers_written = True
    
    def write(self, data):
        self.write_headers()
        return self.writer.write(data)

routes = {}

def connect_to_network():
    (ssid, password) = [line.strip() for line in open('wifi.txt','r').readlines()]

    wlan = network.WLAN(network.STA_IF)
    
    wlan.active(True)
    wlan.config(pm = 0xa11140) # Disable power-save mode
    wlan.connect(ssid, password)
    
    max_wait = 10
    while max_wait > 0:
        if wlan.status() < 0 or wlan.status() >= 3:
            break
        max_wait -= 1
        print("waiting for connection...")
        time.sleep(1)
    
    if wlan.status() != 3:
        raise RuntimeError('Network connection failed')
    else:
        print('connected')
        status = wlan.ifconfig()
        print('ip = ' + status[0])
        
def add_route(path, func):
    routes[path] = func
    
page_template = """<!DOCTYPE html>
<html>
    <head><title>Server Message</title></head>
    <body>
        <p>%s</p>
    </body>
</html>"""

def make_error_handler(status):
    reason_phrase = "UNKNOWN"
    try:
        reason_phrase = http_status_codes[status]
    except:
        pass
    
    def error_handler(request, response):
        response.set_status(status)
        response.write_headers()
        response.write(page_template % reason_phrase)
    
    return error_handler

not_found = make_error_handler(404)
server_error = make_error_handler(500)

async def serve_client(reader, writer):
    print("Client connected")
    req = Request(reader)
    res = Response(writer)
    
    await req.read()
    
    try:
        handler = routes[req.path]
    except:
        handler = not_found
        
    try:
        print("Calling handler")
        handler(req, res)
    except Exception as e:
        server_error(None, res)
        raise e
    finally:
        await writer.drain()
        await writer.wait_closed()

async def main():
    print("Connecting to Network...")
    connect_to_network()
    
    print("Setting up webserver...")
    asyncio.create_task(asyncio.start_server(serve_client, "0.0.0.0", 80))
    while True:
        await asyncio.sleep(0.75)

def run_server():
    try:
        asyncio.run(main())
    finally:
        asyncio.new_event_loop()

def handle_test(request, response):
    response.write(page_template % "This is a test!")
    
if __name__ == "__main__":
    add_route("/test", handle_test)
    run_server()
