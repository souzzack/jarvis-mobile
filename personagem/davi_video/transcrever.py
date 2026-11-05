# Transcreve as duas gravações com o tempo de cada palavra (Whisper small, offline).
import json, sys, subprocess, numpy as np
from faster_whisper import WhisperModel
M = sys.argv[1]
model = WhisperModel(M, device='cpu', compute_type='int8', cpu_threads=4)
out = {}
for who, f in [('davi', 'voz_davi_original.mp3'), ('deus', 'voz_deus_original.mp3')]:
    raw = subprocess.run(['ffmpeg', '-v', 'error', '-i', f, '-ac', '1', '-ar', '16000', '-f', 'f32le', '-'], capture_output=True, check=True).stdout
    audio = np.frombuffer(raw, dtype=np.float32)
    segs, info = model.transcribe(audio, language='pt', word_timestamps=True, vad_filter=False, beam_size=5,
                                  initial_prompt='Pai, Senhor, Davi, Lucas, misericórdias, cachos, segunda-feira.')
    words = []
    for s in segs:
        for w in s.words: words.append([round(w.start, 2), round(w.end, 2), w.word.strip()])
    out[who] = words
    print('==', who); print(' '.join(f"[{w[0]:.2f}]{w[2]}" for w in words))
json.dump(out, open('transcricao.json', 'w'), ensure_ascii=False, indent=1)
