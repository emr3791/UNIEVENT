import os
import re

def replace_opacity(directory):
    pattern = re.compile(r'\.withOpacity\(([^)]+)\)')
    
    def replacer(match):
        val = match.group(1)
        # If the value is a simple number, calculate the alpha if we want,
        # but the safest is to insert the formula to avoid evaluation errors,
        # or we can evaluate if it's a valid float.
        try:
            f = float(val)
            alpha = round(f * 255)
            return f'.withAlpha({alpha})'
        except ValueError:
            return f'.withAlpha(({val} * 255).round())'

    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                new_content, count = pattern.subn(replacer, content)
                
                if count > 0:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f'Replaced {count} occurrences in {filepath}')

if __name__ == "__main__":
    replace_opacity('lib')
