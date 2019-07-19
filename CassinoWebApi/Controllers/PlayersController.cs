using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using CasinoWebApi.DataAccess.Models;

namespace CasinoWebApi.Controllers
{
    [Produces("application/json")]
    [Route("api/[controller]")]
    public class PlayersController : ControllerBase
    {
        private static List<Player> players = new List<Player>();

        public PlayersController()
        {
            if (players.Count == 0)
            {
                players.Add(new Player { Balance = 20.0, Id = 1, Name = "John Doe", PlayerType = PlayerType.Test });
            }
        }

        [HttpGet]
        public ActionResult<List<Player>> GetAll()
        {
            return players;
        }

        [HttpGet("{id}")]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public ActionResult<Player> GetById(int id)
        {
            var player = players.FirstOrDefault(p => p.Id == id);

            if (player == null)
            {
                return NotFound();
            }

            return player;
        }

        [HttpPost]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public ActionResult<Player> Create(Player player)
        {
            player.Id = players.Any() ? players.Max(p => p.Id) + 1 : 1;
            players.Add(player);

            return CreatedAtAction(nameof(GetById), new { id = player.Id }, player);
        }

        [HttpPut("{id}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public ActionResult<Player> Update(int id, [FromBody] Player updatedPayer)
        {
            var player = players.FirstOrDefault(p => p.Id == id);

            if (player == null)
            {
                return NotFound();
            }

            player = updatedPayer;

            return player;
        }

        [HttpDelete("{id}")]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public ActionResult<Player> Delete(int id)
        {
            var player = players.FirstOrDefault(p => p.Id == id);

            if (player == null)
            {
                return NotFound();
            }

            players.Remove(player);

            return player;
        }
    }
}
