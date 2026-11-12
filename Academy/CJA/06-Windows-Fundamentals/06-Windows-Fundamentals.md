### Introduction to Windows (Windows Fundamentals 1/15)

**Lo que ya sabía (repaso):**
- Windows es un sistema operativo gráfico, evolución de MS-DOS
- Windows 95 integró DOS + GUI, introdujo Internet Explorer
- RDP (Remote Desktop Protocol) usa puerto 3389
- `xfreerdp /v:&lt;IP&gt; /u:usuario /p:password` para conectarse desde Linux
- VPN, SSH, FTP, VNC son métodos de acceso remoto

**Lo que NO sabía / no tenía claro:**

**Versiones de Windows y sus números de kernel (tabla crítica):**

| Sistema | Versión NT | Pentesting relevance |
|---|---|---|
| Windows XP | 5.1 | Legacy, sin parches, EternalBlue explotable |
| Windows 7 / Server 2008 R2 | 6.1 | Obsoleto, aún común en empresas |
| Windows 8.1 / Server 2012 R2 | 6.3 | Fin de soporte próximo |
| Windows 10 / Server 2016-2019 | 10.0 | Actual; Server 2019 tiene Kubernetes, Linux containers |

**Windows Server timeline (el que importa para pentesting):**
- Server 2000 → Active Directory debut + MMC
- Server 2003 → server roles, firewall integrado, VSS (Volume Shadow Copy Service)
- Server 2008 → failover clustering, Hyper-V, Server Core, mejoras a AD
- Server 2016/2019 → Kubernetes, Linux containers, seguridad avanzada

**End of Life = oportunidad de ataque:**
&gt; "Windows Server 2008 and 2012 reached end of life for security updates on January 14, 2020"

Esto significa que si encuentro un Server 2008 en una red corporativa, es un blanco fácil. Microsoft lanzó parches "out-of-band" solo para SMBv1/EternalBlue, pero el resto de vulnerabilidades quedan sin parche.

**`Get-WmiObject` — reconocimiento inicial en Windows:**
```powershell
Get-WmiObject -Class win32_OperatingSystem | select Version,BuildNumber
# Version: 10.0.19041 | BuildNumber: 19041

Get-WmiObject -Class Win32_Process      # listar procesos
Get-WmiObject -Class Win32_Service      # listar servicios
Get-WmiObject -Class Win32_Bios         # info del firmware/BIOS
```

- `Get-WmiObject` puede apuntar a máquinas remotas con `-ComputerName <host>`
- WMI (Windows Management Instrumentation) es un canal de administración que también puede usarse para movimiento lateral

**RDP como vector de ataque:**

- Puerto 3389 por defecto
- Archivos `.rdp` guardados con credenciales → oro para el pentester
- `xfreerdp` desde Linux con drive redirection: `xfreerdp /v:<IP> /u:user /p:pass /drive:shared,/home/kali/shared`
- Alternativas: Remmina (GUI), rdesktop (CLI legacy)

**La analogía de IP/puerto/puerta:**

> "a network subnet a street... an IP address... a house... logical ports as windows/doors"


### Operating System Structure (Windows Fundamentals 2/15)

**Lo que ya sabía (repaso):**
- En Windows el directorio raíz es `C:\` (equivalente a `/` en Linux)
- `Program Files` vs `Program Files (x86)` — separación de 64-bit y 32-bit
- `Users` contiene los perfiles de usuario
- `dir` lista contenido de directorios (equivalente a `ls` en Linux)
- `tree` muestra estructura jerárquica de carpetas

**Lo que NO sabía / no tenía claro:**

**`ProgramData` — hidden folder, shared across all users:**
- Contiene datos esenciales para que programas funcionen sin importar qué usuario está logueado
- Está oculto por defecto (`/a` en `dir` lo muestra)
- Ejemplo: configuraciones globales de antivirus, bases de datos de licencias

**`Users` subfolders — el template y el share:**

| Carpeta | Propósito |
|---|---|
| `Default` | Template para nuevos perfiles de usuario. Cada usuario nuevo se basa en esto |
| `Public` | Archivos compartidos entre todos los usuarios. **Compartida en red por defecto** (requiere credenciales) |
| `AppData` (dentro de cada perfil) | Datos y settings por usuario, oculto |

**`AppData` — tres subfolders críticos:**

| Subfolder | Qué guarda | Pentesting relevance |
|---|---|---|
| `Roaming` | Datos independientes de la máquina, siguen al usuario en dominio | Credenciales, tokens, configs de apps |
| `Local` | Específico de esta computadora, no se sincroniza | Caches, datos sensibles locales |
| `LocalLow` | Nivel de integridad bajo (protected/safe mode) | Datos de navegador en modo seguro |

**`System`, `System32`, `SysWOW64` — dónde Windows busca DLLs:**
- Cuando un programa solicita una DLL sin path absoluto, Windows busca aquí
- `SysWOW64` = "Windows on Windows 64-bit": emula 32-bit en sistemas 64-bit
- **DLL hijacking:** si pones una DLL maliciosa en una de estas carpetas (o antes en el search order), el programa la carga

**`WinSxS` (Windows Component Store):**
- Contiene copias de TODOS los componentes de Windows, updates y service packs
- Puede ocupar gigas de espacio
- No se debe borrar manualmente — `dism /online /cleanup-image` es la forma segura

**Explorando desde CMD:**
```cmd
dir c:\ /a              # mostrar todo incluyendo ocultos
tree "c:\Program Files" # estructura visual jerárquica
tree c:\ /f | more      # todos los archivos, paginado
```

**Conexión con Linux:**

|Windows|Linux|Nota|
|---|---|---|
|`C:\`|`/`|raíz|
|`Program Files`|`/usr/bin`, `/opt`|programas instalados|
|`Users\<user>`|`/home/<user>`|perfil de usuario|
|`AppData\Roaming`|no exacto equivalente|más cercano a configs en `$HOME`|
|`System32`|`/lib`, `/usr/lib`|librerías del sistema|
|`dir /a`|`ls -la`|mostrar ocultos|


### File System (Windows Fundamentals 3/15)

**Lo que ya sabía (repaso):**
- FAT32 = compatible universal (USBs, SD cards) pero límite de 4GB por archivo
- NTFS = default de Windows desde NT 3.1, soporta permisos, journaling, compresión
- Permisos básicos: Read, Write, Execute, Full Control

**Lo que NO sabía / no tenía claro:**

**5 tipos de file systems en Windows:**

| File System | Uso actual | Pentesting relevance |
|---|---|---|
| FAT12 | Legacy | No |
| FAT16 | Legacy | No |
| FAT32 | USBs, SD cards | Exfiltración a dispositivos removibles |
| exFAT | Dispositivos modernos, archivos >4GB | Similar a FAT32 sin límite |
| NTFS | Default Windows | Permisos ACL, ADS, journaling forense |

**NTFS vs FAT32 — diferencias críticas:**

| Feature | NTFS | FAT32 |
|---|---|---|
| Tamaño máximo archivo | 16 EB (teórico) | 4 GB |
| Permisos granulares | **✓** ACLs | X Ninguno |
| Journaling | **✓** (log de cambios) | X |
| Compresión nativa | **✓** | X |
| Encripción nativa | **✓** EFS | X |
| Recuperación tras fallo | **✓** | X |

**Journaling en NTFS:** registra adición, modificación y eliminación de archivos. Esto es oro forense — puedes ver QUÉ cambió y CUÁNDO, incluso si el atacante borró logs.

**Permisos NTFS — tabla completa:**

| Permiso | Qué permite | Nota |
|---|---|---|
| Full Control (F) | Todo: leer, escribir, modificar, eliminar, cambiar permisos, tomar ownership | Peligroso si lo tiene un usuario no-admin |
| Modify (M) | Leer, escribir, eliminar | No puede cambiar permisos ni ownership |
| Read and Execute (RX) | Ver, listar, ejecutar | Standard para usuarios normales |
| List Folder Contents | Ver y listar carpetas/subcarpetas, ejecutar archivos | Solo carpetas, heredado |
| Read (R) | Ver contenido de archivos, listar carpetas | Solo lectura |
| Write (W) | Agregar archivos a carpetas, escribir en archivos | No puede leer lo que ya existe |
| Traverse Folder | Navegar a través de carpetas sin permiso de listar | Permite acceder a `c:\a\b\c\file.txt` sin poder ver `c:\a` |

**`icacls` — gestión de permisos desde CMD:**
```cmd
icacls c:\windows              # listar permisos de un directorio
icacls c:\users /grant joe:f   # dar Full Control a joe (solo en esa carpeta)
icacls c:\users /remove joe    # revocar permisos de joe
````

**Flags de herencia (crítico para entender el output):**

|Flag|Significado|Efecto|
|---|---|---|
|`(OI)`|Object Inherit|Los archivos nuevos heredan el permiso|
|`(CI)`|Container Inherit|Las subcarpetas nuevas heredan el permiso|
|`(IO)`|Inherit Only|El permiso NO aplica al contenedor actual, solo a hijos|
|`(NP)`|No Propagate|Herencia de un nivel, no más allá|
|`(I)`|Inherited|El permiso vino del padre, no se seteó aquí|

**Ejemplo del `C:\Windows` del módulo:**

```plain
NT AUTHORITY\SYSTEM:(OI)(CI)(IO)(F)
```

SYSTEM tiene Full Control `(F)` en TODOS los archivos `(OI)` y subcarpetas `(CI)` dentro de `C:\Windows`, pero el permiso `(IO)` indica que solo se aplica a los objetos contenidos, no a la carpeta `Windows` misma.

**Trampa común:**

```cmd
icacls c:\users /grant joe:f
```

Joe tiene Full Control en `C:\users` pero NO en subcarpetas ni archivos porque faltó `(OI)` y `(CI)`. Para heredar:

```cmd
icacls c:\users /grant joe:(OI)(CI)(F)
```

**Conexión con Linux:**

|Windows|Linux|Nota|
|---|---|---|
|`icacls`|`ls -la`, `chmod`, `chown`, `getfacl`|gestión de permisos|
|`(OI)(CI)(F)`|`chmod -R 777`|herencia recursiva|
|`NT AUTHORITY\SYSTEM`|`root`|cuenta del sistema operativo|
|`BUILTIN\Administrators`|`sudo` / `wheel`|grupo de administradores|
|`BUILTIN\Users`|`users`|grupo de usuarios estándar|


### NTFS vs. Share Permissions (Windows Fundamentals 4/15)

**Lo que ya sabía (repaso):**
- NTFS permissions = permisos en el sistema de archivos local
- SMB = protocolo para compartir archivos e impresoras en red
- `smbclient -L <IP>` lista shares disponibles
- `smbclient '\\IP\share' -U user` conecta a un share
- Windows Defender Firewall bloquea tráfico entrante por defecto

**Lo que NO sabía / no tenía claro:**

**Share permissions vs NTFS permissions — son DOS capas diferentes:**

| Capa | Aplica cuando | Permisos disponibles |
|---|---|---|
| **Share permissions** | Acceso remoto vía SMB (desde otra máquina) | Full Control, Change, Read |
| **NTFS permissions** | Acceso local Y remoto | Mucho más granulares (Modify, RX, List, Write, Special) |

**Regla de oro:** los permisos efectivos son el **MÁS restrictivo** de ambas capas.
- Share = Read, NTFS = Full Control → efectivo = **Read**
- Share = Full Control, NTFS = Read → efectivo = **Read**
- Share = Full Control, NTFS = Full Control → efectivo = **Full Control**

**Acceso local bypass share permissions:**
> "someone logged in locally to the machine or via RDP can access the shared folder... only need to consider NTFS permissions"

Esto es clave: si comprometo una máquina vía RDP o shell local, los share permissions no aplican. Solo NTFS.

**Shares administrativos por defecto (PELIGRO):**
- C$ → C:\ (Default share) 
- ADMIN$ → C:\WINDOWS (Remote Admin) 
- IPC$ → (Remote IPC)

- Se crean automáticamente en la instalación de Windows
- `C$` da acceso remoto a TODO el disco C: si tienes credenciales admin
- Estos shares son invisibles en el Explorador pero accesibles vía SMB

**Autenticación: Workgroup vs Domain:**

| Ambiente | Base de autenticación | Dónde valida credenciales |
|---|---|---|
| **Workgroup** | Local SAM database | Cada máquina individualmente |
| **Domain** | Active Directory | Controlador de dominio centralizado |

- En workgroup: `smbclient` pide `WORKGROUP\user`
- En domain: `smbclient` pide `DOMAIN\user`

**Windows Defender Firewall Profiles:**

| Perfil | Cuándo aplica |
|---|---|
| **Domain** | Conectado a una red de dominio confiable |
| **Private** | Red privada (home/work network) |
| **Public** | Red pública (WiFi de café, aeropuerto) |

- Cada perfil tiene sus propias reglas inbound/outbound
- Firewall rules pueden gestionarse centralmente vía **Group Policy** en dominios

**Montar shares en Linux:**
```bash
sudo mount -t cifs -o username=htb-student,password=pass //IP/"Company Data" /mnt/share
```

- Requiere `cifs-utils`: `sudo apt install cifs-utils`
- El share se monta como filesystem local en Linux

**Monitoreo de shares en Windows:**

```cmd
net share                    # listar shares activos
```

- **Computer Management** → Shared Folders → Shares/Sessions/Open Files
- **Event Viewer** → Security logs → trazabilidad de acceso a shares

**Spear-phishing targeting sysadmins:**

> "many spear-phishing attacks are directed at system administrators... They have lots of influence over what is allowed in the environments they oversee"

Esto conecta con el mindset de pentesting: no buscas el camino más difícil, buscas el que tiene más privilegios. Un sysadmin con acceso a Group Policy es más valioso que un CEO sin privilegios técnicos.

### Windows Registry (Windows Fundamentals 5/15)

**Lo que ya sabía (repaso):**
- El Registry es una base de datos jerárquica de configuración de Windows
- `regedit.exe` = editor gráfico del Registry
- Estructura: hives → keys → subkeys → values

**Lo que NO sabía / no tenía claro:**

**Los 5 hives principales:**

| Hive | Abbr | Propósito | Pentesting relevance |
|---|---|---|---|
| `HKEY_CURRENT_USER` | HKCU | Settings del usuario logueado | Persistence (run keys), user-specific configs |
| `HKEY_LOCAL_MACHINE` | HKLM | Settings system-wide (hardware, software, OS) | UAC policy, security settings, installed software |
| `HKEY_CLASSES_ROOT` | HKCR | Asociaciones de archivos y registro de apps | Hijacking de extensiones |
| `HKEY_USERS` | HKU | Perfiles de usuario cargados | Acceso a perfiles de otros usuarios |
| `HKEY_CURRENT_CONFIG` | HKCC | Configuración de hardware actual | Menos relevante para pentesting |

**HKCU vs HKLM:**
- HKCU = afecta solo al usuario actual, no requiere admin
- HKLM = afecta toda la máquina, **requiere privilegios administrativos**

**Tipos de datos en el Registry:**
| Tipo | Descripción | Uso común |
|---|---|---|
| `REG_SZ` | String de texto | Nombres, rutas, valores de configuración |
| `REG_DWORD` | Número de 32 bits | Flags on/off (0 o 1) |
| `REG_QWORD` | Número de 64 bits | Valores numéricos grandes |
| `REG_MULTI_SZ` | Múltiples strings | Listas de valores |
| `REG_BINARY` | Datos binarios raw | Datos encriptados o estructuras complejas |

**`reg.exe` — el equivalente CLI de regedit:**
```cmd
reg query "HKCU\Software\HTB-Academy"           # listar valores de una key
reg query "HKCU\Software\HTB-Academy" /v CourseName   # valor específico
reg query "HKLM\Software" /s                    # recursivo (todas las subkeys)
reg query "HKLM" /f SYSTEM /t REG_SZ /c /e      # buscar "SYSTEM" exacto, case-sensitive
```

```cmd
reg add "HKCU\Software\HTB-Academy" /v CreatedBy /t REG_SZ /d "reg.exe" /f
# /v = value name, /t = type, /d = data, /f = force (sin confirmar)
```

```cmd
reg delete "HKCU\Software\HTB-Academy" /v CreatedBy /f   # borrar un valor
reg delete "HKCU\Software\HTB-Academy" /f                # borrar key completa
```

**Conexión con la práctica de pentesting:**

**UAC policy en el Registry:**

```cmd
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA
# 0x1 = UAC habilitado
# 0x0 = UAC deshabilitado
```

- Desactivar UAC requiere admin + reinicio
- Si encuentro UAC deshabilitado en un assessment, es una mala configuración crítica

**Persistence vía Registry (concepto que conectará con módulos futuros):**

- HKCU/HKLM `...\Run` y `...\RunOnce` = programas que se ejecutan al login
- Modificar estas keys = técnica de persistencia común


### Windows Services & Processes (Windows Fundamentals 6/15)

**Lo que ya sabía (repaso):**
- Services = procesos de larga duración que corren en background
- `services.msc` = GUI para gestionar servicios
- Task Manager muestra procesos, CPU, memoria, etc.
- `lsass.exe` = proceso de autenticación (ya lo había escuchado)

**Lo que NO sabía / no tenía claro:**

**Services vs Processes:**

| | Services | Processes |
|---|---|---|
| **Qué son** | Procesos de larga duración gestionados por SCM | Cualquier programa en ejecución |
| **Inicio** | Auto, Manual, Delayed, Disabled | Por el sistema, por apps, por el usuario |
| **Persistencia** | Corren aunque el usuario se desloguee | Algunos terminan al cerrar sesión |
| **Gestión** | `sc.exe`, `Get-Service`, `services.msc` | Task Manager, `taskkill`, Process Explorer |

**Service Control Manager (SCM):**
- Sistema que gestiona el ciclo de vida de los servicios
- Tres categorías: Local Services, Network Services, System Services
- **Misconfiguraciones de permisos de servicios = vector común de privilege escalation**

**Estados de un servicio:**
- Running, Stopped, Paused
- Starting, Stopping (transitorios)
- Startup Type: Automatic, Automatic (Delayed Start), Manual, Disabled

**Servicios críticos del sistema (no se pueden detener sin reinicio):**

| Proceso | Descripción |
|---|---|
| `smss.exe` | Session Manager SubSystem — maneja sesiones |
| `csrss.exe` | Client Server Runtime — porción user-mode del Windows subsystem |
| `wininit.exe` | Inicia cambios post-instalación al reiniciar |
| `logonui.exe` | Interfaz de login de usuario |
| `lsass.exe` | **Local Security Authentication Server** — verifica logons, genera access tokens |
| `services.exe` | Gestiona inicio/parada de servicios |
| `winlogon.exe` | Secure Attention Sequence (Ctrl+Alt+Del), carga perfiles, screensaver lock |
| `System` | Proceso del kernel de Windows |
| `svchost.exe` | Host para servicios que corren desde DLLs (múltiples instancias) |

**LSASS — el proceso más valioso para un pentester:**
- Verifica intentos de logon
- Crea access tokens basados en permisos del usuario
- Maneja cambios de contraseña
- **Loguea eventos en Windows Security Log**
- **Herramientas como Mimikatz extraen credenciales en plaintext y hashes de la memoria de LSASS**

**Sysinternals Tools — suite portable de Microsoft:**
- Se ejecutan desde `\\live.sysinternals.com\tools\` sin descargar a disco
- **Process Explorer** = Task Manager avanzado (handles, DLLs, parent-child relationships)
- **Process Monitor** = monitorea file system, registry, network por proceso
- **TCPView** = monitorea actividad de red
- **PSExec** = ejecuta comandos remotos vía SMB
- **ProcDump** = captura dumps de procesos para análisis

```cmd
\\live.sysinternals.com\tools\procdump.exe -accepteula
```

**Task Manager tabs:**

|Tab|Qué muestra|
|---|---|
|Processes|Apps y background processes con CPU/memoria/disco/red|
|Performance|Gráficos en tiempo real + Resource Monitor|
|App history|Uso de recursos histórico por app|
|Startup|Programas que inician al boot + impacto en startup|
|Users|Usuarios logueados + sus procesos|
|Details|PID, status, username, CPU, memoria por proceso|
|Services|Servicios instalados con PID, descripción, estado|

**Process Explorer (superior a Task Manager):**

- Muestra handles y DLLs cargados por cada proceso
- Vista de parent-child process relationships
- Detecta procesos huérfanos (orphaned)
- Busca qué procesos usan un handle o DLL específico


### Service Permissions (Windows Fundamentals 7/15)

**Lo que ya sabía (repaso):**
- Services corren en background, gestionados por SCM
- `services.msc` = GUI para ver y configurar servicios
- `sc.exe` = CLI para gestionar servicios
- Misconfiguraciones de servicios = vector de privilege escalation

**Lo que NO sabía / no tenía claro:**

**Service accounts vs user accounts:**
- Instalar un servicio con la cuenta de un usuario real (ej: Bob) es **mala práctica**
- Si Bob se va de la empresa y desactivan su cuenta, los servicios que corren como Bob **fallan al iniciar**
- **Service accounts** = cuentas dedicadas exclusivamente para correr servicios

**Cuentas built-in para servicios:**

| Cuenta | Privilegios | Uso típico |
|---|---|---|
| `LocalSystem` | Máximos privilegios locales | Servicios del sistema operativo |
| `LocalService` | Privilegios mínimos locales | Servicios que no necesitan acceso a red |
| `NetworkService` | Privilegios mínimos + acceso a red | Servicios que necesitan comunicarse en red |

- **LocalSystem** = equivalente a root en Linux. No todos los servicios necesitan esto.
- PoLP: identificar qué apps pueden correr con privilegios mínimos.

**Vector de ataque: reemplazar el binario del servicio:**
```cmd
sc qc wuauserv
# BINARY_PATH_NAME: C:\WINDOWS\system32\svchost.exe -k netsvcs -p
```

- Si el directorio del ejecutable tiene permisos débiles (usuarios normales pueden escribir), un atacante puede **reemplazar el binario original** por uno malicioso
- El servicio corre con los privilegios configurados (ej: LocalSystem) → **ejecución con SYSTEM privileges**

**Modificar el binPath de un servicio:**

```cmd
sc config wuauserv binPath=C:\Winbows\Perfectlylegitprogram.exe
```

- Cambia el ejecutable que corre el servicio
- Requiere privilegios administrativos
- Si ya eres admin, esto es una técnica de persistencia

**Recovery tab = otro vector:**

- Un servicio puede configurarse para **ejecutar un programa** después del primer failure
- Un atacante puede forzar que el servicio falle → recovery ejecuta su payload

**`sc.exe` comandos esenciales:**

```cmd
sc qc <servicio>           # query config: ver configuración del servicio
sc query <servicio>        # query status: ver estado actual
sc stop <servicio>         # detener servicio (requiere admin)
sc start <servicio>        # iniciar servicio
sc config <servicio> binPath=<ruta>   # cambiar ejecutable (admin)
sc \\<IP> query <servicio> # query remoto vía SMB
```

**Security Descriptor Definition Language (SDDL):**
```cmd
sc sdshow wuauserv
# D:(A;;CCLCSWRPLORC;;;AU)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)...
```

**Cómo leer SDDL:**

|Componente|Significado|
|---|---|
|`D:`|Lo que sigue es el DACL (Discretionary Access Control List)|
|`A;;`|Access Allowed (D;; = Denied)|
|`CC`|SERVICE_QUERY_CONFIG|
|`LC`|SERVICE_QUERY_STATUS|
|`SW`|SERVICE_ENUMERATE_DEPENDENTS|
|`RP`|SERVICE_START|
|`LO`|SERVICE_INTERROGATE|
|`RC`|READ_CONTROL|
|`;;;AU`|Security principal = Authenticated Users|

**Security principals comunes en SDDL:**

|Abbr|Significado|
|---|---|
|`AU`|Authenticated Users|
|`BA`|Built-in Administrators|
|`SY`|Local System|
|`WD`|Everyone (World)|
|`BU`|Built-in Users|

**DACL vs SACL:**

||DACL|SACL|
|---|---|---|
|**Propósito**|Controlar quién puede acceder al objeto|Auditar/loguear intentos de acceso|
|**Uso**|Permisos|Logging/forense|

**`Get-Acl` en PowerShell — forma legible:**

```powershell
Get-ACL -Path HKLM:\System\CurrentControlSet\Services\wuauserv | Format-List
```

- Muestra permisos en formato legible (no SDDL crudo)
- También devuelve el SDDL en la propiedad `Sddl`
- Incluye SIDs de security principals

### Windows Sessions (Windows Fundamentals 8/15)

#### Lo que ya sabía (repaso)
- Sesión interactiva: un usuario autentica con credenciales de forma local o de dominio.
- Se puede iniciar con logon directo, con `runas` (secondary logon) o por RDP.

#### Lo que NO sabía / no tenía claro

- Las cuentas **non-interactive** no requieren credenciales ni tienen password: Windows las usa para arrancar servicios y tareas programadas automáticamente.
- Existen 3 tipos, con privilegios bien distintos entre sí.

|Cuenta|Nombre|Privilegios|Uso|
|---|---|---|---|
|Local System Account|`NT AUTHORITY\SYSTEM`|La más poderosa del sistema, más que un admin local|Tareas del OS, arranque de servicios|
|Local Service Account|`NT AUTHORITY\LocalService`|Similar a un usuario local, funcionalidad limitada|Puede iniciar algunos servicios|
|Network Service Account|`NT AUTHORITY\NetworkService`|Similar al Local Service localmente, pero tipo cuenta de dominio estándar|Sesiones autenticadas para servicios de red|

- Dato clave: `SYSTEM` **supera en privilegios a los administradores locales** — eso explica por qué en CTFs buscamos escalar a SYSTEM.