package
{
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	
	import game.forms.FormLogin;
	import game.forms.FormMapLoader;
	import game.forms.FormPreLoader;
	import game.server.ClientConnection;
	import game.server.MessageManager;
	import game.util.Constants;
	import game.util.GameObjects;
	import game.util.Logger;
	import game.worlds.GameWorld;
	
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	
	[SWF(width = "800", height = "600", backgroundColor = "#000000")]
	public class Evangel extends Engine
	{
		public static var formPreLoader:FormPreLoader;
		public static var formLogin:FormLogin;
		public static var formMapLoader:FormMapLoader;
		
		public function Evangel()
		{
			super(Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT, Constants.SCREEN_FRAME_RATE, false);			
		}
		
		override public function init():void { 
			start();	
		}
		
		public function start():void
		{
			Logger.info("ENGINE STARTED");
			
			// define some constants
			GameObjects.MAIN = this;
			
			// create forms
			formPreLoader = new FormPreLoader();
			formLogin = new FormLogin();
			
			GameObjects.CONNECTION = new ClientConnection();
			GameObjects.CONNECTION.addEventListener(NetStatusEvent.NET_STATUS, onConnectionStatus);
			GameObjects.CONNECTION.addEventListener("playerMove", MessageManager.onPlayerMove);
			
			startLoadResources();
		}
		
		public function startLoadResources():void
		{
			formPreLoader.show();
			formPreLoader.startLoadResources();
		}
		
		public function afterLoadResources():void
		{
			startLogin();
		}
		
		public function startLogin():void
		{
			initialize();
			
			formPreLoader.hide();	
			formLogin.show();
			formLogin.getButtonRetry().visible = false;
			connectToServer();
		}
		
		public function afterLogin():void
		{
			startGame();
		}
		
		public function errorLogin():void
		{
			Constants.LOGGED_IN = false;
			GameObjects.PLAYERS = new Array();
			
			formLogin.getButtonRetry().visible = true;
		}
		
		public function startGame():void
		{
			formPreLoader.hide();
			formLogin.hide();
			
			Constants.LOGGED_IN = true;
			
			FP.world = new GameWorld();
		}
		
		public function afterLoadMap():void
		{
			GameObjects.MAP.loadMapContents();
			formMapLoader.hide();
			startGetPlayers();
		}
		
		public function startLoadMap():void
		{
			formPreLoader.hide();
			formLogin.hide();
			GameObjects.MAP.loadMapFile();
		}
		
		public function startGetPlayers():void
		{
			formPreLoader.hide();
			formMapLoader.hide();
			
			formLogin.show();			
			formLogin.getLabelStatus().text = "Getting users joinned...";
			
			MessageManager.sendPlayersJoined();
		}
		
		public function afterGetPlayers():void
		{
			if (Constants.LOGGED_IN == false)
			{
				MessageManager.sendLoginProcessOK();
			}
		}
		
		public function disconnectedGame():void
		{
			Constants.LOGGED_IN = false;
			GameObjects.PLAYERS = new Array();
			
			formPreLoader.hide();
			
			if (formMapLoader != null)
			{
				formMapLoader.hide();
			}
			
			FP.world = null;
			FP.world.visible = false;
			
			formLogin.getLabelStatus().text = "You have been disconnected by server";
			
			formLogin.show();
			formLogin.getButtonRetry().visible = true;
		}
		
		public function loginProcessOK():void
		{
			startGame();
		}
		
		public function connectToServer():void
		{
			GameObjects.CONNECTION.connect(Constants.GAME_SERVER_ADDRESS);
		}
		
		private function onConnectionStatus(e:NetStatusEvent):void
		{
			switch(e.info.code){
				case "NetConnection.Connect.Success":
					Logger.debug("NetConnection.Connect.Success");
					formLogin.loginOnServer();
					break;
				case "NetConnection.Connect.Failed":
					Logger.warn("NetConnection.Connect.Failed");
					formLogin.getLabelStatus().text = "Failed when connect to server (1)";
					errorLogin();
					break;
				case "NetConnection.Connect.Rejected":
					Logger.warn("NetConnection.Connect.Rejected");
					formLogin.getLabelStatus().text = "Failed when connect to server (2)";
					errorLogin();
					break;
				case "NetConnection.Connect.Closed":
					Logger.warn("NetConnection.Connect.Closed");
					formLogin.getLabelStatus().text = "Failed when connect to server (3)";
					disconnectedGame();
					break;
			}
		}
		
		private function initialize():void
		{
			GameObjects.PLAYERS    = new Array();
			GameObjects.MAP_LAYERS = new Array();
		}
		
	}
}