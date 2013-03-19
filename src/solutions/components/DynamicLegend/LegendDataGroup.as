package solutions.components.DynamicLegend
{
	import mx.core.ClassFactory;
	
	import spark.components.DataGroup;
	
	public class LegendDataGroup extends DataGroup
	{
	    public function LegendDataGroup()
	    {
	        super();
	        this.itemRenderer = new ClassFactory(LegendItemRenderer);
	    }
	}
}