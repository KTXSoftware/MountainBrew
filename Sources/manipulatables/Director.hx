package manipulatables;

import kha.Assets;
import dialogue.Action;
import dialogue.ActionWithBla;
import dialogue.Bla;
import manipulatables.UseableSprite;
import kha.Image;
import kha2d.Sprite;
import manipulatables.ManipulatableSprite.OrderType;

// Direktor
class Director extends Sprite implements ManipulatableSprite
{
	static public var the;
	public function new(px : Int, py : Int, name : String = null, image:Image = null, w: Int = 0, h: Int = 0) 
	{
		py -= 40;
		if (image == null) {
			image = Assets.images.boss;
			w = Std.int(192 * 2 / 6);
			h = 64 * 2;
		}
		super(image, w, h);
		x = px;
		y = py;
		if (name == null) {
			this.name = "Director";
		} else {
			this.name = name;
		}
		the = this;
	}
	
	public var slayed = false;
	
	/* INTERFACE manipulatables.ManipulatableSprite */
	
	function get_name():String 
	{
		return name;
	}
	
	public var name(get_name, null):String;
	
	public function getOrder(selectedItem:UseableSprite):OrderType 
	{
		if (selectedItem == null || slayed) {
			return OrderType.Bla;
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
		var jmpMan = Jumpman.getInstance();
		switch (order) {
			case Eat:
				Inventory.loose(Inventory.getSelectedItem());
				Dialogue.set([new Bla("L2A_Drake_Groah",this)]);
			case Slay:
				Dialogue.set([new ActionWithBla(new Bla("L2A_Drake_a", jmpMan), [this], ActionType.Slay),
							  new Bla("L2A_Drake_b", GuyWithExtinguisher.the),
							  new Action([GuyWithExtinguisher.the], ActionType.Run)]);
			case OrderType.Apply:
				Dialogue.set([new ActionWithBla(new Bla("L2B_Wounded_3", jmpMan), [this], ActionType.Slay)]);
			case Bla:
				if (jmpMan.hasHelmet) {
					if (slayed) {
						Dialogue.set([new Bla("L2A_Drake_NoSword_a", jmpMan),
									  new Bla("L2A_Drake_Groah", this),
									  new Bla("L2A_Drake_NoSword_b", jmpMan)]);
					} else {
						Dialogue.set([new Bla("L2A_Drake_NoSword_a", jmpMan),
									  new Bla("L2A_Drake_Groah", this),
									  new Bla("L2A_Drake_NoSword_b", jmpMan)]);
					}
				} else {
					if (slayed) {
						Dialogue.set([new Bla("L2B_Wounded_4", jmpMan)]);
					} else {
						Dialogue.set([new Bla("L2B_Wounded_2", jmpMan)]);
					}
				}
			default:
				// Nothing todo yet.
		}
	}
}
