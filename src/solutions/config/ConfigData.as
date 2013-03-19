////////////////////////////////////////////////////////////////////////////////
//
// Copyright © 2008 - 2009 ESRI
//
// All rights reserved under the copyright laws of the United States.
// You may freely redistribute and use this software, with or
// without modification, provided you include the original copyright
// and use restrictions.  See use restrictions in the file:
// <install location>/FlexViewer/License.txt
//
////////////////////////////////////////////////////////////////////////////////

package solutions.config {
	
	import mx.collections.ArrayCollection;
	
	/**
	 * ConfigData class is used to store configuration information from the config.xml file.
	 */
	public class ConfigData {
		 
		public var configSearchOpts:Array;  
		public var configExtents:Array;
		public var configLocation:String;
		public var configLOD:String;
		public var configwraparound180:Boolean;
		public var configBasemaps:Array;//for menu
		public var configRefmaps:Array;//for menu
		public var configMap:Array;//actual map services
		public var configGraphic:Array;//graphic layer map services
		public var configLinks:Array; //links
		 
		
		public function ConfigData() { 
			configLocation="";
			configLOD="";
			configwraparound180=false;
            configExtents = []; 
            configBasemaps = []; 
            configRefmaps = []; 
            configMap = [];
            configGraphic = [];        
		}

	}
}