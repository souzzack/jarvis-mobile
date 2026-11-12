# Gera epNN/falas.json para a série de orações: palavras do whisper (com correções) + envelope da voz a 30 fps.
# uso (dentro de epNN/): python3 ../../ferramentas/falas_oracao.py '{"errado": "certo", ...}'
import json, subprocess, sys, numpy as np
fix = json.loads(sys.argv[1]) if len(sys.argv) > 1 else {}
ws = [[a, b, fix.get(w, w)] for a, b, w in json.load(open('voz.mp3.words.json'))]
a = np.frombuffer(subprocess.run(['ffmpeg', '-v', 'error', '-i', 'voz.mp3', '-ac', '1', '-ar', '48000', '-f', 'f32le', '-'], capture_output=True).stdout, np.float32)
hop = 1600; n = len(a) // hop
rms = np.array([np.sqrt(np.mean(a[i * hop:(i + 1) * hop] ** 2)) for i in range(n)])
env = np.convolve(np.clip(rms / np.percentile(rms[rms > 0.005], 90), 0, 1.2), [0.25, 0.5, 0.25], 'same')
json.dump({'fps': 30, 'dur': round(len(a) / 48000, 2), 'env': [round(float(x), 3) for x in env], 'words': ws}, open('falas.json', 'w'), ensure_ascii=False)
print('voz', round(len(a) / 48000, 2), 's · fim da fala', ws[-1][1], 's · duração sugerida', round(ws[-1][1] + 2.7, 1), 's')
