package solutions.components.external.toc.tocClasses
{

	import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
	import com.esri.ags.layers.Layer;
	import solutions.components.external.toc.controls.CheckBoxScaleDependant;
	import solutions.components.external.toc.layerAlpha;
	import solutions.SiteContainer;
	import solutions.TemplateEvent;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	import flashx.textLayout.accessibility.TextAccImpl;
	import mx.rpc.events.FaultEvent;
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import mx.containers.TabNavigator;
	import mx.containers.TitleWindow;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.controls.TextArea;
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.controls.treeClasses.TreeListData;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import com.esri.ags.utils.JSONUtil;
	import mx.core.FlexGlobals;
	
	import spark.components.HSlider;
	
	/**
	 * A custom tree item renderer for a map Table of Contents.
	 */
	public class TocItemRenderer extends TreeItemRenderer
	{
	    // Renderer UI components
		private var _checkbox:CheckBoxScaleDependant;
		
		private var _btn:Image;
		
		private var _layAlpha:layerAlpha;
	
	    // UI component spacing
	    private static const PRE_CHECKBOX_GAP:Number = 2;
	
	    private static const POST_CHECKBOX_GAP:Number = 6;
		
		[Embed(source="assets/icons/alpha.png")]
		[Bindable]
		private var _Icon:Class;
		
		
		private function showAlpha(evt:Event):void
		{
			if (data is TocItem) {
				var item:TocItem = TocItem(data);
				//var lay:Layer = FlexGlobals.topLevelApplication.mainMap.getLayer(item.label);
				_layAlpha.layer = item.layer;
				_layAlpha.visible = true;
				_layAlpha.includeInLayout = true;
				label.visible = true;
			}
		}
		
		private function sldrDataTipFormatter(value:Number):String 
		{ 
			return int(value * 100) + "%"; 
		}
	
	    /**
	     * @private
	     */
	    override protected function createChildren():void
	    {
	        super.createChildren();
	
	        // Create a checkbox child component for toggling layer visibility.
	        if (!_checkbox)
	        {
	            _checkbox = new CheckBoxScaleDependant();
	            _checkbox.addEventListener(MouseEvent.CLICK, onCheckBoxClick);
	            _checkbox.addEventListener(MouseEvent.DOUBLE_CLICK, onCheckBoxDoubleClick);
	            _checkbox.addEventListener(MouseEvent.MOUSE_DOWN, onCheckBoxMouseDown);
	            _checkbox.addEventListener(MouseEvent.MOUSE_UP, onCheckBoxMouseUp);
	            addChild(_checkbox);
	        }
			if (!_btn)
			{
				_btn = new Image();
				_btn.id = "btnAlpha"
				_btn.toolTip = "Set Map Layer Transparency";
				_btn.width = 20;
				_btn.height = 20;
				_btn.alpha = 0.6;
				_btn.buttonMode = true;
				_btn.useHandCursor = true;
				_btn.source = _Icon;
				_btn.visible = false;
				_btn.includeInLayout = false;
				addChild(_btn);
				_btn.addEventListener(MouseEvent.CLICK, showAlpha);
			}
			
			if(!_layAlpha)
			{
				_layAlpha = new layerAlpha();
				_layAlpha.visible = false;
				_layAlpha.includeInLayout = false;
				label.visible = true;
				addChild(_layAlpha);
			}
			SiteContainer.addEventListener(TemplateEvent.CLEAR_LAYERS, clearAllL);
	    }
	
		protected function clearAllL(event:TemplateEvent):void
		{
			_checkbox.selected = false;
			
			if (data is TocItem)
			{
				var item:TocItem = TocItem(data);
				item.visible = false;
			}
		}
		
	    /**
	     * @private
	     */
	    override protected function commitProperties():void
	    {
	        super.commitProperties();
	
	        if (data is TocItem)
	        {
	            var item:TocItem = TocItem(data);
	
				// Hide the checkbox for child items of tiled map services
				var checkboxVisible:Boolean = true;
				_checkbox.selected = item.visible;
				_checkbox.scaledependant = item.scaledependant;
				
				//For tidal data in the TOC
				if(item.label == "Full Tidal Output")
				{
					_checkbox.visible = checkboxVisible;
					_btn.visible = true;
					_btn.includeInLayout = true;
					setStyle("fontWeight", "bold");
				}
				else{
					if (item.isTopLevel())
					{
						setStyle("fontWeight", "bold");
						_btn.visible = true;
						_btn.includeInLayout = true;
						_checkbox.visible = false;
					}
					if(item.parent)
					{
						_btn.visible = false;
						_btn.includeInLayout = false;
						_checkbox.visible = false;
					}
					if (item.isGroupLayer())
					{
					}
					else
					{
						_checkbox.visible = checkboxVisible;
						setStyle("fontWeight", "normal");
						_btn.visible = false;
						_btn.includeInLayout = false;
						_layAlpha.visible = false;
						_layAlpha.includeInLayout = false;
					}
				}
	        }
	    }
	
	    /**
	     * @private
	     */
	    override protected function measure():void
	    {
	        super.measure();
	
	        // Add space for the checkbox and gaps
	        if (isNaN(explicitWidth) && !isNaN(measuredWidth))
	        {
	            var w:Number = measuredWidth;
	            w += _checkbox.measuredWidth;
	            w += PRE_CHECKBOX_GAP + POST_CHECKBOX_GAP;
	            measuredWidth = w;
	        }
	    }
	
	    /**
	     * @private
	     */
	    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	    {
	        super.updateDisplayList(unscaledWidth, unscaledHeight);
	
	        var startx:Number = data ? TreeListData(listData).indent : 0;
	        if (icon)
	        {
	            startx = icon.x;
	        }
	        else if (disclosureIcon)
	        {
	            startx = disclosureIcon.x + disclosureIcon.width;
	        }
	        startx += PRE_CHECKBOX_GAP;
	
	        // Position the checkbox between the disclosure icon and the item icon
			if(_checkbox.visible == true)
			{
				_checkbox.x = startx;
				_checkbox.setActualSize(_checkbox.measuredWidth, _checkbox.measuredHeight);
				_checkbox.y = (unscaledHeight - _checkbox.height) / 2;
				startx = _checkbox.x + _checkbox.width + POST_CHECKBOX_GAP;
			}
			else
			{
				_checkbox.x = startx;
				_checkbox.setActualSize(0, _checkbox.measuredHeight);
				_checkbox.y = (unscaledHeight - _checkbox.height) / 2;
				startx = _checkbox.x + _checkbox.width + POST_CHECKBOX_GAP;
			}
			
			_layAlpha.y = (unscaledHeight - _layAlpha.height) / 2;
			if(_layAlpha.visible == false)
				label.visible = true;
			_btn.y = (unscaledHeight - _btn.height) / 2;
			
			if (icon)
			{
				icon.x = startx;
				startx = icon.x + icon.width;
			}
			
			label.x = startx;
			//_layAlpha.x = label.x - 8;
			_layAlpha.x = label.x + label.width - 98;
			label.setActualSize(unscaledWidth - startx, measuredHeight);
			_btn.x = label.x + label.width - 20;
	    }
	
	    /**
	     * Updates the visible property of the underlying TOC item.
	     */
	    private function onCheckBoxClick(event:MouseEvent):void
	    {
	        event.stopPropagation();
	
			if (data is TocItem)
			{
				var item:TocItem = TocItem(data);
				item.visible = _checkbox.selected;
				
				if(item.parent)
				{
					var vis:Boolean = false;
					for each (var item2:TocItem in item.parent.children)
					{
						if(item2.visible)
						{
							vis = true;
							item.parent.visible = true;
						}
					}					
					
					if(item.parent.parent)
					{
						var vis2:Boolean = false;
						for each (var item3:TocItem in item.parent.parent.children)
						{
							if(item3.visible)
							{
								vis2 = true;
							}
						}
						item.parent.parent.visible = vis2;
						
						if(item.parent.parent.parent)
						{
							var vis3:Boolean = false;
							for each (var item4:TocItem in item.parent.parent.parent.children)
							{
								if(item4.visible)
								{
									vis3 = true;
								}
							}
							item.parent.parent.parent.visible = vis3;
							
							if(item.parent.parent.parent.parent)
							{
								var vis4:Boolean = false;
								for each (var item5:TocItem in item.parent.parent.parent.parent.children)
								{
									if(item5.visible)
									{
										vis4 = true;
									}
								}
								item.parent.parent.parent.parent.visible = vis4;
							}
						}
					}
					else
					{
						
					}
				}
					
				/*else{
					for each (var item10:TocItem in item.children)
					{
						item10.visible = item.visible;
					}
				}*/
			}
	    }
	
	    private function onCheckBoxDoubleClick(event:MouseEvent):void
	    {
	        event.stopPropagation();
	    }
	
	    private function onCheckBoxMouseDown(event:MouseEvent):void
	    {
	        event.stopPropagation();
	    }
	
	    private function onCheckBoxMouseUp(event:MouseEvent):void
	    {
	        event.stopPropagation();
	    }
	}
}