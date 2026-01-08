using System.ComponentModel.DataAnnotations;

namespace GEG.Dommain.DTOs.Responses
{
    public class DeptDto
    {
        public short DeptNo { get; set; }

        public string Description { get; set; }

        public string Depttype { get; set; }
    }

    public class CreateDeptDto
    {
        [Required]
        public int DeptNo { get; set; }

        [Required]
        [StringLength(200, ErrorMessage = "Dept text cannot exceed 200 characters.")]
        public string Description { get; set; } = string.Empty;

        public bool IsCode { get; set; }
        public bool IsCorrect { get; set; }
    }

    public class UpdateDeptDto : UpdateUserDept
    {
        [Required]
        [StringLength(200, ErrorMessage = "Choice text cannot exceed 200 characters.")]
        public string Description { get; set; } = string.Empty;

        public bool IsCode { get; set; }

    }

    public class UpdateUserDept
    {
        public int DeptNo { get; set; }
        public bool IsCorrect { get; set; }
    }

}