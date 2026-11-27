### Introduccion (1/17)

Las aplicaciones web son aplicaciones interactivas que corren sobre un navegador. Una de las arquitecturas más comunes empleadas en este tipo de aplicaciones suele ser la cliente-servidor para manejar las interacciones, aunque no es la más eficiente.

Usualmente podemos dividirlas en 2 componentes hablando en términos generales:

- El `front-end`, que se encarga de manejar todo lo que ve y/o con el que interactúa el usuario —llamémosle interfaz gráfica— y corre del lado del cliente (navegador: Google Chrome, Opera, Edge, etc.).
- El `back-end`, donde se maneja el "cerebro" de una aplicación web, dado que se encarga de procesar las solicitudes del usuario y devolver lo que este solicite.

#### Aplicaciones Web vs Sitios Web

Antiguamente en internet se solía interactuar principalmente con `sitios web` estáticos. ¿Qué quiere decir esto? Que son sitios que no pueden cambiar su contenido en tiempo real, o al menos no antes de la llegada de ciertas actualizaciones o uso de librerías de JavaScript — esto por lo menos para sitios web conocidos como `Web 1.0`; antes de esto era HTML puro, por lo que si querías que la información cambiara, los autores debían cambiarla manualmente.

Por otro lado, la mayoría de aplicaciones web o `Web 2.0` pueden cambiar su contenido de manera dinámica dependiendo de cómo interactúe el usuario. Además, otra gran diferencia es que las aplicaciones web son completamente funcionales y pueden desempeñar distintas funciones para el usuario final, mientras que los sitios web carecen de esto. Otras diferencias importantes son:

- **Modularidad**: las aplicaciones web se pueden dividir en varios módulos y/o componentes para cumplir X o Y función.
- **Responsividad**: que el diseño visual se adapte a cualquier pantalla o dispositivo desde el cual se acceda.
- **Funcionar en cualquier plataforma** sin ser optimizado para esta.

#### Aplicaciones Web vs Aplicaciones nativas del SO

A diferencia de las aplicaciones nativas del SO, las aplicaciones web son plataformas independientes que pueden correr en cualquier navegador, lo que les permite correr en cualquier sistema operativo. Estas aplicaciones no requieren obligatoriamente estar instaladas en tu dispositivo, ya que sus principales funcionalidades se ejecutan en un servidor remoto sin consumir demasiados recursos adicionales del usuario final.

#### Distribución de aplicaciones web

Existen un montón de aplicaciones web de código abierto que usan distintas organizaciones a lo largo del mundo, las cuales pueden ser modificadas al gusto y/o las necesidades de estas. Algunas de las aplicaciones web de código abierto más comunes son:

- [WordPress](https://wordpress.com/)
- [OpenCart](https://www.opencart.com/)
- [Joomla](https://www.joomla.org/)

También existen algunas que son de pago, las cuales son desarrolladas y mantenidas por organizaciones para venderlas a otras siguiendo generalmente un modelo de suscripción. Algunas de las más comunes son:

- [Wix](https://www.wix.com/)
- [Shopify](https://www.shopify.com/)
- [DotNetNuke](https://www.dnnsoftware.com/)

#### Riesgos de seguridad en aplicaciones web

A día de hoy podríamos decir que uno de los mayores blancos de ataque por los ciberdelincuentes son las aplicaciones web, esto porque son un objetivo común y generalmente lucrativo, lo cual representa un gran reto para las organizaciones independientemente de su tamaño.

Después de todo, las aplicaciones web pueden ser accesibles desde cualquier parte del mundo; cualquiera con internet y un navegador ya tiene superficie de ataque para estas apps. A día de hoy existe un vasto arsenal de herramientas automatizadas ya sea para atacar o escanear estas aplicaciones web que, en las manos equivocadas, puede generar gran daño y pérdidas a la organización. Pero como pentesters y profesionales de la ciberseguridad, tener acceso a estas herramientas nos permite evaluar y disminuir la superficie de ataque que puedan tener estos ciberdelincuentes, minimizando las pérdidas de las organizaciones y protegiendo sus recursos.

#### Atacando aplicaciones web

A día de hoy es muy común ver que muchas compañías, sin importar su tamaño, manejan 1 o más aplicaciones web. Pueden ir desde aplicaciones simples para publicar anuncios o información manejadas por un `Content Management System` (CMS) como `WordPress`, hasta aplicaciones con funcionalidades complejas como inicios de sesión que soportan autenticación con distintos roles: desde usuarios básicos (privilegios mínimos) hasta usuarios con roles de administrador (privilegios máximos o superusuarios). Si bien a día de hoy no es tan común encontrar servicios o hosts expuestos directamente que puedan ser explotados por medio de `well known exploits` (técnicas o herramientas para explotar vulnerabilidades bien documentadas que generalmente ya se encuentran parchadas), a veces sucede.

Las aplicaciones web representan una vasta superficie de ataque, y más por su naturaleza evolutiva y constante cambio, que si bien en ocasiones puede representar nuevas formas de protegerse o innovadoras funcionalidades, a veces introducen nuevos vectores de ataque que están ahí esperando que alguien los encuentre — preferiblemente un profesional de la ciberseguridad antes que un actor malicioso.

Algunos de los ejemplos de ataques más comunes en el mundo real son:

| Ataque | Escenario del mundo real |
|---|---|
| Inyección SQL | Obtener los usuarios de un `Directorio Activo` y luego realizar un password spraying contra un portal de correo electrónico o una VPN. |
| File Inclusion (Inclusión de archivos) | Leer el código fuente para encontrar una página o directorio oculto que expone funcionalidad adicional que puede usarse para ganar ejecución remota de código (RCE). |
| Unrestricted File Upload (Carga de archivos sin restricción) | Una app que permite subir una foto de perfil acepta cualquier tipo de archivo (no solo imágenes) → se sube código malicioso → control total del servidor de la aplicación web. |
| IDOR (Insecure Direct Object Referencing) | Combinado con broken access control: editás tu perfil yendo a `/user/701/edit-profile`; si cambiás el 701 por 702, podés editar el perfil de otro usuario. |
| Broken Access Control (Control de acceso roto) | Al registrar un usuario, el POST manda `username=bjones&password=Welcome1&email=...&roleid=3`. Si manipulás el parámetro `roleid` y lo cambiás a 0 o 1, podés registrar un usuario administrador y acceder a funciones no previstas de la app. |