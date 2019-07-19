using System.ComponentModel.DataAnnotations;

namespace CasinoWebApi.DataAccess.Models
{
  public class Game
  {
    public int Id { get; set; }

    [Required]
    public string Name { get; set; }

    public string Description { get; set; }

    public bool IsFeatured { get; set; }
  }
}
