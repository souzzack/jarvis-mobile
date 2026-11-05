import sys, json, subprocess, numpy as np
from faster_whisper import WhisperModel
m = WhisperModel(sys.argv[1], device='cpu', compute_type='int8')
for f in sys.argv[2:]:
    a=np.frombuffer(subprocess.run(['ffmpeg','-v','error','-i',f,'-ac','1','-ar','16000','-f','f32le','-'],capture_output=True).stdout,np.float32)
    segs, _ = m.transcribe(a, language='pt', word_timestamps=True, beam_size=5)
    ws = []; txt = []
    for s in segs:
        txt.append(s.text)
        for w in s.words: ws.append([round(w.start, 2), round(w.end, 2), w.word.strip()])
    json.dump(ws, open(f + '.words.json', 'w'), ensure_ascii=False)
    print('=====', f.split('/')[-1]); print(''.join(txt))
