package solutions
{
	import com.esri.ags.components.Navigation;
	
	import flash.events.MouseEvent;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;
	
	
	
	public class TemplateNavigationEvent extends com.esri.ags.components.Navigation
    {
        public function TemplateNavigationEvent()
        {
			//addEventListener(MouseEvent.ROLL_OVER, expandBaseMapOptions);
        }
		public function expandBaseMapOptions(event:MouseEvent):void
		{
			FlexGlobals.topLevelApplication.myZoomSlider.currentState = "expandMapOptions";
		}
	}
}