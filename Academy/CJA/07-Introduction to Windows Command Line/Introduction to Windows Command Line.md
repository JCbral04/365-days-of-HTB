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

### Getting Help (Intro to Windows Command Line 3/23)

#### Lo que ya sabía (repaso)

- `help` lista los comandos built-in con descripción; `help <comando>` da detalles de uso y sintaxis.
- Comandos externos (ej: `ipconfig`) no tienen página de ayuda en `help` → hay que usar `/<comando> /?`.

#### Lo que NO sabía / no tenía claro

- El **por qué** existe: es un manual **offline** (equivalente a man pages en Linux). En engagements con red bloqueada/monitoreada no hay Internet — la ayuda interna es la única fuente.
    
- Recursos externos de referencia:
    - **Microsoft Docs** — lista completa de comandos CMD (man pages online)
    - **ss64.com** — referencia rápida multi-shell (cmd, PowerShell, Bash)
- Truco para preservar historial: a diferencia de Bash, **CMD no guarda historial entre sesiones** — al cerrar la ventana se pierde. Se puede exportar con doskey a un archivo.
- `doskey` es una utilidad MS-DOS que mantiene el historial de comandos de la sesión.

#### Tabla de historial (keys y comandos)

|Key/Comando|Descripción|
|---|---|
|`doskey /history`|Imprime el historial de la sesión (o lo exporta a archivo)|
|Page Up|Trae el primer comando del historial al prompt|
|Page Down|Trae el último comando del historial al prompt|
|↑ / ↓|Navegar historial arriba/abajo|
|→|Escribe el comando anterior carácter por carácter|
|F3|Retipea el comando anterior completo|
|F5|Cicl entre comandos previos (presionar varias veces)|
|F7|Lista interactiva de comandos previos|
|F9|Inserta comando por número en el historial|
|`cls`|Limpia la pantalla (no borra el historial)|
|Ctrl+C|Interrumpe el proceso en ejecución(al igual que en linux)|

- Cuidado con Ctrl+C: el proceso interrumpido queda **incompleto** y puede necesitar cierre limpio(asi como en linux jaja).
