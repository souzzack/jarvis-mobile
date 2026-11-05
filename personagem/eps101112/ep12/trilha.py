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
def rip(st, d=0.35, g=0.25):  # papel rasgando
    t = tt(d); n = rng.standard_normal(len(t)); n = n - lowpass(n, 1500); env = np.exp(-t * 4) * (0.6 + 0.4 * np.abs(np.sin(t * 90)))
    add(n * env, st, g, 0.1)
def chalk(st, d, g=0.05):  # giz riscando
    t = tt(d); n = rng.standard_normal(len(t)); n = n - lowpass(n, 3000); env = (0.5 + 0.5 * np.sin(2 * np.pi * 7 * t)) ** 2 * np.minimum(1, (d - t) / 0.1)
    add(n * env, st, g, 0.3)
# EU TENHO RAIVA DE MIM: pulso tenso, papel rasgando, giz na parede; a luz apaga as frases; piano e cordas crescem; final caloroso
for t in np.arange(0.2, 3.4, 0.5): piano(t, 45, 0.1, 0.7, -0.2)
rip(2.35); rip(2.7, 0.25, 0.15)
pad(3.4, 14.6, [40, 47, 52], 0.06, 420); piano(4.0, 52, 0.07, 3.5); piano(9.5, 55, 0.06, 3.5)
for a, b in [[13.7, 14.4], [14.9, 15.8], [16.1, 17.4]]: chalk(a, b - a)
for m in [63, 64, 65]: piano(16.2, m, 0.04, 2.0)
pad(18.0, 18.0, Am, 0.04, 700)
for i, t in enumerate(np.arange(18.4, 36.0, 2.2)): piano(t, [57, 53, 60, 55][i % 4], 0.08, 3.2); piano(t + 1.1, [64, 60, 64, 62][i % 4], 0.06, 2.8)
strings(36.0, 5.0, [45, 52, 57, 60], 0.05); swell(38.6, 0.8, 0.07); sparkle(39.5)
arp(41.3, 48.4, [F, C, Dm, Am], 0.055); strings(41.3, 7.0, [53, 57, 60, 65], 0.045)
pad(48.4, 1.6, F, 0.04, 900)
pad(50.0, 7.5, [48, 55, 60, 64], 0.045, 1000)
for k in range(14): musicbox(50.3 + k * 0.5, [79, 84, 88, 86, 84, 91, 88][k % 7], 0.05)
arp(57.5, 66.6, [F, C, G, Am], 0.06); swell(58.9, 0.8, 0.07); sparkle(59.7); swell(61.6, 0.7, 0.06); sparkle(62.3)
pad(64.1, 2.5, Am, 0.04, 800)
arp(66.6, 87.2, [F, C, Am, G], 0.065); strings(66.6, 6.4, [53, 60, 65, 69], 0.05); sparkle(68.1); strings(73.0, 4.4, [48, 55, 60, 64], 0.055); sparkle(74.1)
strings(77.4, 3.0, [45, 52, 57, 60], 0.045); sparkle(80.7); strings(80.4, 6.8, [53, 57, 60, 65], 0.05)
strings(87.2, 6.2, [48, 55, 60, 64, 67], 0.06); arp(87.2, 93.4, [C, G, Am, F], 0.06)
pad(93.4, 3.5, [48, 55, 60], 0.045, 900); piano(93.8, 72, 0.06, 3.0); piano(95.0, 67, 0.05, 3.0)
swell(96.3, 0.8, 0.08); strings(96.9, 6.0, [48, 55, 60, 64, 72], 0.08); arp(96.9, 102.9, [C, G, F, C], 0.075); sparkle(97.3)
arp(102.9, 111.8, [C, Am, F, G], 0.07); strings(105.0, 6.5, [48, 55, 60, 64], 0.05)
for i in range(30): add(np.zeros(1), 0)
chalk(106.4, 2.8, 0.03); swell(108.8, 0.8, 0.07); sparkle(109.5); strings(109.5, 3.0, [48, 55, 60, 64, 67, 72], 0.07); piano(111.6, 48, 0.1, 1.0)

mix /= np.max(np.abs(mix)) * 1.15
with wave.open(sys.argv[1], "wb") as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes((mix * 32767).astype("<i2").tobytes())
print("ok")
