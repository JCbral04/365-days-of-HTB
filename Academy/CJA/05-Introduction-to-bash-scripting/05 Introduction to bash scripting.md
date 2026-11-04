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

