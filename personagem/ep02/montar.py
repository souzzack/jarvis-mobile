# Coloca as falas em ordem na linha do tempo, gera as pistas de voz, os envelopes (boca/luz) e as legendas.
import json, subprocess, numpy as np, wave
C = json.load(open('clips.json'))
ORDER = [('D1', 1.0), ('G1', .5), ('D2', .6), ('D3', .6), ('G2', .8), ('D4', .5), ('G3', .5), ('D5', .6), ('G4', .5), ('D6', .8), ('D7', .7),
         ('G5', 1.0), ('G6', .5), ('D8', .5), ('G7', .4), ('D9', .9), ('G8', .6), ('D10', .6), ('G9', .4), ('D11', .4), ('G10', .4), ('D12', .4),
         ('G11', .4), ('D13', 1.0), ('G12', .6), ('G13', .8), ('D14', .6), ('G14', .5), ('D15', 1.0), ('G15', .6)]
OUTRO = 6.5
SR = 48000
src = {}
for who in ('davi', 'deus'):
    raw = subprocess.run(['ffmpeg', '-v', 'error', '-i', f'voz_{who}.mp3', '-ac', '1', '-ar', str(SR), '-f', 'f32le', '-'], capture_output=True, check=True).stdout
    src[who] = np.frombuffer(raw, dtype=np.float32)
t = 0.0; falas = []
for name, gap in ORDER:
    who = 'davi' if name[0] == 'D' else 'deus'; s0, s1, txt = C[who][int(name[1:]) - 1]
    st = t + gap if falas else gap; falas.append([name, round(st, 2), round(st + s1 - s0, 2), who, s0, s1, txt]); t = st + s1 - s0
DUR = round(t + OUTRO, 2)
N = int(DUR * SR); pista = {'davi': np.zeros(N, np.float32), 'deus': np.zeros(N, np.float32)}
for name, st, en, who, s0, s1, txt in falas:
    clip = src[who][int(s0 * SR):int(s1 * SR)].copy(); f = int(0.01 * SR); clip[:f] *= np.linspace(0, 1, f); clip[-f:] *= np.linspace(1, 0, f)
    i = int(st * SR); pista[who][i:i + len(clip)] += clip
for who in pista:
    with wave.open(f'pista_{who}.wav', 'wb') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes((np.clip(pista[who], -1, 1) * 32767).astype('<i2').tobytes())
env = {'fps': 24}
for who in pista:
    hop = SR // 24; a = pista[who]; e = np.array([np.sqrt(np.mean(a[i:i + hop] ** 2)) for i in range(0, N, hop)])
    env[who] = [round(float(x), 3) for x in np.clip(e / np.percentile(e[e > 0.01], 90), 0, 1)]
json.dump(env, open('envelopes.json', 'w'))
json.dump({'dur': DUR, 'falas': falas}, open('falas.json', 'w'), ensure_ascii=False, indent=1)
for f in falas: print(f'{f[0]:4s} {f[1]:6.2f}-{f[2]:6.2f} {f[6]}')
print('DUR', DUR)
