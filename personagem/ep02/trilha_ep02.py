# Trilha do episódio 2 (100 s): piano, cordas, pads e caixinha de música.
import numpy as np, wave

SR = 48000; DUR = 100.0; N = int(SR * DUR)
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
# 0–5,25: abertura delicada
pad(0.0, 5.0, Am, 0.05, 800)
for k, m in enumerate([76, 72, 69, 71]): piano(0.4 + k * 1.1, m, 0.11, 2.8)
# 5,25–12,9: lembrança da escola (caixinha frágil, menor)
pad(5.25, 7.6, Am, 0.06, 700)
for k, m in enumerate([81, 79, 76, 74, 76, 72, 71, 69, 72, 71]): musicbox(5.5 + k * 0.72, m, 0.12)
piano(10.1, 45, 0.13, 4.0)
# 12,9–25,3: conversa, piano suave (com leveza no humor)
arp(12.9, 25.0, [Am, F, C, G], 0.085)
pad(12.9, 12.2, C, 0.04, 900)
sparkle(15.4); sparkle(24.6)
# 25,3–31,9: tristeza (Lucas, ninguém gosta de mim)
pad(25.3, 6.6, [57, 60, 64], 0.07, 650)
for k, m in enumerate([69, 67, 64, 62, 60]): piano(25.6 + k * 1.25, m, 0.12, 3.0)
piano(29.8, 45, 0.14, 4.0)
# 31,9–42,8: o nome na mão (esperança)
arp(31.9, 42.6, [F, C, G, C], 0.09)
pad(31.9, 10.7, [53, 60, 65, 69], 0.06, 1200)
sparkle(34.5); sparkle(35.4); sparkle(40.6)
# 42,8–58,5: "eu te escolhi antes do mundo" (cresce com cordas)
swell(44.0, 1.6, 0.12)
prog = [F, C, G, Am, F, C, G, C]
t0 = 45.6
for i, ch in enumerate(prog):
    d = 4 * BEAT * 0.82
    strings(t0, d, [ch[0] - 12] + ch, 0.08 + 0.035 * min(1, i / 3))
    piano(t0, ch[0] - 12, 0.14, 3.5); piano(t0 + BEAT, ch[2] + 12, 0.1, 2.5); piano(t0 + 2 * BEAT, ch[1] + 12, 0.1, 2.5)
    t0 += d
pad(42.8, 3.0, Am, 0.05, 800)
# 58,5–65,5: "eu canto" (caixinha alegre)
mel = [72, 76, 79, 84, 83, 79, 76, 77, 81, 84, 83, 79, 77, 76, 79, 72]
for k, m in enumerate(mel): musicbox(59.6 + k * 0.36, m, 0.13)
pad(58.5, 7.0, C, 0.06, 1400)
sparkle(59.7); sparkle(61.0); sparkle(63.6)
# 65,5–73,1: silêncio, notas soltas
piano(65.8, 64, 0.11, 3.5); piano(68.0, 60, 0.1, 3.5); pad(65.5, 7.6, Am, 0.035, 600)
for k, m in enumerate([76, 74, 72]): musicbox(69.4 + k * 1.2, m, 0.08)
# 73,1–87,2: Jesus também ficou sozinho (cordas profundas)
prog = [Am, F, C, G, Am, F, C, G]
t0 = 73.1
for i, ch in enumerate(prog):
    d = 4 * BEAT * 0.75
    strings(t0, d, [ch[0] - 12] + ch, 0.07 + 0.03 * min(1, i / 4))
    piano(t0, ch[0] - 12, 0.13, 3.5); piano(t0 + BEAT, ch[2] + 12, 0.09, 2.5)
    t0 += d
swell(81.0, 1.2, 0.1)
# 87,2–94,2: canção de ninar
lull = [76, 79, 81, 79, 76, 74, 72, 74, 76, 72]
for k, m in enumerate(lull): musicbox(87.5 + k * 0.62, m, 0.12)
pad(87.2, 7.0, [48, 55, 60, 64], 0.06, 900)
# 94,2–100: dia seguinte (luz, alegria)
swell(93.4, 0.8, 0.1); sparkle(94.2)
arp(94.2, 99.2, [C, G, F, C], 0.1, 12)
strings(94.2, 5.0, [48, 60, 64, 67], 0.08)
piano(98.6, 48, 0.12, 2.0); piano(98.6, 72, 0.1, 2.0)

mix /= np.max(np.abs(mix)) * 1.15
with wave.open('trilha_ep02.wav', 'wb') as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes((mix * 32767).astype('<i2').tobytes())
print('ok')
