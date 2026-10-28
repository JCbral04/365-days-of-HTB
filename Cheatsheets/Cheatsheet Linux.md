
>[!NOTE]- Comandos que voy aprendiendo, organizados por tipo.
>sección del módulo aún no completada.

## 1. Comandos básicos (navegación y archivos)

|Comando|Qué hace|
|---|---|
|`pwd`|Dónde estoy|
|`ls` / `ls -la`|Lista / lista todo con detalles (ocultos incluidos)|
|`cd <dir>`|Moverme (cd ~ = home · cd - = anterior · cd .. = subir)|
|`tree`|Árbol visual de directorios|
|`touch <archivo>`|Crea vacío / actualiza fecha|
|`mkdir <dir>`|Crea directorio (-p crea la rama completa)|
|`cp origen destino`|Copia (-r para directorios)|
|`mv origen destino`|Mueve o renombra|
|`rm <archivo>`|Elimina (-r directorios · -rf fuerza · ¡sin papelera!)|
|`cat <archivo>`|Muestra contenido (en directorio da "Is a directory")|
|`file <archivo>`|Qué tipo de archivo es (no confiar en extensiones)|

## 2. Comandos de red

|Comando|Qué hace|
|---|---|
|`ifconfig` / `ip a`|Interfaces y sus IPs|
|`ip route get <IP>`|Por qué interfaz sale el tráfico a esa IP|
|`netstat -tulnp`|Mis puertos abiertos (t=tcp u=udp l=listen n=números p=proceso)|
|`ping -c4 <IP>`|¿Está vivo? (ICMP, capa 3, sin puertos)|
|`ssh usuario@<IP>`|Conexión remota (la pass NO se ve al escribirla)|
|`nmap <IP>`|Escaneo de puertos del target|
|`nc <IP> <puerto>`|Hablar un protocolo a mano (raw TCP/UDP)|

## 3. Comandos de sistema, usuarios y procesos

|Comando|Qué hace|
|---|---|
|`whoami` / `id`|Quién soy / uid, gid y grupos|
|`uname -a`|Info del sistema (-r solo kernel)|
|`hostname` / `uptime` / `date`|Nombre / cuánto lleva encendida / fecha|
|`env` / `history`|Variables de entorno / comandos anteriores|
|`sudo <cmd>`|UN comando como root|
|`su - [user]`|Cambiar de usuario completo (sesión nueva; `-` carga su entorno)|
|`useradd -m -s /bin/bash X`|Crear usuario con home y shell|
|`userdel -r X`|Borrar usuario y su home|
|`usermod -aG grupo X`|Agregar a grupo (`-a` = append, sin él REEMPLAZA los grupos ⚠️)|
|`passwd X`|Cambiar contraseña (root no necesita la vieja)|
|`ps aux` / `ps aux \\| grep X`|Todos los procesos / filtrar (¡la `x` es la que muestra daemons!)|
|`kill -9 <PID>`|Matar YA (SIGKILL, sin limpieza). La forma estándar lleva guión|
|`pkill -f <nombre>` / `killall <nombre>` / `pgrep <nombre>`|Matar/buscar por nombre sin buscar PID|
|`jobs` / `bg` / `fg <id>`|Job control: lista procesos suspendidos / manda a background / trae al frente|
|`Ctrl+Z` / `Ctrl+C`|Suspender proceso / interrumpirlo|

## 4. Comandos de búsqueda y texto

|Comando|Qué hace|
|---|---|
|`find / -name X 2>/dev/null`|Busca por nombre en todo el sistema (2>/dev/null oculta "Permission denied")|
|`find . -type f`|Solo archivos (d = directorios)|
|`find / -perm -4000 2>/dev/null`|Por permisos SUID (¡oro para escalada!)|
|`find / -size +100M`|Por tamaño|
|`which <comando>`|Dónde está el binario|
|`grep <patrón> <archivo>`|Filtrar líneas que contienen el patrón|
|`grep -o <patrón>`|EXTRAER solo el match (no la línea entera)|
|`grep -v <patrón>`|INVERTIR: excluir lo que coincide|
|`grep -E <patrón>`|Regex extendida (? + ( ) sin escapar)|
|`sort -u`|Ordenar + quitar duplicados|
|`sed 's/viejo/nuevo/g' <archivo>`|Reemplazar texto|
|`wc -l`|Contar líneas|

**Patrones regex que ya me sirvieron:**

|Patrón|Significado|
|---|---|
|`https?://`|http o https (la `s` es opcional)|
|`[^"[:space:]<>]+`|cualquier cosa que NO sea comilla/espacio/`<`/`>` (para extraer URLs de HTML)|
|`^...$`|anclas: inicio y fin de línea (match exacto)|
|`X?`|X opcional (0 o 1 vez) · `X*` = 0 o más · `X+` = 1 o más|
|`\\|`|OR · `a.*b` = AND en orden|
|`\.`|punto literal (`.` solo = cualquier carácter)|
|`[a-z]` / `[^a-z]`|clase de caracteres / clase negada|

****El pipeline de 4 verbos para análisis de texto:****  
`extraer (grep -o) → transformar (sed) → deduplicar (sort -u) → contar (wc -l)`

## 5. Edición de archivos

|Editor|Comandos clave|
|---|---|
|`nano`|Ctrl+O guardar · Ctrl+X salir|
|`vim`|i = insertar · Esc = normal · :wq guardar y salir · :q! salir SIN guardar|

## 6. Redirección y pipes

|Símbolo|Qué hace|
|---|---|
|stdin / stdout / stderr|0 / 1 / 2|
|`>`|Salida a archivo (SOBRESCRIBE)|
|`>>`|Salida a archivo (AGREGA)|
|`2>`|Solo errores a archivo|
|`2>&1`|Juntar errores con salida normal|
|`<`|Archivo como entrada|
|`\\|`|Pipe: salida de uno → entrada de otro|
|`tee <archivo>`|Pantalla Y archivo a la vez|
|`/dev/null`|Agujero negro: lo que mandas ahí desaparece|

## 7. Permisos

|Comando|Qué hace|
|---|---|
|`chmod 754 <archivo>`|Permisos en octal: 7=owner 5=grupo 4=otros (r=4 w=2 x=1)|
|`chmod u+x a.sh` / `chmod a+r a`|Simbólico: u=user g=group o=others a=all, + dar / - quitar|
|`chown user:grupo <archivo>`|Cambiar dueño y grupo|
|`ls -la`|Ver permisos (la `s` en lugar de `x` = SUID/SGID; `t` = sticky)|

**Regla de oro:** x en un DIRECTORIO = permiso para ATRAVERSARLO (no ejecutar nada). Sin x en el dir: "Permission denied" aunque tengas r. Para crear/borrar adentro: w sobre el directorio.

## 8. Servicios (systemd)

|Comando|Qué hace|
|---|---|
|`systemctl start|stop|
|`systemctl enable|disable <svc>`|
|`systemctl list-units --type=service`|Listar todos los servicios (recon)|
|`systemctl daemon-reload`|Recargar unidades tras crear archivos .service/.timer (¡sin esto ignora lo nuevo, sin error!)|
|`journalctl -u <svc> --no-pager`|Logs del servicio (por qué no arranca)|

## 9. Task scheduling (cron / timers)

|Comando|Qué hace|
|---|---|
|`crontab -e` / `crontab -l`|Editar / listar MIS tareas programadas|
|`cat /etc/crontab` · `ls /etc/cron*`|Tareas del sistema (auditoría: ¿algo descarga y ejecuta?)|
|`grep -rE "curl\\|wget\\|nc " /etc/cron*`|Buscar cron jobs maliciosos 🚩|

****Sintaxis cron:**** `minuto hora dia-mes mes dia-semana` (`*` = todos · `*/6` = cada 6 · 0 y 7 = domingo)

## 10. Ayuda

|Comando|Qué hace|
|---|---|
|`man <comando>`|Manual (q salir, / buscar dentro)|
|`<comando> --help`|Resumen de opciones|

## Notas de uso (mi experiencia)

- `rm -rf` no perdona: miro dos veces el path antes de ejecutarlo (borra TODO)
- `2>/dev/null` con find es el patrón que más uso — los errores de permiso ensucian todo
- Vim con sus 4 comandos básicos basta para sobrevivir en servidores sin nano
- Filtrar por la DEFINICIÓN, no por el ejemplo: `grep -v 127.0.0.1` deja pasar `127.0.0.53` — el loopback entero es `127.0.0.0/8` → `grep -v '127\.'`
- `sed` sin coincidencia no da error: se traga el comando en silencio. Verificar después
- Job control = una sola terminal para todo: `Ctrl+Z` + `bg` deja el listener corriendo mientras trabajo
- `kill -9` lleva guión (`kill 9 PID` del módulo es typo); `kill -l` lista las señales
- Los apuntes de secciones "ya las sé" también van aquí: el cerebro olvida y esta hoja es mi segunda memoria