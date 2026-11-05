# Trilha do episódio 2 (100 s): piano, cordas, pads e caixinha de música.
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
# vergonha de ser cristão: começo tímido; Pedro com cordas graves; "cidade no monte" abre; final corajoso e alegre
pad(0, 5.1, [45, 52, 57], 0.04, 500); piano(1.0, 57, 0.08, 3.0)
arp(5.1, 10.6, [C, Am, F, G], 0.06); sparkle(7.6)
pad(10.6, 5.4, Am, 0.05, 700)
for k, m in enumerate([76, 74, 72, 71, 69]): musicbox(10.8 + k * 0.9, m, 0.08)
pad(16.0, 17.8, [45, 52, 57, 60], 0.05, 650); piano(16.2, 45, 0.12, 3.5); piano(24.2, 64, 0.08, 3.0); piano(29.3, 60, 0.08, 3.0)
prog = [Am, F, Dm, Am]; t0 = 33.8
for ch in prog: strings(t0, 1.45, [ch[0] - 24, ch[0] - 12] + ch, 0.06); t0 += 1.45
arp(39.6, 47.4, [F, C, G, Am], 0.07)
swell(46.6, 1.0, 0.08); strings(47.4, 4.2, [48, 55, 60, 64, 67], 0.08); sparkle(47.6)
pad(51.6, 8.0, Am, 0.045, 800); piano(54.4, 60, 0.09, 3.0)
swell(58.8, 1.0, 0.1)
prog = [C, G, Am, F]; t0 = 59.6
for ch in prog: strings(t0, 1.75, [ch[0] - 12] + ch, 0.08); piano(t0, ch[0] - 12, 0.12, 2.5); t0 += 1.75
arp(66.6, 84.5, [F, C, G, C], 0.07); sparkle(74.8); sparkle(81.9)
pad(84.5, 4.8, [48, 55, 60], 0.05, 1000); piano(84.8, 60, 0.1, 3.0)
for i in range(16): piano(89.3 + i * 0.3, [60, 64, 67, 72][i % 4] + (12 if i > 7 else 0), 0.06 + 0.003 * i, 1.5)
strings(89.3, 5.0, [48, 55, 60, 64], 0.07)
swell(93.6, 0.8, 0.08); sparkle(94.4); arp(94.3, 99.6, [C, G, F, C], 0.09); piano(99.4, 48, 0.1, 1.0)

mix /= np.max(np.abs(mix)) * 1.15
with wave.open(sys.argv[1], 'wb') as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes((mix * 32767).astype('<i2').tobytes())
print('ok')
