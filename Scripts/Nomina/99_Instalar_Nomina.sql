-- Instalador modular de Nomina.
-- Ejecutar en SQLCMD Mode.
-- No incluye Scripts/Nomina/LegacyStoredProcedures porque son fuentes legacy sin adaptar.

:r "C:\Desarrollo\Desarrollo\FullStack\EGestion360\Scripts\Nomina\01_Estructura_NOM.sql"
:r "C:\Desarrollo\Desarrollo\FullStack\EGestion360\Scripts\Nomina\02_Datos_NOM_Migracion.sql"
:r "C:\Desarrollo\Desarrollo\FullStack\EGestion360\Scripts\Nomina\06_Dependencias_RH_EMP_NOM.sql"
:r "C:\Desarrollo\Desarrollo\FullStack\EGestion360\Scripts\Nomina\09_Catalogos_Simples_SIS.sql"
:r "C:\Desarrollo\Desarrollo\FullStack\EGestion360\Scripts\Nomina\07_Demo_Corrida_NOM.sql"
:r "C:\Desarrollo\Desarrollo\FullStack\EGestion360\Scripts\Nomina\17_Procesos_Compat_NOM.sql"
:r "C:\Desarrollo\Desarrollo\FullStack\EGestion360\Scripts\Nomina\10_Operaciones_RH_NOM.sql"
:r "C:\Desarrollo\Desarrollo\FullStack\EGestion360\Scripts\Nomina\11_RH_Empleados_NOM.sql"
:r "C:\Desarrollo\Desarrollo\FullStack\EGestion360\Scripts\Nomina\12_RH_FKs_Vistas_SPs_NOM.sql"
:r "C:\Desarrollo\Desarrollo\FullStack\EGestion360\Scripts\Nomina\13_RH_CRUD_Empleados_NOM.sql"
:r "C:\Desarrollo\Desarrollo\FullStack\EGestion360\Scripts\Nomina\04_Vistas_NOM.sql"
:r "C:\Desarrollo\Desarrollo\FullStack\EGestion360\Scripts\Nomina\05_StoredProcedures_NOM.sql"
:r "C:\Desarrollo\Desarrollo\FullStack\EGestion360\Scripts\Nomina\14_Consolidar_Empresa_SIS_NOM.sql"
:r "C:\Desarrollo\Desarrollo\FullStack\EGestion360\Scripts\Nomina\15_Vistas_Unicas_Menu_Catalogos_NOM.sql"
:r "C:\Desarrollo\Desarrollo\FullStack\EGestion360\Scripts\Nomina\18_Catalogos_Ampliados_SIS_RH_NOM.sql"
-- Primero se alinea el arbol actual si ya existe; despues se aplica el menu Invea 610-930.
:r "C:\Desarrollo\Desarrollo\FullStack\EGestion360\Scripts\Nomina\08_Alineacion_Menu_Claims_NOM.sql"
:r "C:\Desarrollo\Desarrollo\FullStack\EGestion360\Scripts\Nomina\16_Menu_Invea_NOM.sql"
