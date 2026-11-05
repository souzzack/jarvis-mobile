# Trilha instrumental + efeitos sonoros sintetizados (30 s, 48 kHz, estéreo).
import numpy as np, wave

SR = 48000; DUR = 30.0; N = int(SR * DUR)
t_all = np.arange(N) / SR
mix = np.zeros((N, 2))
rng = np.random.default_rng(3)

def note(m): return 440.0 * 2 ** ((m - 69) / 12)
def add(sig, start, gain=1.0, pan=0.0):
    i = int(start * SR); j = min(N, i + len(sig))
    if j <= i: return
    l = np.cos((pan + 1) * np.pi / 4); r = np.sin((pan + 1) * np.pi / 4)
    mix[i:j, 0] += sig[: j - i] * gain * l; mix[i:j, 1] += sig[: j - i] * gain * r
def env(n, a, d, s=0.0, r=0.0):
    e = np.ones(n); A = int(a * SR); D = int(d * SR); R = int(r * SR)
    e[:A] = np.linspace(0, 1, A) if A else e[:A]
    e[A:A + D] = np.linspace(1, s, len(e[A:A + D]))
    e[A + D:] = s
    if R: e[-R:] *= np.linspace(1, 0, R)
    return e
def lowpass(x, fc):
    a = np.exp(-2 * np.pi * fc / SR); y = np.zeros_like(x); acc = 0.0
    for k in range(len(x)): acc = (1 - a) * x[k] + a * acc; y[k] = acc
    return y

BEAT = 0.6  # 100 BPM
CHORDS = [[57, 60, 64], [53, 57, 60], [48, 52, 55], [55, 59, 62]]  # Lá m, Fá, Dó, Sol
BAR = 4 * BEAT
# Pad: entra suave desde o início
for b in range(int(DUR / BAR) + 1):
    ch = CHORDS[b % 4]; start = b * BAR; n = int((BAR + 0.6) * SR)
    tt = np.arange(n) / SR
    s = sum(np.sin(2 * np.pi * note(m) * tt) + 0.3 * np.sin(2 * np.pi * 2 * note(m) * tt + 0.5) for m in ch) / 3
    add(s * env(n, 0.5, 0.3, 0.8, 0.6), start, 0.16, pan=-0.2)
    add(np.sin(2 * np.pi * note(ch[0] + 12) * 1.003 * tt) * env(n, 0.6, 0.3, 0.7, 0.6), start, 0.05, pan=0.3)
# Ritmo a partir da batida da régua (3,5 s)
GROOVE = 3.5
for k in range(int((DUR - GROOVE) / (BEAT / 2))):
    st = GROOVE + k * BEAT / 2; b = int(st / BAR); ch = CHORDS[b % 4]
    # arpejo em colcheias
    m = ch[k % 3] + 12 + (12 if k % 8 == 7 else 0)
    n = int(0.35 * SR); tt = np.arange(n) / SR
    tri = 2 / np.pi * np.arcsin(np.sin(2 * np.pi * note(m) * tt))
    add(tri * np.exp(-tt * 9), st, 0.07, pan=0.35 if k % 2 else -0.35)
    if k % 2 == 0:
        # baixo
        n = int(0.5 * SR); tt = np.arange(n) / SR
        add(np.sin(2 * np.pi * note(ch[0] - 12) * tt) * np.exp(-tt * 4), st, 0.22)
        # bumbo nos tempos 1 e 3
        if (k // 2) % 2 == 0:
            n = int(0.25 * SR); tt = np.arange(n) / SR
            f = 50 + 90 * np.exp(-tt * 30)
            add(np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-tt * 14), st, 0.35)
    else:
        # chimbal
        n = int(0.06 * SR); hh = rng.standard_normal(n); hh = hh - lowpass(hh, 6000)
        add(hh * np.exp(-np.arange(n) / SR * 60), st, 0.05, pan=0.2)
# Final: acorde sustentado
n = int(4 * SR); tt = np.arange(n) / SR
add(sum(np.sin(2 * np.pi * note(m) * tt) for m in [57, 60, 64, 69]) / 4 * env(n, 0.3, 0.5, 0.7, 2.5), 27.0, 0.14)

# ---- Efeitos
def sfx_powerup(start):
    n = int(0.6 * SR); tt = np.arange(n) / SR
    f = 500 + 900 * tt / 0.6
    add(np.sin(2 * np.pi * np.cumsum(f) / SR) * np.sin(np.pi * tt / 0.6) ** 2, start, 0.12)
def sfx_key(start):
    n = int(0.12 * SR); tt = np.arange(n) / SR
    cl = rng.standard_normal(n) * np.exp(-tt * 120)
    add(cl - lowpass(cl, 1500), start, 0.5)
    add(np.sin(2 * np.pi * 120 * tt) * np.exp(-tt * 40), start, 0.35)
def sfx_whoosh(start, d=0.5):
    n = int(d * SR); tt = np.arange(n) / SR
    nz = rng.standard_normal(n); nz = lowpass(nz, 2500) - lowpass(nz, 400)
    add(nz * np.sin(np.pi * tt / d) ** 2, start, 0.5, pan=0.3)
def sfx_ding(start, m):
    n = int(0.9 * SR); tt = np.arange(n) / SR
    s = np.sin(2 * np.pi * note(m) * tt) + 0.3 * np.sin(2 * np.pi * note(m) * 2.76 * tt)
    add(s * np.exp(-tt * 5), start, 0.1, pan=0.25)
def sfx_step(start):
    n = int(0.05 * SR); tt = np.arange(n) / SR
    add(np.sin(2 * np.pi * 300 * tt) * np.exp(-tt * 90), start, 0.12)

sfx_powerup(0.9)
sfx_key(3.48)
for k in range(5): sfx_step(6 + 0.17 + k * 0.35)
for st in [12 + 1.5, 12 + 2.4, 12 + 3.4]: sfx_whoosh(st)
for k, m in enumerate([84, 86, 88, 91, 93]): sfx_ding(18 + 3.6 + k * 0.28, m)
sfx_step(18 + 5.42)
for k, m in enumerate([81, 84, 88, 93]): sfx_ding(24 + 3.0 + k * 0.12, m)

mix /= np.max(np.abs(mix)) * 1.12
with wave.open('trilha.wav', 'wb') as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes((mix * 32767).astype('<i2').tobytes())
print('ok')
