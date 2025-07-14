# DOCUMENTACIÓN PROYECTO


## ESTRUCTURACIÓN DE ARCHIVOS

```
├── infrastructure/
│   └── terraform.lock.hcl # Lock file de proveedores
│   ├── backend.tf         # Configuración de backend S3 + locking
│   ├── iam.tf             # IAM Recursos y roles
│   ├── keypair.tf         # Keypair to access EC2
│   ├── main.tf            # Recursos EC2 y DynamoDB
│   ├── networking.tf      # Recursos Networking
│   ├── outputs.tf         # Salidas del proyecto
│   ├── provider.tf        # Proveedor AWS
│   ├── security.tf        # Grupo de seguridad SSH
│   ├── state.tf           # DynamoDB state
│   ├── variables.tf       # Variables de entrada
├── docker/
│   └── Dockerfile         # Imagen personalizada Linux + herramientas
│   └── index.html         # Archivo HTML a mostrar en web server
└── README.md              # Documentación
```

## PROCESO 

Primero, debes asegurar las credentials necesarias para usar con tu cuenta de AWS. 

Guarda esas crendenciales en `.aws/credentials`. Una vez las tengas continua con los pasos posteriores.

Antes de iniciar debes garantizar que el recurso dynamoDB exista al igual que el s3 donde se guardará el estado remoto. Para ello debes crear un s3 manualmente, con un script o usando comandos de aws cli. En mi caso creé un bucket llamado `authmanve` para almacenar mi estado remoto. 

Una vez se cree el bucket, dirigete a la carpeta **infrastructure** de este repositorio y lanza este comando:

`terraform init`


luego:

`terraform apply -target=aws_dynamodb_table.terraform_locks "-lock=false"`


Adicional, tecuerda haber generado un llave `id_rsa` para conectarte a tu EC2 una vez la crees. Sino las tienes, usa este comando y sigue los pasos que este te indique. (Este comando no es necesario si ya tienes una llave, si la tienes omite este step)

`ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa`    


Luego, aplica el resto de la infra:

`terraform apply`


Una vez se creen el resto de componentes, intenta conectarte a la instancia EC2 teniendo en cuenta la ip_publica de la instancia.


Para ello, creé un output llamado **ssh_connection** que te muestra el comando listo para conectarte, siempre y cuando tu `id_rsa` se encuentre en la ruta por defecto `~/.ssh/id_rsa`. Veras algo como esto:

`ssh -i ~/.ssh/id_rsa ubuntu@<IP_PUBLICA>`


Por ejemplo:

`ssh -i ~/.ssh/id_rsa ubuntu@3.84.3.198`


Para validar que está corriendo el webserver con apache, haz un curl o por tu navegador de internet a:

`curl http://<ip_publica_EC2_instance>`


ejemplo:

`curl http://44.212.2.145`


O desde el navegador abre una pestaña nueva y digita `http://<ip_publica_EC2_instance>`. No olvides que si estás redireccionando a https, no te cargará la pagina, ya que estarías ingresando por el puerto 443, el cual no está activo para este dominio. Por ende, debes siempre garantizar que le apuntas al http para que consumas por el puerto 80.



*Ahora, para explicar un poco lo relacionado a la imagen docker y lo que se ejecuta en el proceso contenerizado tenemos:*

Primero, se exportó temporalmente en la terminal local mis credenciales de Dockerhub.

```export DOCKERHUB_USERNAME="<Your_dockerhub_user>"
export DOCKERHUB_PASSWORD="<Your_dockerhub_password>"
```


Luego, logueate con el sgte comando:

`echo "$DOCKERHUB_PASSWORD" | docker login --username "$DOCKERHUB_USERNAME" --password-stdin`


Deberias ver un **login succeded** si todo salió bien. 


Luego, pasate a la ruta local donde tienes el dockerfile y ejecuta:

`docker build -t $DOCKERHUB_USERNAME/consulting:v1 .`


Lista las imagenes docker en tu local y comprueba que exista la que acabas de crear:

`docker image ls`


Una vez compruebes que existe localmente, haz el push a dockerhub para publicarla:

`docker push $DOCKERHUB_USERNAME/consulting:v1`


Dirigete a tu registry publico, en mi caso Dockerhub, haz login desde la interfaz, ingresa a tus repositorios y valida que se publicó la imagen anterior.


Para realizar una prueba puedes correr un contenedor de prueba ejecutando un comando como este:

`docker run -d -p 80:80 --name app_consulting manveira/consulting:v1`



## VALIDACIONES    


Una vez se cree todo el proyecto, ingresa a tu EC2 server en estado running con el comando citado en sesiones previas de este documento. 

`ssh -i ~/.ssh/id_rsa ubuntu@<IP_PUBLICA>`


Una vez dentro, lista los contenedores docker corriendo con:

`docker ps`


Deberás ver un contenedor llamado `app_consulting`. Para conectarte e iniciar validaciones usa este comando:

`docker exec -it app_consulting bash`


Una vez dentro del conetenedor, lanza los comandos listados debajo uno por uno para validar que están instaladas todas las dependencias solicitadas en el archivo llamado **Requerimiento_prueba_tecnica.md**


Los comandos uno por a listar serían:

```
    git --version
    code --version --no-sandbox --user-data-dir=/tmp/vscode-data
    which code
    mvn -v
    psql --version
    java -version
    dotnet --list-sdks
    apache2ctl -v
    aws --version
```


Una vez validado lo anterior, puedes lanzar un curl a `localhost:80` para validar que puedes ver lo que está desplegado en el webserver. Como es puerto **80**, no es necesario especificar el puerto ya que èl lo toma por defecto.
    
`curl localhost`


Deberás ver una respuesta html con el mensaje **hola mundo**.


Ahora, para realizar la validaciòn de conexión entre el Docker y la DynamoDB realizamos lo sgte:

`aws dynamodb list-tables --region us-east-1`


Al realizar el comando anterior y que no nos deniegue o rechace la petición indica que ese contenedor a través del Role IAM de la instancia, hereda sus permisos y se autentica contra el servicio de DynamoDB. Puesto que en la policy atachada al role tiene estos permisos o actions.


Adicional para corroborar lo previamente expuesto; los sgtes comandos crean un nuevo item en la tabla `app-data`, lee el nuevo item y finalmente elimina el componente. 
Lanzar los comandos uno a uno.


Crear item en tabla app-data:

```
    aws dynamodb put-item \
    --table-name app-data \
    --item '{
        "id": {"S": "123"},
        "nombre": {"S": "Juan"},
        "edad": {"N": "30"}
    }' \
    --region us-east-1
```


Leer item creado previamente:

```
    aws dynamodb get-item \
    --table-name app-data \
    --key '{
        "id": {"S": "123"}
    }' \
    --region us-east-1
```


Eliminar y limpiar items de tabla app-data:

```
    aws dynamodb delete-item \
    --table-name app-data \
    --key '{
        "id": {"S": "123"}
    }' \
    --region us-east-1
```



## LIMPIEZA DE COMPONENTES 


Una vez se realicen las validaciones necesarias y el proyecto funcione de la manera esperada, se crea esta pequeña sección donde se dicta el step necesario para destruir los componentes creados para el proyecto. 
Todo lo anterior para ahorro de costos y no incrementar cargos en facturación.


Para ello, dirijase a la carpeta `/infrastructure` en la raíz del proyecto y ejecute el comando:

`terraform destroy`



## JUSTIFICACIONES


* *Justificar por qué el tipo de servicio de cómputo y base de datos elegidos*. 

    * **EC2 (t3.micro)**: Elegí este servicio y tipo de instancia porque es económico, provee Linux nativo y es suficiente para un contenedor único. 
    
    * **DynamoDB**: Elegí este servicio de base de datos porque es serverless, provee alta disponibilidad y escalabilidad automática sin administración de servidores. Propia para este tipo de laboratorios o proyectos.


* *Explicarnos como la prueba sera ejecutado (Manualmente or con un pipeline)*.  

    * 🎯 **Alcance y simplicidad del proyecto**:
        Dado que el proyecto consistía en una infraestructura mínima y una imagen Docker que no requería cambios frecuentes, opté por un enfoque manual controlado. Implementar un pipeline CI/CD para algo que solo se publica una vez no aportaba valor adicional a lo implementado.

    * 🕐 **Optimización de tiempo y recursos**:
        El objetivo principal del proyecto era validar el despliegue y funcionamiento básico. Automatizar una entrega única con CI/CD hubiese sido sobredimensionar el esfuerzo técnico frente al beneficio obtenido. Adicional del costo indirecto en las herramientas utilizadas.


* *Explique el uso y gestion del state file y donde esta almacenado*. 

    El state file por buenas prácticas de seguridad, decidí almacenarlo en un bucket s3 llamado "authmanve" en el objecto o key "project/terraform.tfstate". Se aclara que primero debe existir este bucket creado antes de realizar el despliegue del resto de componentes por terraform. 


* *Explique la gestion del archive .lock en Terraform para esta evaluación*.

    Se sabe que el propósito del .lock en terraform es asegurar que todos los usuarios del proyecto utilicen las mismas versiones de providers, evitando inconsistencias entre entornos.
    Para mi proyecto usé un locking con DynamoDB, en una tabla llamada terraform-locks. Lo anterior permite aplicar un "state locking", previniendo que dos personas modifiquen el estado remoto al mismo tiempo.



## CHECKS

Se creó el archivo en la raíz del proyecto llamado **Checks.md** para validar y explicar a alto nivel los componentes resueltos en este proyecto, con sus respectivas referencias a cierto detalle dentro de la documentación.



## EVIDENCIAS


Finalmente, se crea esta sección para comprobar y validar que el proyecto se implementó correctamente siguiendo las directrices requeridas para sus validaciones.
Adicional, esta sección también fue creada por si no fuera posible la reproducción del proyecto en otros ambientes o por factores externos agenos, no fuera posible la validación de los mismos.


Para ello, se crea una carpeta en la raíz del proyecto llamada `/evidencias` y en ella se anexan imágenes de validaciones.