package solutions {
	
	import flash.events.Event;

	public class TemplateEvent extends Event { 
		
		//MAP-RELATED TEMPLATE EVENT CONSTANTS...
		public static const CONFIG_LOADED:String = "configLoaded";
		public static const APP_ERROR:String = "appError";
		public static const SET_STATUS:String = "setStatus";
		
		//APPLICATION-SPECIFIC TEMPLATE EVENT CONSTANTS...
		public static const BASEMAP_TOGGLE:String = "basemapToggle";
		public static const TOOL_TOGGLE:String = "toolToggle";
		public static const GEOMETRY_TOGGLE:String = "geometryToggle";
		public static const GROUP_TOGGLE:String = "groupToggle";
		public static const VISIBLE_LAYER_TOGGLE:String = "visibleLayerToggle";
		public static const VISIBLE_LAYER_TOGGLE_ON_TOC:String = "visibleLayerToggleOnTOC";
		public static const VISIBLE_LAYER_TOGGLE_OFF_TOC:String = "visibleLayerToggleOffTOC";
		public static const TOC_STATE_CHANGE:String = "tocStateChange";
		public static const TOC_SELECTION_CHANGE:String = "tocSelChange";
		public static const GET_PARAMS:String = "tocSelChange";
		public static const SYMBOLOGY_CHANGE:String = "symbologyChange";
		public static const UPDATE_SYMBOLOGY:String = "updateSymbology";
		public static const CHANGE_SYMBOL:String = "changeSymbology";
		public static const SYMBOL_CHANGED:String = "symbolChanged";
		public static const DRAW_GRAPHICS_TOGGLE:String = "drawGraphicsToggle";
		public static const DRAW_END_HANDLER:String = "drawEndHandler";
		public static const IDENTIFY_BEGIN_HANDLER:String = "identifyBeginHandler";
		public static const SEND_LAYERS_TO_IDENTIFY:String = "sendLayersToIdentify";
		public static const IDENTIFY_END_HANDLER:String = "identifyEndHandler";
		public static const COORD_GRAPHICS_TOGGLE:String = "drawGraphicsToggle";
		public static const MAP_LEVEL_CHANGE:String = "mapLevelChange";
		public static const SET_BASEMAP_INDEX:String = "setBasemapIndex";
		public static const UPDATE_CURSOR:String = "updateCursor";
		public static const REFRESH_TOC:String = "refreshTOC";
		public static const PRINT_LGD_SCROLLR:String = "printLgdScrollr";
		public static const CUSTOM_TOC:String = "customTOC";
		public static const TOC_LOADED:String = "loadedTOC";
		public static const CLEAR_LAYERS:String = "clearTOC";
		public static const TOC_WIN_CHANGE:String = "changeWindow";
		public static const TOC_SEARCH:String = "tocSearch";
				
		//--------------------------------------------------------------------------
	    //
	    //  Constructor
	    //
	    //--------------------------------------------------------------------------	
	    
		public function TemplateEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:Object=null) {
			if (data != null) _data = data;
			super(type, bubbles, cancelable);
		}
		 
			
	    //--------------------------------------------------------------------------
	    //
	    //  Properties
	    //
	    //--------------------------------------------------------------------------
	    
	    private var _data:Object;
	
	    //The data will be passed via the event. It allows even dispatcher publishes
	    //data to event listener(s).
		public function get data() : Object {
			return _data;
		} 

		public function set data(data:Object) : void {
			_data = data;
		}
		
	}
}