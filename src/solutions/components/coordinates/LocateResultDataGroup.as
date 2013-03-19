package solutions.components.coordinates
{

import mx.core.ClassFactory;

import spark.components.DataGroup;

// these events bubble up from the LocateResultItemRenderer
[Event(name="locateResultClick", type="flash.events.Event")]
[Event(name="locateResultDelete", type="flash.events.Event")]

public class LocateResultDataGroup extends DataGroup
{
    public function LocateResultDataGroup()
    {
        super();

        this.itemRenderer = new ClassFactory(LocateResultItemRenderer);
    }
}

}
