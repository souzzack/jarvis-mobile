# Legendas do episódio 2 a partir dos tempos de cada palavra (transcrição) já posicionadas na linha do tempo.
import json
T = json.load(open('transcricao.json')); F = json.load(open('falas.json'))['falas']
FIX = {'Ele.': 'ele.', 'caneta.': 'caneta?'}
FIRST_UP = True
subs = []
for name, st, en, who, s0, s1, txt in F:
    nxt = min([f[4] for f in F if f[3] == who and f[4] > s0] + [1e9])
    ws = [w for w in T[who] if s0 - 0.1 <= (w[0] + w[1]) / 2 < nxt]
    toks = [[st + max(0, w[0] - s0), st + max(0, w[1] - s0), FIX.get(w[2], w[2])] for w in ws]
    toks[0][2] = toks[0][2][0].upper() + toks[0][2][1:]
    if toks[-1][2][-1] == ',': toks[-1][2] = toks[-1][2][:-1] + '.'
    chunk = []
    for i, tk in enumerate(toks):
        if chunk and tk[2] == 'antes' and len(chunk) >= 3:
            subs.append([round(chunk[0][0] - 0.05, 2), round(chunk[-1][1] + 0.1, 2), 'DAVI' if who == 'davi' else 'DEUS', ' '.join(c[2] for c in chunk), name]); chunk = []
        chunk.append(tk)
        end = tk[2][-1] in '.?!' or (tk[2][-1] == ',' and len(chunk) >= 4) or len(chunk) >= 11
        if end or i == len(toks) - 1:
            subs.append([round(chunk[0][0] - 0.05, 2), round(min(en + 0.1, chunk[-1][1] + 0.1), 2), 'DAVI' if who == 'davi' else 'DEUS', ' '.join(c[2] for c in chunk), name])
            chunk = []
# palavra solta no fim de uma fala ("Davi.") volta para a legenda anterior
out = []
for s_ in subs:
    if out and len(s_[3].split()) == 1 and s_[3][-1] == '.' and out[-1][4] == s_[4]:
        out[-1] = [out[-1][0], s_[1], s_[2], out[-1][3] + ' ' + s_[3], s_[4]]
    else: out.append(s_)
out = [x[:4] for x in out]
for i in range(len(out) - 1): out[i][1] = min(out[i][1], out[i + 1][0] - 0.02)
json.dump(out, open('legendas.json', 'w'), ensure_ascii=False)
for s in out: print(s)

