# Servidor estático em 127.0.0.1 que declara UTF-8. Escrita (PUT) SÓ em Exports/StormIsland/Workshop/ e Terrain/,
# só nomes simples, sem sobrescrever (a fonte e os backups nunca são tocados).
import functools, http.server, os, re, sys
pasta, porta = sys.argv[1], int(sys.argv[2])
EXPORTS = os.path.join(pasta, "Exports", "StormIsland")
class H(http.server.SimpleHTTPRequestHandler):
    extensions_map = {**http.server.SimpleHTTPRequestHandler.extensions_map,
        ".js": "text/javascript; charset=utf-8", ".html": "text/html; charset=utf-8",
        ".json": "application/json; charset=utf-8", ".md": "text/plain; charset=utf-8",
        ".glb": "model/gltf-binary"}
    def do_PUT(self):
        m = re.fullmatch(r"/Exports/StormIsland/(Workshop|Terrain|Arrival)/([A-Za-z0-9._-]{1,80}\.(glb|json|png))", self.path)
        if not m:
            self.send_error(403, "escrita só em /Exports/StormIsland/Workshop|Terrain/"); return
        DESTINO = os.path.join(EXPORTS, m.group(1)); alvo = os.path.join(DESTINO, m.group(2))
        if os.path.exists(alvo):
            self.send_error(409, "arquivo já existe (não sobrescrevo)"); return
        n = int(self.headers.get("Content-Length", "0"))
        if n <= 0 or n > 64 * 1024 * 1024:
            self.send_error(413, "tamanho inválido"); return
        os.makedirs(DESTINO, exist_ok=True)
        dados = self.rfile.read(n)
        with open(alvo, "wb") as f:
            f.write(dados)
        self.send_response(201); self.end_headers(); self.wfile.write(str(len(dados)).encode())
http.server.ThreadingHTTPServer(("127.0.0.1", porta), functools.partial(H, directory=pasta)).serve_forever()
