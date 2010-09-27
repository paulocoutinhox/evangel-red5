package game.entities
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Tilemap;

	public class MapLayer extends Entity
	{
		private var tilemap:Tilemap;
		
		public function MapLayer(index:int)
		{
			layer = index;
		}

		public function getTilemap():Tilemap
		{
			return tilemap;
		}

		public function setTilemap(value:Tilemap):void
		{
			tilemap = value;
		}

	}
}