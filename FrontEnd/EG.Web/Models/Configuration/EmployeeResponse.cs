namespace EG.Web.Models.Configuration;

public partial class EmployeeComplementaryDto
{


    public string MiddleInit { get; set; }

    public string Zip { get; set; }

    public string HomePhone { get; set; }

    public string Addr1 { get; set; }

    public string Addr2 { get; set; }

    public string City { get; set; }

    public string State { get; set; }

    public string EmergPhone { get; set; }

    public string EmergContact { get; set; }

    public byte Dependents { get; set; }

    public string Initials { get; set; }

    public DateOnly? BirthDate { get; set; }

    public string Password { get; set; }

    public short TransToday { get; set; }

    public DateOnly? DatePswdChng { get; set; }

    public short? EmpLocation { get; set; }

    public string JobTitle { get; set; }

    public string EmailAddr { get; set; }

    public string MiddleName { get; set; }

    public string SocialSec { get; set; }

    public string Tabadge { get; set; }

    public bool Sex { get; set; }

    public byte EmpStatus { get; set; }

    public byte JobCode { get; set; }

    public int JobClass { get; set; }

    public string DataSource { get; set; }

    public string Position { get; set; }

}
public partial class EmployeeDto : EmployeeComplementaryDto
{
    public int EmployeeNo { get; set; }

    public string FirstName { get; set; }

    public string LastName { get; set; }

    public string PayrollId { get; set; }

}