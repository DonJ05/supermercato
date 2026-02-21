from http.server import HTTPServer, BaseHTTPRequestHandler
import time
import threading
import os
import cgi

HOST = "localhost"
PORT = 8080
UPLOAD_DIR = "uploads"

os.makedirs(UPLOAD_DIR, exist_ok=True)

class Handler(BaseHTTPRequestHandler):

    def do_GET(self):
        if self.path == "/ping":
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(b"OK")

        elif self.path == "/time":
            server_time = str(int(time.time()))
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(server_time.encode())

        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        if self.path != "/upload":
            self.send_response(404)
            self.end_headers()
            return

        ctype, pdict = cgi.parse_header(self.headers.get("Content-Type"))

        if ctype != "multipart/form-data":
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b"Formato non valido")
            return

        pdict["boundary"] = bytes(pdict["boundary"], "utf-8")
        pdict["CONTENT-LENGTH"] = int(self.headers.get("Content-Length"))

        form = cgi.FieldStorage(
            fp=self.rfile,
            headers=self.headers,
            environ={"REQUEST_METHOD": "POST"},
        )

        if "file" not in form:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b"Nessun file ricevuto")
            return

        file_item = form["file"]
        filename = os.path.basename(file_item.filename)
        filepath = os.path.join(UPLOAD_DIR, filename)

        with open(filepath, "wb") as f:
            f.write(file_item.file.read())

        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.end_headers()
        self.wfile.write(b"Upload completato ")

    def log_message(self, format, *args):
        return  # silenzia log HTTP


def heartbeat():
    while True:
        print("SERVER: in esecuzione")
        time.sleep(1)


print("SERVER: avvio...")
threading.Thread(target=heartbeat, daemon=True).start()

server = HTTPServer((HOST, PORT), Handler)
server.serve_forever()
