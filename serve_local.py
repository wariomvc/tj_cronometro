#!/usr/bin/env python3
import http.server
import socketserver
import os
import sys
import argparse
from pathlib import Path

DEFAULT_PORT = 8080
DIRECTORY = "build/web"

class ChangeDirHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

def find_available_port(start_port):
    port = start_port
    while port < start_port + 10:
        try:
            with socketserver.TCPServer(("", port), http.server.SimpleHTTPRequestHandler) as test_server:
                return port
        except OSError:
            port += 1
    return None

def main():
    parser = argparse.ArgumentParser(description="Servidor web local para proyecto Flutter compilado")
    parser.add_argument("-p", "--port", type=int, default=DEFAULT_PORT, help=f"Puerto del servidor (default: {DEFAULT_PORT})")
    args = parser.parse_args()
    
    web_dir = Path(DIRECTORY)
    
    if not web_dir.exists():
        print(f"Error: Directorio '{DIRECTORY}' no encontrado.")
        print("Asegúrate de compilar el proyecto Flutter primero: flutter build web")
        sys.exit(1)
    
    port = args.port
    
    try:
        with socketserver.TCPServer(("", port), ChangeDirHandler) as httpd:
            print(f"Servidor corriendo en http://localhost:{port}")
            print(f"Sirviendo archivos desde: {web_dir.absolute()}")
            print("Presiona Ctrl+C para detener el servidor")
            
            try:
                httpd.serve_forever()
            except KeyboardInterrupt:
                print("\nServidor detenido por el usuario")
    except OSError as e:
        if e.errno == 98:
            print(f"Error: Puerto {port} ya está en uso.")
            available_port = find_available_port(port + 1)
            if available_port:
                print(f"Sugerencia: Intenta con el puerto {available_port}: python {sys.argv[0]} --port {available_port}")
            else:
                print("No se encontraron puertos disponibles.")
        else:
            print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
