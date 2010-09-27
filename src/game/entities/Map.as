package game.entities
{
	import br.com.stimuli.loading.BulkLoader;
	
	import flash.display.BitmapData;
	
	import game.forms.FormMapLoader;
	import game.util.Constants;
	import game.util.Functions;
	import game.util.GameObjects;
	import game.util.Logger;
	
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Tilemap;

	public class Map extends Entity
	{
		private var tilemap:Tilemap;
		private var name:String;	
		private var xml:XML;
		
		private var mapWidth:Number;
		private var mapHeight:Number;
		
		private var tileWidth:Number;
		private var tileHeight:Number;
		
		private var tileMapSpriteName:String;
		
		private var tilemapBitmap:BitmapData;
		
		public function Map(name:String)
		{
			this.name = name;
		}
		
		public function loadMapFile():void
		{
			Evangel.formMapLoader = new FormMapLoader(name);			
			Evangel.formMapLoader.startLoad();
		}
		
		public function loadMapContents():void
		{
			Evangel.formMapLoader.getLabelStatus().text = "Loading map tiles...";
			
			mapWidth   = xml.@width;
			mapHeight  = xml.@height;
			tileWidth  = xml.@tilewidth;
			tileHeight = xml.@tileheight;
			
			tileMapSpriteName = xml.tileset[0].image.@source;
			tileMapSpriteName = Functions.getFilenameFromUrl(tileMapSpriteName);
			tileMapSpriteName = Functions.removeExtensionFromFilename(tileMapSpriteName);
			
			tilemapBitmap = BulkLoader.getLoader(Constants.BULK_LOADER_NAME).getBitmapData(tileMapSpriteName);
			
			GameObjects.TILES = new Array();
			
			loadMapLayers();
		}
		
		private function loadMapLayers():void
		{
			Logger.debug("Loading map layers...");
			
			loadMapLayer(xml.layer[5], Constants.LAYER_BLOCK);
			loadMapLayer(xml.layer[4], Constants.LAYER_EFFECT);
			loadMapLayer(xml.layer[3], Constants.LAYER_FOREGROUND);
			loadMapLayer(xml.layer[2], Constants.LAYER_CHARACTER);
			loadMapLayer(xml.layer[1], Constants.LAYER_MIDGROUND);
			loadMapLayer(xml.layer[0], Constants.LAYER_BACKGROUND);
						
			Logger.debug("Map layers loaded");
		}
		
		private function loadMapLayer(layer:XML, layerIndex:int):void
		{
			Logger.debug("Load map layer of index: " + layerIndex);
			
			var mapLayer:MapLayer = new MapLayer(layerIndex);
			var tilemap:Tilemap = new Tilemap(tilemapBitmap, mapWidth*tileWidth, mapHeight*tileHeight, tileWidth, tileHeight);
			
			var gid:Number = 0;
			
			for(var x:int = 0; x < mapWidth; x++)
			{
				for(var y:int = 0; y < mapHeight; y++)
				{
					try 
					{
						var tileID:Number = layer.data.tile[gid].@gid-1;
						
						if (tileID > -1)
						{
							tilemap.setTile(y, x, tileID);
							
							if (layerIndex == 5)
							{
								GameObjects.TILES.push(new Tile(y*tileHeight, x*tileWidth, tileWidth, tileHeight));
							}
						}
					}
					catch(e:Error) 
					{
						
					}
					
					gid++;
				}
			}
			
			mapLayer.graphic = tilemap;
			mapLayer.type = layer.@name;
			GameObjects.MAP_LAYERS.push(mapLayer);
		}
		
		public function getXML():XML
		{
			return xml;
		}
		
		public function setXML(xml:XML):void
		{
			this.xml = xml;
		}

		public function getMapWidth():Number
		{
			return mapWidth;
		}

		public function setMapWidth(value:Number):void
		{
			mapWidth = value;
		}

		public function getMapHeight():Number
		{
			return mapHeight;
		}

		public function setMapHeight(value:Number):void
		{
			mapHeight = value;
		}

		public function getTileWidth():Number
		{
			return tileWidth;
		}

		public function setTileWidth(value:Number):void
		{
			tileWidth = value;
		}

		public function getTileHeight():Number
		{
			return tileHeight;
		}

		public function setTileHeight(value:Number):void
		{
			tileHeight = value;
		}


	}
}