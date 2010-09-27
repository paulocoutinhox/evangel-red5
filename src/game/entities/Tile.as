package game.entities
{
	import net.flashpunk.Entity;
	
	public class Tile extends Entity
	{
		
		public function Tile(x:Number, y:Number, width:int, height:int)
		{
			this.x      = x;
			this.y      = y;
			this.width  = width;
			this.height = height;
		}
		
	}
}