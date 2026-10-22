
## Modelo OSI (7 capas) — con su unidad de datos

|   |   |   |   |   |
|---|---|---|---|---|
|Capa|Nombre|Unidad|Dispositivo/protocolo|Ataques típicos|
|7|Aplicación|Data|HTTP, DNS, FTP, SMB|SQLi, XSS|
|6|Presentación|Data|TLS, JSON|(cifrado)|
|5|Sesión|Data|sesiones, APIs|hijacking|
|4|Transporte|Segment|TCP, UDP|SYN flood, escaneo|
|3|Red|Packet|IP, routers, ICMP|spoofing|
|2|Enlace|Frame|MAC, switches|ARP poisoning|
|1|Física|Bits|cables, hubs|tapping|

> [!NOTE]- **Regla pentesting:** cada ataque vive en una capa; cada capa tiene sus herramientas.  
> Troubleshooting ordenado: ¿link? (L1) ¿IP? (L3) ¿puerto? (L4) ¿responde la app? (L7)

## TCP Handshake (clave para nmap)

 ```
 SYN → SYN-ACK → ACK = puerto abierto
 SYN → RST = puerto cerrado
 SYN → (silencio) = filtrado por firewall
 ```

**Tipos de escaneo:** -sS (SYN scan, sigiloso), -sT (connect), -sU (UDP).
## Puertos

**65,535 por protocolo** (TCP y UDP separados).

|Rango|Nombre|Uso|
|---|---|---|
|0-1023|Well-known|Solo root puede bindear|
|1024-49151|Registered|Apps de usuario|
|49152-65535|Dinámicos|El SO los asigna a conexiones salientes|

**Como dev:** 
* 80/443 = web prod
*  8080 = HTTP sin root 
* 3000 = Node 
* 5000 = Flask 
* 3306 MySQL 
* 5432 Postgres (¡5-4-3-2!) 
* 6379 Redis 
* 27017 Mongo  

**Como pentester:** 
* 22 SSH 
* 80/443 web 
* 445 SMB 
* 3389 RDP 
* 5985 WinRM
El puerto es pista del servicio, pero `nmap -sV` dice la verdad.

## Protocolos que hablé a mano (con netcat)

- ****FTP (21):**** dos canales — control (21) + datos (puerto efímero). Modo pasivo: `p1*256+p2`. El canal de control debe vivir. Exige `\r\n` (truco Ctrl+V+Enter).
- ****HTTP (80):**** petición = método + path + headers + línea vacía. `GET / HTTP/1.1` + `Host:` + headers.
- ****SSH (22):**** la contraseña NO se muestra al escribirla (ni asteriscos). Llaves > contraseñas.

## Mi máquina en HTB (3 interfaces)

|   |   |   |
|---|---|---|
|Interfaz|IP|Rol|
|lo|127.0.0.1|tráfico a mí mismo (DB escondida, testing)|
|ens3|pública|internet (Pwnbox vía navegador = nginx:80 → VNC:5901 localhost, reverse proxy)|
|tun0|10.10.x.x|VPN al lab — TODO el tráfico a targets pasa aquí|

`ip route get <IP>` muestra por dónde sale el tráfico.

## Herramientas

- `netstat -tulnp` = mis puertos abiertos (t=tcp u=udp l=listen n=números p=proceso)
- `ping` = capa 3 (ICMP, sin puertos) · `nmap` = capa 4/7 · `nc` = hablar protocolos crudos
- `ifconfig` / `ip a` = interfaces

## Proxies

- **Forward:** yo me escondo detrás (VPN, Burp, Tor)
- **Reverse:** el servidor se esconde (nginx, Cloudflare) — es el caso del Pwnbox
- **SOCKS:** túnel genérico → pivoting vía máquina comprometida (`ssh -D` + proxychains)

## Seguridad en redes públicas

- VPN + MAC random (`wifi.cloned-mac-address=random` en NetworkManager)
- Nunca auto-reconnect a WiFi públicos (evil twin)
- DNS cifrado para no filtrar dominios