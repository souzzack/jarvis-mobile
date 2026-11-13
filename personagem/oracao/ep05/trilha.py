# Trilha: piano, cordas, pads e caixinha de música.
import numpy as np, wave

SR = 48000; import sys
DUR = float(sys.argv[2]); N = int(SR * DUR)
mix = np.zeros((N, 2))
rng = np.random.default_rng(21)
def note(m): return 440.0 * 2 ** ((m - 69) / 12)
def add(sig, st, g=1.0, pan=0.0):
    i = int(st * SR); j = min(N, i + len(sig))
    if j <= i or i < 0: return
    l = np.cos((pan + 1) * np.pi / 4); r = np.sin((pan + 1) * np.pi / 4)
    mix[i:j, 0] += sig[:j - i] * g * l; mix[i:j, 1] += sig[:j - i] * g * r
def tt(d): return np.arange(int(d * SR)) / SR
def lowpass(x, fc):
    a = np.exp(-2 * np.pi * fc / SR); y = np.empty_like(x); acc = 0.0
    for k in range(len(x)): acc = (1 - a) * x[k] + a * acc; y[k] = acc
    return y

def piano(st, m, g=0.2, d=2.6, pan=0.0):
    t = tt(d); f = note(m)
    s = sum(np.sin(2 * np.pi * f * h * t * (1 + 0.0004 * h)) * (0.6 ** (h - 1)) * np.exp(-t * (1.6 + 0.9 * h)) for h in range(1, 7))
    add(s * np.minimum(1, t / 0.004), st, g, pan)
def musicbox(st, m, g=0.12):
    t = tt(1.6); f = note(m)
    s = np.sin(2 * np.pi * f * t) + 0.35 * np.sin(2 * np.pi * f * 3.01 * t) * np.exp(-t * 6)
    add(s * np.exp(-t * 3.2), st, g, 0.2)
def pad(st, d, ch, g=0.1, bright=1200):
    t = tt(d + 1.2); s = 0
    for m in ch:
        for det in (-0.12, 0.0, 0.12):
            ph = 2 * np.pi * note(m) * (1 + det / 100) * t
            s = s + (2 * ((ph / (2 * np.pi)) % 1) - 1) * 0.33
    s = lowpass(s / len(ch), bright)
    e = np.minimum(1, t / 0.9) * np.minimum(1, np.maximum(0, (d + 1.2 - t) / 1.2))
    add(s * e, st, g, -0.1)
def strings(st, d, ch, g=0.1):
    t = tt(d + 1.5); s = 0
    for m in ch:
        f = note(m) * (1 + 0.004 * np.sin(2 * np.pi * 5.2 * t))
        ph = 2 * np.pi * np.cumsum(f) / SR
        s = s + sum(np.sin(ph * h) / h for h in range(1, 8))
    s = lowpass(s / len(ch), 2600)
    e = np.minimum(1, t / 1.4) * np.minimum(1, np.maximum(0, (d + 1.5 - t) / 1.5))
    add(s * e, st, g, 0.15)
def swell(st, d, g=0.18):
    t = tt(d); n = rng.standard_normal(len(t)); n = n - lowpass(n, 4000)
    add(n * (t / d) ** 2.5, st, g)
def sparkle(st):
    for k, m in enumerate([88, 91, 95, 100]): musicbox(st + k * 0.07, m, 0.07)

C, F, G, Am, Em, Dm = [60, 64, 67], [53, 57, 60], [55, 59, 62], [57, 60, 64], [52, 55, 59], [50, 53, 57]
BEAT = 60 / 72
def arp(t0, t1, prog, g=0.1, oct=12, bass=True):
    t = t0
    while t < t1:
        ch = prog[int((t - t0) / (4 * BEAT)) % len(prog)]; k = int(round((t - t0) / (BEAT / 2)))
        piano(t, ch[[0, 1, 2, 1][k % 4]] + oct, g + (0.02 if k % 4 == 0 else 0), 1.8, 0.2)
        if bass and k % 8 == 0: piano(t, ch[0] - 12, g + 0.02, 3.2, -0.2)
        t += BEAT / 2

# ---------- arranjo do vídeo 05 (autoestima), tempos tirados de falas.json
import json
_W = json.load(open('falas.json'))['words']
_cl = lambda w: w.lower().strip('.,…!?"')
def _at(fr):
    q = [_cl(x) for x in fr.split()]
    for i in range(len(_W) - len(q) + 1):
        if all(_cl(_W[i + k][2]) == q[k] for k in range(len(q))): return _W[i][0]
    raise Exception(fr)
# momentos do vídeo 05: respiração = olhar para a câmera; "guarda" = quando a música cresce
K = {'respira': _at('Olha para a'), 'pai': _at('Pai eu te'), 'guarda': _at('Cala as vozes'), 'segura': _at('Ela tem valor'),
     'jesus': _at('Em nome de'), 'disse': _at('Se você disse'), 'fim_fala': _W[-1][1]}
P1 = [Am, F, C, G]          # começo: acolhimento
P2 = [F, C, Am, G]          # oração
P3 = [C, G, Am, F]          # depois do amém: mais luminoso
bar = 4 * BEAT
# 1) gancho e acolhimento: pad + piano bem baixinho
t = 0.0
while t < K['respira']:
    ch = P1[int(t / bar) % 4]; pad(t, bar, [m - 12 for m in ch], 0.09, 900); t += bar
arp(1.0, K['respira'] - 0.5, P1, 0.05, 12, True)
# 2) respiração: só pad, subindo devagar
swell(K['respira'], K['pai'] - K['respira'], 0.05)
pad(K['respira'], K['pai'] - K['respira'], [45, 52, 57, 60], 0.1, 700)
# 3) oração: cordas + pad, piano espaçado; cresce na "paz" e na "mão"
t = K['pai']
while t < K['jesus'] + 1.5:
    ch = P2[int((t - K['pai']) / bar) % 4]
    g = 0.06 + (0.03 if t > K['guarda'] else 0) + (0.02 if t > K['segura'] - 2 else 0)
    strings(t, bar, ch, g); pad(t, bar, [m - 12 for m in ch], 0.07, 800)
    piano(t, ch[0] + 12, 0.07, 3.0, 0.15); piano(t + 2 * BEAT, ch[2] + 12, 0.05, 3.0, 0.15)
    t += bar
# 4) amém: brilho
sparkle(K['jesus'] + 1.3)
# 5) depois do amém e chamada final: piano mais luminoso
arp(K['disse'], K['fim_fala'] + 0.5, P3, 0.07, 12, True)
t = K['disse']
while t < K['fim_fala'] + 0.5:
    ch = P3[int((t - K['disse']) / bar) % 4]; pad(t, bar, [m - 12 for m in ch], 0.07, 1100); t += bar
# 6) final: acorde aberto e brilho no sorriso
pad(K['fim_fala'] + 0.4, DUR - K['fim_fala'] - 0.8, [48, 55, 60, 64, 67], 0.1, 1300)
piano(K['fim_fala'] + 0.4, 72, 0.08, 4.0); piano(K['fim_fala'] + 0.4, 76, 0.06, 4.0); piano(K['fim_fala'] + 0.4, 79, 0.05, 4.0)
sparkle(K['fim_fala'] + 0.6)
# fade final e saída
fade = np.minimum(1, np.maximum(0, (DUR - np.arange(N) / SR) / 2.0))[:, None]
out = mix * fade; out /= max(1e-6, np.abs(out).max()) / 0.8
with wave.open(sys.argv[1], 'wb') as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR); w.writeframes((out * 32767).astype('<i2').tobytes())
print('ok', DUR)
