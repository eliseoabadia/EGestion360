-- Instalador completo de GestionEmpresarial
-- Ejecutar en SQLCMD Mode desde la carpeta Scripts.
-- Orden:
--   1) Crear base si no existe
--   2) Crear estructura completa
--   3) Cargar datos base/catálogos/seguridad
--   4) Crear/actualizar stored procedures generales
--   5) Aplicar modulo Nomina
:r "C:\Desarrollo\Desarrollo\FullStack\EGestion360\Scripts\00_CrearBase_GestionEmpresarial.sql"
:r "C:\Desarrollo\Desarrollo\FullStack\EGestion360\Scripts\01_Estructura_Completa.sql"
:r "C:\Desarrollo\Desarrollo\FullStack\EGestion360\Scripts\02_Datos_Completos.sql"
:r "C:\Desarrollo\Desarrollo\FullStack\EGestion360\Scripts\StoredProcedures.sql"
:r "C:\Desarrollo\Desarrollo\FullStack\EGestion360\Scripts\Nomina\99_Instalar_Nomina.sql"
