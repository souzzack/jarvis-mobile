# Trilha sintetizada do capítulo 1 de "Entrega 23:47" (sem música de terceiros).
# Chuva (ruído filtrado), tapete escuro em Ré menor, pulso grave a 84 bpm, batidas nos momentos-chave.
# Uso: python3 trilha_cap01.py <saida.wav>   (gera 72 s, 48 kHz, estéreo)
import sys, wave
import numpy as np
SR, DUR = 48000, 72.0
t = np.arange(int(SR * DUR)) / SR
rng = np.random.default_rng(23)
def env(a, b, ataque=1.0, saida=1.5):
    return np.clip((t - a) / ataque, 0, 1) * np.clip((b - t) / saida, 0, 1)
def lowpass(x, fc):
    a = np.exp(-2 * np.pi * fc / SR); y = np.empty_like(x); acc = 0.0
    for i in range(len(x)): acc = (1 - a) * x[i] + a * acc; y[i] = acc
    return y
def nota(f): return 440 * 2 ** ((f - 69) / 12)
L = np.zeros_like(t); R = np.zeros_like(t)
# 1) chuva: ruído rosado-ish com pingos; mais forte na rua (0–35 s), abafada dentro do prédio
chuva = lowpass(rng.standard_normal(len(t)), 2500) - lowpass(rng.standard_normal(len(t)), 300) * 0.5
nivel_chuva = 0.10 * env(0, 35.5, 0.5, 1.5) + 0.03 * env(35, 67.4, 1, 0.3)
L += chuva * nivel_chuva; R += np.roll(chuva, 331) * nivel_chuva
# 2) tapete escuro: acordes de Ré menor / Si bemol / Fá / Lá (cada 8 s), dente-de-serra suave filtrado
acordes = [[50, 57, 62, 65], [46, 53, 58, 62], [41, 53, 57, 60], [45, 52, 57, 61]]
pad = np.zeros_like(t)
for k in range(9):
    a = k * 8.0; ac = acordes[k % 4]
    for n in ac:
        f = nota(n); ph = 2 * np.pi * f * t
        pad += (np.sin(ph) + 0.3 * np.sin(2 * ph + 0.4) + 0.12 * np.sin(3 * ph)) * env(a, a + 8.6, 1.2, 1.2) * 0.035
pad *= (0.6 + 0.4 * env(10, 67.4, 6, 0.4)) * (t < 67.4)
L += pad * 0.95; R += np.roll(pad, 240)
# 3) pulso grave (84 bpm) que entra quando o pedido chega e some dentro do apartamento
bpm = 84; beat = 60 / bpm; pulso = np.zeros_like(t)
for i in range(int(DUR / beat)):
    a = 3.6 + i * beat
    if a > 38.6: break
    m = (t >= a) & (t < a + 0.45); x = t[m] - a
    pulso[m] += np.sin(2 * np.pi * nota(38) * x) * np.exp(-x * 9) * 0.32
L += pulso; R += pulso
# 4) batidas (impactos graves com ruído) nos momentos-chave
def impacto(a, forca=1.0):
    m = (t >= a) & (t < a + 2.5); x = t[m] - a
    s = (np.sin(2 * np.pi * (60 * np.exp(-x * 3) + 30) * x) * np.exp(-x * 2.2) + rng.standard_normal(m.sum()) * np.exp(-x * 12) * 0.3) * 0.5 * forca
    L[m] += s; R[m] += s
for a, f in [(2.6, 0.8), (13.0, 0.7), (22.8, 0.8), (38.6, 0.9), (53.5, 0.7), (59.6, 1.1), (66.3, 1.2), (67.9, 1.0)]:
    impacto(a, f)
# 5) caixinha de música desafinada no apartamento (lembrança de infância)
cx = np.zeros_like(t)
mel = [74, 77, 76, 74, 72, 74, 69, 0, 74, 77, 79, 77, 76, 74]
for i, n in enumerate(mel):
    if not n: continue
    a = 40.0 + i * 0.75
    for rep in range(2):
        a2 = a + rep * len(mel) * 0.75
        if a2 > 58: continue
        m = (t >= a2) & (t < a2 + 1.6); x = t[m] - a2; f = nota(n) * 1.006
        cx[m] += (np.sin(2 * np.pi * f * x) + 0.4 * np.sin(2 * np.pi * f * 2.01 * x)) * np.exp(-x * 3.5) * 0.06
L += cx * 0.8; R += cx
# 6) silêncio seco antes do "Kai?" (64,8–66,3) e corte para o preto
silencio = 1 - 0.85 * env(64.8, 66.25, 0.6, 0.05)
L *= silencio; R *= silencio
out = np.stack([L, R], 1); out /= max(1e-9, np.abs(out).max()) / 0.89
with wave.open(sys.argv[1] if len(sys.argv) > 1 else 'trilha_cap01.wav', 'wb') as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR); w.writeframes((out * 32767).astype('<i2').tobytes())
print('ok')
