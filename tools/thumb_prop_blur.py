import cv2, numpy as np
base = cv2.imread('base6.jpg').astype(np.float32) / 255
A = cv2.imread('mA.jpg'); B = cv2.imread('mB.jpg')
H, W = A.shape[:2]
def magenta(img):
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    return ((hsv[..., 0] > 135) & (hsv[..., 0] < 160) & (hsv[..., 1] > 120)).astype(np.uint8)
box = np.zeros((H, W), np.uint8); box[100:420, 560:1400] = 1
plane = (1 - magenta(B)) * box
withb = (1 - magenta(A)) * box
plane = cv2.morphologyEx(plane, cv2.MORPH_OPEN, np.ones((3, 3), np.uint8))
blades = np.clip(withb.astype(int) - cv2.dilate(plane, np.ones((3, 3), np.uint8)).astype(int), 0, 1).astype(np.uint8)
blades = cv2.dilate(blades, np.ones((5, 5), np.uint8))
# remove the real blades: fill them from what's around (sky/fog behind)
img8 = (base * 255).astype(np.uint8)
clean = cv2.inpaint(img8, blades * (1 - plane), 9, cv2.INPAINT_TELEA).astype(np.float32) / 255
# blades in front of the hull: take the hull from the no-blade render, matched to the shot's colours
Af = A.astype(np.float32) / 255; Bf = B.astype(np.float32) / 255
over = ((np.abs(Af - Bf).sum(2) > 0.18) & (plane > 0)).astype(np.uint8)
over = cv2.dilate(over, np.ones((5, 5), np.uint8))
ref = (plane > 0) & (over == 0)
gain = base[ref].mean(0) / np.maximum(Bf[ref].mean(0), 1e-3)
fix = np.clip(Bf * gain, 0, 1)
om = cv2.GaussianBlur(over.astype(np.float32), (0, 0), 1.2)[..., None]
clean = clean * (1 - om) + fix * om
hubs = {
 813: "743,276 741,241 743,206 750,174 761,145 777,122 796,107 818,101 840,107 862,125 881,154 894,191 902,234 903,277 897,318 885,353 868,379 849,395 829,401 808,397 789,385 773,365 759,339 749,309",
 632: "593,261 590,235 590,208 593,183 598,162 606,145 616,134 628,131 640,136 652,150 663,170 672,197 678,228 681,260 679,289 675,315 667,335 658,348 647,354 635,352 624,343 614,329 605,310 598,287",
 910: "819,284 818,245 822,206 832,169 847,136 868,109 893,91 922,85 951,91 979,111 1003,144 1020,187 1028,237 1027,288 1018,335 1000,374 978,403 952,420 925,426 899,421 875,407 855,384 838,355 826,321",
 683: "637,265 634,236 635,208 638,181 645,157 655,138 667,126 681,123 696,128 711,143 724,166 734,196 741,229 743,265 740,298 734,326 724,348 712,362 699,367 685,365 672,355 660,339 650,318 642,293",
}
out = clean.copy()
noprop = clean.copy()
over_rgb = np.zeros_like(clean); over_a = np.zeros((H, W), np.float32)
yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
for hx, s in sorted(hubs.items()):
    pts = np.array([[float(v) for v in p.split(',')] for p in s.split()], np.float32)
    (cx, cy), (ew, eh), ang = cv2.fitEllipse(pts)
    # size the disc to where this hub's real blades reach
    poly = np.zeros((H, W), np.uint8); cv2.fillConvexPoly(poly, pts.astype(np.int32), 1)
    by, bx = np.nonzero(blades * poly)
    a = np.radians(ang)
    if len(bx) > 20:
        dx, dy = bx - cx, by - cy
        u = dx * np.cos(a) + dy * np.sin(a); v = -dx * np.sin(a) + dy * np.cos(a)
        r = np.percentile(np.sqrt((u / (ew / 2)) ** 2 + (v / (eh / 2)) ** 2), 97)
        ew, eh = ew * r, eh * r
    # elliptical coords
    dx, dy = xx - cx, yy - cy
    u = (dx * np.cos(a) + dy * np.sin(a)) / (ew / 2); v = (-dx * np.sin(a) + dy * np.cos(a)) / (eh / 2)
    rr = np.sqrt(u * u + v * v); th = np.arctan2(v, u)
    disc = np.clip((1.02 - rr) / 0.06, 0, 1)
    # blur disc: faint dark tint, a few soft blade "ghost" sweeps, brighter tip ring
    ghost = 0.5 + 0.5 * np.cos(4 * th + hx)  # 4 blades
    ghost = ghost ** 6 * np.clip(rr / 0.4, 0, 1)
    ring = np.exp(-((rr - 0.93) / 0.05) ** 2)
    tint = disc * (0.10 + 0.16 * ghost)
    dark = np.array([0.16, 0.15, 0.14])
    m = tint * (1 - plane * 0.45)
    over_rgb = over_rgb * (1 - m[..., None]) + dark * m[..., None]; over_a = over_a + m * (1 - over_a)
    tipc = np.array([0.35, 0.7, 0.85])  # yellow tips smear into a ring (BGR)
    rm = (ring * 0.16 * disc)[..., None] * (1 - plane[..., None] * 0.6)
    rm2 = rm[..., 0]
    over_rgb = over_rgb * (1 - rm) + tipc * rm; over_a = over_a + rm2 * (1 - over_a)
    # a soft highlight arc on the sun side
    hl = disc * np.exp(-((th + 2.2) / 0.5) ** 2) * np.clip(rr, 0, 1) * 0.25

out = np.clip(noprop, 0, 1)
o8 = (out * 255).astype(np.uint8)
hsv = cv2.cvtColor(o8, cv2.COLOR_BGR2HSV)
pink = (((hsv[..., 0] > 130) & (hsv[..., 0] < 168) & (hsv[..., 1] > 70)) * box).astype(np.uint8)
pink = cv2.dilate(pink, np.ones((5, 5), np.uint8))
out = cv2.inpaint(o8, pink, 5, cv2.INPAINT_TELEA).astype(np.float32) / 255
cv2.imwrite('base7.png', (out * 255).astype(np.uint8))
cv2.imwrite('plane_mask_cap.png', plane * 255)
# crop/scale like the shots
x0 = (W - int(H * 16 / 9)) // 2; nw = int(H * 16 / 9)
for src, dst, interp in (('base7.png', 'b7.png', cv2.INTER_LANCZOS4), ('plane_mask_cap.png', 'b7_mask.png', cv2.INTER_NEAREST)):
    im = cv2.imread(src); cv2.imwrite(dst, cv2.resize(im[:, x0:x0 + nw], (1920, 1080), interpolation=interp))
ov = np.dstack([over_rgb / np.maximum(over_a[..., None], 1e-4), over_a])
ov = cv2.resize(ov[:, x0:x0 + nw], (1920, 1080), interpolation=cv2.INTER_LINEAR)
np.save('b7_props.npy', ov.astype(np.float32))
print('ok', x0)
