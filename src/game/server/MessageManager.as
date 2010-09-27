package game.server 
{
	import game.entities.Map;
	import game.entities.Player;
	import game.util.Constants;
	import game.util.Functions;
	import game.util.GameObjects;
	import game.util.Logger;
	
	import net.flashpunk.FP;
	
	import playerio.Connection;
	import playerio.Message;
	
	public class MessageManager
	{
		private static var instance:MessageManager;
		private var connection:Connection;
				
		/**
		 * Singleton method that return an unique instance of this class
		 * @return MessageManager
		 */
		public static function getInstance():MessageManager
		{
			if (MessageManager.instance == null)
			{
				MessageManager.instance = new MessageManager();
			}
			
			return MessageManager.instance;
		}
		
		/**
		 * Default constructor
		 */
		public function MessageManager() 
		{
			
		}
		
		/**
		 * Initialize method
		 */
		public function initialize():void
		{
			//add disconnected event
			connection.addDisconnectHandler(onDisconnect_Connection);
			
			//add message event to profile of local player
			connection.addMessageHandler("PROFILE", messageProfile);
			
			//add message event to local player movement
			connection.addMessageHandler("PLAYER_MOVE", messageMovePlayer);
			
			//add message event to users already joined
			connection.addMessageHandler("USERS_JOINED", messageUsersJoined);
			
			//add message event to user left
			connection.addMessageHandler("USER_LEFT", messageUserLeft);
			
			//add message event to user join
			connection.addMessageHandler("USER_JOIN", messageUserJoin);
			
			//add message event to login ok
			connection.addMessageHandler("LOGIN_OK", messageLoginOK);
			
			//add message event to login error
			connection.addMessageHandler("LOGIN_ERROR", messageLoginERROR);
			
			//add message event to login process ok
			connection.addMessageHandler("LOGIN_PROCESS_OK", messageLoginProcessOK);
			
			//add message event to no users joined
			connection.addMessageHandler("NO_USERS_JOINED", messageNoUsersJoined);
			
			//add message event to chat message
			connection.addMessageHandler("CHAT_MESSAGE", messageChatMessage);
			
			//add message event to player move denied by server
			connection.addMessageHandler("PLAYER_MOVE_DENIED", messagePlayerMoveDenied);
			
			//add message event to player stop move
			connection.addMessageHandler("PLAYER_STOP_MOVE", messagePlayerStopMove);
			
			//add message event to player data
			connection.addMessageHandler("PLAYER_DATA", messagePlayerData);
			
			//add message event to map name
			connection.addMessageHandler("MAP_NAME", messageMapName);
			
			//add message event to change map
			connection.addMessageHandler("CHANGE_MAP", messageChangeMap);
			
			//add message event to npcs joined
			connection.addMessageHandler("NPCS_JOINED", messageNpcsJoined);
			
			//add message event to no npcs joined
			connection.addMessageHandler("NO_NPCS_JOINED", messageNoNpcsJoined);
			
			//add message event to npc movement
			connection.addMessageHandler("NPC_MOVE", messageMoveNpc);
		}
		
		/**
		 * Message that receive the profile of local player
		 * @param	m
		 * @param	playerId
		 * @param	name
		 * @param	level
		 * @param	hp
		 * @param	mp
		 * @param	exp
		 * @param	posx
		 * @param	posy
		 * @param	direction
		 * @param	tweenVelocity
		 * @param	type
		 */
		private function messageProfile(m:Message, playerId:String, name:String, level:uint, hp:uint, mp:uint, exp:uint, posx:uint, posy:uint, posz:uint, direction:uint, tweenVelocity:Number, type:String):void
		{
			GameObjects.PLAYER = new Player();
					
			GameObjects.PLAYER.playerId            = playerId;
			GameObjects.PLAYER.playerName          = name;
			GameObjects.PLAYER.playerHP            = hp;
			GameObjects.PLAYER.playerMP            = mp;
			GameObjects.PLAYER.playerEXP           = exp;
			GameObjects.PLAYER.playerPosX          = posx;
			GameObjects.PLAYER.playerPosY          = posy;
			GameObjects.PLAYER.playerPosZ          = posz;
			GameObjects.PLAYER.x                   = posx;
			GameObjects.PLAYER.y                   = posy;
			GameObjects.PLAYER.playerDirection     = direction;
			GameObjects.PLAYER.playerTweenVelocity = tweenVelocity;
			GameObjects.PLAYER.visible             = true;
			
			Evangel.formLogin.getLabelStatus().text = "Loading the map...";
			connection.send("MAP_NAME");
		}
		
		/**
		 * Move the local player
		 * @param	m
		 * @param	playerId
		 * @param	posx
		 * @param	posy
		 * @param	direction
		 */
		private function messageMovePlayer(m:Message, playerId:String, posx:uint, posy:uint, posz:uint, direction:uint, tweenVelocity:Number):void
		{
			//get the player
			var player:Player;
			
			if (GameObjects.PLAYER && playerId == GameObjects.PLAYER.playerId)
			{
				player = GameObjects.PLAYER;
				//player.unlockPlayerMovement();
				//return;
			}
			else
			{
				if (GameObjects.PLAYERS[playerId])
				{
					player = GameObjects.PLAYERS[playerId];
				}				
			}
			
			//set the player attributes
			if (player /*&& Core.getInstance().getLoggedIn() == true*/)
			{
				player.playerPosX          = posx;
				player.playerPosY    	   = posy;
				player.playerPosZ    	   = posz;
				player.playerDirection     = direction;
				player.playerTweenVelocity = tweenVelocity;
					
				player.move(direction, posx, posy);
				
			}
		}
		
		/**
		 * Message that receive the startup players information
		 * @param	m
		 * @param	playerId
		 * @param	name
		 * @param	level
		 * @param	hp
		 * @param	mp
		 * @param	exp
		 * @param	posx
		 * @param	posy
		 * @param	direction
		 * @param	tweenVelocity
		 * @param	type
		 */
		private function messageUsersJoined(m:Message, playerId:String, name:String, level:uint, hp:uint, mp:uint, exp:uint, posx:uint, posy:uint, posz:uint, direction:uint, tweenVelocity:Number, type:String):void
		{
			var qtd:uint = m.length;
			
			for (var i:uint = 0; i < qtd; i += 12)
			{
				var id:String = m.getString(i);
				
				if (GameObjects.PLAYER && id != GameObjects.PLAYER.playerId && getPlayerById(id) == null)
				{
						
					var player:Player = new Player();
					
					//set the player attributes
					player.playerId            = id;
					player.playerName          = name;
					player.playerHP            = hp;
					player.playerMP            = mp;
					player.playerEXP           = exp;
					player.playerPosX          = posx;
					player.playerPosY          = posy;
					player.playerPosZ          = posz;
					player.x                   = posx;
					player.y                   = posy;
					player.playerDirection     = direction;
					player.playerTweenVelocity = tweenVelocity;
					player.visible             = true;
										
					GameObjects.PLAYERS[player.playerId] = player;
									
					Logger.debug("Player(" + player.playerId + ") posx: " + player.playerPosX.toString() + " - posy: " + player.playerPosY.toString());
										
				}
			}
			
			//add player to render layer if already logged in
			/*
			if (Core.getInstance().getLoggedIn() == true)
			{
				Core.getInstance().showAllPlayers();	
			}
			*/
			
			Logger.debug("Total of online players here: " + GameObjects.PLAYERS.length);
			
			//get the joined npcs
			//FormLogin.getInstance().getLbStatus().setText("Getting npcs...");
			
			//connection.send("NPCS_JOINED");
			GameObjects.MAIN.afterGetPlayers();
		}
		
		/**
		 * Message that receive the player that left
		 * @param	m
		 * @param	playerId		 
		 */
		private function messageUserLeft(m:Message, playerId:String):void
		{
			if ( GameObjects.PLAYERS[playerId] )
			{
				var player:Player = GameObjects.PLAYERS[playerId];

				FP.world.remove(player);
				
				delete GameObjects.PLAYERS[playerId];
			}
		}
		
		/**
		 * Message that receive the last user join
		 * @param	m
		 * @param	playerId
		 * @param	name
		 * @param	level
		 * @param	hp
		 * @param	mp
		 * @param	exp
		 * @param	posx
		 * @param	posy
		 * @param	direction
		 * @param	tweenVelocity
		 * @param	type
		 */
		private function messageUserJoin(m:Message, playerId:String, name:String, level:uint, hp:uint, mp:uint, exp:uint, posx:uint, posy:uint, posz:uint, direction:uint, tweenVelocity:Number, type:String):void
		{
			if ( playerId != GameObjects.PLAYER.playerId && !GameObjects.PLAYERS[playerId] )
			{
					
				//get the local player
				var player:Player = new Player();
				
				//set the player attributes			
				player.playerId            = playerId;
				player.playerName          = name;
				player.playerHP            = hp;
				player.playerMP            = mp;
				player.playerEXP           = exp;
				player.playerPosX          = posx;
				player.playerPosY          = posy;
				player.playerPosZ          = posz;
				player.x                   = posx;
				player.y                   = posy;
				player.playerDirection     = direction;
				player.playerTweenVelocity = tweenVelocity;
				player.visible             = true;
				
				GameObjects.PLAYERS[player.playerId] = player;
					
				//add the player to map
				FP.world.add(player);
				
				Evangel.formLogin.getLabelStatus().text = "New user joined (" + playerId.toString() + "): " + player.playerName;
				
				//add animation
				//AnimationList.playerJoin(player);
			}
		}
		
		/**
		 * Message that receive the login OK confirmation
		 * @param	m
		 * @param	playerId		 
		 */
		private function messageLoginOK(m:Message, playerId:String):void
		{
			Evangel.formLogin.getLabelStatus().text = "Getting profile, wait...";
			connection.send("PROFILE");
		}
		
		/**
		 * Message that receive the login ERROR confirmation
		 * @param	m
		 * @param	playerId		 
		 */
		private function messageLoginERROR(m:Message, playerId:String, error:String):void
		{
			Evangel.formLogin.getLabelStatus().text = error;
			GameObjects.MAIN.errorLogin();
		}
		
		/**
		 * Message that receive the login process OK confirmation
		 * @param	m
		 * @param	playerId		 
		 */
		private function messageLoginProcessOK(m:Message, playerId:String):void
		{
			/*
			OwnPlanet.formLogin.getLabelStatus().text = "You are now logged in";
			Core.getInstance().initializeGame();
			*/
			Evangel.formLogin.getLabelStatus().text = "You are now logged in";
			GameObjects.MAIN.loginProcessOK();
		}
		
		/**
		 * Message that receive the no users joined message
		 * @param	m
		 * @param	playerId		 
		 */
		private function messageNoUsersJoined(m:Message, playerId:String):void
		{
			Logger.debug("Total of online players here: " + GameObjects.PLAYERS.length);
			
			//get the joined npcs
			//FormLogin.getInstance().getLbStatus().setText("Getting npcs...");
			
			//connection.send("NPCS_JOINED");
			GameObjects.MAIN.afterGetPlayers();
		}
		
		/**
		 * Message that receive the chat message
		 * @param	m
		 * @param	playerId		 
		 * @param	chatMessage
		 */
		private function messageChatMessage(m:Message, playerId:String, playerName:String, chatMessage:String, color:String):void
		{
			/*
			var player:Player = null;
			
			if ( Core.getInstance().getPlayers()[playerId] )
			{
				player = Core.getInstance().getPlayers()[playerId];
			}
			else if (playerId == Core.getInstance().getPlayer().playerId)
			{
				player = Core.getInstance().getPlayer();
			}
			
			if (player)
			{
				AnimationList.balloon(player, AnimationList.ANIMATION_BALLOON_CHAT);
			}
			
			//show message
			FormChat.getInstance().addMessage(chatMessage, playerId, playerName, color);
			*/
		}
		
		/**
		 * Message that receive the player move denied message from server
		 * @param	m
		 * @param	playerId		 
		 */
		private function messagePlayerMoveDenied(m:Message, playerId:String, posx:uint, posy:uint, posz:uint, direction:uint):void
		{
			GameObjects.PLAYER.playerState = Player.PLAYER_STATE_STAND;
			GameObjects.PLAYER.unlockPlayerMovement();
			return;
			
			//get the player
			var player:Player;
			
			if (GameObjects.PLAYER && playerId == GameObjects.PLAYER.playerId)
			{
				player = GameObjects.PLAYER;
			}
			else
			{
				if (GameObjects.PLAYERS[playerId])
				{
					player = GameObjects.PLAYERS[playerId];
				}
			}
			
			//set the player attributes
			if (player)
			{
				/*
				player.playerState = Player.PLAYER_STATE_STAND;
				player.unlockPlayerMovement();				
				return;
				*/
				
				player.playerPosX          = posx;
				player.playerPosY    	   = posy;
				player.playerPosZ    	   = posz;
				player.playerDirection     = direction;
				
				//player.x                   = posx;
				//player.y            	   = posy;
				
				player.playerState = Player.PLAYER_STATE_STAND;
				player.unlockPlayerMovement();
			}
		}
		
		/**
		 * Message that receive the player stop move
		 * @param	m
		 * @param	playerId		 
		 */
		private function messagePlayerStopMove(m:Message, playerId:String):void
		{
			if (playerId == GameObjects.PLAYER.playerId)
			{
				GameObjects.PLAYER.playerState = Player.PLAYER_STATE_STAND;
			}
			else
			{
				if ( GameObjects.PLAYERS[playerId] )
				{				
					GameObjects.PLAYERS[playerId].playerState = Player.PLAYER_STATE_STAND;				
				}
			}
		}
		
		/**
		 * Message that receive the player data
		 * @param	m
		 * @param	playerId
		 * @param	name
		 * @param	level
		 * @param	hp
		 * @param	mp
		 * @param	exp
		 * @param	posx
		 * @param	posy
		 * @param	direction
		 * @param	tweenVelocity
		 * @param	type
		 */
		private function messagePlayerData(m:Message, playerId:String, name:String, level:uint, hp:uint, mp:uint, exp:uint, posx:uint, posy:uint, posz:uint, direction:uint, tweenVelocity:Number, type:String):void
		{
			//get the player
			var player:Player;
			
			if (playerId == GameObjects.PLAYER.playerId)
			{
				player = GameObjects.PLAYER;
			}
			else
			{
				if (GameObjects.PLAYERS[playerId])
				{
					player = GameObjects.PLAYERS[playerId];
				}
			}
			
			//set the player attributes
			if (player)
			{
				player.playerName          = name;
				player.playerHP            = hp;
				player.playerMP            = mp;
				player.playerEXP           = exp;
				player.playerPosX          = posx;
				player.playerPosY          = posy;
				player.playerPosZ          = posz;
				player.x                   = posx;
				player.y                   = posy;
				player.playerDirection     = direction;
				player.playerTweenVelocity = tweenVelocity;
			}
		}
		
		/**
		 * Message that receive the player map
		 * @param	m
		 * @param	playerId
		 * @param	map
		 */
		private function messageMapName(m:Message, playerId:String, map:String):void
		{
			GameObjects.MAP = new Map("map1.tmx");
			GameObjects.MAIN.startLoadMap();
		}
		
		/**
		 * Message that receive the change map
		 * @param	m
		 * @param	playerId
		 * @param	map
		 */
		private function messageChangeMap(m:Message, playerId:String, map:String):void
		{
			/*
			Core.getInstance().resetGame();
			connection.send("PROFILE");
			*/
		}
		
		/**
		 * Message that receive the npcs informations
		 * @param	m
		 * @param	playerId
		 * @param	name
		 * @param	level
		 * @param	hp
		 * @param	mp
		 * @param	exp
		 * @param	posx
		 * @param	posy
		 * @param	direction
		 * @param	tweenVelocity
		 * @param	type
		 */
		private function messageNpcsJoined(m:Message, playerId:String, name:String, level:uint, hp:uint, mp:uint, exp:uint, posx:uint, posy:uint, posz:uint, direction:uint, tweenVelocity:Number, type:String):void
		{
			/*
			//get all players data
			var qtd:uint = m.length;
			
			for (var i:uint = 0; i < qtd; i += 12)
			{
				var id:uint = m.getUInt(i);
				
				if (Core.getInstance().getNpcs() && !Core.getInstance().getNpcs()[id])
				{
					
					//create a new npc
					var player:Player = new Player(m.getString(i + 11));
					
					//set the npc attributes			
					player.playerId      = id;
					player.playerName    = m.getString(i+1);
					player.level         = m.getUInt(i+2);
					player.hp            = m.getUInt(i+3);
					player.mp            = m.getUInt(i+4);
					player.exp           = m.getUInt(i+5);
					player.posx          = m.getUInt(i+6);
					player.posy          = m.getUInt(i+7);				
					player.posz          = m.getUInt(i+8);
					player.direction     = m.getUInt(i+9);
					player.tweenVelocity = m.getNumber(i + 10);
					
					player.setPlayerName(player.playerName);
					player.setType(m.getString(i + 11));
					
					player.visible       = true;
					
					player.x          = player.posx;
					player.y          = player.posy;
					
					player.isNpc = true;
					
					Core.getInstance().getNpcs()[player.playerId] = player;
					
					FormConsole.getInstance().setLogText("Npc(" + player.playerId + ") posx: " + player.posx.toString() + " - posy: " + player.posy.toString());					
				}
			}
			
			//add npc to render layer if already logged in
			if (Core.getInstance().getLoggedIn() == true)
			{
				Core.getInstance().showAllNpcs();	
			}
			
			FormConsole.getInstance().setLogText("Total of npcs here: " + Core.getInstance().getNpcs().length);
			
			//send login process confirmation
			if (Core.getInstance().getLoggedIn() == false)
			{
				OwnPlanet.formLogin.getLabelStatus().text = "Login process finished";
				connection.send("LOGIN_PROCESS_OK");
			}
			*/
		}
		
		/**
		 * Message that receive the no npcs joined message
		 * @param	m
		 * @param	playerId		 
		 */
		private function messageNoNpcsJoined(m:Message, playerId:String):void
		{
			/*
			//send login process confirmation
			if (Core.getInstance().getLoggedIn() == false)
			{
				OwnPlanet.formLogin.getLabelStatus().text = "Login process finished";
				connection.send("LOGIN_PROCESS_OK");
			}
			*/
		}
		
		/**
		 * Move the npc
		 * @param	m
		 * @param	playerId
		 * @param	posx
		 * @param	posy
		 * @param	direction
		 */
		private function messageMoveNpc(m:Message, playerId:String, posx:uint, posy:uint, posz:uint, direction:uint, tweenVelocity:Number):void
		{
			/*
			//get the player
			var player:Player;
			
			if (Core.getInstance().getNpcs() && Core.getInstance().getNpcs()[playerId])
			{
				player = Core.getInstance().getNpcs()[playerId];
			}
			
			//set the player attributes
			if (player)
			{
				player.posx          = posx;
				player.posy          = posy;
				player.posz          = posz;
				player.direction     = direction;
				player.tweenVelocity = tweenVelocity;
				
				player.move();
			}
			*/
		}
		
		/**
		 * Connection - onDisconnect
		 */
		private function onDisconnect_Connection():void
		{
			GameObjects.MAIN.disconnectedGame();
		}
		
		private function getPlayerById(id:String):Player
		{
			for (var playerId:String in GameObjects.PLAYERS)
			{
				if ( playerId == id )
				{
					return GameObjects.PLAYERS[playerId]; 
				}
			}
			
			return null;
		}
		
				
		/**
		 * Getters and Setters
		 */
		public function getConnection():Connection { return connection; }
		public function setConnection(value:Connection):void { connection = value; }
		
		
		////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////
			
		
		
		public static function sendLogin(username:String, password:String):void
		{
			GameObjects.CONNECTION.call("login", MessageResponder.getLoginResponder(), username, password);
		}
		
		public static function sendProfile():void
		{
			GameObjects.CONNECTION.call("profile", MessageResponder.getProfileResponder());
		}
		
		public static function sendMapName():void
		{
			GameObjects.CONNECTION.call("mapName", MessageResponder.getMapNameResponder());
		}
		
		public static function sendLoginProcessOK():void
		{
			GameObjects.CONNECTION.call("loginProcessOK", MessageResponder.getLoginProcessOKResponder());
		}
		
		public static function sendPlayerMove(direction:int):void
		{
			GameObjects.CONNECTION.call("playerMove", MessageResponder.getPlayerMoveResponder(), direction);
		}
		
		public static function sendPlayersJoined():void
		{
			GameObjects.CONNECTION.call("playersJoined", MessageResponder.getPlayersJoinedResponder());
		}
		
		public static function onLoginOK(r:String):void
		{
			Logger.debug("onLoginOK");
			
			if (r == "LOGIN_OK")
			{
				sendProfile();				
			}
			else
			{
				Evangel.formLogin.getLabelStatus().text = "Username or password is invalid";
				GameObjects.MAIN.errorLogin();
			}
		}
		
		public static function onProfileOK(r:Object):void
		{
			Logger.debug("onProfileOK");
			
			GameObjects.PLAYER = new Player();
			GameObjects.PLAYER.fromObject(r);
			GameObjects.PLAYER.initialize();
			
			Evangel.formLogin.getLabelStatus().text = "Loading the map...";
			sendMapName();	
		}
		
		public static function onMapNameOK(r:String):void
		{
			Logger.debug("onMapNameOK");
			
			GameObjects.MAP = new Map(r + ".tmx");
			GameObjects.MAIN.startLoadMap();
		}
		
		public static function onPlayersJoinedOK(r:Array):void
		{
			Logger.debug("onPlayersJoinedOK");
			
			if (r.length > 0)
			{
				for (var x:int = 0; x < r.length; x++)
				{
					var receivedPlayer:Object = r[x];
					
					if (GameObjects.PLAYER && receivedPlayer.id != GameObjects.PLAYER.playerId && Functions.getPlayerById(receivedPlayer.id) == null)
					{
						var newPlayer:Player = new Player();
						newPlayer.fromObject(receivedPlayer);
						newPlayer.initialize();
						
						GameObjects.PLAYERS.push(newPlayer);
					}
				}
				
			}
			
			Logger.debug("Total of online players here: " + GameObjects.PLAYERS.length);
			GameObjects.MAIN.afterGetPlayers();
		}
		
		public static function onLoginProcessOK(r:String):void
		{
			Logger.debug("onLoginProcessOK");
			
			Evangel.formLogin.getLabelStatus().text = "You are now logged in";
			GameObjects.MAIN.loginProcessOK();
		}
		
		public static function onPlayerMove(r:Object):void
		{
			Logger.debug("onPlayerMove");
			
			//get the player
			var player:Player;
			var playerId:String = r.id;
			
			if (GameObjects.PLAYER && playerId == GameObjects.PLAYER.playerId)
			{
				player = GameObjects.PLAYER;
			}
		
			else
			{
				player = Functions.getPlayerById(playerId);				
			}
			
			if (player)
			{
				player.playerPosX          = r.posX;
				player.playerPosY    	   = r.posY;
				player.playerPosZ    	   = r.posZ;
				player.playerDirection     = r.direction;
				player.playerTweenVelocity = r.tweenVelocity;
				
				player.move(player.playerDirection, player.playerPosX, player.playerPosY);
			}
		}
		
		public static function onPlayerLeave(r:Object):void
		{
			Logger.debug("onPlayerLeave");
			
			//get the player
			var playerId:String = r.id;
			var player:Player = Functions.getPlayerById(playerId);
			
			if ( player )
			{
				FP.world.remove(player);				
				delete GameObjects.PLAYERS[player];
			}
		}
		
		public static function onPlayerJoin(r:Object):void
		{
			Logger.debug("onPlayerJoin");
			
			//get the player
			var player:Player;
			var playerId:String = r.id;
			
			player = Functions.getPlayerById(playerId);				
			
			if (!player)
			{
				var newPlayer:Player = new Player();
				newPlayer.fromObject(r);
				newPlayer.initialize();
				
				GameObjects.PLAYERS.push(newPlayer);
				
				FP.world.add(newPlayer);
			}
		}
		
	}
	
}