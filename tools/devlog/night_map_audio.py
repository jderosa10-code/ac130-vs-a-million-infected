import numpy as np, wave
SR = 44100
SC = [2.8, 2.6, 3.4, 2.4, 4.8, 3.2]
T = sum(SC); n = int(T * SR); t = np.arange(n) / SR
rng = np.random.default_rng(1)
out = np.zeros(n)
starts = np.cumsum([0] + SC[:-1])
def add(sig, at, gain=1.0):
    i = int(at * SR); j = min(n, i + len(sig)); out[i:j] += sig[:j - i] * gain
def lp(x, a):  # one-pole low-pass
    y = np.zeros_like(x); s = 0.0
    for k in range(len(x)):
        s += a * (x[k] - s); y[k] = s
    return y
# low drone bed with a slow pulse
bed = 0.5 * np.sin(2 * np.pi * 55 * t) + 0.25 * np.sin(2 * np.pi * 82.4 * t) + 0.15 * np.sin(2 * np.pi * 110 * t + np.sin(t))
bed *= 0.6 + 0.4 * np.sin(2 * np.pi * t * (120 / 60) / 2) ** 2
bed *= np.clip(t / 0.4, 0, 1) * np.clip((T - t) / 0.8, 0, 1)
out += bed * 0.10
# whoosh into every scene change
def whoosh(d=0.45):
    m = int(d * SR); x = rng.normal(0, 1, m); e = np.sin(np.pi * np.arange(m) / m) ** 2
    return lp(x, 0.08) * e
for s in starts[1:]:
    add(whoosh(), s - 0.3, 0.9)
# thermal switch: a bright click + hum
add(np.sin(2 * np.pi * 1800 * np.arange(int(0.05 * SR)) / SR) * np.exp(-np.arange(int(0.05 * SR)) / 300), starts[4], 0.5)
# cannon fire + impacts in the thermal scenes
def thump(f0=70, d=0.35):
    m = int(d * SR); k = np.arange(m) / SR
    return (np.sin(2 * np.pi * f0 * k * (1 - 0.4 * k / d)) * np.exp(-k * 14) + lp(rng.normal(0, 1, m), 0.15) * np.exp(-k * 20) * 0.6)
def shot():
    m = int(0.06 * SR); k = np.arange(m) / SR
    return lp(rng.normal(0, 1, m), 0.35) * np.exp(-k * 70)
for s0, a, b, rate in [(starts[0], 0.05, 2.7, 7), (starts[4], 0.5, 4.6, 7)]:
    tt = a
    while tt < b:
        for k in range(4):
            add(shot(), s0 + tt + k * 0.06, 0.35)
            add(thump(rng.uniform(55, 80)), s0 + tt + k * 0.06 + 0.22, 0.3)
        tt += 1 / rate
# end hit
add(thump(45, 1.2), starts[5], 1.0)
out = np.tanh(out * 1.4) * 0.8
pcm = (out * 32767).astype(np.int16)
with wave.open('/tmp/vid/audio.wav', 'wb') as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(pcm.tobytes())
print(T)
