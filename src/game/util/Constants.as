package game.util
{
	import flash.display.LoaderInfo;

	public class Constants
	{
		
		public static var DEBUG:Boolean = true;
		
		public static var URL_BASE:String = getURLBase();
		public static var URL_RESOURCES_XML:String = URL_BASE + "assets/data/loader.xml?" + getRandomNumber();
		public static var URL_MAPS:String = URL_BASE + "assets/data/map/";
				
		public static var PLAYER_USERNAME:String = "test";
		public static var PLAYER_PASSWORD:String = "test";
		
		public static var BULK_LOADER_NAME:String = "loader";	
		
		public static var SCREEN_WIDTH:int = 800;
		public static var SCREEN_HEIGHT:int = 600;
		public static var SCREEN_FRAME_RATE:int = 60;
		
		public static var LOGGED_IN:Boolean = false;
		
		public static var GAME_SERVER_ADDRESS:String = getServerAddress();
		
		public static var LAYER_EFFECT:int = 0;
		public static var LAYER_FOREGROUND:int = 1;
		public static var LAYER_CHARACTER:int = 2;
		public static var LAYER_MIDGROUND:int = 3;
		public static var LAYER_BACKGROUND:int = 4;
		public static var LAYER_BLOCK:int = 5;
		
		public static var TOTAL_MAP_LAYERS:int = 6;
		
		private static function getURLBase():String
		{
			var URL:String = "";
			
			if (DEBUG == true)
			{
				URL = "http://localhost/evangel-red5/";
			}
			else
			{
				URL = "http://www.prsolucoes.com/evangel-red5/"
			}
			
			return URL;
		}
		
		private static function getServerAddress():String
		{
			var URL:String = "";
			
			if (DEBUG == true)
			{
				URL = "rtmp://localhost/EvangelServer";
			}
			else
			{
				URL = "rtmp://prsolucoes.virtuaserver.com.br/EvangelServer";
			}
			
			return URL;
		}
		
		private static function getRandomNumber():Number
		{
			return Functions.randomNumber(0, 9999999);			
		}
	}
}