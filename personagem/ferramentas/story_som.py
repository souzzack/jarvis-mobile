# Som do story: caixinha de música + pad suave + "pop" quando cada balão aparece
import numpy as np, wave, sys
SR = 48000; DUR = 13.5; N = int(SR * DUR); mix = np.zeros(N)
def note(m): return 440 * 2 ** ((m - 69) / 12)
def tt(d): return np.arange(int(d * SR)) / SR
def add(s, st, g):
    i = int(st * SR); j = min(N, i + len(s)); mix[i:j] += s[:j - i] * g
def mb(st, m, g=0.2):
    t = tt(1.6); f = note(m); add((np.sin(2*np.pi*f*t) + 0.35*np.sin(2*np.pi*f*3.01*t)*np.exp(-t*6)) * np.exp(-t*3.2), st, g)
def pad(st, d, ch, g):
    t = tt(d); s = sum(np.sin(2*np.pi*note(m)*t) + 0.3*np.sin(4*np.pi*note(m)*t) for m in ch) / len(ch)
    add(s * np.minimum(1, t/0.8) * np.minimum(1, (d - t)/0.8), st, g)
def pop(st):
    t = tt(0.15); f = 500 + 900 * t / 0.15; add(np.sin(2*np.pi*np.cumsum(f)/SR) * np.exp(-t*30), st, 0.35)
beat = 0.42
mel = [72, 76, 79, 76, 77, 81, 79, 77, 76, 79, 84, 79, 77, 74, 72, 74, 76, 79, 76, 72, 74, 77, 76, 74, 72, 76, 79, 84]
for k, m in enumerate(mel): mb(0.3 + k * beat, m, 0.16)
for k, ch in enumerate([[48, 55, 64], [53, 57, 65], [55, 59, 62], [48, 55, 64]]): pad(k * 3.4, 3.8, ch, 0.12)
for t in [0.4, 3.1, 6.4, 9.8]: pop(t)
for k, m in enumerate([84, 88, 91, 96]): mb(10.3 + k * 0.08, m, 0.1)
mix *= np.minimum(1, (DUR - np.arange(N)/SR) / 1.2)
mix /= np.max(np.abs(mix)) * 1.1
with wave.open(sys.argv[1], 'wb') as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes((mix * 32767).astype('<i2').tobytes())
