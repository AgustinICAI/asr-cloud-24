# MEJORAS
- Añadir más reglas en armor
- Hacer copias del contenido del servidor a cloud storage
- Crear un managed instance group
- Usar IAP en vez de SSH
- Reducir validez certificado
- Hardening servidor
- Actualización automática <- ojo !
- Rotar claves SSH
- meter un proxy <- sólo aplica en la empresa
- Meter headers de Content Security Policy
- Segmentación de red <- ojo que estamos en cloud
- Implantación CDN: cacheo y distribución de la carga en zonas más cercanas al usuario.
- Meter doble autenticación en el servidor de salto.
- Usar registries privados para paquetería
- Desplegar los servidores multiregion o multizona en HA
- Servidores en standby en otra zona. Para ello hará falta discos probablemente multiregionales.
- Certificado de una CA de confianza
- Meter automatismos ante fallos.
- Parches automáticos: revisar ciclo de parcheado de la aplicación y S.0.
- Implatanción monitorización y alertado: Usar logging y meter alertas en caso de problemas de rendimiento (volumen poco o mucho, tiempo de respuesta y volumen de errores) o seguridad
- Copias de seguridad
- Aumentar los logs
- Aplicar jerarquia de roles en GOogle CLoud
- Utilizar PGA
- Acceso a la máquina de salto por VPN
- Usar certbot
- Hacer redirección de http a https en el front del balanceador
- Hacer auditorias de seguridad
- Definir un modelo de DR
- Definir subnets distintas para máquina de salto y servidores web
- Instalación de antivirus y antimalware

## Otras mejoras
- Limitar conexiones simultaneas al servidor en el balanceador
- implantar recaptcha
- Implantar nuestra web con contenedores
- Limitar versiones TLS y SSL
- Backup de discos controlados
- Ajustar a la IP origen la máquina de salto incluso apagarla cuando no se use
- Uso de IAP con OSLOGIN
- Implantación de modelos de CICD y IaC para la configuración del servidor NGINX mediante el uso de playbooks de Ansible.
- No usar Cloud NAT y hacer la instalación de la paquetería movimiendo los artefactos o usando un registry privado.
- Cambiar a una solución PaaS
- Cambiar a una solución SaaS
