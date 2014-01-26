package manipulatables;
import dialogue.Bla;
import kha.Loader;
import manipulatables.UseableSprite;

import kha.Image;
import kha.Sprite;
import manipulatables.ManipulatableSprite.OrderType;

// Direktor
class Director extends Sprite implements ManipulatableSprite
{

	public function new(px : Int, py : Int, name : String = null, image:Image = null, w: Int = 0, h: Int = 0) 
	{
		if (image == null) image = Loader.the.getImage("pizza_pixel");
		super(image, w, h);
		x = px;
		y = py;
		if (name == null) {
			this.name = "Director";
		} else {
			this.name = name;
		}
	}
	
	/* INTERFACE manipulatables.ManipulatableSprite */
	
	function get_name():String 
	{
		return name;
	}
	
	public var name(get_name, null):String;
	
	public function getOrder(selectedItem:UseableSprite):OrderType 
	{
		if (selectedItem == null) {
			return OrderType.ToolTip;
		} else if (Std.is(selectedItem, Injection)) {
			return OrderType.Apply;
		} else if (Std.is(selectedItem, Sword)) {
			return OrderType.Slay;
		} else if (Std.is(selectedItem, Pizza)) {
			return OrderType.Eat;
		} else {
			return OrderType.WontWork;
		}
	}
	
	public function executeOrder(order:OrderType):Void 
	{
		switch (order) {
			case Eat:
				Inventory.loose(Inventory.getSelectedItem());
				Dialogue.set([new Bla("L2A_Drake_Groah",this)]);
			case Slay:
				// TODO: Slay Dragon
			default:
				// Nothing todo yet.
		}
	}
	
}