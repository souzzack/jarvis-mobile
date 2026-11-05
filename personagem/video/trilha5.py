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

BEAT = 0.5  # 120 BPM
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
GROOVE = 2.0
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
# Camada que aparece no alto-falante do celular: palmas, chimbal em semicolcheias e synth brilhante
for k in range(int((DUR - GROOVE) / (BEAT / 4))):
    st = GROOVE + k * BEAT / 4
    n = int(0.04 * SR); hh = rng.standard_normal(n); hh = hh - lowpass(hh, 7000)
    add(hh * np.exp(-np.arange(n) / SR * 90), st, 0.09 if k % 2 else 0.05, pan=-0.25)
    if k % 8 == 4:
        n = int(0.22 * SR); tt = np.arange(n) / SR; cl = rng.standard_normal(n)
        cl = lowpass(cl, 5000) - lowpass(cl, 900)
        env_c = np.exp(-tt * 22) + 0.6 * np.exp(-np.maximum(0, tt - 0.012) * 30) * (tt > 0.012)
        add(cl * env_c, st, 0.55)
for k in range(int((DUR - GROOVE) / (BEAT / 2))):
    st = GROOVE + k * BEAT / 2; b = int(st / BAR); ch = CHORDS[b % 4]
    if k % 4 in (0, 3) or k % 8 == 6:
        n = int(0.22 * SR); tt = np.arange(n) / SR; f = note(ch[(k // 2) % 3] + 24)
        saw = sum(np.sin(2 * np.pi * f * h * tt) / h for h in range(1, 7))
        add(saw * np.exp(-tt * 10), st, 0.06, pan=0.3)
# baixo com harmônicos (soa em alto-falante pequeno)
for k in range(int((DUR - GROOVE) / BEAT)):
    st = GROOVE + k * BEAT; b = int(st / BAR); ch = CHORDS[b % 4]
    n = int(0.42 * SR); tt = np.arange(n) / SR; f = note(ch[0] - 12)
    s = np.tanh(3.0 * np.sin(2 * np.pi * f * tt)) * 0.6 + 0.4 * np.sin(2 * np.pi * 2 * f * tt)
    add(lowpass(s, 1800) * np.exp(-tt * 5), st, 0.16)

# Final: acorde sustentado
n = int(4 * SR); tt = np.arange(n) / SR
add(sum(np.sin(2 * np.pi * note(m) * tt) for m in [57, 60, 64, 69]) / 4 * env(n, 0.3, 0.5, 0.7, 2.5), 26.5, 0.14)

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

def sfx_riser(start, d):
    n = int(d * SR); tt = np.arange(n) / SR
    nz = rng.standard_normal(n); nz = nz - lowpass(nz, 300 + 2000 * tt[-1])
    f = 200 + 1200 * (tt / d) ** 2
    add((nz * 0.5 + np.sin(2 * np.pi * np.cumsum(f) / SR) * 0.4) * (tt / d) ** 2, start, 0.35)
def sfx_boom(start, g=0.8):
    n = int(1.2 * SR); tt = np.arange(n) / SR
    f = 35 + 120 * np.exp(-tt * 12)
    add(np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-tt * 3.5), start, g)
    nz = rng.standard_normal(int(0.3 * SR)); add(lowpass(nz, 3000) * np.exp(-np.arange(len(nz)) / SR * 14), start, 0.4)
def sfx_thump(start):
    n = int(0.3 * SR); tt = np.arange(n) / SR
    add(np.sin(2 * np.pi * (60 + 140 * np.exp(-tt * 25)) * tt) * np.exp(-tt * 12), start, 0.45)

# gancho: pulso grave + tique-taque; impacto em "AMADOR?"; subida até o drop em 2,0 s
for k in range(8):
    n = int(0.05 * SR); tt = np.arange(n) / SR
    add(np.sin(2 * np.pi * 1800 * tt) * np.exp(-tt * 120), k * 0.25, 0.06)
sfx_boom(0.0, 0.35)
sfx_boom(0.9, 0.7); sfx_thump(0.9)
sfx_riser(1.05, 0.95)
sfx_boom(2.0, 0.85)
sfx_key(2.98); sfx_thump(2.98)
for c in [5.5, 10.0, 15.0, 19.5, 24.0]: sfx_whoosh(c - 0.22, 0.42)
for c in [7.6, 12.6, 17.4, 21.8]: sfx_whoosh(c - 0.1, 0.22)
for k in range(8): sfx_step(5.55 + k * 0.24)
for st in [3.6, 7.45, 8.85, 10.92, 11.49, 12.2, 13.55, 16.88, 17.39, 17.85, 20.55, 21.32, 21.74, 22.38, 24.7, 26.72, 27.54]: sfx_thump(st)
for st in [10.8, 11.37, 12.08]: sfx_whoosh(st, 0.3)
sfx_step(18.3); sfx_step(22.55)
for k, m in enumerate([84, 88, 91, 96]): sfx_ding(21.8 + k * 0.09, m)
for k, m in enumerate([81, 84, 88, 93]): sfx_ding(27.54 + k * 0.12, m)
sfx_ding(28.3, 96)
mix /= np.max(np.abs(mix)) * 1.12
with wave.open('trilha.wav', 'wb') as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes((mix * 32767).astype('<i2').tobytes())
print('ok')
