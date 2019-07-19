using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using CasinoWebApi.DataAccess.Models;

namespace CasinoWebApi.Controllers
{
  [Produces("application/json")]
  [Route("api/[controller]")]
  public class GamesController : ControllerBase
  {
    private static List<Game> games = new List<Game>();

    public GamesController()
    {
      if (games.Count == 0)
      {
        games.Add(new Game
        {
          Id = 1,
          Name = "Millionaries 2019",
          Description = "Considered the best casino game of the year."
        });
        games.Add(new Game
        {
          Id = 2,
          Name = "Ultraslots Remastered",
          Description = "The legendary slot game is back!",
          IsFeatured = true
        });
      }
    }

    [HttpGet("{id}")]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public ActionResult<Game> GetById(int id)
    {
      var game = games.FirstOrDefault(g => g.Id == id);

      if (game == null) return NotFound();

      return game;
    }

    [HttpGet]
    public ActionResult<List<Game>> Get([FromQuery] bool featuredOnly = false)
    {
      if (featuredOnly) return games.Where(g => g.IsFeatured).ToList();

      return games;
    }

    [HttpPost]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public ActionResult<Game> Create(Game game)
    {
      game.Id = games.Any() ? games.Max(p => p.Id) + 1 : 1;
      games.Add(game);

      return CreatedAtAction(nameof(GetById), new { id = game.Id }, game);
    }
  }
}
