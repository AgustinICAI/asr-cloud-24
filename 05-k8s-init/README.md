### Introducción
El objetivo del siguiente ejemplo es el de introducir Google Kubernetes Engine (GKE),
un servicio de Kubernetes gestionado y seguro para el despliegue, gestión y
(auto)escalado de aplicaciones contenerizadas usando la infraesturctura de 
GCP. Para ello, en este ejemplo vamos a crear un cluster GKE, que consiste
en un conjunto de VMs (instancias de Google Compute Engine), y desplegaremos
en éste una aplicación sencilla `hello-world`.


### 1. Creación del cluster GKE
Lo primero que vamos a hacer es asegurarnos de tener configurada una 
zona de procesamiento predeterminada. Para establecer nuestra zona de procesamiento
predeterminada en `europe-west1-b` ejecutaremos el siguiente comando:

```shell
gcloud config set compute/zone europe-west1-b
```

Una vez configurada la zona por defecto, vamos a proceder a crear un cluster GKE.
Éste constará de, al menos, una instancia principal y varias VMs que ejecutarán los procesos de
Kubernetes, llamadas en este contexto nodos. 
Así, los nodos son VMs de Compute Engine que ejecutan los procesos de Kubernetes necesarios.

A continuación vamos a crear nuestro cluster, el cual tendrá el nombre que queramos especificar
en la variable `$CLUSTER_NAME`

```shell
gcloud container clusters create $CLUSTER_NAME \
--enable-master-authorized-networks \
--enable-ip-alias \
--disk-size 35 \
--master-authorized-networks "$(curl ifconfig.me)/32"
```
La creación del clúster podrá llevar varios minutos.

#### Explicación:
CLUSTER_NAME: El nombre que le quieras dar al cluster.
ZONE: La zona donde quieres crear el cluster (ejemplo: us-central1-a).
--enable-ip-alias: Opción para habilitar alias de IP.
--disk-size DISK_SIZE: Tamaño del disco para cada nodo en GB. Reemplázalo con el tamaño que prefieras (por ejemplo, 20 para 20 GB).
--master-authorized-networks "$(curl ifconfig.me)/32": Restringe el acceso al API server solo a tu IP pública.

Una vez la creación ha finalizado satisfactoriamente, vamos a proceder a interaccionar con el cluster.
Para ello necesitamos los credenciales correspondientes, los cuales los podemos obtener
fácilmente mediante la ejecución del siguiente comando:

```shell
# La primera vez necesitaremos instalar el siguiente plugin
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin
# Una vez instalado este comando nos configurará nuestro cluster en el fichero ~/.kube/config
gcloud container clusters get-credentials $CLUSTER_NAME
```

Una vez nos hemos autenticado, podemos comenzar a gestionar el cluster GKE. 
Una de las labores más comunes en la gestión de un cluster es el despliegue de una aplicación
en el mismo. En este ejemplo vamos a proceder a desplegar una aplicación tipo `hello-world`,
con el ánimo de simplemente mostrar los inicios (que pueden llegar a ser bastante duros)
con GKE.

### 2. Despliegue y exposición de la aplicación

⚠️ Para la gestión del cluster necesitaremos tener instalado `kubectl` (the Kubernetes command-line tool).
You can find the installer [here](https://kubernetes.io/docs/tasks/tools/).

```shell
LATEST_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
KUBECTL_URL="https://storage.googleapis.com/kubernetes-release/release/${LATEST_VERSION}/bin/linux/amd64/kubectl"
curl -Lo kubectl $KUBECTL_URL
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client
```


GKE utiliza los objetos de Kubernetes (una abstracción para representar el estado de 
de un cluster) para crear y administrar los recursos de sus clústeres. 
Algunos de los objetos que oferta k8s son:

* `Deployment`: para implementar aplicaciones sin estado como servidores web
  
* `Service`: definen las reglas y el balanceo de cargas para acceder a su aplicación desde Internet

Para crear un nuevo objeto `Deployment`, que llamaremos `hello-server`, a partir de la 
imagen del contenedor `hello-app` (que se encuentra en `gcr.io/google-samples/hello-app`),
vamos a usar el siguiente comando kubectl:

```shell
kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:1.0
```

Una vez hemos creado el objeto `deployment` que nos ha permitido desplegar la imagen, 
necesitaremos crear un objeto `service`, un recurso de Kubernetes que permite exponer 
la aplicación al tráfico externo. 
En nuestro caso, queremos exponer la aplicación al tráfico externo vía puerto `8080`.
Para ello:

```shell
kubectl expose deployment hello-server --type=LoadBalancer --port 8080
```

En este comando, la opción `type="LoadBalancer"` crea un balanceador de cargas de Compute
Engine para el contenedor.

Una vez que se ha creado, podemos inspeccionar el objeto `Service` hello-server mediante:

```shell
kubectl get service
```


### Usando un IDE avanzado para trabajar con kubernetes

*K9s* es una herramienta de interfaz de línea de comandos (CLI) diseñada para gestionar y visualizar clústeres de Kubernetes. Proporciona una forma interactiva y muy eficiente de explorar y gestionar recursos de Kubernetes sin necesidad de usar comandos kubectl constantemente.

```shell
LATEST_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4)
K9S_URL="https://github.com/derailed/k9s/releases/download/${LATEST_VERSION}/k9s_Linux_amd64.tar.gz"
curl -Lo k9s.tar.gz $K9S_URL
tar -xzf k9s.tar.gz
sudo mv k9s /usr/local/bin/
rm k9s.tar.gz
k9s version
```

### Lanzar el script (si se quiere, pero lanzando los comandos anteriores es suficiente)

⚠️ La generación de la IP pública puede tardar aproximadamente un minuto.

Finalmente, ahora podemos proceder a ver la aplicación en nuestro navegador web
usando la `[EXTERNAL-IP]` de `hello-server` en `http://[EXTERNAL-IP]:8080`

La creación del cluster, despliegue y exposición de la app se pueden hacer
simplemente ejecutando [deployment.sh](deployment.sh):

```shell
chmod a+x deployment.sh && ./deployment.sh
```

### 3. Borrar el cluster

Para borrar el clúster, solo tenemos que ejecutar:

```shell
gcloud container clusters delete $CLUSTER_NAME --quiet
```

El proceso de borrado del clúster puede llevar unos minutos.
Este borrado también se podría haber hecho mediante [clean.sh](clean.sh):

```shell
chmod a+x clean.sh && ./clean.sh
```
