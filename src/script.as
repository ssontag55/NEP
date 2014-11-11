	/* Main Script for Index Page */	
	import TitleWindowCustom.CustomTitleWindow;
	
	import com.esri.ags.events.MapEvent;
	import com.esri.ags.events.ZoomEvent;
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
	import com.esri.ags.layers.ArcGISImageServiceLayer;
	import com.esri.ags.layers.ArcGISTiledMapServiceLayer;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.layers.Layer;
	import com.esri.ags.symbols.SimpleFillSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	import com.esri.ags.utils.WebMercatorUtil;
	
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLVariables;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.core.IFlexDisplayObject;
	import mx.events.CloseEvent;
	import mx.managers.CursorManager;
	import mx.managers.PopUpManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.mxml.HTTPService;
	
	import solutions.SiteContainer;
	import solutions.TemplateEvent;
	import solutions.components.coordinates.coordinatesTool;
	import solutions.components.draw.drawTool;
	import solutions.components.identify.identifyTool;
	import solutions.components.toc.TOCMain;
	import solutions.config.ConfigData;
	
	import spark.components.SkinnableContainer;
	
	private var configData:ConfigData;
	private var fullExtent:Extent;
	
	//Symbology Array
	[Bindable] public var allSymbologyArray:Array = new Array();
	
	//selected layer in the toc so we can work with it in identify etc
	[Bindable]public var allDynLayers:Array=[];
	[Bindable]public var tocSelLayerID:String="";
	[Bindable]public var tocSelLayerURL:String="";
	
	//Map zoom level
	[Bindable]public var mapZoomLevel:Number;
	
	//Graphics layers...
	private var identifyGraphicsLayer:GraphicsLayer = new GraphicsLayer();
	private var drawGraphicsLayer:GraphicsLayer = new GraphicsLayer();
	private var coordinatesGraphicsLayer:GraphicsLayer = new GraphicsLayer();
	
	//Create the Tools ...
	private var myTOC:TOCMain = new TOCMain;
	private var myDrawTool:drawTool = new drawTool;
	private var myIdentifyTool:identifyTool = new identifyTool;
	private var myCoordinatesTool:coordinatesTool = new coordinatesTool;
		
	//Get selected basemap from TOC
	[Bindable]public var selectedBaseMap:String;
	//Get selected basemap from incoming URL
	[Bindable]public var selectedMap:String;
	//Get selected toc option from incoming URL
	[Bindable]public var tocType:String;
	[Bindable]public var useCustomTOC:Boolean =  false;
	
	//Not sure wha layersForLegend does, think it can be deleted, charlie-11/03
	[Bindable]public var layersForLegend:Array = [];
	
	//Array of stings(layer name + id) to check against layers in toc being built, if match make toclayer toggled as visible.
	//[Bindable]public var arrForLegend:Array = new Array;
	
	//Cursors
	[Embed(source="assets/icons/eraser_cursor.png")]
	public var eraserCursor:Class;
	[Embed(source="assets/icons/draw_cursor.png")]
	public var drawCursor:Class;
	[Embed(source="assets/icons/identify_cursor.png")]
	public var identifyCursor:Class;
	
	//Called from the main application container (TemplateEventSample.mxml)
	//in the "creationComplete" attribute. Registers all needed 
	//event listeners in the application...
	[Bindable]public var urlParams:String;
	[Bindable]public var params:Object;
	[Bindable]public var result:URLVariables = new URLVariables();
	[Bindable]public var lastCursor:String;
	

	private function init() : void
	{ 
		SiteContainer.addEventListener(TemplateEvent.TOC_LOADED, tocDone);
		SiteContainer.addEventListener(TemplateEvent.MAP_LEVEL_CHANGE, handleBaseMapsZoom);
		SiteContainer.addEventListener(TemplateEvent.CONFIG_LOADED, configMap);
		SiteContainer.addEventListener(TemplateEvent.BASEMAP_TOGGLE, toggleBaseMap);
		
		SiteContainer.addEventListener(TemplateEvent.TOC_SELECTION_CHANGE, updateLayerSelection);
		//SiteContainer.addEventListener(TemplateEvent.SYMBOLOGY_CHANGE, updateSymbology);
		SiteContainer.addEventListener(TemplateEvent.IDENTIFY_BEGIN_HANDLER, beginIdentify);
		//createDefaultSymbology();
		
		//Cursor Handlers
		SiteContainer.addEventListener(TemplateEvent.UPDATE_CURSOR, updateCursor);
	}
	
	private function mapZoomChange(event:ZoomEvent):void{
		mapZoomLevel = mainMap.level;
		SiteContainer.dispatchEvent(new TemplateEvent(TemplateEvent.MAP_LEVEL_CHANGE,false,false,mapZoomLevel));
	}
	
	private function tocDone(event:TemplateEvent):void{
		pb.visible = false;
	}
	
	private function handleBaseMapsZoom(event:TemplateEvent):void{
		var currentBaseMap:String = selectedBaseMap;
		if(currentBaseMap == null){
			currentBaseMap = "Ocean";
		}
		
		if ((currentBaseMap == "Ocean") && (mainMap.level > 13)){		
			selectedMap = "Imagery";
			SiteContainer.dispatchEvent(new TemplateEvent(TemplateEvent.BASEMAP_TOGGLE, false, false, selectedMap));		
			hddnOceanChckBx.selected = true;
		}
		
		if ((currentBaseMap == "Topo") && (mainMap.level > 17)){
			hddnStreetChckBx.selected = true;
			SiteContainer.dispatchEvent(new TemplateEvent(TemplateEvent.BASEMAP_TOGGLE, false, false, selectedMap));
		}
		if ((currentBaseMap == "Nautical") && (mainMap.level > 16)){
			hddnGrayChckBx.selected = true;
			selectedMap = "Imagery";
			SiteContainer.dispatchEvent(new TemplateEvent(TemplateEvent.BASEMAP_TOGGLE, false, false, selectedMap));				
		}
		
		if ((selectedMap == "Imagery") && (hddnOceanChckBx.selected == true) && (mainMap.level < 14)){
			selectedMap = "Ocean";
			SiteContainer.dispatchEvent(new TemplateEvent(TemplateEvent.BASEMAP_TOGGLE, false, false, selectedMap));
			hddnOceanChckBx.selected = false;
		}
		
		if ((selectedMap == "Imagery") && (hddnStreetChckBx.selected == true) && (mainMap.level < 18)){
			selectedMap = "Topo";
			SiteContainer.dispatchEvent(new TemplateEvent(TemplateEvent.BASEMAP_TOGGLE, false, false, selectedMap));
			hddnStreetChckBx.selected = false;
		}
		if ((selectedMap == "Imagery") && (hddnGrayChckBx.selected == true) && (mainMap.level < 17)){
			selectedMap = "Nautical";
			SiteContainer.dispatchEvent(new TemplateEvent(TemplateEvent.BASEMAP_TOGGLE, false, false, selectedMap));
			hddnGrayChckBx.selected = false;
		}
		
		//SiteContainer.dispatchEvent(new TemplateEvent(TemplateEvent.SET_BASEMAP_INDEX,false,false, selectedMap));
	}
	
	private function beginIdentify(event:TemplateEvent):void
	{
		//comment out to allow for identify for all layer services not just ones in the NEP TOC
		//SiteContainer.dispatchEvent(new TemplateEvent(TemplateEvent.SEND_LAYERS_TO_IDENTIFY,false,false,allDynLayers));
		SiteContainer.dispatchEvent(new TemplateEvent(TemplateEvent.SEND_LAYERS_TO_IDENTIFY,false,false,mainMap.layers));
		setIdentifyCursor();
	}
	
	private function createDefaultSymbology():void
	{
		//point
		var pointOutlineSymbol:SimpleLineSymbol = new SimpleLineSymbol("solid",0xDD0000,.5,2);
		var pointSymbol:SimpleMarkerSymbol = new SimpleMarkerSymbol("circle",8,0x000000,.5,0,0,0,pointOutlineSymbol);
		var point:Object = {
			id: "Default Point",
			type: "point",
			drawSelected: "yes",
			coordSelected: "yes",
			marker: pointSymbol
		}
		var pointSymArray:ArrayList = new ArrayList();
		pointSymArray.addItem(point);
		allSymbologyArray.push(pointSymArray);
		//line
		var lineSymbol:SimpleLineSymbol = new SimpleLineSymbol("solid",0x0066FF,.5,4);
		var line:Object = {
			id: "Default Line",
			type: "line",
			drawSelected: "yes",
			coordSelected: "yes",
			marker: lineSymbol
		}
		var lineSymArray:ArrayList = new ArrayList();
		lineSymArray.addItem(line);
		allSymbologyArray.push(lineSymArray);
		//polygon
		var polygonOutlineSymbol:SimpleLineSymbol = new SimpleLineSymbol("solid",0x006600,.5,4);
		var polygonSymbol:SimpleFillSymbol = new SimpleFillSymbol("solid", 0x00FF66, .5, polygonOutlineSymbol);
		var polygon:Object = {
			id: "Default Polygon",
			type: "polygon",
			drawSelected: "yes",
			buffer: "yes",
			coordSelected: "yes",
			marker: polygonSymbol
		}
		var polygonSymArray:ArrayList = new ArrayList();
		polygonSymArray.addItem(polygon);
		allSymbologyArray.push(polygonSymArray);
		
		//SiteContainer.addEventListener(TemplateEvent.SYMBOLOGY_CHANGE, updateSymbology);
		//SiteContainer.dispatchEvent(new TemplateEvent(TemplateEvent.SYMBOLOGY_CHANGE, false, false, allSymbologyArray));
	}
	
	private function updateSymbology(event:TemplateEvent):void
	{
		//if(event.data != null) allSymbologyArray = event.data as Array;
		//SiteContainer.dispatchEvent(new TemplateEvent(TemplateEvent.UPDATE_SYMBOLOGY, false, false, allSymbologyArray));
	}
	
	private function getURLParameters():Object
	{
		try
		{
			if (ExternalInterface.available)
			{
				// See http://livedocs.adobe.com/flex/3/langref/flash/external/ExternalInterface.html
				var search:String = ExternalInterface.call("window.location.search.substring(1).toString");		
				
				//search="XY=-72.06410156295456;40.571272680783885&level=7&basemap=Imagery&layers=jbandl=1,5;georegs=0;marineinf=0;humanuse=0;biology=8;geology=0;agencies=0;"
				if (search && search.length > 0)
				{				
					result.decode(search);	
				}
			}
		}
		catch (error:Error)
		{
			Alert.show(error.toString());
		}				
		return search;			
	}    
	
	private function handleURLParams():void
	{	
		urlParams = getURLParameters() as String;
		if (urlParams != null&& urlParams !=''){
				if (result.XY)
				{						
					var tempXY:String = new String(result.XY.replace(/,/g,""));				
					var latlong:Array = String(tempXY).split(";");				
					if (latlong.length == 2)
					{
						var loadCntrPt:MapPoint = new MapPoint(latlong[0], latlong[1]);
						loadCntrPt = WebMercatorUtil.geographicToWebMercator(loadCntrPt) as MapPoint;
						mainMap.centerAt(loadCntrPt);
					}
				}
				if (result.level)
				{				
					mainMap.level = result.level;
				}
				if (result.basemap)
				{
					selectedMap= result.basemap;
					if (selectedMap == 'Ocean'){
						selectedMap = "Ocean";
					}
					if (selectedMap == 'Topo'){
						selectedMap = "Topo";
					}
					if (selectedMap == 'Imagery'){
						selectedMap = "Imagery";
					}
					if (selectedMap == 'Nautical'){
						selectedMap = "Nautical";
					}
					//Dispatch the "BASEMAP_TOGGLE" TemplateEvent passing the "selectedMap" String...
					SiteContainer.dispatchEvent(new TemplateEvent(TemplateEvent.BASEMAP_TOGGLE, false, false, selectedMap));	
					
				}
				if (result.layers)
				{	
					allDynLayers=[];				
					var lyrGrps:Array = String(result.layers).split(";");				
					lyrGrps.pop();
					
					for(var j:int = 0; j < lyrGrps.length; j++){					
						var lyrGrp:Array = String(lyrGrps[j]).split("=");					
						
						var layr:Layer = returnLayerInfo(lyrGrp[0]) as Layer;
						
						if(layr.id == 'montauk' || layr.id == 'ngdc'|| layr.id == 'seclands')
						{
							layr.visible = true;
							allDynLayers.push(layr);
						}
						else if(layr is ArcGISDynamicMapServiceLayer)
						{	
							var dsLyr:ArcGISDynamicMapServiceLayer =layr as ArcGISDynamicMapServiceLayer;	
							var visibleLayers:ArrayCollection = new ArrayCollection;
							var vizLyrArr:Array =  String(lyrGrp[1]).split(",");	
							
							for each (var visItem in vizLyrArr){
								
								visibleLayers.addItem(visItem); 
								if(visItem != '9999'){
									dsLyr.visible = true;
								}
								dsLyr.visibleLayers = visibleLayers;
								var layerNameIdStr:String =  lyrGrp[0].toString() + visItem;						
								//arrForLegend.push(layerNameIdStr);											
							}
							allDynLayers.push(layr);
						}	
					}
					if (!result.toc){
						//SiteContainer.dispatchEvent(new TemplateEvent(TemplateEvent.REFRESH_TOC, false, false, arrForLegend));
					}
				}
		}	
	}
	
	private function returnLayerInfo(id:String):Layer
	{
		var returnLyr:Layer;
		for each(var lyr:Layer in mainMap.layers){
			if(lyr.id == id) {
				returnLyr = lyr; 
				break;
			}
		}
		return returnLyr;
	}
	
	//Configures the map based on settings in the config file (xml/config.xml)...
	private function configMap(event:TemplateEvent) : void {
		
		configData = event.data as ConfigData;
		var i:int = 0; 
		
		for (i = 0; i < configData.configExtents.length; i++) {
			var id:String = configData.configExtents[i].id;
			var ext:String = configData.configExtents[i].extent;
			var extArray:Array = ext.split(" ");
			var extent:Extent = new Extent(parseFloat(extArray[0])*.75, parseFloat(extArray[1])*.75, parseFloat(extArray[2])*.75, parseFloat(extArray[3])*.75);
			extent = WebMercatorUtil.geographicToWebMercator(extent) as Extent;      
			if (id == "full") {
				fullExtent = extent;
			}
			if (id == "initial") {
				mainMap.extent = extent;
			}
		}
		
		var initLoc:Array = configData.configLocation.split(",");
		var x:Number;
		var y:Number;
		
		if (initLoc.length > 1) {
			if (configData.configExtents.length < 1) { 
				var extent2:Extent = new Extent(10, 10, 20, 20);
				extent2 = WebMercatorUtil.geographicToWebMercator(extent2) as Extent; 
					mainMap.extent = extent2;
			}
			x = parseFloat(initLoc[0]);
			y = parseFloat(initLoc[1]); 
			var centerPt:MapPoint = new MapPoint(x,y);
			centerPt = WebMercatorUtil.geographicToWebMercator(centerPt) as MapPoint;
			if (configData.configLOD) mainMap.level = parseInt(configData.configLOD);
			if (configData.configwraparound180) mainMap.wrapAround180 = configData.configwraparound180;
			mainMap.centerAt(centerPt);
		} 
		
		
		for (i = 0; i < configData.configMap.length; i++) {
			
	    	var label:String  = configData.configMap[i].label;
	    	var type:String = configData.configMap[i].type;
	    	var url:String =  configData.configMap[i].url;		
	    	var visible:Boolean = configData.configMap[i].visible;
	    	var alpha:Number = Number(configData.configMap[i].alpha);
			var serviceID:String = configData.configMap[i].serviceID;
			var visibleLayersOnLoad:String = configData.configMap[i].vislayers;
	    	
	        switch (type.toLowerCase()) {
				case "dynamic": {
					var dynlayer:ArcGISDynamicMapServiceLayer = new ArcGISDynamicMapServiceLayer(url);
					
					//var dsLyr:ArcGISDynamicMapServiceLayer = returnLayerInfo(lyrGrp[0]) as ArcGISDynamicMapServiceLayer;	
					var visibleLayers:ArrayCollection = new ArrayCollection;
					var dynVisArr:Array = visibleLayersOnLoad.split(","); 	
					
					for each (var visItem in dynVisArr){
						
						visibleLayers.addItem(visItem); 
						dynlayer.visibleLayers = visibleLayers;
						var layerNameIdStr:String =  url + "/" + visItem;						
						//arrForLegend.push(layerNameIdStr);											
					}					
					
					dynlayer.id = serviceID;
					dynlayer.name = label;
					dynlayer.visible = visible; 
					dynlayer.alpha = alpha;				
					
					
					mainMap.addLayer(dynlayer);
					//layersForLegend.push(dynlayer);
					allDynLayers.push(dynlayer);
					break;
				}
				case "tiled": {
					var tiledlayer:ArcGISTiledMapServiceLayer = new ArcGISTiledMapServiceLayer(url);
					tiledlayer.id = label;
					tiledlayer.visible = visible;
					tiledlayer.alpha = alpha;
					mainMap.addLayer(tiledlayer); 
					break;
				}
				
				case "image": {
					var imagelayer:ArcGISImageServiceLayer = new ArcGISImageServiceLayer(url);
					imagelayer.id = label;
					imagelayer.visible = visible;
					imagelayer.alpha = alpha;
					mainMap.addLayer(imagelayer); 
				}			
			}			
	    }
		
		handleURLParams()
	}  
	
	private function readyToAcceptCoordinates(event:MapEvent):void
	{
		//Track the lat/long of the mouse
		mainMap.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
	}
	
	private function mouseMoveHandler(event:MouseEvent) : void {  
		const mapPoint:MapPoint = mainMap.toMapFromStage(event.stageX, event.stageY);   
		const latlong:MapPoint = WebMercatorUtil.webMercatorToGeographic(mapPoint) as MapPoint;                      
		mouseLat.content = latlong.y.toFixed(3);
		mouseLong.content = latlong.x.toFixed(3);
	}
	
	private function toggleBaseMap(event:TemplateEvent) : void {
		
		//Convert the "data" property of the TemplateEvent to a String...this value 
		//was passed in the "baseMapSelector" component when the TempleEvent was dispatched. 
		//This String's value corresponds to the "label" attribute of the 
		//mapservice layer (xml/config.xml) to set visible...
		var requestedMapLayerLabel:String = event.data as String;
		
		//Fetch the Array of available map layers. These are populated into the "configBasemaps" Array
		//"configMap" function by way of the "ConfigData" object...
		var configLayers:Array = configData.configBasemaps;
		
		//Loop through all the map layers and decide how to toggle the "visible" attribute...
		for (var x:Number=0; x<configLayers.length; x++) {
			var layer:Layer = mainMap.getLayer(configLayers[x].label);
			if (configLayers[x].label == requestedMapLayerLabel ){ //|| (requestedMapLayerLabel == 'Raster Nautical Chart' && configLayers[x].label == 'Ocean Map')) {			
				layer.visible = true;
				
			} else {
				layer.visible = false;
			}
		}
	}
	
	private function updateLayerSelection(event:TemplateEvent) : void {
		
		if (event.data.state == 'layer') { 
			tocSelLayerID =  event.data.layer.layerID;
			tocSelLayerURL = event.data.layer.urlSel; 
		} 
	} 
	
	/***** DRAW TOOL FUNCTIONS *****/
	//Draw Tool Selected from toggleTool
	//Send the current map and graphics layer I want to work with to draw tool
	//All functions can then be handled within the draw tool and passed back to 
	//main application
	private function draw():void
	{
		mainMap.addLayer(drawGraphicsLayer);
		
		myDrawTool.graphicsService = drawGraphicsLayer;
		myDrawTool.map = mainMap;
		
		//displayTool(myDrawTool);
		
		//drawTool.visible = true;
		//myDrawTool.graphicsLayer = drawGraphicsLayer;
	}
	
	
	/***** COORDINATE TOOL FUNCTIONS *****/
	//Coordinate Tool Selected from toggleTool
	private function coordinates():void {
		mainMap.addLayer(coordinatesGraphicsLayer);
		
		myCoordinatesTool.graphicsService = coordinatesGraphicsLayer;
		myCoordinatesTool.map = mainMap;
		
		//PopUpManager.addPopUp(myCoordinatesTool, this);
	}
	
	private function displayTool(tool:SkinnableContainer):void
	{
		var titleWindow:CustomTitleWindow = new CustomTitleWindow();
		titleWindow.enforceBoundaries = true;
		titleWindow.resizeEnabled = true;
		titleWindow.moveEnabled = true;
		titleWindow.addEventListener(CloseEvent.CLOSE, closeWindow);
	
		titleWindow.addElement(tool);
		
		PopUpManager.addPopUp(titleWindow, this);
	}
	
	private function closeWindow(event:CloseEvent):void
	{
		PopUpManager.removePopUp(event.currentTarget as IFlexDisplayObject);	
	}
	
	//Set Cursors
	private function updateCursor(event:TemplateEvent):void
	{
		this["set"+event.data+"Cursor"]();
		lastCursor = event.data.toString();
	}
	
	private function setDefaultCursor():void
	{
		CursorManager.removeAllCursors();
	}
	
	private function setEraserCursor():void
	{
		CursorManager.removeCursor(CursorManager.currentCursorID);
		CursorManager.setCursor(eraserCursor, 2, -3, -16);
	}
	
	private function setDrawCursor():void
	{
		CursorManager.removeCursor(CursorManager.currentCursorID);
		CursorManager.setCursor(drawCursor, 2, 0, -16); 
	}
	
	private function setIdentifyCursor():void
	{
		CursorManager.removeCursor(CursorManager.currentCursorID);
		CursorManager.setCursor(identifyCursor,2,0,0);
	}
	
	/*private function disclaimer():void
	{		
		//var disclaimer:disclaimerTitleWindow =  disclaimerTitleWindow(PopUpManager.createPopUp(this, disclaimerTitleWindow, true));
	}*/
	