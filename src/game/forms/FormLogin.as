package game.forms
{
	import br.com.stimuli.loading.lazyloaders.LazyXMLLoader;
	
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	
	import flash.events.MouseEvent;
	
	import game.server.MessageManager;
	import game.util.Constants;
	import game.util.GameObjects;
	import game.util.Logger;

	public class FormLogin extends Form
	{
		private var labelStatus:Label; 
		private var loader:LazyXMLLoader;
		private var buttonRetry:PushButton;
		
		public function FormLogin()
		{
			super("Login", 300, 150, true, false);
						
			// create the label
			labelStatus = new Label(form.content, 10, form.height - 50, "Connecting...");					
			labelStatus.setSize(280, 50);
			labelStatus.autoSize = false;
			
			// create the buttons
			buttonRetry = new PushButton(form.content, (form.width/2) - 50, (form.height/2) - 25, "Reconnect", onReconnectClickOK);
			buttonRetry.width = 100;
			buttonRetry.height = 22;
			buttonRetry.visible = false;
		}
		
		private function onReconnectClickOK(e:MouseEvent):void
		{
			GameObjects.MAIN.startLogin();	
		}
		
		public function loginOnServer():void
		{
			Logger.debug("Connecting to game server...");
			labelStatus.text = "Connecting to game server...";
			
			MessageManager.sendLogin(Constants.PLAYER_USERNAME, Constants.PLAYER_PASSWORD);
		}
		
		public function getLabelStatus():Label
		{
			return labelStatus;
		}
		
		public function getButtonRetry():PushButton
		{
			return buttonRetry;
		}
	
	}
}