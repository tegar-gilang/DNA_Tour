import os
import re

lib_dir = "lib"

for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith(".dart"):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()
            
            new_content = content
            # Replace GoogleFonts.outfit with TextStyle
            new_content = re.sub(r'GoogleFonts\.outfit', 'TextStyle', new_content)
            # Reduce massive shadows
            new_content = re.sub(r'blurRadius:\s*24', 'blurRadius: 4', new_content)
            new_content = re.sub(r'blurRadius:\s*32', 'blurRadius: 6', new_content)
            new_content = re.sub(r'blurRadius:\s*16', 'blurRadius: 2', new_content)
            new_content = re.sub(r'offset:\s*const\s*Offset\(0,\s*10\)', 'offset: const Offset(0, 2)', new_content)
            new_content = re.sub(r'offset:\s*const\s*Offset\(0,\s*8\)', 'offset: const Offset(0, 2)', new_content)
            # Simplify Apple Glass gradients
            # This might be tricky, let's just see how much we can reduce the bloated design.
            
            if new_content != content:
                with open(filepath, 'w') as f:
                    f.write(new_content)
                print(f"Updated {filepath}")
