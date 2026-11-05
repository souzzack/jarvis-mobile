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
Bb = [58, 62, 65]
def pluck(st, ch, g=0.07):  # violão dedilhado
    for k, m in enumerate(ch + [ch[0] + 12]): piano(st + k * 0.06, m, g, 1.4, 0.3)
# EU NÃO SOU BOM EM NADA: começo vazio; lembranças dos talentos brilhantes; palco tenso; Moisés e faraó com cordas; memórias quentes; medalhas no céu; final suave
pad(0, 6.3, [45, 52, 57], 0.045, 550); piano(1.2, 57, 0.08, 3.0); piano(4.8, 60, 0.07, 3.0)
arp(6.3, 11.0, [C, G, Am, F], 0.06); sparkle(6.85); sparkle(9.6)
for i, t in enumerate(np.arange(7.85, 9.45, 0.4)): pluck(t, [G, Am, F, C][i % 4], 0.05)
pad(11.0, 1.4, Am, 0.04, 500)
pad(12.1, 5.8, [40, 47, 52], 0.06, 400)
for t in np.arange(12.4, 17.6, 0.8): piano(t, 40, 0.1, 0.8, -0.2); piano(t + 0.25, 40, 0.06, 0.6, -0.2)
for m in [63, 64, 65]: piano(16.4, m, 0.05, 2.0)
pad(17.9, 5.0, Am, 0.045, 700); piano(18.3, 64, 0.07, 3.0)
for i, ch in enumerate([Dm, Am, Dm, Am]): strings(22.9 + i * 1.35, 1.35, [ch[0] - 24, ch[0] - 12] + ch, 0.055)
pad(28.2, 1.7, F, 0.04, 800)
swell(29.0, 0.9, 0.08)
for i, ch in enumerate([Dm, Bb, C, Dm]): strings(29.9 + i * 0.92, 0.92, [ch[0] - 24, ch[0] - 12] + ch, 0.08); piano(29.9 + i * 0.92, ch[0] - 24, 0.13, 1.5)
arp(33.6, 48.7, [F, C, G, Am], 0.065); sparkle(34.0)
strings(41.2, 4.3, [53, 60, 65, 69], 0.05)
pad(48.7, 2.0, F, 0.04, 900)
arp(50.6, 65.0, [C, Am, F, G], 0.06)
for k, m in enumerate([72, 76, 79, 77, 76, 74, 72, 74, 76, 72]): musicbox(51.0 + k * 1.3, m, 0.07)
strings(57.5, 7.5, [48, 55, 60, 64], 0.045); sparkle(56.7)
pad(65.0, 1.6, Am, 0.04, 800)
arp(66.5, 80.8, [F, C, Am, G], 0.065); strings(66.5, 6.0, [53, 57, 60, 65], 0.05); strings(73.2, 4.7, [50, 57, 62, 65], 0.05)
swell(80.0, 0.8, 0.1); strings(80.8, 5.2, [48, 55, 60, 64, 67, 72], 0.09); sparkle(81.2); sparkle(82.6); sparkle(84.2)
for i in range(12): musicbox(81.0 + i * 0.42, [84, 88, 91, 96][i % 4], 0.05)
arp(86.0, 94.6, [F, C, G, Am], 0.065)
pad(91.5, 3.1, [53, 60, 65], 0.04, 900)
swell(94.0, 0.8, 0.08); strings(94.6, 6.0, [48, 55, 60, 64], 0.07); arp(94.6, 100.5, [C, G, F, C], 0.075); sparkle(95.0)
pad(100.5, 6.0, Am, 0.045, 700); piano(100.8, 69, 0.08, 3.0); piano(102.4, 67, 0.07, 3.0); piano(104.0, 64, 0.07, 3.0)
swell(105.8, 0.9, 0.07); strings(106.6, 4.5, [48, 55, 60, 64, 67], 0.08); sparkle(106.8); arp(106.6, 110.6, [C, F, C], 0.07); piano(110.4, 48, 0.1, 1.0)

mix /= np.max(np.abs(mix)) * 1.15
with wave.open(sys.argv[1], "wb") as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes((mix * 32767).astype("<i2").tobytes())
print("ok")
