import os
import re
from pathlib import Path
from typing import Dict, List, Tuple

ZSHRC_PATH = Path.home() / ".zshrc"

def get_aliases() -> Dict[str, str]:
    """
    Parse ~/.zshrc and return a dictionary of aliases.
    Format: {'name': 'command'}
    """
    aliases = {}
    if not ZSHRC_PATH.exists():
        return aliases
        
    # Matches: alias name='command' or alias name="command" or alias name=command
    with open(ZSHRC_PATH, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line.startswith("alias "):
                content = line[6:].strip()
                if "=" in content:
                    name, value = content.split("=", 1)
                    if (value.startswith("'") and value.endswith("'")) or \
                       (value.startswith('"') and value.endswith('"')):
                        value = value[1:-1]
                    aliases[name] = value
                    
    return aliases

def add_alias(name: str, command: str) -> bool:
    """
    Add or update an alias in ~/.zshrc.
    Returns True if successful.
    """
    if not ZSHRC_PATH.exists():
        # Create empty .zshrc if it doesn't exist
        with open(ZSHRC_PATH, "w", encoding="utf-8") as f:
            pass
            
    with open(ZSHRC_PATH, "r", encoding="utf-8") as f:
        lines = f.readlines()
        
    new_line = f"alias {name}='{command}'\n"
    updated = False
    
    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith(f"alias {name}="):
            lines[i] = new_line
            updated = True
            break
            
    if not updated:
        if lines and not lines[-1].endswith('\n'):
            lines[-1] += '\n'
        arch_manager_comment = "# Added by Arch Zsh Manager\n"
        if arch_manager_comment not in lines:
            lines.append("\n" + arch_manager_comment)
        lines.append(new_line)
        
    with open(ZSHRC_PATH, "w", encoding="utf-8") as f:
        f.writelines(lines)
        
    return True

def remove_alias(name: str) -> bool:
    """
    Remove an alias from ~/.zshrc.
    Returns True if removed, False if not found.
    """
    if not ZSHRC_PATH.exists():
        return False
        
    with open(ZSHRC_PATH, "r", encoding="utf-8") as f:
        lines = f.readlines()
        
    new_lines = []
    removed = False
    for line in lines:
        if line.strip().startswith(f"alias {name}="):
            removed = True
            continue
        new_lines.append(line)
        
    if removed:
        with open(ZSHRC_PATH, "w", encoding="utf-8") as f:
            f.writelines(new_lines)
            
    return removed
