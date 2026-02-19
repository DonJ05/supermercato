import socket

HOST = "localhost"
PORT = 8000
FILE_DB = "../progetto_casse4Alt/prodotti_server.csv"

def main():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

    server.bind((HOST, PORT))
    server.listen(5)

    print(f"Server in ascolto su {HOST}:{PORT}")

    while True:
        conn, addr = server.accept()
        print(f"Cassa connessa da {addr}")

        try:
            with open(FILE_DB, "rb") as f:
                conn.sendall(f.read())
            print("File inviato correttamente.")
        except Exception as e:
            print("Errore durante invio:", e)

        conn.close()

if __name__ == "__main__":
        main()