package game.entities
{
	import br.com.stimuli.loading.BulkLoader;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	
	import flash.display.BitmapData;
	
	import game.server.MessageManager;
	import game.util.Constants;
	import game.util.Functions;
	import game.util.GameObjects;
	
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.Tween;
	import net.flashpunk.graphics.Graphiclist;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.tweens.misc.VarTween;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	
	public class Player extends Entity
	{
		private var playerBitmap:BitmapData;
		private var playerSprite:Spritemap;
		
		private var playerBodyBitmap:BitmapData;
		private var playerBodySprite:Spritemap;
		
		public var playerDirection:int;
		public var playerStopped:Boolean;
		public var playerWalking:Boolean;
		public var playerWithoutAction:Boolean;
		
		public var playerId:String;
		public var playerName:String;
		public var playerLevel:int;
		public var playerMP:Number;
		public var playerHP:Number;
		public var playerEXP:Number;
		
		public var playerPosX:Number;
		public var playerPosY:Number;
		public var playerPosZ:Number;
		
		public var playerWidth:int;
		public var playerHeight:int;
		
		public var playerCanMove:Boolean;
		
		public var playerIsNpc:Boolean;
		
		public var playerTweenVelocity:Number = 0.4; 
		
		public var playerDistanceMovement:Number;
		
		public var playerState:int;
		
		public var playerType:String;
		
		public static var PLAYER_STATE_STAND:int = 1;
		public static var PLAYER_STATE_WALK:int = 2;
		
		public function Player()
		{
			layer = Constants.LAYER_CHARACTER;
			initializeProperties();
		}
		
		public function initialize():void
		{
			setHitbox(width, height, (width/2)-16, 32);
				
			loadPlayerData();
			
			playerSprite.add("up", [36,37,38,39,40,41,42], 12, true); 
			playerSprite.add("right", [54,55,56,57,58,59,60], 12, true);
			playerSprite.add("down", [0,1,2,3,4,5,6], 12, true);
			playerSprite.add("left", [18,19,20,21,22,23,24], 12, true);
			
			playerSprite.add("stop_up", [36], 12, true); 
			playerSprite.add("stop_right", [54], 12, true);
			playerSprite.add("stop_down", [0], 12, true);
			playerSprite.add("stop_left", [18], 12, true);
			
			
			var boots:BitmapData = BulkLoader.getLoader(Constants.BULK_LOADER_NAME).getBitmapData("head-crown");
			var playerBoots:Spritemap = new Spritemap(boots, 21, 15);
			playerBoots.x = (playerSprite.width / 2) - (playerBoots.width / 2); 
			
			playerBodyBitmap = BulkLoader.getLoader(Constants.BULK_LOADER_NAME).getBitmapData("chest-terranite-male");
			playerBodySprite = new Spritemap(playerBodyBitmap, 64, 64);
			
			playerBodySprite.add("up", [36,37,38,39,40,41,42], 12, true); 
			playerBodySprite.add("right", [54,55,56,57,58,59,60], 12, true);
			playerBodySprite.add("down", [0,1,2,3,4,5,6], 12, true);
			playerBodySprite.add("left", [18,19,20,21,22,23,24], 12, true);
			
			playerBodySprite.add("stop_up", [36], 12, true); 
			playerBodySprite.add("stop_right", [54], 12, true);
			playerBodySprite.add("stop_down", [0], 12, true);
			playerBodySprite.add("stop_left", [18], 12, true);
			
			graphic = new Graphiclist( playerSprite, playerBodySprite );
			
			stop(playerDirection);
		}
		
		public function updatePosition():void
		{
			// pressionar tecla
			if (isLockedPlayerMovement() == false)
			{
				if (Input.check(Key.LEFT)) { 
					if (checkPlayerCollision(4)==false)
					{
						lockPlayerMovement();
						playerState = PLAYER_STATE_WALK;
						MessageManager.sendPlayerMove(4);					
					}
					else
					{
						stop(playerDirection);
					}
				} else if (Input.check(Key.RIGHT)) { 
					if (checkPlayerCollision(2)==false)
					{
						lockPlayerMovement();
						playerState = PLAYER_STATE_WALK;
						MessageManager.sendPlayerMove(2);
					}
					else
					{
						stop(playerDirection);
					}
				} else if (Input.check(Key.UP)) { 
					if (checkPlayerCollision(1)==false)
					{
						lockPlayerMovement();
						playerState = PLAYER_STATE_WALK;
						MessageManager.sendPlayerMove(1);
					}
					else
					{
						stop(playerDirection);
					}
				} else if (Input.check(Key.DOWN)) { 
					if (checkPlayerCollision(3)==false)
					{
						lockPlayerMovement();
						playerState = PLAYER_STATE_WALK;
						MessageManager.sendPlayerMove(3);
					}
					else
					{
						stop(playerDirection);
					}
				}
			}
				
			// liberar tecla
			if (Input.released(Key.LEFT)) { 
				playerState = PLAYER_STATE_STAND;
			} else if (Input.released(Key.RIGHT)) { 
				playerState = PLAYER_STATE_STAND;
			} else if (Input.released(Key.UP)) { 
				playerState = PLAYER_STATE_STAND;
			} else if (Input.released(Key.DOWN)) { 
				playerState = PLAYER_STATE_STAND;
			}
			
			// pressionar tecla para movimentar camera
			if (Input.check(Key.A)) { 
				FP.camera.x -= 2;
				GameObjects.PLAYERS[1].x -= 2;
			} else if (Input.check(Key.D)) { 
				FP.camera.x += 2;
				GameObjects.PLAYERS[1].x += 2;
			} else if (Input.check(Key.W)) { 
				FP.camera.y -= 2;
			} else if (Input.check(Key.S)) { 
				FP.camera.y += 2;
			}
		}
		
		public function move(direction:int, posX:int, posY:int):void
		{
			this.playerDirection = direction;
			
			switch(direction)
			{
				case 1:
					createMovementTweenUsingGreensockTween(posX, posY);					
					playerSprite.play("up");
					playerBodySprite.play("up");
					break;
				
				case 2:
					createMovementTweenUsingGreensockTween(posX, posY);
					playerSprite.play("right");
					playerBodySprite.play("right");
					break;
				
				case 3:
					createMovementTweenUsingGreensockTween(posX, posY);
					playerSprite.play("down");
					playerBodySprite.play("down");
					break;
				
				case 4:
					createMovementTweenUsingGreensockTween(posX, posY); 
					playerSprite.play("left");
					playerBodySprite.play("left");
					break;
			}
		}
		
		public function stop(direction:int):void
		{
			playerState = PLAYER_STATE_STAND;
			
			switch(direction)
			{
				case 1:
					playerSprite.play("stop_up");
					playerBodySprite.play("stop_up");
					break;
				
				case 2:
					playerSprite.play("stop_right");
					playerBodySprite.play("stop_right");					
					break;
				
				case 3:
					playerSprite.play("stop_down");
					playerBodySprite.play("stop_down");					
					break;
				
				case 4:
					playerSprite.play("stop_left");
					playerBodySprite.play("stop_left");					
					break;
			}
		}
		
		private function loadPlayerData():void
		{
			playerBitmap = BulkLoader.getLoader(Constants.BULK_LOADER_NAME).getBitmapData(playerType);
			playerSprite = new Spritemap(playerBitmap, playerWidth, playerHeight);	
		}
		
		private function initializeProperties():void
		{
			playerPosX = 0;
			playerPosY = 0;
			playerPosZ = 0;
			
			playerDirection     = 1;			
			playerStopped       = true;
			playerWalking       = false;
			playerWithoutAction = false;
			
			playerCanMove = true;
			
			playerIsNpc = false;
			
			playerWidth  = 32;
			playerHeight = 32;
			
			playerDistanceMovement = 32;
			
			width = playerWidth; 
			height = playerHeight;
			
			playerState = PLAYER_STATE_STAND;
		}
	
		public function lockPlayerMovement():void
		{
			playerCanMove = false;
		}
		
		public function unlockPlayerMovement():void
		{
			playerCanMove = true;
		}
		
		public function isLockedPlayerMovement():Boolean
		{
			return !playerCanMove;
		}
		
		private function createMovementTweenUsingGreensockTween(posX:Number, posY:Number):void
		{
			TweenLite.to(this, playerTweenVelocity, { x:posX, y:posY, onComplete: onCompleteMoveTween, immediateRender: true, ease:Linear.easeNone } );
		}
		
		private function createMovementTweenUsingDefaultTween(posX:Number, posY:Number):void
		{
			var tweenX:VarTween = new VarTween(onCompleteMoveTween, Tween.ONESHOT);
			tweenX.tween(this, "x", posX, playerTweenVelocity);
			addTween(tweenX, false);
			
			var tweenY:VarTween = new VarTween(onCompleteMoveTween, Tween.ONESHOT);
			tweenY.tween(this, "y", posY, playerTweenVelocity);
			addTween(tweenY, false);
			
			tweenX.start();
			tweenY.start();
		}
		
		private function onCompleteMoveTween():void
		{
			unlockPlayerMovement();
			
			if (playerId != GameObjects.PLAYER.playerId)
			{
				stop(playerDirection);
			}
			else
			{
				if (playerState == PLAYER_STATE_STAND)
				{
					stop(playerDirection);	
				}
			}
		}
		
		public function toObject():Object
		{
			return {

			}
		}
		
		public function fromObject(o:Object):void
		{
			if (o.id)
				playerId = o.id;
			
			if (o.type)
				playerType = o.type;
			
			if (o.direction) 
				playerDirection = o.direction;
			
			if (o.name)
				playerName = o.name;
			
			if (o.level)
				playerLevel = o.level;
			
			if (o.mp)
				playerMP = o.mp;
			
			if (o.hp)
				playerHP = o.hp;
			
			if (o.exp)
				playerEXP = o.exp;
			
			if (o.posX) {
				playerPosX = o.posX;
				x = o.posX;
			}
			
			if (o.posY) {
				playerPosY = o.posY;
				y = o.posY;
			}
			
			if (o.posZ)
				playerPosZ = o.posZ;
			
			if (o.width) {
				playerWidth = o.width;
				width = o.width;
			}
			
			if (o.height) {
				playerHeight = o.height;
				height = o.height;
			}
			
			if (o.tweenVelocity)
				playerTweenVelocity = o.tweenVelocity;
			
			if (o.distanceMovement)
				playerDistanceMovement = o.distanceMovement;			
		}
		
		private function checkPlayerCollision(direction:int):Boolean
		{
			switch(direction)
			{
				case 1:
					return Functions.collideWithLayer(this, playerPosX, playerPosY-playerDistanceMovement);
					break;
				
				case 2:
					return Functions.collideWithLayer(this, playerPosX+playerDistanceMovement, playerPosY);
					break;
				
				case 3:
					return Functions.collideWithLayer(this, playerPosX, playerPosY+playerDistanceMovement);
					break;
				
				case 4:
					return Functions.collideWithLayer(this, playerPosX-playerDistanceMovement, playerPosY);
					break;
			}
			
			return false;
		}
	}
}