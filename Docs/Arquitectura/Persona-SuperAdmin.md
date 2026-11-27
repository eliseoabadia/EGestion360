# Persona técnica del SuperAdmin — desarrollo

Aplicado el 26/11/2026 a GestionEmpresarial en DESKTOP-B2UQJB2.

- SIS.Usuario 1 / ADMIN001 permanece activo, con su contraseña y rol SuperAdmin intactos.
- NOM.Persona 1: Eliseo Abadia, eliseo.abadia@gmail.com, clave SYS-SUPERADMIN, EsPersonaSistema=1 y Activo=0. Activo aquí significa participación operativa; no desactiva la cuenta SIS.Usuario.
- Sin empresa laboral, contrato, puesto, sueldo ni cuentas bancarias. Los campos obligatorios de fechas de la tabla utilizan 1900-01-01 como marcador técnico; no representan fechas personales o laborales. RFC y CURP vacíos.
- La anterior persona 1, Erasmo Flores, fue trasladada íntegramente a Persona 33, conservando todas sus columnas y actualizando las FK y referencias heredadas identificadas. Su cuenta sigue siendo SIS.Usuario 2. Los IDs de usuario y sus referencias de auditoría no se renumeraron.
- Se retiró la persona técnica temporal 32. Persona 31 conserva la identidad laboral de GABRIELA CORONA ESPINOSA; no se trasladó su historial al SuperAdmin.

Las vistas NOM.Vw_Persona, NOM.Vw_RhEmpleado, RHCT.Persona, NOM.Vw_OperacionNomina y NOM.Vw_RhEntidadNomina excluyen las personas de sistema. Se validaron y activaron 34 restricciones para impedir asignaciones a relaciones operativas, incluidas columnas heredadas sin FK y firmas autorizadas. SIS.Usuario mantiene la relación permitida. Una restricción adicional impide convertir la persona técnica en una persona activa, con empresa o datos de remuneración.

Scripts aplicados: 20261126_PersonaSistemaSuperAdmin.sql y 20261126_ReservarPersona1SuperAdmin.sql. Usan transacciones, verificación del destino y comprobaciones de identidad. La migración compara todas las columnas de Erasmo y los conteos de sus relaciones antes de confirmar. Los scripts no guardan copias de datos.

Verificado en SQL: Persona 1 ausente de Empleados, catálogo Personas y rama de empleados de Operación Nómina; Persona 32 inexistente; 34 restricciones habilitadas y confiables. Pruebas con rollback confirmaron que Persona 1 no puede activarse ni asignarse a una requisición. No había contratos laborales para realizar esa prueba negativa específica. LoginInformationEmployee devuelve usuario 1, persona 1, Eliseo Abadia, correo confirmado y rol SuperAdmin; no se imprimieron contraseñas ni hashes. Esta comprobación de identificación no sustituye un inicio de sesión interactivo con contraseña.

Se debe cerrar sesión y volver a entrar para renovar los datos de identidad del navegador. Las pruebas de carga siguen en pausa. Sin commits, push ni respaldos.
