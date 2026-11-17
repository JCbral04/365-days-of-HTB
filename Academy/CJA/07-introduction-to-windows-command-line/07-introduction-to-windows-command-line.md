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


### System Navigation (Intro to Windows Command Line 4/23)

#### Lo que ya sabía (repaso)

- `dir` lista el directorio actual (con `<DIR>` para carpetas, tamaños, fechas, y bytes libres al final).
- `cd` / `chdir` sin argumentos muestra el directorio de trabajo actual.

#### Lo que NO sabía / no tenía claro

- Rutas en Windows: **absoluta** parte de la raíz (`C:\Users\htb\Pictures`); **relativa** parte del directorio actual (`.\Pictures`, `..\..\..\`).
- `..` sube un nivel; con `cd ..\..\..\` se llega de una subcarpeta a la raíz en un solo comando.
- Dato curioso: `C:\` es raíz porque en MS-DOS `A:\` y `B:\` eran floppy drives.
- `tree` imprime el árbol de carpetas de una ruta completa sin moverse; con **`/F`** incluye archivos. En hosts grandes genera output masivo → interrumpir con Ctrl+C cuando ya se vio lo necesario.

|Variable|Ruta|Por qué importa|
|---|---|---|
|`%SYSTEMROOT%\Temp`|`C:\Windows\Temp`|Accesible a todos los usuarios con RWX → dropear archivos como low-priv|
|`%TEMP%`|`C:\Users\<user>\AppData\Local\Temp`|Solo del usuario dueño; útil al comprometer una cuenta|
|`%PUBLIC%`|`C:\Users\Public`|RWX para cualquier cuenta interactiva; menos monitoreado que Windows\Temp|
|`%ProgramFiles%`|`C:\Program Files`|Apps de 64-bit instaladas → reconocimiento|
|`%ProgramFiles(x86)%`|`C:\Program Files (x86)`|Apps de 32-bit instaladas|

### Working with Directories and Files - CMD (Intro to Windows Command Line 5/23)

#### Lo que ya sabía (repaso)

- `dir` / `tree /F` listan contenido; `cd` navega.
- Muchas tareas tienen varios comandos equivalentes en Windows (md=mkdir, rd=rmdir, del=erase, ren=rename — pares sinónimos).

#### Lo que NO sabía / no tenía claro

**Directorios**

|Comando|Uso|Nota|
|---|---|---|
|`md` / `mkdir`|Crear directorio|Sinónimos|
|`rd` / `rmdir`|Borrar directorio|Falla si no está vacío → `rd /S` borra el árbol (pide confirmación)|
|`move <origen> <destino>`|Mover dir completo con contenido|También renombra|

- **xcopy**: existe pero **está deprecado** (sucedido por robocopy). Sintaxis: `xcopy <origen> <destino> <opciones>`. `/E` incluye subdirs vacíos. Brillo propio: quita el bit read-only al copiar (`/K` conserva atributos). Wildcards solo en origen.
- **Robocopy**: sucesor; copia/mueve local, entre drives y por red **reteniendo atributos, timestamps, ownership y ACLs**. No le gustan archivos sueltos (está pensado para árboles/drives).
    
    - `/L` = modo what-if (simula sin ejecutar)
    - `/MIR` = espejo; **cuidado: borra en destino lo que no esté en origen**
    - `/B` o `/ZB` = backup mode → requiere derechos _Backup and Restore Files_ (SeBackupPrivilege); sin ellos falla
    - Workaround: `/MIR` marca los archivos como backup de sistema y los **oculta** → limpiar con `/A-:SH`
    - Como atacante: copiar archivos bloqueados/sistema sin instalar herramientas; como defensor: adquirir evidencia conservando estado.
        

**Archivos — ver contenido**

|Comando|Uso|Nota|
|---|---|---|
|`more <archivo>`|Ver paginado con % avance|`/S` comprime líneas en blanco; acepta pipe: `ipconfig /all \| more`|
|`type <archivo>`|Volcar contenido (varios archivos a la vez)|**No bloquea el archivo**; admite redirección|
|`openfiles`|Ver archivos abiertos y por quién|Requiere admin; no habilitado por defecto|

**Crear/modificar/renombrar**

- `echo texto > archivo` → crea/sobrescribe; `>>` → anexa
- `fsutil file createNew <archivo> <tamaño>` → crear archivo de N bytes
- `ren` / `rename` → renombrar

**I/O y encadenamiento**

- `>` envía output a archivo (sobrescribe); `>>` anexa; `<` alimenta un archivo como input a un comando (`find /i "see" < test.txt`); `|` pipe entre comandos (`ipconfig /all | find /i "IPv4"`)
- `A & B` → corre ambos sin importar resultado
- `A && B` → B solo si A tuvo éxito
- `A || B` → B solo si A falló

**Borrar archivos**

- `del` / `erase`: aceptan lista, wildcards y filtros por atributo:
    
    - `/A:R` read-only, `/A:H` hidden, `/A:S` system, etc. (ver `help del`)
    - `/F` fuerza borrado de read-only; `/S` en todos los subdirs; `/Q` sin preguntar; `/P` confirma cada uno

- Detectar antes de borrar: `dir /A:R` (read-only), `dir /A:H` (hidden) → los archivos ocultos no aparecen en listado normal ni en GUI.
- Combinación clásica: `del /F <dir>` para vaciar + `rd /S <dir>` para eliminar la estructura.

**Copiar/mover archivos**

- `copy <origen> <destino>` — puede renombrar en destino; `/V` valida la copia
- `move` — mueve y/o renombra (archivos y dirs)

