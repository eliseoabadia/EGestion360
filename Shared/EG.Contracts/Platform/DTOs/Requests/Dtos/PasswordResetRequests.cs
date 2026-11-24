using System.ComponentModel.DataAnnotations;

namespace EG.Domain.DTOs.Requests;

public sealed class ForgotPasswordRequest
{
    [Required(ErrorMessage = "Captura tu correo electrónico.")]
    [EmailAddress(ErrorMessage = "Captura un correo electrónico válido.")]
    [StringLength(256)]
    public string Email { get; set; } = string.Empty;
}

public sealed class ResetPasswordRequest
{
    [Required]
    [StringLength(8192)]
    public string Token { get; set; } = string.Empty;

    [Required(ErrorMessage = "Captura la nueva contraseña.")]
    [StringLength(128, MinimumLength = 6, ErrorMessage = "Usa entre 6 y 128 caracteres.")]
    public string NewPassword { get; set; } = string.Empty;

    [Required(ErrorMessage = "Confirma la nueva contraseña.")]
    [Compare(nameof(NewPassword), ErrorMessage = "Las contraseñas no coinciden.")]
    public string ConfirmPassword { get; set; } = string.Empty;
}
