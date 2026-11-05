import sys, json, subprocess, numpy as np
from faster_whisper import WhisperModel
m = WhisperModel(sys.argv[1], device='cpu', compute_type='int8')
for ep in sys.argv[2:]:
    F = json.load(open(f'{ep}/falas.json'))['falas']
    for who in ('davi','deus'):
        a = np.frombuffer(subprocess.run(['ffmpeg','-v','error','-i',f'{ep}/voz_{who}.mp3','-ac','1','-ar','16000','-f','f32le','-'],capture_output=True).stdout,np.float32)
        for name, stt, en, w, s0, s1 in F:
            if w != who: continue
            seg = np.concatenate([np.zeros(8000,np.float32), a[int(s0*16000):int(s1*16000)], np.zeros(8000,np.float32)])
            t = ''.join(s.text for s in m.transcribe(seg, language='pt', beam_size=3)[0])
            print(ep, name, f'{s0:.2f}-{s1:.2f}', t)
