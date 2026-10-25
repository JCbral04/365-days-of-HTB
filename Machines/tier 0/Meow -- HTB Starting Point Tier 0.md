**Fecha:** 2026-10-24
**Dificultad:** Very Easy · **OS:** Linux  
**IP target:** 10.129.120.195  
**Tags:** Telnet · Weak Credentials · Misconfiguration  
**Estado:**  Pwned

## 1. Conexión y setup

- Conexión: Pwnbox (US StartingPoint 2) — 1h51m de sesión
- Target spawneado: IP anotada y verificada
![[Pasted image 20261024222444.png]]

### Tareas de la plataforma (respondidas)

|#|Pregunta|Respuesta|
|---|---|---|
|1|¿Qué significa VM?|Virtual Machine|
|2|¿Tool para interactuar vía comandos?|Terminal|
|3|¿Servicio para el VPN?|openvpn|
|4|¿Tool para ICMP echo request?|ping|
|5|¿Tool para encontrar puertos abiertos?|nmap|
|6|¿Servicio en 23/tcp?|telnet|

## 2. Enumeración
##### Ping (¿está viva?)
```bash
ping -c4 10.129.120.195
```

>[!NOTE] Utilizo `-c4` para enviar solo  4 paquetes, porque sino pongo ese argumento el 
> comando ping manda paquetes hasta que se haga `ctrl + c`

→ 4/4 replies, ttl=63. Conexión estable.
![[Pasted image 20261024223201.png]]

##### Escaneo de puertos
```bash
sudo nmap -sV 10.129.120.195
```
```bash
PORT STATE SERVICE VERSION  
23/tcp open telnet Linux telnetd
```

**Un solo puerto abierto: 23/tcp (telnet).** Sin banner que oculte más superficie. El resto: 999 cerrados.
![[Pasted image 20261024223401.png]]

## 3. Foothold — Telnet con credenciales débiles
```bash
telnet 10.129.120.195 #Accedo por medio de telnet(servicio escuchando en el puerto 23)
```

Intentos de login:

- `meow` → Login incorrect
- `admin` → Login incorrect
- `root` + **password vacío**→  sesión root

```bash
Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-77-generic x86_64)  
root@Meow:~#
```
![[Pasted image 20261024223625.png]]

### ¿Por qué funcionó?
Bien dada la guia adjunta al laboratorio, las preguntas de el lab y  al protocolo que se suele seguir(5 fases del hackeo), primero se hace un reconocimiento, el cual se hace usualmente con `nmap` con eso identificamos la superficie de ataque dado que se identifico el puerto 23 con protocolo `tcp`, accedo al objetivo mediante telnet luego ingreso 2 posibles usuarios los cuales son incorrectos y finalmente pruebo con el usuario `root` donde busco el flag con el comando `ls` .

## 4. Flag
Parcha: el banner decía "75 updates pendientes" — un sistema sin mantener es un buffet para exploits conocidos.
```bash
root@Meow:~# ls
flag.txt  snap
root@Meow:~# cat flag.txt  #cat para leer la bandera y capturarla
b40abdfe23665f766f9c61ecba8a4c19
```

![[Pasted image 20261024224730.png]]

## 5. Lo que aprendí

- Aprendi sobre el reconocimiento inicial que se hace a un objetivo en este caso Nmap
-  Aprendi lo que seria una como es mi primer ataque a una maquina de laboratorio
-  Todo se reduce al reconocimiento y accceso mediante puntos abiertos.

## 6. Blue Team: ¿cómo se detecta/preventa esto?

- Detección(Que rastro queda de mi ataque?):
	- **Logs de autenticación:** Bueno en ubuntu, los logins de telnet se guardan en `/var/log/auth.log` -- una linea tipo `session open for user root` desde tu IP es tu firma . Un SIEM podria generar una alerta tipo "Login remoto de root" y pum pillado.
	- **El trafico es texto plano:** telnet no cifra nada. Cualquiera con `tcpdump` en la red habría visto `root` y el password vacío pasar en claro.
	- **El escaneo:** con los  `ping` y `nmap` dejan rastro en logs de red/firewall patrones de muchas conexiones rápidas a puertos distintos.
- Prevención:
	- **Mata el servicio:** telnet no debería existir en producción(un protocolo obsoleto nada se cifra) usa SSH (22). Un `sudo systemctl stop telnetd` o desinstalarlo cierra todo el vector.
	- **Nunca passwords vacíos:** el error raíz fue root sin contraseña. Política de contraseñas + `passwd` forzoso.
	- **Root remoto, no:** ni por telnet ni por SSH (`PermitRootLogin no`) — administra con usuario normal y `sudo`.
	- **Firewall:** 23/tcp solo desde IPs de administración conocidas, no abierto al mundo.
	- **Parcha:** el banner decía "75 updates pendientes" — un sistema sin mantener es un buffet para exploits conocidos.

## 7. Datos del sistema (post-login)

Del banner de Ubuntu: kernel 5.4.0-77, 75 updates pendientes, disco 41.7% usado.  
