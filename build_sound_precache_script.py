import os

sound_dir = os.path.join('reality_mixture_gamedir', 'sound')
output_script_path = os.path.join('reality_mixture_gamedir', 'scripts', 'vscripts', 'reality_mixture', 'custom_sound_precache.nut')
target_sound_file_entries = [
    # music
    os.path.join('reality_mixture', 'music', 'zombiechoir'),
    os.path.join('reality_mixture', 'music', 'witch'),
    os.path.join('reality_mixture', 'music', 'boomer'),

    os.path.join('reality_mixture', 'npc', 'mega_mob_incoming.wav'),

    # infected
    os.path.join('reality_mixture', 'npc', 'infected'),
    os.path.join('reality_mixture', 'npc', 'witch'),
    os.path.join('reality_mixture', 'player', 'tank'),
    os.path.join('reality_mixture', 'player', 'boomer'),
    os.path.join('reality_mixture', 'player', 'smoker'),
    os.path.join('reality_mixture', 'player', 'hunter'),
    os.path.join('reality_mixture', 'player', 'charger'),
    os.path.join('reality_mixture', 'player', 'spitter'),
    os.path.join('reality_mixture', 'player', 'jockey'),
]

script_statements = []

def add_sound_file(path):
    global script_statements
    path = os.path.relpath(path, sound_dir)
    path = path.replace('\\', '/')
    script_statements.append(f'EnsureSoundPrecached("{path}");')
    print(f'{path} added')

for entry in target_sound_file_entries:
    entry_path = os.path.join(sound_dir, entry)
    if os.path.isdir(entry_path):
        for dirpath, dirnames, filenames in os.walk(entry_path):
            for filename in filenames:
                add_sound_file(os.path.join(dirpath, filename))
    else:
        add_sound_file(entry_path)

with open(output_script_path, 'w') as script_file:
    for statement in script_statements:
        script_file.write(statement)
        script_file.write('\n')
print(f'{output_script_path} written')

print('DONE')