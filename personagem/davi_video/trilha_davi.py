# Trilha emocional do vídeo do Davi (95 s): piano, cordas, pads e caixinha de música.
import numpy as np, wave

SR = 48000; DUR = 95.0; N = int(SR * DUR)
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
BEAT = 60 / 76

# 0–23: leve e brincalhão (piano dedilhado)
prog = [C, G, Am, F]
t0 = 0.8
while t0 < 22.5:
    ch = prog[int((t0 - 0.8) / (4 * BEAT)) % 4]
    k = int(round((t0 - 0.8) / (BEAT / 2)))
    piano(t0, ch[[0, 1, 2, 1][k % 4]] + 12, 0.11 + (0.03 if k % 4 == 0 else 0), 1.6, 0.2)
    if k % 8 == 0: piano(t0, ch[0] - 12, 0.12, 3.0, -0.2)
    t0 += BEAT / 2
pad(0.0, 22.0, C, 0.05, 900)
sparkle(4.31)
# 23–30,8: confissão (menor, esparso)
pad(23.0, 7.6, Am, 0.08, 700)
for k, m in enumerate([69, 67, 64, 62, 64]): piano(23.4 + k * 1.5, m, 0.12, 3.0)
piano(23.0, 45, 0.14, 4.0)
# 30,8–50,5: acolhimento (cresce devagar)
prog = [F, C, G, Am]
t0 = 30.8
while t0 < 50.0:
    i = int((t0 - 30.8) / (4 * BEAT)); ch = prog[i % 4]
    pad(t0, 4 * BEAT, ch, 0.07 + 0.02 * min(1, (t0 - 30.8) / 15), 1000 + 60 * (t0 - 30.8))
    for j in range(4): piano(t0 + j * BEAT, ch[j % 3] + 12, 0.1, 2.0, 0.15)
    piano(t0, ch[0] - 12, 0.12, 3.2)
    t0 += 4 * BEAT
sparkle(38.2); sparkle(45.3)
# 50,5–57,7: nascer do sol (cordas + pad cheio)
swell(48.9, 1.6, 0.14)
strings(50.5, 7.0, [48, 55, 60, 64, 67], 0.12)
pad(50.5, 7.0, [48, 55, 60, 64], 0.09, 2200)
for k, m in enumerate([72, 74, 76, 79, 76, 74, 72]): piano(50.6 + k * 1.0, m, 0.13, 2.5)
# 57,7–64,6: leve de novo
t0 = 57.7
while t0 < 64.4:
    k = int(round((t0 - 57.7) / (BEAT / 2))); ch = [C, G][int((t0 - 57.7) / (4 * BEAT)) % 2]
    piano(t0, ch[[0, 2, 1, 2][k % 4]] + 12, 0.09, 1.4, 0.2); t0 += BEAT / 2
pad(57.7, 6.8, C, 0.05, 1000)
sparkle(61.4); sparkle(62.4)
# 64,6–67,9: silêncio quase total, uma nota
piano(64.9, 64, 0.12, 3.5); pad(64.6, 3.3, Am, 0.04, 600)
# 67,9–81,8: auge emocional
prog = [Am, F, C, G, Am, F, C, G]
t0 = 67.9
for i, ch in enumerate(prog):
    d = 4 * BEAT * (0.82 if i < 4 else 0.82)
    strings(t0, d, [ch[0] - 12] + ch, 0.09 + 0.03 * min(1, i / 3))
    piano(t0, ch[0] - 12, 0.14, 3.5); piano(t0 + BEAT, ch[2] + 12, 0.1, 2.5); piano(t0 + 2 * BEAT, ch[1] + 12, 0.1, 2.5)
    t0 += d
swell(70.6, 1.3, 0.12)
# 81,8–95: canção de ninar (caixinha de música)
lull = [76, 79, 81, 79, 76, 74, 72, 74, 76, 72, 67, 72]
for k, m in enumerate(lull): musicbox(82.2 + k * 0.62, m, 0.13)
pad(81.8, 12.0, [48, 55, 60, 64], 0.07, 900)
for k, m in enumerate([72, 76, 79, 84]): musicbox(90.0 + k * 0.4, m, 0.1)
piano(92.0, 48, 0.12, 3.0); piano(92.0, 60, 0.1, 3.0)

mix /= np.max(np.abs(mix)) * 1.15
with wave.open('trilha_davi.wav', 'wb') as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes((mix * 32767).astype('<i2').tobytes())
print('ok')
