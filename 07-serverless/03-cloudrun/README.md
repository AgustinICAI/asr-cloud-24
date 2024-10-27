### Introducción

El objetivo de este lab es la demostración de como
podemos desplegar de manera sencilla una app en
Google Cloud Run

## Prerrequisitos

1. Configuración de Proyecto: Crea o usa un proyecto en Google Cloud y configura el SDK para usar ese proyecto:
```shell
gcloud config set project [YOUR_PROJECT_ID]
```

Habilitar APIs: Asegúrate de que las APIs de Cloud Run y Container Registry estén habilitadas:
```shell
gcloud services enable run.googleapis.com containerregistry.googleapis.com
```

## Paso 1: Crear la Aplicación
Vamos a crear un archivo de Python que servirá como nuestra aplicación para Cloud Run.

Crea una carpeta para el proyecto:

```shell
mkdir cloud-run-example
cd cloud-run-example
```

Dentro de esta carpeta, crea un archivo llamado app.py con el siguiente código Python
```python
# app.py
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return "¡Hola desde Cloud Run!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
```

## Paso 2: Crear un Dockerfile
Cloud Run ejecuta contenedores, así que vamos a crear un archivo Dockerfile para definir la imagen de Docker de nuestra aplicación.

En la misma carpeta (cloud-run-example), crea un archivo llamado Dockerfile y añade el siguiente contenido:

Dockerfile
```dockerfile
# Dockerfile
FROM python:3.9-slim

# Establece el directorio de trabajo en /app
WORKDIR /app

# Copia los archivos necesarios
COPY app.py ./

# Instala Flask
RUN pip install Flask

# Expone el puerto 8080
EXPOSE 8080

# Comando para ejecutar la aplicación
CMD ["python", "app.py"]
```

## Paso 3: Construir y Subir la Imagen a Google Container Registry
Autentica Docker con Google Cloud:

```shell
gcloud auth configure-docker
```

Construye la imagen de Docker y sube la imagen a Google Container Registry (reemplaza [YOUR_PROJECT_ID] con el ID de tu proyecto):

```shell
docker build -t gcr.io/[YOUR_PROJECT_ID]/cloud-run-example .
docker push gcr.io/[YOUR_PROJECT_ID]/cloud-run-example
```

## Paso 4: Desplegar en Cloud Run
Ahora que la imagen está en el Container Registry, vamos a desplegarla en Cloud Run.

Despliega la imagen en Cloud Run (reemplaza [YOUR_PROJECT_ID] con el ID de tu proyecto):

```shell
gcloud run deploy cloud-run-example \
    --image gcr.io/[YOUR_PROJECT_ID]/cloud-run-example \
    --platform managed \
    --region europe-southwest1 \
    --allow-unauthenticated
```

- --platform managed: Desplega en la plataforma de Cloud Run completamente gestionada.
- --region europe-southwest1: Ubicación donde se desplegará el servicio (puedes cambiarla según prefieras).
- --allow-unauthenticated: Permite que el servicio sea accesible públicamente.


Cuando termine el despliegue, verás una URL en la salida del comando. Esta URL es el endpoint público de tu aplicación en Cloud Run.

## Paso 5: Probar el Servicio
Visita la URL proporcionada por Cloud Run en tu navegador, y deberías ver la respuesta ¡Hola desde Cloud Run!.

## Paso 6: Limpiar Recursos (Opcional)
Si quieres evitar costos innecesarios, elimina el servicio de Cloud Run y la imagen del Container Registry.

Borra el servicio de Cloud Run:

```shell
gcloud run services delete cloud-run-example --region europe-southwest1
```

Borra la imagen de Docker del Container Registry:

```shell
gcloud container images delete gcr.io/[YOUR_PROJECT_ID]/cloud-run-example
```
