using EG.Web.Models.Almacen;

namespace EG.Web.Contracts.Almacen;

public interface IAlmacenBienService : IGenericCrudService<BienResponse> { }

public interface IAlmacenTipoBienService : IGenericCrudService<TipoBienResponse> { }


