Construir un proyecto en Terraform que permita crear una infraestructura en AWS que cumpla con los siguientes requisitos:

Crear un servicio de cómputo con SO Linux (EC2, ECS, EKS, etc…).                    ✅ = Opté por una EC2 instance con una imagen basada en SO Ubuntu
Crear un servicio de base de datos (RDS, DynamoDB, Aurora, etc …).                  ✅ = Opté por el servicio de BD DynamoDB
Crear políticas de seguridad para el acceso SSH (por ejemplo, restricción de IPs).  ✅ = Opté por restricción de IPs, por temas de la prueba lo dejé en 0.0.0.0/0 pero segmentarlo a su IP 
Construir una imagen de Docker con SO Linux y publicarla, la imagen debe contar con las siguientes especificaciones:
Instalar Git                                                                        ✅ = Se validó desde el contenedor que corre en la EC2
Instalar Vs Code                                                                    ✅ = Se validó desde el contenedor que corre en la EC2
Instalar Maven                                                                      ✅ = Se validó desde el contenedor que corre en la EC2
Instalar PostgreSQL                                                                 ✅ = Se validó desde el contenedor que corre en la EC2
Instalar Java JRE                                                                   ✅ = Se validó desde el contenedor que corre en la EC2
Debe poder compilar proyectos NetCore                                               ✅ = Se valida con las dependencias citadas previamente
Debe poder compilar aplicaciones Java                                               ✅ = Se valida con las dependencias citadas previamente
Subir un servidor apache con un “hola mundo” o cualquier proyecto público.          ✅ = Se validó cuando consumes el curl o por navegador a la ip publica de la EC2
Montar la imagen de Docker creada en el servicio de computo elegido en el paso 1    ✅ = Se validó al crear un contenedor a partir de la imagen docker publicada
NOTA:
Debe haber conexión entre el Docker y el servicio de base de datos elegido.         ✅ = Se validó cuando se lista, crea, lee o elimina archivos desde el contenedor hacia la dynamoDB
Debe ser elaborado en una cuenta propia (debe explorar sus opciones).               ✅ = Lo elaboré en mi cuenta personal de aws y recursos. Finalmente hice destroy para ahorrar costos         
Concedernos acceso a la imagen de Docker publicada.                                 ✅ = Es una imagen publica de dockerhub. Acá el command para obtenerla: docker pull manveira/consulting:v1
Concedernos acceso a los archivos de Terraform creados.                             ✅ = Están en el repositorio de Github que creé para este proyecto
Justificar por qué el tipo de servicio de cómputo y base de datos elegidos.         ✅ = Muy extenso justificar aquí, pero está en el README.md
Es un plus cualquier configuración adicional realizada.                             ✅ = Muy extenso justificar aquí, pero está en el README.md
Explicarnos como la prueba sera ejecutado (Manualmente or con un pipeline).         ✅ = Muy extenso justificar aquí, pero está en el README.md
Explique el uso y gestion del state file y donde esta almacenado.                   ✅ = Muy extenso justificar aquí, pero está en el README.md
Explique la gestion del archive .lock en Terraform para esta evaluación.            ✅ = Muy extenso justificar aquí, pero está en el README.md
Para la entrega del reto, no es necesario tener los recursos desplegados en la nube de AWS, de nuestro lado necesitamos solo acceso al repo de GitHub por ejemplo o enviarnos un archivo comprimido con la solución completa.