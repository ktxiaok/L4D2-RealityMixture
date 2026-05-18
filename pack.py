import os
import shutil
import subprocess

mapnames = [
    'reality_mixture_m1_entrance'
]
src_maps_dir = os.path.join('l4d2_dir_symlink', 'left4dead2', 'maps')
dst_maps_dir = os.path.join('reality_mixture_gamedir', 'maps')

for mapname in mapnames:
    for ext in ('.bsp', '.nav'):
        filepath = os.path.join(src_maps_dir, mapname + ext)
        shutil.copy(filepath, dst_maps_dir)
print('Map files copied')

output_vpk_filename = 'RealityMixture.vpk'

if os.path.exists(output_vpk_filename):
    os.remove(output_vpk_filename)
subprocess.run([
    'vpkeditcli', 
    'reality_mixture_gamedir', 
    '--output', output_vpk_filename, 
    '--version', '1',
    '--single-file',
])
print(f'{output_vpk_filename} created')

print('DONE')
