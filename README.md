<h1 align="center">Aplicación Móvil de Gestión y Venta de Lotes Inmobiliarios</h1>

## Descripción del Proyecto 👇
Esta aplicación móvil está diseñada para gestionar la venta y administración de lotes en planos inmobiliarios, permitiendo una interacción dinámica y en tiempo real con las propiedades disponibles. A través de un sistema de autenticación seguro y roles específicos (Administrador, Agente Inmobiliario y Usuario), cada usuario tiene acceso a funciones personalizadas. La app está desarrollada en Flutter y utiliza procesamiento de imágenes para detectar automáticamente los lotes en los planos cargados, facilitando la visualización y edición de detalles.

## Características 👇
**Carga de Imágenes de Planos**: Permite a usuarios autorizados cargar imágenes de planos detallados en la aplicación y almacenarlos en una base de datos MySQL mediante Django.

![Captura de pantalla 2024-11-14 162417](https://github.com/user-attachments/assets/32a8487c-b753-4eed-b4b8-ad84d699e509)

**Detección Automática de Lotes**: Utiliza técnicas de procesamiento de imágenes, incluyendo la conversión a escala de grises y el filtro Gaussiano, para preparar los planos y reducir el ruido visual. La detección de bordes y contornos se realiza mediante OpenCV, NumPy y Shapely, asignando coordenadas y almacenando el estado del lote (disponible o vendido).

![Captura de pantalla 2024-11-14 162433](https://github.com/user-attachments/assets/bcedd738-8710-4543-bf48-2665ea672f5e)

**Interfaz y Listado de Planos**: Interfaz intuitiva que muestra los planos cargados junto con sus detalles y miniaturas.

![Captura de pantalla 2024-11-14 162501](https://github.com/user-attachments/assets/cf02cc60-af5c-4563-ba5f-6bb310a92d5c)

**Interactividad con Lotes**: Visualización del plano completo, donde cada lote es clickeable, permitiendo ver detalles específicos. Los lotes se colorean según su disponibilidad (verde para disponibles y rojo para vendidos).

![Captura de pantalla 2024-11-14 162443](https://github.com/user-attachments/assets/867dcea1-0bb2-44b0-9826-69161026b074)


## Tecnologías Utilizadas:
---

- ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white) **Flutter**: Framework para la interfaz de usuario.
- ![Django](https://img.shields.io/badge/Django-092E20?style=for-the-badge&logo=django&logoColor=white) **Django**: Framework de backend para gestionar la base de datos y la autenticación.
- ![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white) **MySQL**: Sistema de gestión de bases de datos relacional.
- ![OpenCV](https://img.shields.io/badge/OpenCV-5C3EE8?style=for-the-badge&logo=opencv&logoColor=white) **OpenCV**: Biblioteca para el procesamiento de imágenes y detección de bordes.
- ![NumPy](https://img.shields.io/badge/NumPy-013243?style=for-the-badge&logo=numpy&logoColor=white) **NumPy**: Librería para computación numérica y manipulación de matrices.
- ![Shapely](https://img.shields.io/badge/Shapely-4CAF50?style=for-the-badge&logo=shapely&logoColor=white) **Shapely**: Librería para manipulación y análisis de datos geométricos.
- ![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white) **Python**: Lenguaje de programación principal para el backend y procesamiento de imágenes.


## Configuración del Backend (Django) 🔧
---
 ```bash
 python3 -m venv venv
 source venv/bin/activate  # En Windows: venv\Scripts\activate
```
#Instalar las dependencias del backend:

```bash
pip install -r backend/requirements.txt
```
#Configurar la base de datos:
Crea una base de datos en MySQL para la aplicación.
```bash
'NAME': 'gestion_lotes',  # Nombre de la base de datos creada en Laragon
```

#Ejecutar migraciones para crear las tablas en la base de datos:

```bash
python manage.py migrate
```
#Ejecutar el servidor de desarrollo de Django:

```bash
python manage.py runserver
```
El backend estará activo en http://127.0.0.1:8000/.


### Configuración del Frontend (Flutter)

#Instalar las dependencias de Flutter:
```bash
flutter pub get
```
