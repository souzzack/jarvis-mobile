# Separa cada fala das gravações usando a transcrição (palavras) + o ponto mais silencioso entre as falas.
import json, subprocess, numpy as np
T = json.load(open('transcricao.json'))
# primeiras palavras de cada fala (índice na transcrição)
STARTS = {
  'davi': [0, 5, 14, 16, 21, 27, 40, 46, 50, 56, 59, 61, 66, 75, 80],
  'deus': [0, 4, 6, 17, 24, 30, 41, 46, 60, 73, 75, 78, 88, 105, 115],
}
SR = 48000
out = {}
for who, st in STARTS.items():
    raw = subprocess.run(['ffmpeg', '-v', 'error', '-i', f'voz_{who}.mp3', '-ac', '1', '-ar', str(SR), '-f', 'f32le', '-'], capture_output=True, check=True).stdout
    a = np.frombuffer(raw, dtype=np.float32); dur = len(a) / SR
    hop = SR // 100; e = np.array([np.sqrt(np.mean(a[i:i + hop] ** 2)) for i in range(0, len(a), hop)])
    es = np.convolve(e, np.ones(5) / 5, 'same')
    W = T[who]; cuts = [0.0]
    for k in st[1:]:
        lo = W[k - 1][0] + 0.12; hi = W[k][0] + 0.12
        i0, i1 = int(lo * 100), max(int(lo * 100) + 1, int(hi * 100))
        cuts.append((i0 + int(np.argmin(es[i0:i1]))) / 100)
    cuts.append(dur)
    clips = []
    thr = max(0.008, np.percentile(e, 95) * 0.06)
    for n in range(len(st)):
        a0, a1 = int(cuts[n] * 100), int(cuts[n + 1] * 100)
        on = np.where(e[a0:a1] > thr)[0]
        s0 = max(cuts[n], (a0 + on[0]) / 100 - 0.06); s1 = min(cuts[n + 1], (a0 + on[-1]) / 100 + 0.12)
        txt = ' '.join(w[2] for w in W[st[n]:(st[n + 1] if n + 1 < len(st) else len(W))])
        clips.append([round(s0, 2), round(s1, 2), txt])
        print(f'{who} {n + 1:2d} {s0:6.2f}-{s1:6.2f}  {txt}')
    out[who] = clips
json.dump(out, open('clips.json', 'w'), ensure_ascii=False, indent=1)
