package solutions.config {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import solutions.SiteContainer;
	import solutions.TemplateEvent;
	
    [Event(name="configLoaded", type="solutions.TemplateEvent")]
	public class ConfigManager extends EventDispatcher {

		public function ConfigManager() {
			super(); 
			//make sure the container is properly initialized and then
			//proceed with configuration initialization.
			SiteContainer.addEventListener(SiteContainer.CONTAINER_INITIALIZED, init); 
		}
        		
		//init - start loading the configuration file and parse.
		public function init(event:Event) : void {
			//Alert.show('here');
			configLoad();
		}
			
		//config load
		private function configLoad() : void {
			var configService:HTTPService = new HTTPService();
			configService.url = "xml/config.xml";
			configService.resultFormat = "e4x";
			configService.addEventListener(ResultEvent.RESULT, configResult);
			configService.addEventListener(FaultEvent.FAULT, configFault);	
			configService.send();
		}
				
		//config fault
		private function configFault(event:mx.rpc.events.FaultEvent) : void {
			var sInfo:String = "Error: ";
			sInfo += "Event Target: " + event.target + "\n\n";
			sInfo += "Event Type: " + event.type + "\n\n";
			sInfo += "Fault Code: " + event.fault.faultCode + "\n\n";
			sInfo += "Fault Info: " + event.fault.faultString;
			SiteContainer.dispatchEvent(new TemplateEvent(TemplateEvent.APP_ERROR, false, false, sInfo));
			//Alert.show(sInfo);
		}
		
		//config result
		private function configResult(event:ResultEvent) : void {
			
			try {	
				//parse config.xml to create config data object
				var configData:ConfigData = new ConfigData();
				var configXML:XML = event.result as XML;
				var i:int;
				var j:int; 
				
				//=================================================
				//extents
				 
				var configExtents:Array = [];
				var initialExtent:String = configXML.map.@initialExtent;
				var fullExtent:String = configXML.map.@fullExtent;
				var initialLocation:String = configXML.map.@initialLocation;
				var initialLOD:String = configXML.map.@initialLOD;
				var initialwraparound180:Boolean = configXML.map.@wraparound180;
				if (initialExtent) {
					var iExt:Object =  {
						id: "initial",
						extent: initialExtent
					}
					configExtents.push(iExt);
				}
				if (fullExtent) {
					var fExt:Object = {
						id: "full",
						extent: fullExtent
					}
					configExtents.push(fExt);
				}
				configData.configExtents = configExtents;
				
				if (initialLocation) { 
					configData.configLocation=initialLocation;
					if (initialLOD)	{ 
						configData.configLOD = initialLOD;
					}
				}
				
				if (initialwraparound180) {
					configData.configwraparound180 = initialwraparound180;
				}
				 
			 
				//================================================	
				//map
				var configMap:Array = [];
				var mapserviceList:XMLList = configXML..mapservice;
				for (i = 0; i < mapserviceList.length(); i++) {
					var msLabel:String = mapserviceList[i].@label;
					var msID:String = mapserviceList[i].@id;
					var msType:String = mapserviceList[i].@type;
					var msVisibleLayers:String = mapserviceList[i].@vislayers;
					var msVisible:Boolean = true;					
					if (mapserviceList[i].@visible == "false")
						msVisible = false;	
					var msAlpha:Number = 1;
					if (!isNaN(mapserviceList[i].@alpha))
						msAlpha = Number(mapserviceList[i].@alpha);						
					var msURL:String = mapserviceList[i];
					var mapservice:Object =  {
						label: msLabel,
						type: msType,
						visible: msVisible,
						vislayers: msVisibleLayers,
						alpha: msAlpha,
						url: msURL,
						serviceID: msID
					}
					configMap.push(mapservice);
				}
				configData.configMap = configMap;
				
				 
				//basemaps
				var configBasemaps:Array = [];
				var basemapList:XMLList = configXML.map.basemaps.mapservice;
				for (i = 0; i < basemapList.length(); i++) {
					var bmId:String = i.toString();
					var bmLayerId:String = basemapList[i].@layerid;
					var bmLabel:String = basemapList[i].@label;
					var bmTabIndex:int = int(basemapList[i].@tab);
					var bmDefaultTabLayer:String = basemapList[i].@defaultTabLayer;
					var basemap:Object = {
						id: bmId,
						layerid: bmLayerId,
						label: bmLabel,
						tab: bmTabIndex,
						defaultTabLayer: bmDefaultTabLayer
					}
					configBasemaps.push(basemap);
				}
				configData.configBasemaps = configBasemaps;
				
				//reference maps
				var configRefmaps:Array = [];
				var refmapList:XMLList = configXML.map.referencemaps.mapservice;
				for (i = 0; i < refmapList.length(); i++) {
					var rId:String = i.toString();
					var rLabel:String = refmapList[i].@label;
					var refmap:Object = {
						id: rId,
						label: rLabel
					}
					configRefmaps.push(refmap);
				}
				configData.configRefmaps = configRefmaps;
				
				//graphics layer services
				var configGraphics:Array = [];
				var graphicList:XMLList = configXML.map.graphiclayers.graphicservice;
				for (i = 0; i < graphicList.length(); i++) {
					var glId:String = i.toString();
					var glLabel:String = graphicList[i].@label;
					var grahicL:Object = {
						id: glId,
						label: glLabel
					}
					configGraphics.push(grahicL);
				}
				configData.configGraphic = configGraphics;
				
				//links
				var configLinks:Array = [];
				var linksList:XMLList = configXML.links.link;
				for (i = 0; i < linksList.length(); i++) {
					var linkName:String = linksList[i].@name;
					var linkValue:String = linksList[i].@value;
					var linkItem:Object = {
						name: linkName,
						value: linkValue
					}
					configLinks.push(linkItem);
				}
				configData.configLinks = configLinks;
				
				//dispatch event
				// Alert.show('configloaded');
				SiteContainer.dispatchEvent(new TemplateEvent(TemplateEvent.CONFIG_LOADED, false, false, configData));
				
			}catch(error:Error){
				SiteContainer.dispatchEvent(new TemplateEvent(TemplateEvent.APP_ERROR, false, false, error.message));		
			}
		}
		
		//get menu items
		private function getMenuItems(xmlList:XMLList, menuId:String, itemAction:String) : Array {
			var menuItems:Array = [];
			for (var i:int = 0; i < xmlList.length(); i++) {
				if (xmlList[i].@menu == menuId) {
					var itemLabel:String = xmlList[i].@label;
					var itemIcon:String = xmlList[i].@icon;
					var itemValue:String = xmlList[i];
					var menuItem:Object = {
						id: i,
						label: itemLabel,
						icon: itemIcon,
						value: itemValue,
						action: itemAction
					}
					menuItems.push(menuItem);
				}
			}
			return menuItems;
		}
		
		//get basemap menu items
		private function getBasemapMenuItems(xmlList:XMLList) : Array {
			var menuItems:Array = [];
			if (xmlList.length() > 1) {
				for (var i:int = 0; i < xmlList.length(); i++) {
					var itemLabel:String = xmlList[i].@label;
					var itemIcon:String = xmlList[i].@icon;
					var itemValue:String = i.toString();
					var menuItem:Object = {
						id: i,
						label: itemLabel,
						icon: itemIcon,
						value: itemValue,
						action: "basemap"
					}
					menuItems.push(menuItem);
				}
			}
			return menuItems;
		}	
	}
}