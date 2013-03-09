package com.bryanberger.nuyork.network
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.media.Microphone;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.net.NetStream;
	
	import org.osflash.signals.Signal;
	
	
	[Event(name="complete",type="flash.events.Event")]
	[Event(name="status",type="flash.events.StatusEvent")]
	[Event(name="share_complete", type="com.events.ShareEvent")]
	[Event(name="recieve_complete", type="com.events.ShareEvent")]
	
	public class P2PManager extends EventDispatcher
	{
		private var _connected:Boolean;
		
		public var netConnection:NetConnection;
		public var netStream_out:NetStream;
		
		private var _seq:int;
		private var spec:GroupSpecifier;
		private var connected:Signal;
		
		[Bindable]
		public var netGroup:NetGroup;
		
		private const SERVER:String = "rtmfp:";
		private const DEVKEY:String = "3542f8bb100b2e652000797f-0b5cb2bc795b";
		
		public function P2PManager(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function connect():void
		{
			netConnection = new NetConnection();
			netConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatus);				
			netConnection.connect( SERVER );
		}
		
		
		protected function netStatus(event:NetStatusEvent):void
		{
			log(event.info.code);
			
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
				//	connected.dispatch();
					
					//onGroupConnected();
					break;
				
				case "NetGroup.Neighbor.Connect":
					//sendMessage();
					neighborChange();
					break;
				
				case "NetGroup.Neigbhor.Disconnect":
					neighborChange();
					break;
				
				case "NetConnection.Connect.NetworkChange":
					neighborChange();
					break;
				
				case "NetGroup.SendTo.Notify":
					sendMessage(event.info.message);
					break;
				
						
				default:
					break;
			}
		}
		
		protected function onGroupConnected():void
		{		
			// setup netstream
			netStream_out = new NetStream(netConnection, spec.groupspecWithAuthorizations());
			//netStream_out = new NetStream(netConnection, NetStream.DIRECT_CONNECTIONS);
			netStream_out.addEventListener(NetStatusEvent.NET_STATUS, netStatus);

		}
		
		private function sendMessage(msg:String):void
		{
			log('Sending message');
			
			var message:Object = new Object();
			message.sender = netConnection.nearID;
			//message.sender = netGroup.convertPeerIDToGroupAddress(netConnection.nearID);
			//			message.user = txtUser.text;
			message.text = msg;
			message.sequence = _seq++; // *to keep unique
			
			netGroup.sendToAllNeighbors(message);
			//netGroup.post(message);
			//receiveMessage(message);
		}
		
		
		protected function setupGroup():void
		{
			log("setupGroup");
			
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
		
		protected function neighborChange():void
		{
			log('neighbor_change');
			var e:StatusEvent = new StatusEvent(StatusEvent.STATUS, false, false, "neighbor_change", netGroup.estimatedMemberCount.toString());
			dispatchEvent(e);	
		}
		
		protected function log(str:String):void
		{
			trace(str);
//			var e:StatusEvent = new StatusEvent(StatusEvent.STATUS, false, false, "status", str);
//			dispatchEvent(e);
		}
		
	} // END CLASS
} // END PACKAGE