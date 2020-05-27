# Schematics-VPC-Schematics-3-Tier-Websphere-OracleXE

Plantilla para el aprovisionamiento de recursos necesarios para el despliegue de Oracle Xpress en una arquitectura VPC IBM CLoud

## Requerimentos para el uso de Terraform

Como caracteristicas especificas de este laboratorio se uso:

*	Contar con una cuenta en IBM Cloud 💻
* Contar con Ansible para la ejecución local del playbook de configuración

## Indice

* Arquitectura de implementación
* Ejecución de la plantilla de terraform en IBM Cloud Schematics
* Ejecución del playbook de ansible para la configuración de mysql en el virtual server
* Despliegue y configuración de la imagen joomla en el cluster de kubernetes

---

### 1. Arquitectura de implementación

Con el fin de ilustrar los recursos necesarios para el despliegue de la plataforma Joomla, a continuación de muestra un diagrama.

<p align="center">
<img width="500" alt="img8" src="https://user-images.githubusercontent.com/40369712/78384024-0ad1e880-759f-11ea-98fb-5693f2c9a60e.png">
</p>

---

### 2. Ejecución de la plantilla de terraform en IBM Cloud Schematics

Ingrese a IBM Cloud para crear un espacio de trabajo en [Schematics](https://cloud.ibm.com/schematics/workspaces) y seleccione crear espacio de trabajo.

<p align="center">
<img width="900" alt="img8" src="https://user-images.githubusercontent.com/40369712/78297909-3a78e600-74f6-11ea-8912-35423ddee121.png">
</p>

Allí debera proporcional un nombre, las etiquetas que desee, la descripción y seleccionar el grupo de recursos.


<p align="center">
<img width="400" alt="img8" src="https://user-images.githubusercontent.com/40369712/78298384-d1926d80-74f7-11ea-88d6-877e7202ca48.png">
</p>

Ingrese la [URL del git](https://github.com/emeloibmco/Schematics-VPC-Schematics-3-Tier-Oracle-SQL-Server/tree/master/Terraform) donde se encuentra la plantilla de despliegue de terraform y presione recuperar variables de entrada.

<p align="center">
<img width="400" alt="img8" src="https://user-images.githubusercontent.com/40369712/78303221-e116b400-7501-11ea-9d71-6d2ce8610c74.png">
</p>

Ingrese en los campos las variables necesarias para el despliegue, en este caso el API key de infraestructura, la llave publica ssh y el grupo de recursos.

<p align="center">
<img width="800" alt="img8" src="https://user-images.githubusercontent.com/40369712/78373792-a871eb80-7590-11ea-8348-f194fcf57618.png">
</p>

Una vez creado el espacio de trabajo, presione generar plan y posteriormente aplicar plan para desplegar los recursos descritos en la plantilla.

<p align="center">
<img width="800" alt="img8" src="https://user-images.githubusercontent.com/40369712/78304020-78c8d200-7503-11ea-8dfd-5f7c35c83b29.png">
</p>

---

### 3. Ejecución del playbook de ansible para la configuración de OracleXE en el virtual server

Antes de ejecutar el playbook debe configurarse la llave ssh, la dirección ip del virtual server.

Para editar el archivo que contiene la llave ssh, debe ingresar a la ruta /etc/ansible/.ssh/ y allí debera copiar el archivo que contiene la llave privada y renombrarlo con la extención .pem.

Ahora debera modificar la ruta y la direccíon Ip del virtual server, para esto con el editor de texto edite el archivo **hosts**, en la primera linea de este archivo debera colocar la direccíon IP y el nombre de su nuevo archivo con la llave privada ssh.

Por ultimo, debera agregar la dirección Ip en el playbook a ejecutar, para esto edite el archivo oracle.yml y cambie la dirección Ip por la del servidor.

Ahora podra ejecutar su playbook con el siguiente comando:

```
ansible-playbook -i hosts oracle.yml
```

---

### 4. Despliegue y configuración de la imagen WebsPhere en el cluster de kubernetes

**a.**	Obtenga la imagen de WebPhere localmente ejecutando el siguiente comando.

```
docker pull websphere-liberty
```

**b.**	Etiquete la imagen de Docker que acaba de añadir a su repositorio local para que sea compatible con el formato requerido por IBM, ejecute el siguiente comando:

```
docker tag <nombre_imagen_local> us.icr.io/<namespace>/<nombre_imagen>
Ejemplo: docker tag websphere-liberty us.icr.io/webspherens/websphere-liberty
```

**c.**	Realice el push de la imagen que acaba de crear al cr de IBM Cloud.

```
docker push us.icr.io/<namespace>/<nombre_imagen>
Ejemplo: docker push us.icr.io/webspherens/websphere-liberty
```

**d.**	Cree el despliegue de la imagen.

```
kubectl create deployment <nombre_despliegue> --image=us.icr.io/<namespace>/<imagen>
Ejemplo: kubectl create deployment websphere-liberty --image=us.icr.io/webspherens/websphere-liberty
```

**e.**	Exponga el servicio del despliegue.

```
kubectl expose deployment/websphere-liberty --type=NodePort --port=80
```

**f.**	Exponga un balanceador de carga para hacer visible el despliegue de forma pública.

```
kubectl expose deployment/websphere-liberty --type=LoadBalancer --name=lb-svc  --port=80 --target-port=32692
```

---

# Referencias 📖

* [Pagina de joomla](https://www.joomla.org/about-joomla.html).
* [Guia para la instalación de mysql](https://linuxize.com/post/how-to-install-mysql-on-ubuntu-18-04/).
* [Instalación de ansible en SO Ubuntu](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-ubuntu).
* [Modulos de ansible](https://docs.ansible.com/ansible/latest/modules/).
