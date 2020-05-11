# aik-infrastructure

Infraestructura para el portal AIK

### Equipo de trabajo

Ricardo Nuñez - @RicNuva18

Sebastian Quintero - @squintero14

Andres Varela - @dvlopez9811

# Diseño prototipo de Infraestructura

## Diagrama de la solución (Staging Environment)

![Diagrama Solucion Prototipo](/images/diagramasolucionprot.png)

# Diseño completo

## Diseño de la solución

![Diseno Solucion](/images/disenosolucion.png)

## Diagrama de la solución

![Diagrama Solucion](/images/diagramasolucion.png)

## Ejecución

1. Primero, se deben exportar las credenciales de acceso a la cuenta de AWS: </br>
 `export AWS_ACCESS_KEY_ID=XXXXXXX`</br>
 `export AWS_SECRET_ACCESS_KEY=XXXXXX`</br>

2. En este momento, contamos con las credenciales para empezar a configurar la infraestructura. Los templates se encuentran en la carpeta `infrastructure_template` </br>
</br> En esta carpeta hay dos subcarpetas, la primera `00_rds`realiza la configuración de la base datos rds. La segunda, `01_compute` realiza la configuración del back-end y front-end.

3. Por lo tanto, primero se realiza la configuración de la base de datos rds. </br>
    - Primero, tenemos que crear un archivo `rds-variables.tfvars` en el directorio `$HOME` con algunas variables necesarias para realizar la configuración de la misma:
</br>rds-name="name"
</br>rds-username="username"
</br>rds-password="password" </br> 

    - En la carpeta `00_rds` irían los siguiente comandos para inicializar y aplicar la configuración de iac: </br>
    `terraform init` </br>
    `terraform apply -var-file=$HOME/rds-variables-tfvars`

    - Guardamos las variables de salida que son necesarias para realizar la configuración de las instancias: </br>
    `terraform output > $HOME/compute-variables.tfvars`

    - Por último, modificamos este archivo colocándole comillas a los valores de cada llave: `key="value"`

4. Una vez termine la construcción del código anterior, realizamos el aprovisionamiento manual de la base de datos:

    - Descargamos el archivo .mysql de la base de datos previamente creada y la guardamos en la carpeta `$HOME`.

    - Abrimos la terminal en la carpeta `$HOME` y accedemos por mysql a la base de datos:</br>
    `mysql -h endpoint-rds -P 3306 -u root -p`

    - Ingresamos la contraseña y colocamos los siguientes comandos: </br>
    `use dbAIK;`</br>
    `source dbAIK.sql;` </br>

5. Una vez realizado el aprovisionamiento manual de la base de datos, procedemos a iniciar la configuración de las instancias back y front:</br>

    - En la carpeta `01_compute` irían los siguiente comandos para inicializar y aplicar la configuración de iac: </br>
    `terraform init` </br>
    `terraform apply -var-file=$HOME/compute-variables-tfvars`

## <p style='text-align: center;'>¡Listo! La infraestructura estaría configurada y desplegada en AWS. </p>






