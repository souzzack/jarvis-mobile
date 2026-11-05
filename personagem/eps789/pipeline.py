# Episódio: separa as falas, posiciona na linha do tempo, gera pistas, envelopes e legendas.  uso: python3 pipeline.py ep03
import json, subprocess, sys, wave, numpy as np
ep = sys.argv[1]; P = lambda f: f'{ep}/{f}'
T = json.load(open(P('transcricao.json'))); C = json.load(open(P('config.json')))
SR = 48000; src = {}; clips = {}
for who in ('davi', 'deus'):
    raw = subprocess.run(['ffmpeg', '-v', 'error', '-i', P(f'voz_{who}.mp3'), '-ac', '1', '-ar', str(SR), '-f', 'f32le', '-'], capture_output=True, check=True).stdout
    a = np.frombuffer(raw, dtype=np.float32); src[who] = a; dur = len(a) / SR
    hop = SR // 100; e = np.array([np.sqrt(np.mean(a[i:i + hop] ** 2)) for i in range(0, len(a), hop)]); es = np.convolve(e, np.ones(5) / 5, 'same')
    W = T[who]; st = C['S_' + who]; cuts = [0.0]
    for k in st[1:]:
        lo = W[k - 1][0] + 0.12; hi = W[k][0] + 0.12; i0, i1 = int(lo * 100), max(int(lo * 100) + 1, int(hi * 100))
        cuts.append((i0 + int(np.argmin(es[i0:i1]))) / 100)
    cuts.append(dur); thr = max(0.008, np.percentile(e, 95) * 0.06); cl = []
    for n in range(len(st)):
        a0, a1 = int(cuts[n] * 100), int(cuts[n + 1] * 100); on = np.where(e[a0:a1] > thr)[0]
        s0 = max(cuts[n], min((a0 + on[0]) / 100 - 0.06, W[st[n]][0] - 0.05)); s1 = min(cuts[n + 1], (a0 + on[-1]) / 100 + 0.12)
        cl.append([round(s0, 2), round(s1, 2)])
    clips[who] = cl
# linha do tempo
t = 0.0; falas = []
for tok in C['order'].split():
    name, gap = (tok.split(':') + ['0.6'])[:2]; gap = float(gap)
    who = 'davi' if name[0] == 'D' else 'deus'; s0, s1 = clips[who][int(name[1:]) - 1]
    stt = t + gap if falas else gap; falas.append([name, round(stt, 2), round(stt + s1 - s0, 2), who, s0, s1]); t = stt + s1 - s0
DUR = round(t + C.get('outro', 6.5), 2); N = int(DUR * SR)
pista = {w: np.zeros(N, np.float32) for w in src}
for name, stt, en, who, s0, s1 in falas:
    c = src[who][int(s0 * SR):int(s1 * SR)].copy(); f = int(0.01 * SR); c[:f] *= np.linspace(0, 1, f); c[-f:] *= np.linspace(1, 0, f)
    i = int(stt * SR); pista[who][i:i + len(c)] += c
for who in pista:
    with wave.open(P(f'pista_{who}.wav'), 'wb') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes((np.clip(pista[who], -1, 1) * 32767).astype('<i2').tobytes())
env = {'fps': 24}
for who in pista:
    hop = SR // 24; a = pista[who]; e = np.array([np.sqrt(np.mean(a[i:i + hop] ** 2)) for i in range(0, N, hop)])
    env[who] = [round(float(x), 3) for x in np.clip(e / np.percentile(e[e > 0.01], 90), 0, 1)]
json.dump(env, open(P('envelopes.json'), 'w'))
# legendas (palavras atribuídas ao trecho que contém o meio da palavra)
FIX = C.get('fix', {}); subs = []
for name, stt, en, who, s0, s1 in falas:
    mine = [f for f in falas if f[3] == who]
    owner = lambda m: min(mine, key=lambda f: max(f[4] - m, 0, m - f[5]))[0]
    ws = [w for w in T[who] if owner((w[0] + w[1]) / 2) == name]
    toks = [[stt + max(0, w[0] - s0), stt + max(0, w[1] - s0), FIX.get(w[2], w[2])] for w in ws]
    if not toks: continue
    toks[0][2] = toks[0][2][0].upper() + toks[0][2][1:]
    if toks[-1][2][-1] == ',': toks[-1][2] = toks[-1][2][:-1] + '.'
    chunk = []
    for i, tk in enumerate(toks):
        chunk.append(tk)
        if tk[2][-1] in '.?!' or (tk[2][-1] == ',' and len(chunk) >= 4) or len(chunk) >= 11 or i == len(toks) - 1:
            subs.append([round(chunk[0][0] - 0.05, 2), round(min(en + 0.1, chunk[-1][1] + 0.1), 2), 'DAVI' if who == 'davi' else 'DEUS', ' '.join(c[2] for c in chunk), name]); chunk = []
out = []
for s_ in subs:
    if out and len(s_[3].split()) == 1 and s_[3][-1] == '.' and out[-1][4] == s_[4]: out[-1] = [out[-1][0], s_[1], s_[2], out[-1][3] + ' ' + s_[3], s_[4]]
    else: out.append(s_)
out = [x[:4] for x in out]
for x in out:
    for o, n in C.get('fixs', []): x[3] = x[3].replace(o, n)
    x[0], x[1] = float(x[0]), float(x[1])
for i in range(len(out) - 1): out[i][1] = min(out[i][1], out[i + 1][0] - 0.02)
json.dump(out, open(P('legendas.json'), 'w'), ensure_ascii=False)
json.dump({'dur': DUR, 'falas': falas}, open(P('falas.json'), 'w'))
for f in falas: print(f'{f[0]:4s} {f[1]:6.2f}-{f[2]:6.2f}')
print('DUR', DUR); [print(s) for s in out]
