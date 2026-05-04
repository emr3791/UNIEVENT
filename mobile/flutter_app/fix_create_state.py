import os
import re

def fix_create_state(directory):
    pattern = re.compile(r'\s*_(.*?State)\s*createState\(\)\s*=>\s*_\1\(\);')
    
    def replacer(match):
        state_class = match.group(1) # e.g. "SearchScreenState"
        widget_class = state_class.replace('State', '') # e.g. "SearchScreen"
        return f'  State<{widget_class}> createState() => _{state_class}();'

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
                    print(f'Replaced {count} createState occurrences in {filepath}')

if __name__ == "__main__":
    fix_create_state('lib')
