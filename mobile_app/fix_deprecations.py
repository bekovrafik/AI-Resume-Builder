
import os
import re

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Regex to find .withOpacity(value) and replace with .withValues(alpha: value)
    # Handling potential whitespace
    # pattern: \.withOpacity\(\s*([^)]+)\s*\)
    
    new_content = re.sub(r'\.withOpacity\(\s*([^)]+)\s*\)', r'.withValues(alpha: \1)', content)
    
    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Fixed {filepath}")

def main():
    start_dir = '/Users/bekovrafik/Documents/GetKoji/Resume Builder/AI-Resume-Builder/mobile_app/lib'
    for root, dirs, files in os.walk(start_dir):
        for file in files:
            if file.endswith('.dart'):
                fix_file(os.path.join(root, file))

if __name__ == '__main__':
    main()
