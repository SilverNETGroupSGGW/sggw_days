#!/usr/bin/env python3
import http.server
import os

class SPAHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory='/workspaces/sggw_days/build/web', **kwargs)

    def do_GET(self):
        path = self.translate_path(self.path)
        if not os.path.exists(path) or (os.path.isdir(path) and not os.path.exists(os.path.join(path, 'index.html'))):
            self.path = '/index.html'
        return super().do_GET()

if __name__ == '__main__':
    server = http.server.HTTPServer(('0.0.0.0', 8080), SPAHandler)
    print('Serving on http://localhost:8080')
    server.serve_forever()
