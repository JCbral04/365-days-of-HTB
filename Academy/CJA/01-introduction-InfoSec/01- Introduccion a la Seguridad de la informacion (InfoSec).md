## Definicion

> [!NOTE]+ Concepto Principal
> Podemos llamarlo como la proteccion de la informacion y los sistemas que la procesan, almacenan y transmiten.
> 
> No diria que es un estado absoluto, es gestion de riesgo, encarecer el ataque, detectar rapido y recuperar.

---

## Triada CIA (pilares)

|Pilar | Que protege |
|------|-------------|
|**Confidencialidad** | Solo los que estan autorizados pueden acceder a la informacion |
|**Integridad** | La informacion no se altera sin permiso |
| **Disponibilidad** | La informacion debe ser accesible cuando se necesita |

> [!INFO] Extensiones
> Extensiones: **Autenticidad**(Info/Origen genuino) y **No repudio**(nadie puede negar sus acciones)

---

## Amenazas basicas o mas comunes

- **Malware**(virus, troyanos, spyware): Podriamos definir el **malware** cualquier codigo o programa informatico cuyo proposito es intencionalmente dañar, infectar, espiar o tomar el control no autorizado de un sistema, red o dispositivo. Su objetivo principal es el beneficio del atacante a expensas del usuario afectado.
- **Ransomware/ RaaS**(Ransomware-as-a-Service): Desarrolladores o programadores alquilan ransomware, afiliados eecutan el ataque y generalmente parten el rescate (Ej:70/30). Modelo copiado del SaaS: panel de control, soporte, actualizaciones. Ej: LockBit, Conti.
- **DDoS y/o DoS**(Denegacion de servicio): Los ataques de denegacion de servicio buscan saturar un servidor,  red o servicio web de 3ros con trafico falso para saturar y agotar los recursos de su infraestructura  y dejarlo inaccesible para los usuarios reales. 

> [!FAQ] Diferencia clave: DoS vs DDoS
> La diferencia clave esta en el origen: Mientras que **DoS** se ejecuta desde **una sola computadora**, un **DDoS** en cambio de forma distribuida desde **miles de dispositivos infectados**(tambien llamado una *botnet*) a la vez, lo que vuelve a este ultimo mucho mas masivo y dificil de bloquear.

##### Ingenieria social
  **(El humano el eslabon mas debil):** Podemos definir a la ingenieria social como el conjunto de tecnicas de manipulacion psicologica utilizadas por los ciberdelicuentes con el fin de engañar a las personas y lograr que realicen acciones voluntarias que compromenten su seguridad. A diferencia de los hackeos tecnicos que atacan al software, este metodo **ataca al "eslabon humano"**, explotando emociones como la confianza, el miedo o la curiosidad para robar contraseñas, obtener datos confidenciales o infectar equipos.
  
- **Insider threat**(amenza interna): Una **amenza interna** o **insider threat** es el riesgo de seguridad que proviene de el interior de la propia organizacion. Ocurre cuando un empleado, exempleado, contratista o socio de confianza utiliza sus privilegios legitimos de acceso ya sea para dañar los sistemas, robar propiedad intelectual o sabotear la infraestructura, ya sea de forma intencionada(maliciosa) o por negligencia(Error involuntario).

   **Tipos de Insider Threats:**
   * **El malicioso (Malicious):** Roba o destruye informacion para beneficio propio o venganza-
   * **El negligente (careless):** Comete un error o ignora las politicas de seguridad (p. ej., caer en [[#Ingenieria social]])
   * **El infiltrado (compromised):** Un atacante externo roba sus credenciales legitimas.
   
- **APT**(*Advanced Persisten Threat* o Amenaza Persistente Avanzada): Es un ciberataque sigiloso y dirigido a gran escala, ejecutada por grupos de hackers altamente financiados con recursos infinitos, persistencia de años, máximo sigilo(a menudo respaldados por gobiernos). A diferencia de los ataques rapidos que puede hacer un hacker del comun, un **APT** busca infiltrarse en una red  especifica y **permanecer oculta durante meses o años** para espiar, sabotear o robar informacion critica de forma continua sin ser detectados.

## Threat Actors (quiénes atacan)


|Actor|Motivación|Nivel|
|---|---|---|
|Script kiddie|diversion/ego|Bajo|
|Hacktivista|ideologica|Medio|
|Crimen organizado|dinero|Alto (con economia profesional: IABs, money mules)|
|Insider|dinero/venganza|Variable|
|APT / nación-estado|Espionaje|Muy alto|
|Terrorista|Caos|Bajo-medio|

> [!NOTE]+ **Idea clave:** el actor define los TTPs y por tanto la defensa. Un ransomware no persiste años como una APT.

## Equipos de ciberseguridad

* **Red team(equipo rojo):** Simula al atacante. Sofisticado = roles definidos, sigilo, persistencia, C2 propio. Lone wolf = flexible pero mas ruidoso.
* **Blue team(equipo azul):** Defiende, detecta y responde. Su arma es la observacion + frustracion, nunca devuelve el golpe(Solo defiende).
* **Purple Team:** integra ambos (Rojo y Azul) el ataque informa la defensa en tiempo real.
* **SOC(Security Operations Center o **Centro de Operaciones de Seguridad**):** monitorea 24/7. Niveles: L1 (triaje de alertas) → L2 (investigación) → L3 (threat hunting). Herramienta central: SIEM.
* **Bug bounty hunters:** hackers éticos con permiso de  la empresa o empresas las cuales prometen no demandar si se respetan las reglas.  ¿Por qué los bug bounters no traicionan a las empresas? Porque el _hunter_ protege celosamente su reputación y su perfil en la comunidad, los cuales constituyen su activo profesional más valioso, además de que reciben compensaciones económicas legítimas por sus hallazgos.

## Conceptos clave

- ****C2 (Command & Control):**** infraestructura del atacante para comunicarse con máquinas comprometidas. Detectar el C2 (beaconing, dominios raros) = encontrar al intruso.
- ****Honeypot:**** trampa que registra al atacante. Caer en uno = estás detectado, quemado (IOCs compartidos) y perdiendo tiempo con datos falsos.
- ****Hack back**** (atacar al atacante): técnicamente posible, ilegal sin autorización. Lo legal: takedowns vía ISP/registrar, sinkholing, threat intel.
- ****"¿Sistemas inhackeables?":**** no existen (complejidad, humano, 0-days, hasta air-gapped cayó con Stuxnet). La meta es gestionar riesgo, no eliminarlo.
- ****Anonimato ≠ seguridad.**** El proxy protege el tráfico; el anonimato protege la identidad.