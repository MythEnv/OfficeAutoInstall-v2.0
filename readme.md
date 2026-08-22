# Office AutoInstall
Instalación directa (Abrir el PowerShell como Administrador) y copiar el siguiente comando en la terminal:
```text
iex "& { $(irm https://raw.githubusercontent.com/WenliangK/OfficeAutoInstall/main/InstalarOffice.ps1) }"
```
# README PLS

```text
  ___  _____ _____ ___ ____ _____ 
 / _ \|  ___|  ___|_ _/ ___| ____|
| | | | |_  | |_   | | |   |  _|  
| |_| |  _| |  _|  | | |___| |___ 
 \___/|_|   |_|   |___\____|_____|
                                 (\_/)
                         .-""-.-.-' a\
                         /  \      _.--'
                        (\  /_---\_\_
                         `'-.
                          ,__)

        MythEnv - Sh1romsi
```

Script de instalación automatizada y desatendida para Microsoft Office Profesional Plus 2024. 

Diseñado para agilizar la configuración de equipos post-formateo. El script gestiona todo el proceso: descarga, limpieza de versiones conflictivas, instalación limpia y configuración final, sin requerir intervención manual.

## Características

- **100% Desatendido:** Sin ventanas de "Siguiente", clics, ni opciones confusas.
- **Detección Inteligente:** Escanea el registro de Windows buscando y limpiando versiones antiguas de Office antes de instalar.
- **Descarga Oficial:** Utiliza la herramienta oficial de despliegue de Microsoft (ODT).
- **Ligero y Limpio:** Descarga e instala solo lo necesario. Elimina automáticamente todos los archivos temporales al terminar.

## Cómo usarlo (También puedes usar forma directa de arriba)

1. Ve a la parte superior de este repositorio, haz clic en el botón verde **`<> Code`** y selecciona **`Download ZIP`**.
2. Extrae el archivo `.zip` en tu computadora.
3. Entra a la carpeta extraída y haz **doble clic** en el archivo `Instalar.bat`.
4. Acepta los permisos de Administrador que solicita Windows.
5. ¡Siéntate y espera! La consola te irá informando del progreso.

## Transparencia y Seguridad

Este es un proyecto Open Source (Código Abierto). 

- **Auditable:** Puedes abrir cualquiera de los archivos (`.ps1`, `.bat`, `.xml`) con el Bloc de notas o VS Code para verificar su contenido. No hay código ofuscado.
- **Binarios limpios:** El archivo `setup.exe` incluido es la herramienta oficial firmada digitalmente por Microsoft. Puedes subirlo a [VirusTotal](https://www.virustotal.com/) y comprobar que está libre de malware (0 detecciones).
- **Instalación:**
- **Automatización de la instalación de esta forma:** https://learn.microsoft.com/es-es/office/ltsc/2021/deploy
- **setup.exe:** https://www.microsoft.com/en-us/download/details.aspx?id=49117
- **configuration.xml:** https://config.office.com/deploymentsettings

### Aviso sobre detecciones en Antivirus (Falsos Positivos)

Si analizas el archivo `InstalarOffice.ps1` en VirusTotal o tu antivirus local, es muy probable que arroje alertas como `HEUR:HackTool.Script.KMSAuto.gen` (Kaspersky) o `Trojan:Script/Wacatac.B!ml` (Windows Defender). **Esto es completamente normal y seguro.**

**¿Por qué ocurre esto?**
Las alertas no se deben a que el archivo contenga malware, sino a la línea final del código encargada de la activación automática:

1. **La alerta "HackTool":** Los antivirus están programados para proteger el sistema de licencias de Microsoft. Al detectar un comando que interactúa con el servicio KMS, lo clasifican correctamente como una "Herramienta de evasión/HackTool", pero no como un virus que dañará tu PC o robará datos.
2. **La alerta "Wacatac.B!ml":** El sufijo `!ml` significa *Machine Learning*. La Inteligencia Artificial de Windows Defender bloquea preventivamente los scripts de PowerShell que descargan y ejecutan instrucciones desde internet de forma silenciosa (el comando `iex irm...`). Es una detección por *comportamiento*, no por infección.

El motor de instalación principal (`setup.exe`) es el binario oficial firmado por Microsoft y está 100% limpio. Te invito a abrir los archivos `.ps1` y `.bat` en tu editor de código para que compruebes por ti mismo que no hay nada oculto.

---
*Desarrollado para automatizar configuraciones y ahorrar tiempo. by Sh1romsi <3*
                                            
