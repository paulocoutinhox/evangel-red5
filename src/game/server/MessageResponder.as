package game.server
{
	import flash.net.Responder;

	public class MessageResponder
	{
		public function MessageResponder()
		{
		}
		
		public static function getLoginResponder():Responder
		{
			return new Responder(MessageManager.onLoginOK);
		}
		
		public static function getProfileResponder():Responder
		{
			return new Responder(MessageManager.onProfileOK);
		}
		
		public static function getMapNameResponder():Responder
		{
			return new Responder(MessageManager.onMapNameOK);
		}
		
		public static function getPlayersJoinedResponder():Responder
		{
			return new Responder(MessageManager.onPlayersJoinedOK);
		}
		
		public static function getLoginProcessOKResponder():Responder
		{
			return new Responder(MessageManager.onLoginProcessOK);
		}
		
		public static function getPlayerMoveResponder():Responder
		{
			return new Responder(MessageManager.onPlayerMove);
		}
		
		
	}
}