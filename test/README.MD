# aik-infrastructure

# Diseño de pruebas para infraestructura

### Test #1

| Nombre del servicio | NPM |
| - | - |
| Propósito de la prueba | Probar que el servicio NPM esté instalado |
| Pre-condiciones | La instancia EC2 debe haberse creado |
| Forma de comprobación | Verificación por medio de script de extensión .rb |

### Test #2

| Nombre del servicio | NPM |
| - | - |
| Propósito de la prueba | Probar que el servicio instala las dependencias necesarias para el portal AIK |
| Pre-condiciones | La instancia EC2 debe haberse creado. El servicio de NPM debe estar instalado. |
| Forma de comprobación | Verificación por medio de script de extensión .rb |

### Test #3

| Nombre del servicio | GIT |
| - | - |
| Propósito de la prueba | Probar que el servicio GIT esté instalado |
| Pre-condiciones | La instancia EC2 debe haberse creado |
| Forma de comprobación | Verificación por medio de script de extensión .rb |

### Test #3

| Nombre del servicio | GIT |
| - | - |
| Propósito de la prueba | Probar que el servicio GIT esté instalado |
| Pre-condiciones | La instancia EC2 debe haberse creado |
| Forma de comprobación | Verificación por medio de script de extensión .rb |

### Test #4

| Nombre del servicio | NODEJS |
| - | - |
| Propósito de la prueba | Probar que el servicio NODEJS está instalado |
| Pre-condiciones | La instancia EC2 debe haberse creado |
| Forma de comprobación | Verificación por medio de script de extensión .rb |

### Test #5

| Nombre del servicio | NODEJS |
| - | - |
| Propósito de la prueba | Probar que el servicio NODEJS ejecuta correctamente los archivos de frontend y backend |
| Pre-condiciones | La instancia EC2 debe haberse creado. El servicio de NODEJS debe haberse instalado. El servicio NPM debe haberse instalado. El servicio NPM debe haber instalado todas las dependencias necesarias |
| Forma de comprobación | Verificación por medio de script de extensión .rb, donde se debe verificar que el servicio está ejecutándose en el puerto 3030 y en el 3000.|

### Test #6

| Nombre del servicio | MySQL |
| - | - |
| Propósito de la prueba | Probar que se ha instalado una RDS con el servicio de mysql |
| Pre-condiciones | La instancia RDS ha sido creada |
| Forma de comprobación | Verificación por medio de script de extensión .rb, donde se comprueba el valor de tipo de la rds que debe ser mysql. |

### Test #6

| Nombre del servicio | MySQL |
| - | - |
| Propósito de la prueba | Probar que el servicio MySQL se está ejecutando |
| Pre-condiciones | La instancia RDS ha sido creada. El servicio de MySQL debe haberse instalado |
| Forma de comprobación | Verificación por medio de script de extensión .rb. |
