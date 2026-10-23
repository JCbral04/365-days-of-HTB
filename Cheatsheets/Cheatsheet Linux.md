
>[!NOTE]- Comandos que voy aprendiendo, organizados por tipo.
>sección del módulo aún no completada.

## 1. Comandos básicos (navegación y archivos)
   

| Comando             | Qué hace                                                |
| ------------------- | ------------------------------------------------------- |
| `pwd`               | Dónde estoy                                             |
| `ls` / `ls -la`     | Lista / lista todo con detalles (ocultos incluidos)     |
| `cd <dir>`          | Moverme (cd ~ = home · cd - = anterior · cd .. = subir) |
| `tree`              | Árbol visual de directorios                             |
| `touch <archivo>`   | Crea vacío / actualiza fecha                            |
| `mkdir <dir>`       | Crea directorio (-p crea la rama completa)              |
| `cp origen destino` | Copia (-r para directorios)                             |
| `mv origen destino` | Mueve o renombra                                        |
| `rm <archivo>`      | Elimina (-r directorios · -rf fuerza · ¡sin papelera!)  |
| `cat <archivo>`     | Muestra contenido (en directorio da "Is a directory")   |
| `file <archivo>`    | Qué tipo de archivo es (no confiar en extensiones)      |

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

## 3. Comandos de sistema y usuarios


|Comando|Qué hace|
|---|---|
|`whoami`|Qué usuario soy|
|`id`|uid, gid y grupos|
|`uname -a`|Info del sistema (-r solo kernel)|
|`hostname`|Nombre de la máquina|
|`uptime`|Cuánto lleva encendida|
|`date`|Fecha/hora del sistema|
|`ps aux`|Todos los procesos (ps solo los míos)|
|`kill <PID>`|Mata proceso (-9 fuerza)|
|`env`|Variables de entorno ($PATH, $HOME, $USER)|
|`history`|Comandos anteriores (!n repite el n)|

## 4. Comandos de búsqueda y texto

|   |   |
|---|---|
|Comando|Qué hace|
|`find / -name X 2>/dev/null`|Busca por nombre en todo el sistema (2>/dev/null oculta "Permission denied")|
|`find . -type f`|Solo archivos (d = directorios)|
|`find / -perm -4000 2>/dev/null`|Por permisos SUID (¡oro para escalada!)|
|`find / -size +100M`|Por tamaño|
|`which <comando>`|Dónde está el binario|
|🔜 Filter Contents|(sección pendiente del módulo)|
|🔜 Regular Expressions|(sección pendiente del módulo)|

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

## 7. Ayuda

|Comando|Qué hace|
|---|---|
|`man <comando>`|Manual (q salir, / buscar dentro)|
|`<comando> --help`|Resumen de opciones|

## Notas de uso (mi experiencia)

- `rm -rf` no perdona: miro dos veces el path antes de ejecutarlo(borra TODO, comando peligroso)
- `2>/dev/null` con find es el patrón que más uso — los errores de permiso ensucian todo
- Vim con sus 4 comandos básicos basta para sobrevivir en servidores sin nano