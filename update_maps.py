import os
import shutil

mapnames = ['reality_mixture_m1_entrance']
fileexts = ['.bsp', '.nav']
src_maps_dir = os.path.join('l4d2_dir_symlink', 'left4dead2', 'maps')
dst_maps_dir = os.path.join('reality_mixture_gamedir', 'maps')

for mapname in mapnames:
    for ext in fileexts:
        filepath = os.path.join(src_maps_dir, mapname + ext)
        shutil.copy(filepath, dst_maps_dir)

print('[update_maps] Done')
