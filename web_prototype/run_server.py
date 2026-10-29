import SimpleHTTPServer
import SocketServer
import os
import sys

PORT = 8000
DIRECTORY = os.path.dirname(os.path.abspath(__file__))

os.chdir(DIRECTORY)

class Handler(SimpleHTTPServer.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        SimpleHTTPServer.SimpleHTTPRequestHandler.end_headers(self)

SocketServer.TCPServer.allow_reuse_address = True
httpd = SocketServer.TCPServer(("", PORT), Handler)

print "LabLens AI Server running at http://localhost:%d/" % PORT
print "Directory: %s" % DIRECTORY
sys.stdout.flush()

httpd.serve_forever()
