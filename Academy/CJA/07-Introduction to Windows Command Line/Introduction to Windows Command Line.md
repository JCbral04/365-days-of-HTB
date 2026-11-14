### Introduction (Introduction to Windows Command Line 1/23)

#### Lo que ya sabía (repaso)
- CMD.exe y PowerShell vienen en todos los hosts Windows y dan acceso directo al OS para automatizar tareas.
- Desde PowerShell se pueden correr comandos de CMD; desde CMD hay que prefijar con `powershell` para correr cmdlets (ej: `powershell get-alias`).

#### Lo que NO sabía / no tenía claro
- Diferencias clave CMD vs PowerShell — tabla comparativa:

| Aspecto               | PowerShell        | CMD                                    |
| --------------------- | ----------------- | -------------------------------------- |
| Introducido           | 2006              | 1981                                   |
| Comandos              | Batch + cmdlets   | Solo batch                             |
| Aliases               | **✓**             | **X**                                  |
| Output a otro comando | **✓** (objetos)   | **X** (solo texto)                     |
| Formato de salida     | Objetos           | Texto                                  |
| Secuencia en script   | Cadena de cmdlets | Un comando termina antes del siguiente |
| ISE                   | **✓**             | **X**                                  |
| Acceso a librerías    | **✓** (.NET)      | **X**                                  |
| Multiplataforma       | **✓** (Linux)     | **X** (solo Windows)                   |

- CMD es interacción estática con el OS; PowerShell es lenguaje de scripting completo (scripts simples y complejos).
- El módulo se conecta con pentesting: reconocimiento, explotación y exfiltración usando herramientas built-in + third-party.
- Conexión a los labs: **solo por SSH** → `ssh htb-student@<IP>` (aceptar certificado + password).
### Command Prompt Basics (Intro to Windows Command Line 2/23)

#### Lo que ya sabía (repaso)

- `cmd.exe` es el intérprete de línea de comandos por defecto de Windows, basado en COMMAND.COM de DOS; presente en casi todas las versiones.
- Acceso local: `Win + R` → `cmd`, o `C:\Windows\System32\cmd.exe`.
- `dir` lista el directorio actual (request-response: comando → output).

#### Lo que NO sabía / no tenía claro

- **Local access** = físico/virtual directo (periféricos), no requiere red. **Remote access** = periféricos virtuales por red: SSH, RDP, WinRM, PsExec, telnet (inseguro, no recomendado).
- La conveniencia del acceso remoto es también riesgo: mal configurado o con credenciales robadas, un atacante obtiene acceso amplio al entorno.
- **Case study clave (Windows Recovery)**: desde el disco de instalación → Repair Mode → Command Prompt. En Windows 7 se puede reemplazar `sethc.exe` (Sticky Keys) por una copia de `cmd.exe`; al reiniciar, **Shift 5 veces** en la pantalla de login abre un CMD con `NT AUTHORITY\SYSTEM` → bypass total de autenticación.
- Dato ofensivo: cuando PowerShell está bloqueado (AppLocker), **CMD sigue disponible** — herramienta de legado útil para escalar privilegios y seguir moviéndose.