package com.bryanberger.nuyork.network
{
	import com.bryanberger.nuyork.core.MessageVO;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.geom.Point;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	
	import org.osflash.signals.Signal;
	
	
	[Event(name="complete",type="flash.events.Event")]
	[Event(name="status",type="flash.events.StatusEvent")]
	[Event(name="share_complete", type="com.events.ShareEvent")]
	[Event(name="recieve_complete", type="com.events.ShareEvent")]
	
	public class P2PManager extends EventDispatcher
	{
		private var _connected:Boolean;
		
		public var netConnection:NetConnection;
		public var netGroup:NetGroup;
		
		private var _seq:int;
		private var spec:GroupSpecifier;
		public var connected:Signal;
		public var newPlayerConnected:Signal;
		public var newPlayerDisconnect:Signal;
		public var movePlayer:Signal;
		private var _coords:Point = new Point();
		
		public var joinTime:int;
		
		private const SERVER:String = "rtmfp:";
		private const DEVKEY:String = "3542f8bb100b2e652000797f-0b5cb2bc795b";
		private var _channelId:uint = int( Math.random() * (99999 - 1) + 1 );
		public var msg:MessageVO;
		
		public function P2PManager(target:IEventDispatcher=null)
		{
			super(target);
			
			connected = new Signal(int);
			newPlayerConnected = new Signal(MessageVO);
			newPlayerDisconnect = new Signal(MessageVO);
			movePlayer = new Signal(MessageVO);
			
			msg = new MessageVO();
		}
		
		public function get channelId():uint
		{
			return _channelId;
		}

		public function set channelId(value:uint):void
		{
			_channelId = value;
		}

		public function connect():void
		{
			netConnection = new NetConnection();
			netConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatus);				
			netConnection.connect( SERVER );
		}
		
		public function sendCoords(x:Number, y:Number):void
		{		
			msg.channelId = _channelId;
			//	msg.coords = new Point(BattleState.user.x, BattleState.user.y);
			msg.sequence = _seq++;
			msg.x = x;
			msg.y = y;
			msg.type = "move";
			
			// send to peer
			//netGroup.sendToNearest(msg, 'com.bryanberger.nuyork');
			netGroup.sendToAllNeighbors(msg);
		}
		
		
		protected function netStatus(event:NetStatusEvent):void
		{
			//log(event.info.code);
			
			switch(event.info.code)
			{
				case "NetConnection.Connect.Success":
					setupGroup();
					break;
				
				case "NetConnection.Connect.Closed":
					_connected = false;
					break;
				
				case "NetGroup.Connect.Success":
					_connected = true;
					
					joinTime = new Date().getTime();
					
					//connected.dispatch(netGroup.neighborCount);
					sendHandshake();
					//onGroupConnected();
					break;
				
				case "NetGroup.Neighbor.Connect":
					
					
					// sendHandshake to peers
					sendHandshake();
					
					// listen for their handshake
					
					
					// neighborChange();
					break;
				
				case "NetGroup.Neigbhor.Disconnect":
					
					//neighborChange();
					break;
				
				case "NetConnection.Connect.NetworkChange":
					//neighborChange();
					break;
				
				case "NetGroup.SendTo.Notify":
					
					if(event.info.message.channelId == _channelId)
						break;
					
					switch(event.info.message.type)
					{
						case "handshake":
							//var msg:MessageVO = new MessageVO();
							msg.channelId = event.info.message.channelId;
							msg.x = event.info.message.x;
							msg.y = event.info.message.y;
							msg.sequence = event.info.message.sequence;
							msg.joinTime = event.info.message.joinTime;
							msg.type = event.info.message.type;
							
							newPlayerConnected.dispatch(msg);
						break;
						
						case "move":						
							//var msg2:MessageVO = new MessageVO();
							msg.channelId = event.info.message.channelId;
							msg.x = event.info.message.x;
							msg.y = event.info.message.y;
							msg.sequence = event.info.message.sequence;
							//msg2.joinTime = event.info.message.joinTime;
							msg.type = event.info.message.type;
							
							movePlayer.dispatch(msg);
						break;
					}
					//sendMessage(event.info.message);
					break;
				
						
				default:
					break;
			}
		}
		
		private function sendHandshake():void
		{
			var msg:MessageVO = new MessageVO();
			msg.channelId = _channelId;
		//	msg.coords = new Point(BattleState.user.x, BattleState.user.y);
			msg.sequence = _seq++;
			msg.joinTime = joinTime;
			msg.type = "handshake";
			
			// send to peer
			netGroup.sendToAllNeighbors(msg);
		}
	
		
		protected function setupGroup():void
		{		
			spec = new GroupSpecifier("com.bryanberger.nuyork");
			spec.multicastEnabled = true;
			spec.postingEnabled = true;
			//spec.serverChannelEnabled = true;
			spec.routingEnabled = true;
			spec.ipMulticastMemberUpdatesEnabled = true;
			spec.addIPMulticastAddress('225.225.0.1', '30303');

			//			spec.objectReplicationEnabled = true;	
			
			//netGroup.replicationStrategy = NetGroupReplicationStrategy.LOWEST_FIRST;
			netGroup = new NetGroup(netConnection, spec.groupspecWithAuthorizations());
			netGroup.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
		}

		
	} // END CLASS
} // END PACKAGE