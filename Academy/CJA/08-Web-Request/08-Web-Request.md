### HyperText Transfer Protocol (HTTP) (Web Requests 1/8)

#### Lo que ya sabía (repaso)
- HTTP = protocolo de nivel de aplicación para acceder a recursos de la World Wide Web; "hypertext" = texto con links a otros recursos.
- Comunicación cliente-servidor: el cliente pide un recurso, el servidor lo procesa y lo devuelve. Puerto default: **80** (configurable).
- Se usa un FQDN como URL (ej. www.hackthebox.com) para llegar al sitio.

#### Lo que NO sabía / no tenía claro

**Estructura de una URL** (componentes):

| Componente | Ejemplo | Descripción |
|---|---|---|
| Scheme | `http://` `https://` | Protocolo; termina en `://` |
| User Info | `admin:password@` | Opcional; credenciales separadas por `:` y del host por `@` |
| Host | `inlanefreight.com` | Ubicación del recurso (hostname o IP) |
| Port | `:80` | Separado del host por `:`; default 80 (http) / 443 (https) si no se especifica |
| Path | `/dashboard.php` | Recurso (archivo o carpeta); sin path → el server devuelve el index default |
| Query String | `?login=true` | Empieza con `?`; pares parámetro=valor; varios se separan con `&` |
| Fragments | `#status` | Procesados **client-side** por el browser para ubicar secciones dentro de la página |

- Solo **scheme y host son obligatorios** — sin ellos la request no tiene recurso.

**HTTP Flow (alta nivel):**
1. El usuario ingresa la URL; el browser consulta a un **DNS server** para resolver el dominio a IP (sin IP no hay comunicación).
2. El browser manda **GET al puerto 80**, path `/`.
3. El web server procesa y devuelve el recurso default (index.html) + **status code** (200 OK = éxito).
4. El browser renderiza y presenta.

- El browser primero busca en el archivo local **`/etc/hosts`**; si el dominio no está ahí, consulta DNS servers. Podemos **agregar registros manualmente** en /etc/hosts (IP + dominio) — truco clásico de labs y pentesting.

**cURL (client URL):**
- Herramienta CLI + library; soporta HTTP y muchos otros protocolos → ideal para scripts y automatización. Esencial para web pentesting (las dos herramientas del módulo: browser + cURL).
- `curl http://info.cern.ch/` → imprime el HTML **crudo** (no renderiza JS/CSS como un browser) — como pentester nos interesa el contexto request/response, más rápido que el browser.
- `curl -O <url>` → descarga guardando con el **nombre remoto**; `-o <nombre>` → nombre custom; `-s` → silent (apaga el status).
- `curl -h` → help por categorías; `--help all` → todo; `-h http` → help de flags http; `man curl` → manual completo.
- Flags que vienen en secciones siguientes: `-d` (POST data), `-i` (incluir response headers), `-u` (user:password), `-A` (User-Agent), `-v` (verbose).

### Hypertext Transfer Protocol Secure (HTTPS) (Web Requests 2/8)

#### Lo que ya sabía (repaso)
- HTTP transfiere todo en **clear-text**: cualquiera entre origen y destino puede hacer MiTM y ver los datos (ej. credenciales de un POST a /login.php en plaintext).
- HTTPS = HTTP con cifrado: aunque un tercero intercepte, no puede extraer los datos. Por eso HTTPS es el estándar y HTTP está en vías de extinción (los browsers pronto ni dejarán visitar sitios HTTP).

#### Lo que NO sabía / no tenía claro

**Señales de un sitio HTTPS:**
- `https://` en la URL + candado en la address bar (a la izquierda de la URL; clickeable para ver info del sitio/cert).
- El tráfico interceptado (Wireshark) se ve como **un solo stream cifrado** (TLSv1.2 application data) vs. HTTP donde se leen usuario/password en claro.

**Matiz importante**: HTTPS cifra los datos, pero el dominio consultado igual se puede filtrar si se usa un **DNS server en claro**. Mitigación: DNS cifrado (8.8.8.8, 1.1.1.1) o VPN.

**HTTPS Flow (alta nivel):**
1. El usuario tipea `http://` en un sitio que fuerza HTTPS → request al puerto 80 → el server responde **301 Moved Permanently** redirigiendo a HTTPS:443.
2. **TLS handshake**: client "client hello" (info sobre sí mismo) → server "server hello" → intercambio de claves y **certificados SSL** → el cliente verifica el cert del server y manda el suyo → handshake cifrado de confirmación.
3. De ahí en más, la comunicación HTTP sigue pero **encriptada**. (El detalle del key exchange está fuera del scope del módulo.)

**HTTP Downgrade attack:** un atacante con un proxy MiTM puede intentar bajar HTTPS→HTTP para volver todo claro-text. Los browsers/servers/apps modernos se defienden de esto.

**cURL con HTTPS:**
- cURL maneja el handshake TLS y el cifrado/descifrado automáticamente.
- Si el sitio tiene certificado SSL inválido o viejo → cURL **se niega a seguir** por defecto: `curl: (60) SSL certificate problem: Invalid certificate chain` (los browsers modernos hacen lo mismo).
- Caso típico del pentester: apps locales o de práctica sin cert válido → **`curl -k`** (skip certificate check) y la request pasa.

### HTTP Requests and Responses (Web Requests 3/8)

#### Lo que ya sabía (repaso)
- La comunicación HTTP = request (cliente: cURL/browser) + response (server). La request lleva recurso, datos, headers y opciones; la response lleva response code y, si hay acceso, el recurso.

#### Lo que NO sabía / no tenía claro

**Anatomía de un HTTP Request — primera línea (3 campos separados por espacios):**

| Campo | Ejemplo | Descripción |
|---|---|---|
| Method | `GET` | El verbo HTTP: tipo de acción a realizar |
| Path | `/users/login.html` | Recurso; puede llevar query string (`?username=user`) |
| Version | `HTTP/1.1` | Versión del protocolo |

- Después: **headers** (pares clave:valor — Host, User-Agent, Cookie, etc.) que especifican atributos de la request. Los headers terminan con una **línea vacía** (newline) — necesaria para que el server valide la request.
- Al final (opcional): **request body** con datos.
- HTTP 1.X = texto claro, campos separados por newline. **HTTP 2.X = datos binarios en forma de diccionario**.

**Anatomía de un HTTP Response — primera línea (2 campos):**
1. Versión (HTTP/1.1)
2. **Response code** (ej. 200 OK) — estado de la request (sección 5)

- Luego headers (Date, Server, Set-Cookie, Content-Type...) y, tras una línea vacía, el **response body**: típicamente HTML, pero puede ser **JSON**, imágenes, stylesheets, scripts, o un documento (PDF).

**cURL `-v` (verbose):** muestra la **request y response completas** — ideal para pentesting/exploits:
- `> ` = líneas de la request (GET / HTTP/1.1, Host, User-Agent, Accept, Connection)
- `< ` = líneas de la response (HTTP/1.1 401 Unauthorized, Server, Content-Length, Content-Type)
- Ejemplo: `curl inlanefreight.com -v` → request mínima de cURL, response 401 con `WWW-Authenticate: Basic realm="Restricted Content"`.
- `-vvv` = aún más verbose (ejercicio: probarlo y ver qué extra sale).

**Browser DevTools:**
- F12 o Ctrl+Shift+I (Chrome/Firefox). Varios tabs; el foco del módulo: **Network tab**.
- Cada página = múltiples requests/responses para renderizar. En Network tab + refresh: lista de requests con **status code**, **método**, dominio y **path**.
- **Filter URLs** para buscar un request específico cuando la página carga muchos.
- Clickear un request → pestaña **Response** (body) → botón **Raw** (código fuente sin renderizar).

### HTTP Headers (Web Requests 4/8)

#### Lo que ya sabía (repaso)
- Los headers pasan información entre cliente y servidor; algunos solo para requests, otros solo para responses, otros comunes a ambos. Formato: `Nombre: valor` (un header puede tener múltiples valores).
- El módulo usa la clasificación clásica de **RFC 2616** (5 categorías) como modelo mental — obsoleta desde 2014 (RFC 7230-7235) y hoy (2022) **RFC 9110**, que agrupa por función (representation metadata, content negotiation, auth, caching). Las categorías siguen usándose en la práctica.

#### Lo que NO sabía / no tenía claro

**1. General Headers** (contexto del mensaje, no su contenido):
| Header | Ejemplo | Descripción |
|---|---|---|
| `Date` | `Wed, 16 Feb 2022 10:38:44 GMT` | Fecha/hora de origen del mensaje (preferido en UTC) |
| `Connection` | `close` / `keep-alive` | Si la conexión muere tras la request (`close`) o se mantiene abierta (`keep-alive`) |
| `Cache-Control` | `no-store` | Cómo se cachea el mensaje en browsers/proxies. **Seguridad**: respuestas con datos sensibles (tokens, info personal) → `no-store` para que no se escriba a disco ni cachés compartidos |

**2. Entity Headers** (describen el contenido transferido; comunes en responses y POST/PUT):
| Header | Ejemplo | Descripción |
|---|---|---|
| `Content-Type` | `text/html`, `application/json` | Media type del recurso; incluye `charset` (ej. UTF-8). Lo agrega el browser y el server |
| `Content-Length` | `385` | Tamaño del entity en bytes. **Necesario**: el server lo usa para leer el body |
| `Content-Encoding` | `gzip` | Transformaciones aplicadas al dato (ej. compresión) |
| `Transfer-Encoding` | `chunked` | Encoding para transferir el body seguro en HTTP/1.1; `chunked` permite streamear sin conocer el largo total. ⚠️ El manejo inconsistente de Transfer-Encoding vs Content-Length entre proxy front-end y server back-end = **root cause de HTTP request smuggling** |
| `boundary` | param de `Content-Type: multipart/form-data` | Separador de partes en mensajes multiparte; se usa como `--<valor>` entre partes del form |

**3. Request Headers** (los manda el cliente; no sobre el contenido):
| Header | Ejemplo | Descripción |
|---|---|---|
| `Host` | `www.inlanefreight.com` | Host consultado. **Objetivo de enumeración** (un server puede hostear varios sitios revelados por hostname) y de **Host header injection** |
| `User-Agent` | `curl/7.77.0` | Describe al cliente (browser, versión, OS) — revela mucho |
| `Referer` | `http://www.inlanefreight.com/` | De dónde viene la request. **Peligroso confiar**: se manipula fácilmente |
| `Accept` | `*/*` | Media types que el cliente entiende (varios separados por coma) |
| `Cookie` | `PHPSESSID=b4e4fbd93540` | Pares `nombre=valor`; identificador de sesión guardado client+server; varias cookies separadas por `;` |
| `Authorization` | `Basic cGFzc3dvcmQK` | Identificación del cliente: esquemas **Basic, Bearer (tokens/JWT), Digest**. A diferencia de la cookie, el cliente la genera y adjunta en cada request |
| `X-Forwarded-For` | `203.0.113.5` | IP original del cliente, agregada por proxies/load balancers. **Client-controllable** → se puede spoofear para bypass de controles por IP, rate limiting o blocklists |

**4. Response Headers** (los manda el server):
| Header | Ejemplo | Descripción |
|---|---|---|
| `Server` | `Apache/2.4.41 (Ubuntu)` | Info del server → enumeración (versión). Hardening: suprimirlo/generalizarlo |
| `Location` | `https://.../login` | Con redirects 3xx, a dónde ir. Si se arma con input no validado → **open redirect** |
| `Set-Cookie` | `PHPSESSID=...; Secure; HttpOnly; SameSite=Strict` | Manda cookie al cliente para guardar y reenviar. Atributos de seguridad: **Secure** (solo HTTPS), **HttpOnly** (inaccesible a JS → mitiga robo por XSS), **SameSite** (Strict/Lax/None → defensa CSRF) |
| `WWW-Authenticate` | `Basic realm="localhost"` | Tipo de auth requerida; va con **401** |

**5. Security Headers** (agrupación de la industria, popularizada por OWASP Secure Headers Project):
| Header | Ejemplo | Descripción |
|---|---|---|
| `Content-Security-Policy` | `script-src 'self'` | Política de recursos inyectables: el browser solo acepta recursos de dominios de confianza → previene **XSS** |
| `Strict-Transport-Security` | `max-age=31536000` | Fuerza HTTPS; el browser no accede por HTTP en claro |
| `X-Content-Type-Options` | `nosniff` | El browser respeta el `Content-Type` declarado y no "adivina" el MIME → sin esto, un upload se podría convertir en **stored XSS** |
| `X-Frame-Options` | `DENY` | Si la página puede renderizarse en frame/iframe/object → anti-**clickjacking**. (Reemplazado por `frame-ancestors` en CSP, pero sigue desplegado) |
| `Access-Control-Allow-Origin` | `https://www.inlanefreight.com` | Parte de **CORS**: qué origins pueden leer la response. Misconfigs (reflejar el Origin del requester, o `*` con credentials) = vulnerabilidades CORS |
| `Referrer-Policy` | `origin` | Controla si el browser manda el `Referer` — evita filtrar URLs/info sensible |

- Lista autoritativa actual de headers: **IANA HTTP Field Name Registry** (cada nombre linkea a su RFC). Las apps también pueden definir headers custom.

**cURL:**
- `-I` → manda **HEAD request**, muestra **solo response headers**.
- `-i` → muestra **headers + body** (envía el request que especifiques).
- `-H` → setear request headers (sección 7). Algunos tienen flag propio: `-A` para User-Agent (`curl <url> -A 'Mozilla/5.0'`).
- Verificar con `-I` o `-v` que el header cambió.

**DevTools:** Network tab → click en request → pestaña **Headers** (request + response headers organizados; botón **Raw** para formato crudo) + pestaña **Cookies**.

### HTTP Methods and Codes (Web Requests 5/8)

#### Lo que ya sabía (repaso)
- Los métodos le dicen al server cómo procesar la request y cómo responder; el status code indica el resultado. Con cURL `-v`, el método está en la primera línea (`GET / HTTP/1.1`); en DevTools, en la columna Method.

#### Lo que NO sabía / no tenía claro

**Métodos comunes (tabla del módulo):**

| Método | Descripción |
|---|---|
| `GET` | Pide un recurso. Datos extra via query string en la URL (`?param=value`) |
| `POST` | Manda datos al server (texto, PDFs, binario) en el **request body**. Uso típico: formularios/logins, uploads de imágenes/documentos |
| `HEAD` | Pide **solo los headers** que devolvería un GET (sin body). Sirve para chequear el response length antes de descargar |
| `PUT` | **Crea** recursos nuevos en el server. Si está habilitado sin controles → upload de recursos maliciosos |
| `DELETE` | **Borra** un recurso existente. Sin control → **DoS** borrando archivos críticos |
| `OPTIONS` | Devuelve info del server: métodos que acepta |
| `PATCH` | **Modificación parcial** del recurso en la ubicación especificada |

- Corrección mía de antes: **PATCH sí está en la tabla oficial** del módulo — te lo había dicho fuera de la lista. Acá confirmado.
- La disponibilidad de cada método depende del server y de la config de la app.
- **La mayoría de las web apps modernas usan GET y POST**. Las que usan REST APIs también se apoyan en **PUT y DELETE** (update y delete en el endpoint).

**Status codes — 5 clases:**

| Clase | Significado |
|---|---|
| 1xx | Informativos; no afectan el procesamiento |
| 2xx | La request tuvo éxito |
| 3xx | El server redirige al cliente |
| 4xx | Request impropia del cliente (recurso inexistente, formato malo) |
| 5xx | Problema del server |

**Los comunes de cada clase:**

| Code | Significado |
|---|---|
| 200 OK | Request exitosa; el body trae el recurso pedido |
| 302 Found | Redirect a otra URL (ej. al dashboard tras login exitoso) |
| 400 Bad Request | Request malformada (ej. faltan line terminators) |
| 403 Forbidden | El cliente no tiene acceso al recurso; también cuando el server detecta input malicioso |
| 404 Not Found | El recurso no existe en el server |
| 500 Internal Server Error | El server no puede procesar la request |

- Existen listas completas de codes estándar; además, providers como **Cloudflare o AWS implementan sus propios codes**.

### GET (Web Requests 6/8)

#### Lo que ya sabía (repaso)
- Al visitar cualquier URL, el browser manda GET por default para obtener el recurso; después puede mandar otros métodos (visible en Network tab).
- GET pasa datos vía **query string en la URL** (`?param=value`).

#### Lo que NO sabía / no tenía claro

**HTTP Basic Auth (vs login forms):**
- La auth básica la maneja el **webserver directamente** para proteger una página/directorio — **sin interactuar con la web app** (distinto a un formulario POST con parámetros).
- Sin credenciales → `curl -i http://IP:PORT/` devuelve **401** + header `WWW-Authenticate: Basic realm="Access denied"` + body "Access denied". El `realm` confirma el esquema.
- Con credenciales (admin:admin en el ejercicio), tres formas de pasarlas:
  1. `curl -u admin:admin http://IP:PORT/`
  2. En la URL: `curl http://admin:admin@IP:PORT/`
  3. Header manual: `curl -H 'Authorization: Basic YWRtaW46YWRtaW4=' http://IP:PORT/` (`-H` se puede repetir para varios headers)
- Detalle técnico: `-v` muestra que Basic auth manda `Authorization: Basic <base64(user:pass)>` — `YWRtaW46YWRtaW4=` = `admin:admin` en base64. **Base64 ≠ cifrado**: se decodifica al instante; solo va "ofuscado". Con JWT sería `Authorization: Bearer <token largo>`.

**GET Parameters en acción (City Search):**
- La search del ejercicio dispara un GET a `search.php?search=<término>` → el backend devuelve los datos (formato específico tipo JSON, sin el layout HTML).
- Atajo DevTools: **Ctrl+Shift+E** = ir directo al Network tab. El ícono de **trash (arriba a la izquierda)** limpia requests previos para monitorear solo los nuevos.
- Diferencia clave: pegar la URL de la request directo en el browser/cURL da los datos **crudos** (sin el HTML que los envuelve en la página).

**Copiar requests desde DevTools (dos joyas):**
- **Copy → Copy as cURL**: copia el comando cURL completo con todos los headers → pegar en terminal = misma response. Se pueden borrar headers de más y quedarse solo con los necesarios (ej. `Authorization`).
- **Copy → Copy as Fetch**: copia la request en sintaxis **JavaScript Fetch** → pegar en la **Consola** (Ctrl+Shift+K) + Enter = la request se ejecuta desde el browser y podés inspeccionar la response ahí mismo.

### POST (Web Requests 7/8)

#### Lo que ya sabía (repaso)
- GET pone los parámetros del usuario en la URL; cuando las apps necesitan transferir archivos o sacar los parámetros de la URL, usan POST.
- POST coloca los parámetros en el **request body**.

#### Lo que NO sabía / no tenía claro

**3 beneficios del POST vs GET:**
1. **Lack of logging**: los POST pueden transferir archivos grandes (uploads); no es eficiente que el server loguee archivos subidos como parte de la URL (como pasaría si el upload fuera GET).
2. **Less encoding requirements**: las URLs se diseñaron para compartir → solo caracteres convertibles a letras. El body acepta **datos binarios**; solo hay que encodear los caracteres que separan parámetros.
3. **More data**: el largo máximo de URL varía entre browsers (Chrome/Firefox/IE), web servers (IIS, Apache, nginx), CDNs (Fastly, Cloudfront, Cloudflare) y hasta URL shorteners (bit.ly, amzn.to). Regla general: mantener URLs **bajo 2,000 caracteres** → no sirven para muchos datos.

**Login forms (POST manual con cURL):**
- El ejercicio usa **PHP login form** (no Basic Auth). Login admin:admin → la app funciona igual que la del GET.
- En DevTools (Network, filtrando por IP del server para descartar requests externos): el POST de login lleva body `username=admin&password=admin` (pestaña **Request** → botón **Raw** para verlo crudo).
- Crafting manual:
  `curl -X POST -d 'username=admin&password=admin' http://<IP>:<PORT>/`
  - `-X POST` = método | `-d` = POST data
  - Si el HTML de la response ya no tiene el form de login y sí la search function → autenticación exitosa.
- **Tip: `-L`** → seguir redirects (muchos logins redirigen a /dashboard.php tras autenticar).

**Authenticated Cookies:**
- Al autenticar, el server manda `Set-Cookie: PHPSESSID=...; path=/` (visible con `-i` o `-v`).
- Reutilizar la sesión sin re-loguear:
  - `curl -b 'PHPSESSID=xxx' http://<IP>:<PORT>/` (`-b` = cookie)
  - o como header: `curl -H 'Cookie: PHPSESSID=xxx' http://<IP>:<PORT>/`
- En el browser: **Storage tab (Shift+F9)** → Cookies → reemplazar el valor de PHPSESSID con el autenticado → refresh → entrás sin login.
-  Dato clave del módulo: **una cookie válida puede ser suficiente para autenticarse** en muchas apps → parte esencial de ataques como **XSS** (robo de cookies = robo de sesión).

**JSON Data:**
- La search del ejercicio envía POST a `search.php` con body **JSON**: `{"search":"london"}` + header `Content-Type: application/json` (confirmable con Copy → Copy Request Headers).
- Replicar con cURL:
  `curl -X POST -d '{"search":"london"}' -b 'PHPSESSID=xxx' -H 'Content-Type: application/json' http://<IP>:<PORT>/search.php`
  → response: `["London (UK)"]` (array JSON)
- Lograr interactuar con la app **sin pasar por el front-end** = skill esencial para web assessments y bug bounty (mucho más rápido testear así).
- Ejercicio del módulo: repetir la request **sin** cookie y **sin** Content-Type → ver cómo reacciona distinto la app (ej. 401 sin cookie; error/malformado sin JSON header).

### CRUD API (Web Requests 8/8)

#### Lo que ya sabía (repaso)
- Las APIs permiten interactuar con una base de datos: en la query se especifica **tabla y fila**, y el método HTTP define la operación (ej. `curl -X PUT http://IP:PORT/api.php/city/london`).
- Las apps tradicionales usan PHP parameters para buscar; esta sección muestra cómo la misma función se implementa vía API y cómo interactuar directo con el endpoint.

#### Lo que NO sabía / no tenía claro

**CRUD — las 4 operaciones:**

| Operación | Método | Descripción |
|---|---|---|
| Create | POST | Agrega el dato especificado a la tabla |
| Read | GET | Lee la entidad especificada |
| Update | PUT | Actualiza el dato de la entidad |
| Delete | DELETE | Borra la fila especificada |

- El principio aplica a **CRUD APIs, REST APIs y otras**. No todas las APIs funcionan igual y el **access control del usuario** limita qué acciones podés hacer y qué resultados ver. (Detalle en *Introduction to Web Applications*.)

**Read (GET):**
- `curl http://IP:PORT/api.php/city/london` → JSON string: `[{"city_name":"London","country_name":"(UK)"}]`
- Formatear: pipe a **`jq`** + `-s` para silenciar cURL:
  `curl -s http://IP:PORT/api.php/city/london | jq` → JSON pretty-printed.
- Búsqueda parcial: `/api.php/city/le` → todos los matcheos (Leeds, Dudley, Leicester...).
- **String vacío** → trae TODAS las entradas de la tabla: `/api.php/city/`.
- Las mismas URLs funcionan en el browser (renderiza el JSON).

**Create (POST):**
- `curl -X POST http://IP:PORT/api.php/city/ -d '{"city_name":"HTB_City","country_name":"HTB"}' -H 'Content-Type: application/json'`
- Luego verificar con Read (`/api.php/city/HTB_City` | jq → aparece la nueva).
- Ejercicio: crear una ciudad desde DevTools con Fetch (como en la sección 7).

**Update (PUT):**
- Similar a POST, pero hay que **especificar la entidad en la URL** (si no, la API no sabe qué editar):
  `curl -X PUT http://IP:PORT/api.php/city/london -d '{"city_name":"New_HTB_City","country_name":"HTB"}' -H 'Content-Type: application/json'`
- Resultado: `london` deja de existir, `New_HTB_City` aparece (verificar leyendo ambos).
- **PATCH vs PUT**: PATCH actualiza **parcialmente** (solo algunos campos, ej. solo city_name); PUT actualiza la **entrada completa**. Con **OPTIONS** se puede consultar cuál acepta el server.
- Nota: en algunas APIs, Update también **crea** si la entrada no existe (upsert); en el ejemplo del módulo no (probar con una ciudad inexistente).

**Delete (DELETE):**
- `curl -X DELETE http://IP:PORT/api.php/city/New_HTB_City` → al leer después, devuelve `[]` (array vacío = ya no existe).

**Cierre del módulo:** las 4 operaciones CRUD corren por cURL. En una app real, permitirlas a cualquier usuario = **vulnerabilidad**; cada usuario tiene privilegios de read/write. Para autenticarse contra la API: cookie o header de autorización (ej. **JWT**) como en secciones anteriores.

