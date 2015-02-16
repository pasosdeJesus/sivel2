
# EVOLUCION DEL TIEMPO DE RESPUESTA DE SIVeL - SJR Venezuela 2.0a1

Tiempos en segundos.

## ESPECIFICACION DE SERVIDORES

SERVIDOR SJR-1:
* AMD FX-6100 3315MHz, 6 núcleos
* RAM: 8G
* Disco: 2 discos de 1T
* Plataforma: adJ 5.4p1, PostgreSQL 9.3.2, ruby 2.0.0, RoR 4.1.0rc1, unicorn-4.8.2
* Conexión a Internet por Claro 12MB fibra óptica. 6M de subida.
* Cortafuegos con adJ 5.5 

SERVIDOR SJR-1d:
El mismo SJR-1 pero con
* Plataforma: adJ 5.4p1, PostgreSQL 9.3.2, ruby 2.0.0, RoR 4.1.0rc1, webricks. Modo desarrollo

SERVIDOR SJR-55:
El mismo SJR-1 pero con
* Plataforma: adJ 5.5, PostgreSQL 9.3.5, ruby 2.1.0, RoR 4.1.6, unicorn 4.8.3

SERVIDOR SJR-55d:
El mismo SJR-55 pero con
* Plataforma: adJ 5.5, PostgreSQL 9.3.5, ruby 2.1.0, RoR 4.1.6, webricks modo desarrollo

SERVIDOR SJR-552b2d:
El mismo SJR-55 pero con
* Plataforma: adJ 5.5, PostgreSQL 9.3.5, ruby 2.1.0, RoR 4.2.0.beta2, webricks modo desarrollo

SERVIDOR AP-55p2r42d:
* Intel(R) Core(TM) i7-4790 CPU @ 3.60GH, 8 núcleos
* RAM: 12G
* Disco: 1 discos de 2T
* Plataforma: adJ 5.5p2, PostgreSQL 9.3.6, ruby 2.1.5, RoR 4.2.0, webrick
* Conexión a Internet por Claro 12MB fibra óptica. 6M de subida.
* Cortafuegos con adJ 5.5p2



## ESPECIFICACION DE CLIENTES

CLIENTE V-1:
* AMD E-450. 1647.97 MHz
* RAM: 4G
* Disco: 500G
* Conexión a Internet por UNE Inalámbrico 2MB
* Plataforma: adJ 5.6, chrome 32

CLIENTE W-1:
* AMD Athlon 64 X2 Dual Core 5600+. 2813Mhz
* RAM: 1G
* Disco: 1T
* Conexión a servidor directa LAN 100G.
* Plataforma: adJ 5.5, chrome 32


## MEDICIONES

### Fecha: 10.Oct.2014. Servidor: SJR-552b2d. Cliente: V-1
* Autenticar: 3,5
* Lista de actividades: 1,5
* Editar una actividad: 1,7
* Lista de casos: 1,7
* Editar un caso: 5,1
* Agregar etiqueta y guardar: 6,5
* Editar de nuevo: 4,5


### Fecha: 13.Feb.2015. Servidor: AP-55p2r22d. Cliente: AP-55p2r22d. Local
* Autenticar: 2,5
* Lista de actividades: 1,25
* Editar una actividad: 1,11
* Lista de casos: 1,18
* Editar un caso: 1,48
* Agregar etiqueta y guardar: 2,5
* Editar de nuevo: 1,25



