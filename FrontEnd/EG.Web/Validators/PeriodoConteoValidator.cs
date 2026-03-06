//// Validators/PeriodoConteoValidator.cs
//using FluentValidation;

//using EG.Web.Models.Configuration;

//namespace EG.Web.Validators
//{
//    public class PeriodoConteoValidator : AbstractValidator<PeriodoConteoCreateDto>
//    {
//        public PeriodoConteoCreateValidator()
//        {
//            RuleFor(x => x.CodigoPeriodo)
//                .NotEmpty().WithMessage("El código es requerido")
//                .MaximumLength(50).WithMessage("El código no puede exceder 50 caracteres")
//                .Matches("^[A-Z0-9-]+$").WithMessage("El código solo puede contener letras mayúsculas, números y guiones");

//            RuleFor(x => x.Nombre)
//                .NotEmpty().WithMessage("El nombre es requerido")
//                .MaximumLength(100).WithMessage("El nombre no puede exceder 100 caracteres");

//            RuleFor(x => x.Descripcion)
//                .MaximumLength(500).WithMessage("La descripción no puede exceder 500 caracteres");

//            RuleFor(x => x.SucursalId)
//                .GreaterThan(0).WithMessage("Debe seleccionar una sucursal");

//            RuleFor(x => x.TipoConteoId)
//                .GreaterThan(0).WithMessage("Debe seleccionar un tipo de conteo");

//            RuleFor(x => x.FechaInicio)
//                .NotEmpty().WithMessage("La fecha de inicio es requerida")
//                .GreaterThanOrEqualTo(DateTime.Today).WithMessage("La fecha de inicio no puede ser anterior a hoy");

//            RuleFor(x => x.FechaFin)
//                .GreaterThan(x => x.FechaInicio).When(x => x.FechaFin.HasValue)
//                .WithMessage("La fecha fin debe ser mayor a la fecha inicio");

//            RuleFor(x => x.ResponsableId)
//                .GreaterThan(0).WithMessage("Debe seleccionar un responsable");

//            RuleFor(x => x.ArticulosSeleccionados)
//                .NotEmpty().WithMessage("Debe seleccionar al menos un artículo")
//                .Must(x => x.Count > 0).WithMessage("Debe seleccionar al menos un artículo");
//        }
//    }

//    public class PeriodoConteoUpdateValidator : AbstractValidator<PeriodoConteoUpdateDto>
//    {
//        public PeriodoConteoUpdateValidator()
//        {
//            RuleFor(x => x.Id)
//                .GreaterThan(0).WithMessage("ID de periodo inválido");

//            RuleFor(x => x.CodigoPeriodo)
//                .NotEmpty().WithMessage("El código es requerido")
//                .MaximumLength(50).WithMessage("El código no puede exceder 50 caracteres");

//            RuleFor(x => x.Nombre)
//                .NotEmpty().WithMessage("El nombre es requerido")
//                .MaximumLength(100).WithMessage("El nombre no puede exceder 100 caracteres");

//            RuleFor(x => x.FechaInicio)
//                .NotEmpty().WithMessage("La fecha de inicio es requerida");

//            RuleFor(x => x.FechaFin)
//                .GreaterThan(x => x.FechaInicio).When(x => x.FechaFin.HasValue)
//                .WithMessage("La fecha fin debe ser mayor a la fecha inicio");

//            RuleFor(x => x.ResponsableId)
//                .GreaterThan(0).WithMessage("Debe seleccionar un responsable");
//        }
//    }
//}