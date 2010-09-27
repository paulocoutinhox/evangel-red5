package game.worlds
{
	import game.util.Camera;
	import game.util.Constants;
	import game.util.GameObjects;
	
	import net.flashpunk.FP;
	import net.flashpunk.World;
	
	public class GameWorld extends World
	{
		
		public function GameWorld()
		{
			super();
			initialize();
		}
		
		public function initialize():void
		{
			add(GameObjects.PLAYER);
			addList(GameObjects.PLAYERS);
			addList(GameObjects.MAP_LAYERS);
			
			GameObjects.CAMERA = new Camera(Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT);
			GameObjects.CAMERA.adjustToPlayer(GameObjects.MAP.width, GameObjects.MAP.height, GameObjects.PLAYER);
			
			if (GameObjects.PLAYER)
			{
				var cameraX:Number = GameObjects.PLAYER.x - (Constants.SCREEN_WIDTH / 2) + (GameObjects.PLAYER.width); 
				var cameraY:Number = GameObjects.PLAYER.y - (Constants.SCREEN_HEIGHT / 2) + (GameObjects.PLAYER.height);
				
				FP.camera.x = cameraX;
				FP.camera.y = cameraY;
			}
		}
		
		override public function update():void
		{
			if (GameObjects.PLAYER)
			{
				GameObjects.CAMERA.followPlayer(GameObjects.MAP.width, GameObjects.MAP.height, GameObjects.PLAYER);
				GameObjects.PLAYER.updatePosition();
			}
			
			super.update();
		}
	}
}