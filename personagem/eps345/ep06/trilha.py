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
# primeiro amor: delicado e esperançoso; lembranças com caixinha de música; semente com piano subindo; cidade com cordas
arp(0.3, 8.3, [C, Am, F, G], 0.07)
pad(0, 8.3, C, 0.04, 900)
mel = [76, 79, 81, 79, 76, 74, 76, 72, 74, 76, 79, 84, 81, 79]
for k, m in enumerate(mel): musicbox(8.4 + k * 0.55, m, 0.11)
pad(8.3, 7.9, [48, 55, 60, 64], 0.05, 1200)
arp(16.2, 23.2, [F, C, G, C], 0.075); sparkle(18.3)
for k, m in enumerate(mel[::-1]): musicbox(23.3 + k * 0.5, m, 0.1)
pad(23.2, 7.1, [53, 60, 65, 69], 0.05, 1200)
pad(30.3, 5.4, Am, 0.05, 600); piano(30.5, 57, 0.1, 3.5); piano(32.6, 60, 0.09, 3.5)
arp(35.7, 54.9, [Am, F, C, G], 0.07); sparkle(42.0)
t0 = 54.9
for i in range(16):
    piano(t0 + i * 0.6, [60, 64, 67, 72, 64, 67, 72, 76][i % 8] + (12 if i > 7 else 0), 0.08 + 0.004 * i, 2.0)
strings(56.0, 8.4, [48, 55, 60, 64, 67], 0.08); swell(58.5, 1.0, 0.08); sparkle(63.5)
pad(64.6, 7.7, [45, 52, 57, 60], 0.06, 600); piano(64.9, 45, 0.13, 4.0); piano(68.9, 64, 0.08, 3.0)
swell(76.2, 1.0, 0.1)
prog = [F, C, G, Am, F, C, G, C]; t0 = 77.2
for i, ch in enumerate(prog):
    d = 4 * BEAT * 0.75; strings(t0, d, [ch[0] - 12] + ch, 0.08 + 0.03 * min(1, i / 3)); piano(t0, ch[0] - 12, 0.13, 3.5); piano(t0 + BEAT, ch[2] + 12, 0.1, 2.5); t0 += d
arp(85.0, 101.4, [C, G, Am, F], 0.07); sparkle(89.4); sparkle(92.7)
pad(101.5, 5.8, C, 0.05, 1000)
for k, m in enumerate([72, 76, 79, 84, 79, 76]): musicbox(101.7 + k * 0.7, m, 0.1)
arp(107.3, 118.0, [F, C, G, C], 0.075)
strings(116.5, 6.0, [48, 55, 60, 64], 0.07); sparkle(118.3)
lull = [76, 79, 81, 79, 76, 74, 72, 74, 76, 72]
for k, m in enumerate(lull): musicbox(122.4 + k * 0.55, m, 0.1)
pad(122.3, 5.5, [48, 55, 60, 64], 0.05, 900)

mix /= np.max(np.abs(mix)) * 1.15
with wave.open(sys.argv[1], 'wb') as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes((mix * 32767).astype('<i2').tobytes())
print('ok')
