import numpy as np
from PIL import Image


def miffilegen_multi(infiles, outfname, img_size=16):
    all_pixels = []

    for infile in infiles:
        img = Image.open(infile).convert('RGB')
        img_resized = img.resize((img_size, img_size), Image.BILINEAR)

        img_np = np.array(img_resized, dtype=np.float32)

        # Scale like original
        img_scaled = img_np / 16.0 - 1.0

        for r in range(img_size):
            for c in range(img_size):
                red   = int(img_scaled[r, c, 0])
                green = int(img_scaled[r, c, 1])
                blue  = int(img_scaled[r, c, 2])

                color = red * 256 + green * 16 + blue
                all_pixels.append(color)

    depth = len(all_pixels)

    with open(outfname, 'w') as f:
        f.write(f'-- {len(infiles)} images, each {img_size}x{img_size}\n\n')
        f.write('WIDTH = 12;\n')
        f.write(f'DEPTH = {depth};\n\n')
        f.write('ADDRESS_RADIX = UNS;\n')
        f.write('DATA_RADIX = UNS;\n\n')
        f.write('CONTENT BEGIN\n')

        for addr, color in enumerate(all_pixels):
            f.write(f'{addr:4d} : {color:4d};\n')

        f.write('END;\n')

    return outfname, depth


if __name__ == '__main__':
    miffilegen_multi(
        infiles=[
            '0.png', '1.png', '2.png', '3.png', '4.png',
            '5.png', '6.png', '7.png', '8.png', '9.png',

            'A.png', 'B.png', 'E.png', 'G.png', 'I.png', 'L.png', 
            'M.png', 'N.png', 'O.png', 'P.png', 'r.png', 'S.png',
            'T.png', 'V.png', 'W.png', 'Y.png'
        ],
        outfname='mem_init.mif'
    )