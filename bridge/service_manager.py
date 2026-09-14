import subprocess
from typing import List, Dict

def get_services() -> List[Dict[str, str]]:
    try:
        cmd1 = "systemctl list-unit-files --type=service -q --no-legend | awk '{print $1}' | grep -v '@\\.service$'"
        result1 = subprocess.run(cmd1, shell=True, capture_output=True, text=True)
        unit_names = result1.stdout.strip().split()
        
        if not unit_names:
            return []
            
        cmd2 = ["systemctl", "show", "-p", "Id,ActiveState,SubState,UnitFileState,Description"] + unit_names
        result2 = subprocess.run(cmd2, capture_output=True, text=True)
        
        services = []
        current_svc = {}
        for line in result2.stdout.splitlines():
            line = line.strip()
            if not line:
                if current_svc and "Id" in current_svc:
                    services.append(current_svc)
                    current_svc = {}
                continue
            if "=" in line:
                key, val = line.split("=", 1)
                current_svc[key] = val
        if current_svc and "Id" in current_svc:
            services.append(current_svc)
            
        formatted_services = []
        for svc in services:
            name = svc.get("Id", "").replace(".service", "")
            active = svc.get("ActiveState", "unknown")
            sub = svc.get("SubState", "unknown")
            file_state = svc.get("UnitFileState", "unknown")
            desc = svc.get("Description", "")
            
            formatted_services.append({
                "name": name,
                "active": active,
                "sub": sub,
                "enabled": file_state,
                "desc": desc
            })
            
        return sorted(formatted_services, key=lambda x: x["name"])
    except Exception:
        return []
