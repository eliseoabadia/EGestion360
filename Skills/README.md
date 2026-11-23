# Skills reutilizables para modulos empresariales

Cada subcarpeta es una skill independiente. Esta carpeta es la copia editable y transportable; no contiene credenciales ni direcciones de servidores de produccion.

| Skill | Ejemplo de solicitud |
|---|---|
| eae-modulo-completo | Usa $eae-modulo-completo para crear el modulo de mantenimiento con equipos y ordenes de trabajo. |
| eae-catalogos-blazor | Usa $eae-catalogos-blazor para agregar el catalogo de tipos de equipo siguiendo las pantallas actuales. |
| eae-sqlserver-integridad | Usa $eae-sqlserver-integridad para preparar la baja logica y validar dependencias activas del catalogo. |
| eae-permisos-modulos | Usa $eae-permisos-modulos para restringir las ordenes por area y permitir autorizarlas solo al responsable. |
| eae-flujos-autorizacion | Usa $eae-flujos-autorizacion para implementar envio, rechazo y reenvio de ordenes sin duplicados. |
| eae-deploy-iis | Usa $eae-deploy-iis para preparar los ZIP de esta version; te indico nombres, destinos y conexion en el mensaje. |

Para un modulo completo empieza con la primera. Para ajustes puntuales menciona la especializada; no hace falta cargar todas. Tambien pueden seleccionarse automaticamente cuando la descripcion coincide con el pedido.

## Uso aqui y en otros proyectos

En este equipo se instalaron copias verificadas en `C:\Users\Eliseo\.codex\skills`, junto a las skills existentes de Codex. La copia editable esta en la carpeta `Skills` de este repositorio. Los cambios en una copia no se sincronizan automaticamente con la otra.

Para compartir con otro equipo, copia las subcarpetas completas al directorio personal de skills que use su instalacion; la documentacion actual indica `~/.agents/skills`. Para versionarlas con un proyecto, coloca las elegidas en `.agents/skills/` de ese repositorio. Evita instalar el mismo nombre simultaneamente en varios directorios de descubrimiento porque pueden aparecer duplicados.

Codex detecta cambios de skills; si no aparecen, reinicia la aplicacion. Puedes pedir explicitamente que lea un `SKILL.md` de esta carpeta mientras se actualiza la lista.

Los ejemplos de EGestion son condicionales: las skills deben inspeccionar el proyecto destino. La skill de Blazor y la de SQL Server solo corresponden a esas tecnologias; no convierten otros proyectos. Las skills no conceden acceso al servidor ni autorizan envios, escrituras de produccion o reinicios por el hecho de invocarlas.

## Mantenimiento

Edita el SKILL.md de la skill que cambia y sincroniza su carpeta con la instalacion personal. Si trasladas solo una skill, incluye sus referencias. Mantén las reglas verificadas y acotadas; no copies historial, contrasenas o configuraciones de cliente. No es necesario modificar el codigo de la aplicacion para usar estas instrucciones.

Documentacion de estructura, descubrimiento e invocacion: https://learn.chatgpt.com/docs/build-skills
