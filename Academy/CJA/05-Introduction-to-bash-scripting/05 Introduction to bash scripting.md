## Bourne Again Shell

**Bash** es el lenguaje de scripting que nos sirve para comunicarnos con terminales en SO basados en unix para dar instrucciones o comandos al sistema. Desde el año 2019 se puede usar en windows ya que desde ese año proveen el **WSL**(Windows Subsistem Linux) que nos permite utilizar `Bash` en un entorno de windows. Es escencial practicar y dominar este lenguaje dado que nos permite trabajar de una manera muy eficiente con el. La diferencia principal entre el scripting y los lenguajes de programacion es que no necesitamos compilar el codigo que se ejecuta en `sh` como normalmente se haria con un lenguaje de programacion.

> **Por qué importa para pentesting :** en redes empresariales Unix manejamos volúmenes enormes de datos. Filtrar, combinar comandos y automatizar procesos = velocidad, y la velocidad es eficiencia — especialmente en privilege escalation.

### Lo importante de la sección

**Estructura de cualquier lenguaje de scripting** (misma que programación, otro dialecto): I/O · argumentos/variables/arrays · condicionales · aritmética · loops · comparadores · funciones

**Ejecutar un script:**
```bash
bash script.sh    # con bash explícito
sh script.sh      # con sh (genérico)
./script.sh       # directo (requiere chmod +x)
```

**Variables de argumentos:**

|Símbolo|Qué es|
|---|---|
|`$0`|nombre del script|
|`$1`, `$2`|argumento 1, 2|
|`$#`|cuántos argumentos llegaron|
|`$?`|exit code del último comando (0 = OK)|

### CIDR.sh  anatomía del script del módulo

**Qué hace:** le das un dominio y hace recon completo solo — resuelve sus IPs, averigua a qué rango de red pertenecen y hace ping sweep a todas las IPs del rango.

**El flujo en 5 movimientos:**
1. `if [ $# -eq 0 ]` — valida que le pasé el dominio; si no llegó, muestra el uso y sale (`exit 1`)
2. `host $domain | grep "has address" | cut -d" " -f4` — el clásico pipeline: resuelve el dominio y extrae solo las IPs
3. `whois $ip | grep "NetRange\|CIDR"` — pregunta quién es dueño de la IP y filtra el rango de red; `prips $cidr` lo convierte en lista de IPs
4. La función `ping_host` recorre la lista con un loop, hace ping a cada una (`> /dev/null 2>&1` para no inundar pantalla) y lleva la cuenta de cuántas respondieron
5. Un menú con `case` deja elegir qué función correr (rango / ping / ambas / salir)

**Piezas que ya conocía de mi módulo de Linux:** `tee -a` (pantalla + archivo), `> /dev/null 2>&1` (silenciar), `grep|cut` en pipeline.

**La idea que me llevo:** 40 líneas que reemplazan cuatro tareas manuales de recon. El patrón: cuando me pille repitiendo "host → whois → ping" a mano en HTB, es señal de que toca convertirlo en script con funciones y menú.

### Conditional Execution (Bash Scripting 2/10)

**Qué es:** controlar el flujo del script — si pasa X, ejecuta este bloque y salta los demás; si no, evalúa el siguiente. Sin condicionales todo sería comando tras comando sin decisión.
**Lo que ya sabía de programar:** la lógica if / elif / else es idéntica en cualquier lenguaje — solo cambia la sintaxis.
**Lo NUEVO (lo específico de bash):**

**Shebang — la primera línea de TODO script:**
```bash
#!/bin/bash
```
Dice qué intérprete ejecuta el archivo (siempre va arriba, empieza con #!). Sirve para cualquier intérprete, no solo bash:
```bash
#!/usr/bin/env python
#!/usr/bin/env perl
```
Es lo que hace que `./script.sh` sepa a quién pedir ejecución sin escribir `bash` antes.

Sintaxis if/elif/else en bash (el dialecto):
```bash
if [ $# -eq 0 ]              # la condición va entre corchetes [ ]
then
    echo -e "Usage: $0 <domain>"
    exit 1
elif [ $# -eq 1 ]
then
    domain=$1
else
    echo "Too many arguments"
    exit 1
fi                           # todo if se cierra con fi (if al revés)
```

- `[ ... ]` = el comando `test` (evalúa la condición)
- Los comparadores son de palabra:
     - `-eq` del ingles equal (`=`),
     - `-gt` del ingles greater than (`>`)
     - `-lt` del ingles less than(`<`) 
- `echo -e` interpreta escapes como `\n`(salto de linea) y `\t`(organiza la salida como en forma de tabla)
- `exit 1` = terminar con error (0 = éxito; cualquier otro número = falla)

El ejercicio del final (HTB):
```bash
var="nef892na9s1p9asn2aJs71nIsm"
for counter in {1..40}
do
    var=$(echo $var | base64)
done
```
Con el siguiente enunciado:
Codifica el string 40 veces seguidas en base64. 
El truco del ejercicio: 
contar los caracteres finales con `echo $var | wc -m`(asi como nos da indirectas el mismo HTB).

### Ejercicios resueltos (sección 2/10 — mi bitácora)

**Ejercicio 1:** codificar `var` 40 veces en base64 y contar caracteres.
**Mi solución:** loop de 40 iteraciones + función `count()` que hace `echo $var | wc -m`.

```bash
#!/bin/bash
count() {
  echo $var | wc -m  #Aqui establecemos el metodo para con los caracteres obteniendo var
}

var="nef892na9s1p9asn2aJs71nIsm" #aca simplemente definimos la variable que nos da HTB
for counter in {1..40} #Contamos con un bucle que va de 1 hasta 40
do
  var=$(echo $var | base64)
done

count # Y finalmente llamamos el metodo para contar y cuenta pues var
```
Resultado: 5388161 

### Arguments, Variables, and Arrays (Bash Scripting 3/10)

**Lo que ya sabía (repaso):**
- `$1`, `$2`, `$3`... = argumentos posicionales pasados al script (ya lo usé en mi función `serve()` donde `${1:-8000}` toma el primer argumento)
- `echo $variable` = mostrar valor de variable
- `chmod +x script.sh` = dar permiso de ejecución
- `./script.sh` vs `bash script.sh` = ejecutar con el shebang definido vs forzar bash como intérprete
- Arrays básicos en otros lenguajes (Python, JavaScript)

**Lo que NO sabía / no tenía claro:**

**Argumentos y variables especiales:**
- Hasta **9 argumentos** posicionales: `$0` (nombre del script) a `$9`
- **Variables especiales** que no necesito declarar:

| Variable | Qué guarda |
|---|---|
| `$#` | número de argumentos recibidos |
| `$@` | lista de TODOS los argumentos |
| `$n` | argumento en posición n (`$1`, `$2`...) |
| `$$` | PID del proceso actual |
| `$?` | exit status del último comando (0 = éxito, 1+ = fallo) |

- El ejemplo del módulo con `$#`, `$0`, `$1`:
```bash
if [ $# -eq 0 ]          # ¿no me pasaron argumentos?
then
    echo -e "Usage:\n\t$0 &lt;domain&gt;"   # $0 = nombre del script
    exit 1
else
    domain=$1            # $1 = primer argumento
fi
```

**Variables — la regla del espacio:**

- Asignación: **`variable="valor"`** (sin espacios alrededor del `=`)
- Uso: **`$variable`** (con `$`)
- Error clásico: `variable = "valor"` → bash interpreta `variable` como comando a ejecutar

**Arrays en Bash:**

- Declaración: `dominios=(val1 val2 val3)` — espacios separan elementos
    
- Acceso: `${dominios[0]}` — índice empieza en 0
    
- **Comillas y arrays:** si pongo `"val1 val2"` dentro del array, se guarda como UN solo elemento (las comillas "blindan" los espacios internos)

```bash
dominios=(www.test.com ftp.test.com vpn.test.com)
echo ${dominios[0]}    # www.test.com
echo ${dominios[1]}    # ftp.test.com
```

### Conditionals (Bash Scripting 4/10)

**Lo que ya sabía (repaso):**
- `if [ condición ]; then ... fi` — estructura básica de condicionales en bash
- `if / then / elif / else / fi` — flujo con múltiples ramas
- `[[ ... ]]` vs `[ ... ]` — ya los usaba, aunque no entendía bien la diferencia
- `&&` (AND lógico) y `||` (OR lógico) — ya los usé en mis pipelines y en el ejercicio anterior
- `-gt`, `-lt`, `-eq` — operadores de comparación numérica (ya los usé en el `for` del base64)

**Lo que NO sabía / no tenía claro:**

**Comparación de strings vs integers: operadores DISTINTOS**

| Tipo | Operadores | Ejemplo |
|---|---|---|
| **String** | `==`, `!=`, `&lt;`, `&gt;`, `-z`, `-n` | `[ "$var" == "HackTheBox" ]` |
| **Integer** | `-eq`, `-ne`, `-lt`, `-le`, `-gt`, `-ge` | `[ $# -gt 1 ]` |

- **Error clásico:** usar `&gt;` con enteros dentro de `[ ]` → bash lo interpreta como redirección de archivo, no como comparación. Solución: usar `-gt` con `[ ]`, o usar `[[ ]]` donde `&gt;` sí funciona para strings ASCII
- `&lt;` y `&gt;` en strings comparan **orden alfabético ASCII**, no longitud: `"Apple" &lt; "Banana"` porque `'A'` (65) &lt; `'B'` (66)

**Comillas dobles en variables de string:**
```bash
if [ "$1" != "HackTheBox" ]   #  comillas: bash trata el contenido como string
if [ $1 != HackTheBox ]       #  sin comillas: errores si hay espacios/caracteres especiales
```

**File operators (recon y validación de archivos):**

|Operador|Qué prueba|
|---|---|
|`-e`|el archivo/directorio existe|
|`-f`|es un archivo regular|
|`-d`|es un directorio|
|`-L`|es un symlink|
|`-r` / `-w` / `-x`|permisos read/write/execute|
|`-s`|tamaño mayor que 0 (no vacío)|
|`-O`|el usuario actual es dueño|
|`-G`|el grupo del archivo coincide con el usuario actual|
|`-N`|archivo modificado después de la última lectura|

```bash
if [ -e "$1" ]; then
    echo "El archivo existe"
elif [ ! -e "$1" ]; then   # ! = negación lógica
    echo "No existe"
fi
```

**Boolean / Logical operators:**

|Operador|Significado|
|---|---|
|`!`|NOT (negación)|
|`&&`|AND (ambas condiciones)|
|`\|`|OR (una u otra)|

bash

```bash
# Ambas deben cumplirse: archivo existe Y se puede leer
if [[ -e "$1" && -r "$1" ]]; then
    echo "Existe y tenemos permiso de lectura"
fi
```

**La diferencia crucial: `[ ]` vs `[[ ]]`**

|Feature|`[ ]` (test)|`[[ ]]` (bash builtin)|
|---|---|---|
|`<`, `>` para strings|X (interpretado como redirección)|✔|
|`&&`, `\|` dentro|X (usa `-a`, `-o`)|✔|
|Pattern matching (`*`)|X|✔|
|Regex (`=~`)|X|✔|

### Arithmetic (Bash Scripting 5/10)

**Lo que ya sabía (repaso):**
- `+`, `-`, `*`, `/`, `%` — operadores aritméticos básicos (mismo sentido que en cualquier lenguaje)
- `variable++` / `variable--` — incremento/decremento (visto en C, JavaScript, etc.)
- `${#variable}` — longitud de string (ya lo usé en el ejercicio del base64: `${#var} -gt 113450`)

**Lo que NO sabía / no tenía claro:**

**Sintaxis de aritmética en Bash: `$(( ))`**
```bash
echo $((10 + 10))     # 20
echo $((10 / 10))     # 1
echo $((10 % 4))      # 2 (resto de la división)
```

- **Sin `$(( ))`** bash interpreta todo como strings: `echo 10 + 10` → imprime literalmente "10 + 10"
- **Dentro de `$(( ))`** no necesitas `$` para las variables: `echo $((increase++))` funciona; `echo $(($increase++))` también pero es redundante

**El patrón del `CIDR.sh` del módulo :**
```bash
while [ $stat -eq 1 ]
do
    ping -c 2 $host > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        ((stat--))        # decremento: sale del while
        ((hosts_up++))     # contador de hosts activos
        ((hosts_total++))  # contador total
    else
        ((stat--))         # decremento igual: sale del while aunque esté down
        ((hosts_total++))
    fi
done
```
**La lógica del while:** `stat=1` → entra al while → hace ping → sin importar si fue up o down, `((stat--))` lo deja en 0 → la condición `[ $stat -eq 1 ]` falla → sale del while. Es un while que corre **exactamente una vez** por host, controlado por la bandera `stat`. No es un while "infinito" como parece a primera vista.

**Diferencia clave:**

|Sintaxis|Qué evalúa|Contexto|
|---|---|---|
|`$(( ))`|expresión aritmética|devuelve el resultado numérico|
|`(( ))`|expresión aritmética|**exit code** (0 = resultado ≠ 0, 1 = resultado = 0)|

```bash
if (( 5 > 3 )); then echo "sí"; fi   # funciona: exit code 0 = true
if (( 0 )); then echo "sí"; fi       # no entra: 0 = false en aritmética
```


### Input and Output (Bash Scripting 6/10)

**Lo que ya sabía (repaso):**
- Redirecciones: `>` (sobrescribir), `>>` (append), `2>&1` (stderr a stdout) — del módulo Linux Fundamentals
- Pipes (`|`) — conectar output de un comando al input de otro
- Variables y funciones — ya los domino de secciones anteriores

**Lo que NO sabía / no tenía claro:**

**Input interactivo: `read`**
```bash
read -p "Select your option: " opt
```

- `-p` = **prompt**: muestra el mensaje y espera input en la **misma línea** (sin salto de línea)
- El input del usuario se guarda en la variable `opt`
- Sin `-p`: `echo "Select:"; read opt` — dos líneas, más feo

**Patrón de menú interactivo (del `CIDR.sh`):**
Se usa como un switch case para seleccionar una u otra opcion
```bash
echo -e "Additional options available:"
echo -e "\t1) Identify network range."
echo -e "\t2) Ping discovered hosts."
echo -e "\t3) All checks."
echo -e "\t*) Exit.\n"

read -p "Select your option: " opt

case $opt in
    "1") network_range ;;
    "2") ping_host ;;
    "3") network_range && ping_host ;;
    "*") exit 0 ;;
esac
```
- `\t` = tabulación (indenta el menú)
- `case` ejecuta la función correspondiente según el número ingresado
- `*)` = wildcard: cualquier otra cosa → salir

**Output Control: `tee` (la joya de esta sección)**

|Comando|Qué hace|¿Ves en pantalla?|¿Guarda en archivo?|
|---|---|---|---|
|`cmd > file`|redirección|X|✓ (sobrescribe)|
|`cmd >> file`|redirección append|X|✓ (agrega)|
|`cmd \| tee file`|tee|✓|✓ (sobrescribe)|
|`cmd \| tee -a file`|tee append|✓|✓ (agrega)|

```bash
# Ejemplo del CIDR.sh: whois muestra en pantalla Y guarda en CIDR.txt
netrange=$(whois $ip | grep "NetRange\|CIDR" | tee -a CIDR.txt)

# Otro ejemplo del CIDR.sh: descubrimiento de hosts
hosts=$(host $domain | grep "has address" | cut -d" " -f4 | tee discovered_hosts.txt)
```

**Por qué `tee` es superior a redirección pura en scripts largos:**

- Un script de enumeración puede tardar minutos. Con `>` solo, esperas en silencio sin saber si avanza o se colgó.
- Con `tee`, **ves el progreso en tiempo real** y al mismo tiempo **queda guardado** para el reporte.