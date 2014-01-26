package;

import kha.AnimatedImageCursor;
import kha.Animation;
import kha.Color;
import kha.Cursor;
import kha.Font;
import kha.FontStyle;
import kha.ImageCursor;
import kha.Loader;
import kha.Painter;
import kha.Scene;
import kha.Sprite;
import manipulatables.ManipulatableSprite;
import manipulatables.UseableSprite;

class AdventureCursor implements Cursor {
	private var font: Font;
	private var toolTip : String;
	private var toolTipY : Int;
	
	public var width(get,never): Int;
	public var height(get, never): Int;
	public var clickX(get,never): Int;
	public var clickY(get, never): Int;
	
	private function get_clickX() : Int {
		if (currentCursor != null)
			return currentCursor.clickX;
		else
			return 3;
	}
	private function get_clickY() : Int {
		if (currentCursor != null)
			return currentCursor.clickY;
		else
			return 3;
	}
	private function get_width() : Int {
		if (currentCursor != null)
			return currentCursor.width;
		else
			return 16;
	}
	private function get_height() : Int {
		if (currentCursor != null)
			return currentCursor.height;
		else
			return 16;
	}
	
	var currentCursor : Cursor;
	var cursors : Map<OrderType, Cursor> = new Map();
	
	public var hoveredType : OrderType = Nothing;
	public var hoveredObject : ManipulatableSprite = null;
	
	public var forcedTooltip : String = null;
	
	public function new() {
		cursors[MoveTo] = new AnimatedImageCursor(Loader.the.getImage("gumba"), Std.int(96 / 3), 32, new Animation([0, 2], 14), 16, 16);
		cursors[Take] = new ImageCursor(Loader.the.getImage("handcursor"), 6, 9);
		cursors[InventoryItem] = new ImageCursor(Loader.the.getImage("handcursor"), 6, 9);
		cursors[WontWork] = new ImageCursor(Loader.the.getImage("pizza_pixel"), 5, 5); // TODO: cursor
		cursors[Eat] = new ImageCursor(Loader.the.getImage("pizza_pixel"), 15, 15); // TODO: cursor
		cursors[Enter] = new AnimatedImageCursor(Loader.the.getImage("gumba"), Std.int(96 / 3), 32, new Animation([0, 2], 14), 16, 16); // TODO: cursor
		currentCursor = null;
		kha.Sys.mouse.forceSystemCursor(true);
		font = Loader.the.loadFont("Liberation Sans", new FontStyle(false, false, false), 14);
	}
	
	public function render(painter: Painter, x: Int, y: Int): Void {
		if (currentCursor != null) {
			currentCursor.render(painter, x, y);
			
			if (forcedTooltip != null) {
				drawTooltip(painter, forcedTooltip, x, toolTipY);
			} else if (toolTip != null) {
				drawTooltip(painter, toolTip, x, toolTipY);
			}
		}
	}
	
	private function drawTooltip(painter: Painter, tip: String, x: Int, y: Int): Void {
		painter.setColor(Color.fromBytes(0, 0, 0));
		painter.fillRect(x - 2, y - 2, font.stringWidth(tip) + 4, font.getHeight() + 4);
		painter.setColor(Color.fromBytes(255, 255, 255));
		painter.drawString(tip, x, y);
	}
	
	public function update(x : Int, y : Int) {
		var toolTipTop : Bool = false;
		hoveredType = OrderType.Nothing;
		hoveredObject = Inventory.getItemBelowPoint(x, y);
		var jmpMan = Jumpman.getInstance();
		if (hoveredObject != null) {
			toolTipTop = true;
			toolTip = hoveredObject.name;
			hoveredType = OrderType.InventoryItem;
		} else if (y >= Inventory.y) {
			toolTipTop = true;
			toolTip = null;
		} else {
			var worldX = x + Scene.the.screenOffsetX;
			var worldY = y + Scene.the.screenOffsetY;
			for (obj in Scene.the.getSpritesBelowPoint(worldX, worldY)) {
				if (Std.is(obj, ManipulatableSprite)) {
					hoveredObject = cast obj;
					hoveredType = hoveredObject.getOrder(Inventory.getSelectedItem());
					if (hoveredType == OrderType.Nothing) {
						hoveredObject = null;
						toolTip = null;
					} else {
						if (Inventory.getSelectedItem() != null) {
							toolTip = Inventory.getSelectedItem().name + " " + hoveredType + " " + hoveredObject.name;
						} else {
							toolTip = hoveredType + " " + hoveredObject.name;
						}
					}
					break;
				}
			}
			if (hoveredObject == null) {
				if (worldX < jmpMan.x || jmpMan.x + jmpMan.width < worldX) {
					hoveredType = OrderType.MoveTo;
				}
			}
		}
		
		if (cursors.exists(hoveredType)) {
			currentCursor = cursors[hoveredType];
			kha.Sys.mouse.forceSystemCursor(false);
			currentCursor.update(x, y);
		} else {
			kha.Sys.mouse.forceSystemCursor(true);
			currentCursor = null;
		}
		if (toolTipTop) {
			toolTipY = y - clickY - 16;
		} else {
			toolTipY = y - clickY + height;
		}
	}
}
