package solutions.components.external.toc.tocClasses
{

	import com.esri.ags.events.LayerEvent;
	import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
	import com.esri.ags.layers.supportClasses.LayerDetails;
	import com.esri.ags.layers.Layer;
	import com.esri.ags.layers.supportClasses.LayerInfo;
	import solutions.components.external.toc.utils.MapUtil;
	
	import mx.rpc.AsyncResponder;
	import mx.collections.ArrayList;
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	/**
	 * A TOC item representing a map service or graphics layer.
	 */
	public class TocMapLayerItem extends TocItem
	{
	    private var _isMSOnly:Boolean = false;
	
	    public function TocMapLayerItem(layer:Layer, labelFunction:Function = null, isMapServiceOnly:Boolean = false)
	    {
	        super();
	
	        _layer = layer;
	        _isMSOnly = isMapServiceOnly;
	        // Set the initial visibility without causing a layer refresh
	        setVisible(layer.visible, false);
	
	        if (labelFunction == null)
	        {
	            // Default label function
	            labelFunction = MapUtil.labelLayer;
	        }
	        _labelFunction = labelFunction;
	        label = labelFunction(layer);
	
	        if (!isMapServiceOnly)
	        {
	            if (layer.loaded)
	            {
	                // Process the layer info immediately
	                createChildren();
	            }
	        }
	
	        // Listen for future layer load events
	        layer.addEventListener(LayerEvent.LOAD, onLayerLoad, false, 0, true);
	
	        // Listen for changes in layer visibility
	        layer.addEventListener(FlexEvent.SHOW, onLayerShow, false, 0, true);
	        layer.addEventListener(FlexEvent.HIDE, onLayerHide, false, 0, true);
	    }
	
	    private var _layer:Layer;
	
	    private var _labelFunction:Function;
	
	    //--------------------------------------------------------------------------
	    //  Property:  mapLayer
	    //--------------------------------------------------------------------------
	
	    /**
	     * The map layer to which this TOC item is attached.
	     */
	    public function get layer():Layer
	    {
	        return _layer;
	    }
	
		/**
		 * @private
		 */
		override internal function updateScaleDependantState( calledFromChild:Boolean = false ):void
		{
			scaledependant = DEFAULT_SCALEDEPENDANT;
			
			// Recurse up the tree
			if (parent) {
				parent.updateScaleDependantState(true);
			}
		}
	
	    /**
	     * @private
	     */
	    override internal function refreshLayer():void
	    {
	        layer.visible = visible;
	
	        // ArcIMS requires layer names, whereas ArcGIS Server requires layer IDs
	        //var useLayerInfoName:Boolean = (layer is ArcIMSMapServiceLayer);
			var useLayerInfoName:Boolean = false;
	        var visLayers:Array = [];
	        for each (var child:TocItem in children)
	        {
	            accumVisibleLayers(child, visLayers, useLayerInfoName);
	        }
	
	        if (layer is ArcGISDynamicMapServiceLayer)
	        {
	            ArcGISDynamicMapServiceLayer(layer).visibleLayers = new ArrayCollection(visLayers);
	        }
	    }
	
	    private function accumVisibleLayers(item:TocItem, accum:Array, useLayerInfoName:Boolean = false):void
	    {
	        if (item.isGroupLayer())
	        {
	            // Don't include group layer IDs/names in the visible layer list, since the ArcGIS REST API
	            // implicitly turns on all child layers when the group layer is visible. This goes
	            // counter to what most users have come to expect from apps, e.g. ArcMap.
	            for each (var child:TocItem in item.children)
	            {
	                accumVisibleLayers(child, accum, useLayerInfoName);
	            }
	        }
	        else
	        { // Leaf layer
	            if (item.visible)
	            {
	                if (item is TocLayerInfoItem)
	                {
	                    var layer:TocLayerInfoItem = TocLayerInfoItem(item);
	                    accum.push(useLayerInfoName ? layer.layerInfo.name : layer.layerInfo.layerId);
	                }
	            }
	        }
	    }
	
	    private function onLayerLoad(event:LayerEvent):void
	    {
	        // Relabel this item, since map layer URL or service name might have changed.
	        label = _labelFunction(layer);
	        if (!_isMSOnly)
	        {
	            createChildren();
	        }
	    }
	
	    private function onLayerShow(event:FlexEvent):void
	    {
	        setVisible(layer.visible, true);
	    }
	
	    private function onLayerHide(event:FlexEvent):void
	    {
	        setVisible(layer.visible, true);
	    }
	
	    /**
	     * Populates this item's children collection based on any layer info
	     * of the map service.
	     */
	    private function createChildren():void
	    {
	        children = null;
	        var layerInfos:Array; // of LayerInfo
	        var visibleLayers:Array;
			
			if (layer is ArcGISDynamicMapServiceLayer)
	        {
	            layerInfos = ArcGISDynamicMapServiceLayer(layer).layerInfos;
	            if (ArcGISDynamicMapServiceLayer(layer).visibleLayers)
	            {
	                visibleLayers = ArcGISDynamicMapServiceLayer(layer).visibleLayers.toArray();
	            }
	        }
	        if (layerInfos)
	        {
	            var rootLayers:Array = findRootLayers(layerInfos);
	            for each (var layerInfo:LayerInfo in rootLayers)
	            {
	                addChild(createTocLayer(this, layerInfo, layerInfos, visibleLayers, layer));
	            }
	        }
	    }
	
	    private static function findRootLayers(layerInfos:Array):Array // of LayerInfo
	    {
	        var roots:Array = [];
	        for each (var layerInfo:LayerInfo in layerInfos)
	        {
	            // ArcGIS: parentLayerId is -1
	            // ArcIMS: parentLayerId is NaN
	            if (isNaN(layerInfo.parentLayerId) || layerInfo.parentLayerId == -1)
	            {
	                roots.push(layerInfo);
	            }
	        }
	        return roots;
	    }
	
	    private static function findLayerById(id:Number, layerInfos:Array):LayerInfo
	    {
	        for each (var layerInfo:LayerInfo in layerInfos)
	        {
	            if (id == layerInfo.layerId)
	            {
	                return layerInfo;
	            }
	        }
	        return null;
	    }
	
	    private static function createTocLayer(parentItem:TocItem, layerInfo:LayerInfo, layerInfos:Array, visibleLayers:Array, tlayer:Layer):TocLayerInfoItem
	    {
	        var item:TocLayerInfoItem = new TocLayerInfoItem(parentItem, layerInfo, visibleLayers);
			
			if (tlayer is ArcGISDynamicMapServiceLayer) {
				ArcGISDynamicMapServiceLayer(tlayer).getDetails(layerInfo.layerId, new AsyncResponder(
					function myResultFunction(result:LayerDetails, token:Object = null):void
					{
						item.minScale = result.minScale
						item.maxScale = result.maxScale
					},
					function myFaultFunction(error:Object, token:Object = null):void
					{
						//do nothing
					}
				));
			}
	
	        // Handle any sublayers of a group layer
	        if (layerInfo.subLayerIds)
	        {
	            for each (var childId:Number in layerInfo.subLayerIds)
	            {
	                var childLayer:LayerInfo = findLayerById(childId, layerInfos);
	                if (childLayer)
	                {
	                    item.addChild(createTocLayer(item, childLayer, layerInfos, visibleLayers, tlayer));
	                }
	            }
	        }
	        return item;
	    }
	}
}
