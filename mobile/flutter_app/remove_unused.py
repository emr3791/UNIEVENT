import re

def remove_line(filepath, pattern):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    new_content = re.sub(pattern, '', content)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)

remove_line('lib/screens/personal_info_screen.dart', r'\s*String\? _selectedGender;.*?\n')
remove_line('lib/screens/personal_info_screen.dart', r'\s*_selectedGender = user\?\.gender \?\? \'neutral\';.*?\n')

remove_line('lib/widgets/app_logo.dart', r'\s*final primary = theme\.primaryColor;.*?\n')

remove_line('lib/screens/payment_screen.dart', r'\s*final theme = Theme\.of\(context\);.*?\n')

remove_line('lib/screens/messaging_screen.dart', r'\s*final conv = [^;]+;\s*// unused local variable conv\n')

# Wait, the warning says 'conv' and 'peer' in messaging_screen.
