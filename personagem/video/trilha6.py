# Trilha + efeitos do vídeo "Coisas que ninguém te conta sobre ser uma IA" (38 s, 48 kHz, estéreo).
# Mixada para soar bem também em alto-falante de celular (palmas, chimbal, synth brilhante, baixo com harmônicos).
import numpy as np, wave

SR = 48000; DUR = 38.0; N = int(SR * DUR)
mix = np.zeros((N, 2))
rng = np.random.default_rng(11)

def note(m): return 440.0 * 2 ** ((m - 69) / 12)
def add(sig, start, gain=1.0, pan=0.0):
    i = int(start * SR); j = min(N, i + len(sig))
    if j <= i or i < 0: return
    l = np.cos((pan + 1) * np.pi / 4); r = np.sin((pan + 1) * np.pi / 4)
    mix[i:j, 0] += sig[: j - i] * gain * l; mix[i:j, 1] += sig[: j - i] * gain * r
def lowpass(x, fc):
    a = np.exp(-2 * np.pi * fc / SR); y = np.zeros_like(x); acc = 0.0
    for k in range(len(x)): acc = (1 - a) * x[k] + a * acc; y[k] = acc
    return y
def tt_(d): return np.arange(int(d * SR)) / SR

BEAT = 0.5; BAR = 4 * BEAT
CHORDS = [[57, 60, 64], [53, 57, 60], [48, 52, 55], [55, 59, 62]]
def chord_at(t): return CHORDS[int(t / BAR) % 4]

# ---------- instrumentos
def kick(st, g=0.5):
    t = tt_(0.3); f = 50 + 110 * np.exp(-t * 30)
    add(np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t * 12), st, g)
def clap(st, g=0.5):
    t = tt_(0.22); n = rng.standard_normal(len(t)); n = lowpass(n, 5000) - lowpass(n, 900)
    add(n * (np.exp(-t * 22) + 0.6 * np.exp(-np.maximum(0, t - 0.012) * 30) * (t > 0.012)), st, g)
def hat(st, g=0.07, pan=-0.25):
    t = tt_(0.04); n = rng.standard_normal(len(t)); n = n - lowpass(n, 7000)
    add(n * np.exp(-t * 90), st, g, pan)
def bass(st, m, g=0.2, d=0.42):
    t = tt_(d); f = note(m)
    s = np.tanh(3.0 * np.sin(2 * np.pi * f * t)) * 0.6 + 0.4 * np.sin(2 * np.pi * 2 * f * t)
    add(lowpass(s, 1800) * np.exp(-t * 5), st, g)
def pluck(st, m, g=0.06, pan=0.3):
    t = tt_(0.25); f = note(m)
    s = sum(np.sin(2 * np.pi * f * h * t) / h for h in range(1, 7))
    add(s * np.exp(-t * 10), st, g, pan)
def pad(st, d, ch, g=0.12):
    t = tt_(d + 0.5)
    s = sum(np.sin(2 * np.pi * note(m) * t) + 0.25 * np.sin(2 * np.pi * 2 * note(m) * t + 0.4) for m in ch) / len(ch)
    e = np.minimum(1, t / 0.4) * np.minimum(1, np.maximum(0, (d + 0.5 - t) / 0.5))
    add(s * e, st, g, -0.15)

def groove(a, b, level=1.0, drums=True):
    t = a
    while t < b - 1e-6:
        k = int(round((t - a) / (BEAT / 4)))
        if drums:
            hat(t, (0.09 if k % 2 else 0.05) * level)
            if k % 8 == 0: kick(t, 0.5 * level)
            if k % 8 == 4: clap(t, 0.5 * level)
            if k % 16 == 10: kick(t, 0.35 * level)
        if k % 2 == 0:
            ch = chord_at(t)
            if k % 4 == 0: bass(t, ch[0] - 12, 0.2 * level)
            if (k // 2) % 4 in (0, 3) or (k // 2) % 8 == 6: pluck(t, ch[(k // 2) % 3] + 24, 0.06 * level)
        t += BEAT / 4
    b0 = a
    while b0 < b - 1e-6:
        pad(b0, min(BAR, b - b0), chord_at(b0), 0.1 * level); b0 += BAR

# ---------- efeitos
def boom(st, g=0.7):
    t = tt_(1.2); f = 35 + 120 * np.exp(-t * 12)
    add(np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t * 3.5), st, g)
def thump(st, g=0.45):
    t = tt_(0.3); add(np.sin(2 * np.pi * (60 + 140 * np.exp(-t * 25)) * t) * np.exp(-t * 12), st, g)
def whoosh(st, d=0.42, g=0.45):
    t = tt_(d); n = rng.standard_normal(len(t)); n = lowpass(n, 2500) - lowpass(n, 400)
    add(n * np.sin(np.pi * t / d) ** 2, st, g, 0.3)
def ding(st, m, g=0.12):
    t = tt_(0.9); s = np.sin(2 * np.pi * note(m) * t) + 0.3 * np.sin(2 * np.pi * note(m) * 2.76 * t)
    add(s * np.exp(-t * 5), st, g, 0.2)
def riser(st, d, g=0.35):
    t = tt_(d); n = rng.standard_normal(len(t)); n = n - lowpass(n, 1200)
    f = 220 + 1600 * (t / d) ** 2
    add((n * 0.5 + np.sin(2 * np.pi * np.cumsum(f) / SR) * 0.45) * (t / d) ** 2, st, g)
def scratch(st):
    # disco arranhando: ruído filtrado com tom que desce e sobe rápido
    t = tt_(0.32); f = 900 - 700 * np.sin(np.pi * t / 0.32)
    s = np.sin(2 * np.pi * np.cumsum(f) / SR) * 0.6 + (lowpass(rng.standard_normal(len(t)), 3000) * 0.7)
    add(s * np.sin(np.pi * t / 0.32) ** 0.5, st, 0.5)
def clonc(st, g=0.6):
    # régua de plástico batendo na tecla (e quicando)
    for d, gg in [(0, 1.0), (0.17, 0.45), (0.27, 0.2)]:
        t = tt_(0.18); n = rng.standard_normal(len(t)); n = lowpass(n, 4000) - lowpass(n, 700)
        tone = np.sin(2 * np.pi * 980 * t) * 0.6 + np.sin(2 * np.pi * 1530 * t) * 0.35
        add((n * 0.7 + tone) * np.exp(-t * 38), st + d, g * gg)
def tick(st, g=0.08, f=1800):
    t = tt_(0.04); add(np.sin(2 * np.pi * f * t) * np.exp(-t * 120), st, g)
def whirr(st, d):
    t = tt_(d); f = 300 + 1500 * (t / d)
    add(np.sin(2 * np.pi * np.cumsum(f) / SR) * 0.35 * np.minimum(1, t / 0.2), st, 0.25)
def choir(st, d=0.75):
    # "aaah" de anjo: acorde de serras com vibrato, filtrado
    t = tt_(d); s = 0
    for m in [69, 73, 76, 81]:
        f = note(m) * (1 + 0.006 * np.sin(2 * np.pi * 5.5 * t))
        s = s + sum(np.sin(2 * np.pi * np.cumsum(f * h) / SR) / h for h in range(1, 6))
    e = np.minimum(1, t / 0.05) * np.minimum(1, (d - t) / 0.3)
    add(lowpass(s / 4, 3500) * e, st, 0.32)
def boing(st):
    t = tt_(0.45); f = 220 + 160 * np.sin(2 * np.pi * 9 * t) * np.exp(-t * 4)
    add(np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t * 5), st, 0.4)
def pop(st):
    t = tt_(0.08); add(np.sin(2 * np.pi * (1200 - 6000 * t) * t) * np.exp(-t * 60), st, 0.4)
def rewind(st, d=0.6):
    t = tt_(d); f = 1500 - 1300 * (t / d)
    s = np.sin(2 * np.pi * np.cumsum(f) / SR) * 0.4 + lowpass(rng.standard_normal(len(t)), 2000) * 0.3
    add(s * np.sin(np.pi * t / d), st, 0.4)

# ---------- linha do tempo
# 0–3: abertura de "documentário": grave, tum, falha da estrela, disco arranhando
t = tt_(2.9); add(np.sin(2 * np.pi * 55 * t) * np.minimum(1, t / 0.6) * 0.5 + np.sin(2 * np.pi * 82.4 * t) * 0.25, 0.0, 0.5)
boom(0.1, 0.55); boom(1.85, 0.6); thump(1.85)
tick(2.5, 0.1, 2600); tick(2.68, 0.1, 2600)
scratch(2.72)
# 3–12,6: groove
groove(3.0, 12.6)
thump(3.1); whoosh(2.85); thump(6.3)
clonc(7.35); ding(7.36, 88, 0.08)
thump(9.1); whoosh(8.85); thump(11.6)
# 12,6–15: silêncio total (só ele balançando)
# 15–21: relógio; 17,4–19,3 avanço rápido; "pling" no 900/900
whoosh(14.85); thump(15.1)
for k in range(int((17.4 - 15.0) / 0.5)): tick(15.0 + k * 0.5, 0.12, 1700 if k % 2 else 2200)
tt0 = 17.4
while tt0 < 19.3:
    tick(tt0, 0.09, 2400); tt0 += max(0.035, 0.25 * (1 - (tt0 - 17.4) / 1.9))
whirr(17.4, 1.9)
for k, m in enumerate([84, 88, 91, 96]): ding(19.3 + k * 0.08, m, 0.12)
pad(19.4, 1.6, [53, 57, 60], 0.08)
groove(20.0, 21.0, 0.5, drums=False)
# 21–24,2: groove leve + subida; BLAM + coro em 24,2
whoosh(20.85); thump(21.1)
groove(21.0, 24.2, 0.7)
riser(22.7, 1.5)
boom(24.2, 0.9); choir(24.22)
groove(25.0, 27.0, 0.85)
thump(24.85)
# 27–33: momento sincero (sem bateria)
whoosh(26.85, 0.5, 0.3)
groove(27.0, 33.0, 0.8, drums=False)
thump(31.7, 0.35)
# 33–38: volta a batida; tombo, pose e erros de gravação
whoosh(32.85)
groove(33.0, 37.0)
boing(34.3); pop(35.3); ding(35.3, 93, 0.1)
for k, m in enumerate([81, 84, 88, 93]): ding(36.0 + k * 0.1, m, 0.1)
rewind(37.0); pop(37.6)

mix[int(12.6 * SR):int(14.84 * SR)] = 0   # corte seco: a música para e fica só o silêncio
mix /= np.max(np.abs(mix)) * 1.1
with wave.open('trilha6.wav', 'wb') as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes((mix * 32767).astype('<i2').tobytes())
print('ok')
