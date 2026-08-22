# Office AutoInstall

```text
  ___  _____ _____ ___ ____ _____ 
 / _ \|  ___|  ___|_ _/ ___| ____|
| | | | |_  | |_   | | |   |  _|  
| |_| |  _| |  _|  | | |___| |___ 
 \___/|_|   |_|   |___\____|_____|
                        by Sh1romsi
```

Script de instalación automatizada y desatendida para Microsoft Office Profesional Plus 2021. 

Diseñado para agilizar la configuración de equipos post-formateo. El script gestiona todo el proceso: descarga, limpieza de versiones conflictivas, instalación limpia y configuración final, sin requerir intervención manual.

## Características

- **100% Desatendido:** Sin ventanas de "Siguiente", clics, ni opciones confusas.
- **Detección Inteligente:** Escanea el registro de Windows buscando y limpiando versiones antiguas de Office antes de instalar.
- **Descarga Oficial:** Utiliza la herramienta oficial de despliegue de Microsoft (ODT).
- **Ligero y Limpio:** Descarga e instala solo lo necesario. Elimina automáticamente todos los archivos temporales al terminar.

## Cómo usarlo

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

---
*Desarrollado para automatizar configuraciones y ahorrar tiempo.*
                                                     by Sh1romsi
