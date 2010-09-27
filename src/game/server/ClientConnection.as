package game.server
{
	import flash.net.NetConnection;
	
	public class ClientConnection extends NetConnection
	{
		public function ClientConnection()
		{
			super();
		}
		
		public function playerMove(r:Object):void 
		{
			MessageManager.onPlayerMove(r);
		} 
		
		public function playerLeave(r:Object):void 
		{
			MessageManager.onPlayerLeave(r);
		}
		
		public function playerJoin(r:Object):void 
		{
			MessageManager.onPlayerJoin(r);
		}
		
		public function playersJoined(r:Array):void 
		{
			MessageManager.onPlayersJoinedOK(r);
		}
	}
}