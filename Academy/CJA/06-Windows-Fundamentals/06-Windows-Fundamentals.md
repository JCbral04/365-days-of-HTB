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