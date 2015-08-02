package net.natpat 
{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.drm.DRMPlaybackTimeWindow;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import net.natpat.gui.Button;
	import net.natpat.gui.InputBox;
	import net.natpat.particles.Emitter;
	import net.natpat.utils.Sfx;
	import flash.system.Security;
	
	import net.natpat.gui.Text;
	import net.natpat.gui.GuiManager
	import net.natpat.utils.Ease;
	import net.natpat.utils.Key;
	
	/**
	 * ...
	 * @author Nathan Patel
	 */
	public class GameManager 
	{
		public var socket:Socket = new Socket();
		
		public var serverText:Text = new Text(10, 10, "", 15, true, 0xffffff)
		
		/**
		 * Bitmap and bitmap data to be drawn to the screen.
		 */
		public var bitmap:Bitmap;
		public static var renderer:BitmapData;
		public var livingBuffer:BitmapData;
		
		public var map:Map;
		public var player:Player;
		
		public var players:Vector.<NetworkLiving>;
		
		public var inGame:Boolean = false;
		public var id:int;
		
		public function GameManager(stageWidth:int, stageHeight:int) 
		{
			GC.SCREEN_WIDTH = stageWidth;
			GC.SCREEN_HEIGHT = stageHeight;
			
			renderer = new BitmapData(stageWidth, stageHeight, false, 0x000000);
			
			bitmap = new Bitmap(renderer);
			
			GV.screen = renderer;
			
			GuiManager.add(serverText);
			serverText.text = "Connecting...";
			players = new Vector.<NetworkLiving>();
			
			//Attempt to connect to our node server...
			socket.addEventListener(Event.CONNECT, connected);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onData);
			socket.connect("192.168.1.159", 8124);
			
			//map = new Map(40, 40);
			livingBuffer = new BitmapData(GC.MAP_SIZE * Cell.SIZE, GC.MAP_SIZE * Cell.SIZE, true, 0);
		}
		
		public function startGame(map:Map):void
		{
			player = new Player(map);
			this.map = map;
			inGame = true;
			var timer:Timer = new Timer(1000 / GC.UPDATES_PER_SECOND, 0);
			timer.addEventListener(TimerEvent.TIMER, sendNewPosition);
			timer.start();
		}
		
		
		public function connected(e:Event):void
		{
			serverText.text = "Connected. Getting current game.\n";
		}
		
		public function onData(e:ProgressEvent):void
		{
			var data:String = socket.readUTFBytes(socket.bytesAvailable);
			var messages:Array = data.split('\n');
			//trace(messages);
			for each(var message:String in messages)
			{
				var type:String = message.charAt(0);
				trace(type);
				var values:String = message.slice(1);
				switch(type)
				{
					
					case "W":
						this.id = int(values);
						break;
					//Send a new map!
					case "S":
						var newMap:Map = new Map(GC.MAP_SIZE, GC.MAP_SIZE);
						var string:String = newMap.toNetworkString();
						
						socket.writeUTFBytes("M" + string + "\n");
						socket.flush();
						startGame(newMap);
						break;
						
					case "M":
						trace("Got a map!");
						var newMap:Map = Map.fromNetworkString(values);
						startGame(newMap);
						break;
					
					case "J":
						var newPlayer:NetworkLiving = new NetworkLiving(map, int(values));
						players.push(newPlayer);
						break;
					
					case "N":
						var id_:int = int(values);
						var newPlayer = new NetworkLiving(map, id_);
						players.push(newPlayer);
						break;
						
					case "U":
						var split:Array = values.split(":");
						var id:int = int(split[0]);
						var np:NetworkLiving = getPlayerByID(id);
						if (np != null)
						{
							np.updateFromNetwork(split[1]);
						}
						break;
						
					case "L":
						var np:NetworkLiving = getPlayerByID(int(values));
						if (np != null)
							players.splice(players.indexOf(np), 1);
						break;
				}
			}
		}
		
		public function onSecurityError(e:SecurityErrorEvent):void {
			serverText.text = "Security error. The policy server is probably down."
		}
		
		public function onIOError(e:IOErrorEvent):void
		{
			serverText.text = "Network Error. The server may be down."
			serverText.text += e.text;
		}
		
		public function render():void
		{
			if (inGame)
			{
				livingBuffer.fillRect(livingBuffer.rect, 0);
				player.render(livingBuffer);
				for each(var np:NetworkLiving in players)
				{
					np.render(livingBuffer);
				}
			}
			
			renderer.lock();
			
			//Render the background
			renderer.fillRect(new Rectangle(0, 0, renderer.width, renderer.height), 0x000000);
			
			if (inGame)
			{
				var m:Matrix = new Matrix();
				m.translate(int(GC.SCREEN_WIDTH / 2 - player.getPos().x), int(GC.SCREEN_HEIGHT / 2 - player.getPos().y));
				renderer.draw(map.getBottomBuffer(), m, null, null, null, false);
				renderer.draw(livingBuffer, m);
				renderer.draw(map.getTopBuffer(), m, null, null, null, false);
			}
			GuiManager.render();
			
			renderer.unlock();
		}
		
		public function update():void
		{
			GuiManager.update();
			
			if (inGame)
			{
				player.update();
				for each(var np:NetworkLiving in players)
				{
					np.update();
				}
			}
			
			Input.update();
		}
		
		private function getPlayerByID(id:int):NetworkLiving
		{
			for each(var np:NetworkLiving in players)
			{
				if (np.getID() == id)
					return np;
			}
			return null;
		}
		
		private function sendNewPosition(e:TimerEvent):void
		{
			if (player.shouldSendUpdate())
			{
				socket.writeUTFBytes("U" + player.toNetworkString() + "\n");
				socket.flush();
				player.sentUpdate();
			}
		}
		
	}

}