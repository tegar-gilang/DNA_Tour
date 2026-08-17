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
            # Remove GoogleFonts import
            new_content = re.sub(r"import\s+'package:google_fonts/google_fonts\.dart';\n?", "", new_content)
            
            # Remove flutter_animate import
            new_content = re.sub(r"import\s+'package:flutter_animate/flutter_animate\.dart';\n?", "", new_content)
            
            # Strip out flutter_animate calls like .animate().fade()... 
            # This is tricky because it can chain indefinitely. 
            # Let's just remove .animate(...) followed by standard animation chains if possible, 
            # or just rely on regex replacing .animate()..*?(,|\))
            # Actually, regex for chained method calls across multiple lines is notoriously hard.
            # I will instead remove the imports and let the dart compiler complain, then fix it.
            # Wait, no flutter tool is available to `dart fix`. So if I remove the import, it breaks the code!
            # It's better to just remove `.animate()...` manually or via a careful regex.
            # Let's try a regex for simple cases: \.animate\(\)[\w\.\(\)\s,]*
            # That's too risky. Let's just find and replace simple ones.
            # Often it's `.animate().fade(duration: 400.ms).slideY(...)`
            new_content = re.sub(r'\.animate\(\)(?:\s*\.[a-zA-Z]+\(.*?\))*', '', new_content)
            
            if new_content != content:
                with open(filepath, 'w') as f:
                    f.write(new_content)
                print(f"Updated {filepath}")
