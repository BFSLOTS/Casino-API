using System.ComponentModel.DataAnnotations;

namespace CasinoWebApi.DataAccess.Models
{
  public class Player
  {
    public int Id { get; set; }

    [Required]
    public string Name { get; set; }

    [Required]
    public PlayerType PlayerType { get; set; }

    public double Balance { get; set; }
  }

  public enum PlayerType
  {
    Test = 0,
    Real = 1
  }
}
