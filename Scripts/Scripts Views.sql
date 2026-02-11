/*Vistas*/
CREATE    VIEW  [SIS].[VW_EmpresaDepartamanto]
AS
SELECT E.PKIdEmpresa,
	   E.Nombre AS EmpresaNombre,
	   E.RFC,
	   D.PKIdDepartamento,
	   D.Nombre AS DepartamentoNombre,
	   D.Activo AS DepartamentoActivo,
	   E.Activo AS EmpresaActivo
FROM [SIS].[Empresa] E WITH (NOLOCK)
INNER JOIN [SIS].[Departamento] D WITH (NOLOCK) ON E.PKIdEmpresa = D.FKIdEmpresa_SIS
WHERE E.Activo = 1 AND D.Activo = 1 ;

GO


CREATE    VIEW  [SIS].[VW_EstadoEmpresa]
AS
SELECT E.PKIdEstado,
	   E.Nombre AS EstadoNombre,
	   T.PKIdEmpresa,
	   T.Nombre AS EmpresaNombre,
	   T.RFC,
	   T.Activo AS EmpresaActivo
FROM [SIS].Estados E WITH (NOLOCK)
INNER JOIN [SIS].[Empresa] T WITH (NOLOCK) ON E.PKIdEstado = T.PKIdEmpresa
WHERE T.Activo = 1 ;

GO


