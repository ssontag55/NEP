package solutions.components.coordinates
{

import com.esri.ags.geometry.MapPoint;
import com.esri.ags.symbols.Symbol;

import flash.events.EventDispatcher;

[Bindable]
[RemoteClass(alias="widgets.Locate.LocateResult")]

public class LocateResult extends EventDispatcher
{
    public var title:String;

    public var symbol:Symbol;

    public var content:String;

    public var point:MapPoint;

    public var link:String;

    public var selected:Boolean;
}

}
