package solutions.components.external.toc.controls
{
	import flash.events.Event;
	
	import mx.controls.CheckBox;
	import solutions.SiteContainer;
	import solutions.TemplateEvent;
	
	/**
	 * CheckBox that supports a tri-state check. In addition to selected and
	 * unselected, the CheckBox can be in an scale depandant state.
	 */
	public class CheckBoxScaleDependant extends CheckBox
	{
		/**
		 * Creates a new tri-state CheckBox with custom skin.
		 */
		public function CheckBoxScaleDependant()
		{
			setStyle("icon", CheckBoxScaleDependantIcon);
			setStyle("checked", this.selected);
			setStyle("scaledependant", _scaledependant);
			
			SiteContainer.addEventListener(TemplateEvent.CLEAR_LAYERS, clearAllL);
		}
		
		//--------------------------------------------------------------------------
		//  Property:  scaledependant
		//--------------------------------------------------------------------------
		
		protected function clearAllL(event:TemplateEvent):void
		{
			this.selected = false;
		}
		private var _scaledependant:Boolean = false;
		
		[Bindable("scaledependantChanged")]
		/**
		 * Whether this check box is in the scaledependant state.
		 */
		public function get scaledependant():Boolean
		{
			return _scaledependant;
		}
		/**
		 * @private
		 */
		public function set scaledependant( value:Boolean ):void
		{
			if (value != _scaledependant) {
				_scaledependant = value;
				setStyle("checked", this.selected);
				setStyle("scaledependant", _scaledependant);
				dispatchEvent(new Event("scaledependantChanged"));
			}
		}
	}
}