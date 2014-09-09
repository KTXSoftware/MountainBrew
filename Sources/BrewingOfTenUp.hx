package;

import AdventureCursor;
import kha.Framebuffer;
import kha.graphics2.Graphics;
import kha.Image;
import kha.math.Matrix3;
import kha.Scaler;
import manipulatables.Door;
import manipulatables.ManipulatableSprite;
import manipulatables.Pizza;
import manipulatables.UseableSprite;
import kha.Button;
import kha.Color;
import kha.Cursor;
import kha.Font;
import kha.FontStyle;
import kha.Game;
import kha.HighscoreList;
import kha.ImageCursor;
import kha.Key;
import kha.Loader;
import kha.LoadingScreen;
import kha.Music;
import kha.Scene;
import kha.Score;
import kha.Configuration;
import kha.Storage;
import kha.Tile;
import kha.Tilemap;

enum Mode {
	Init;
	Game;
	BlaBlaBla;
}

class BrewingOfTenUp extends Game {
	static var instance : BrewingOfTenUp;
	private var backbuffer: Image;
	var highscoreName : String;
	var shiftPressed : Bool;
	private var font: Font;
	public var mode : Mode;
	
	public function new() {
		super("Brewing", false);
		instance = this;
		shiftPressed = false;
		highscoreName = "";
		mode = Mode.Init;
	}
	
	public static function getInstance() : BrewingOfTenUp {
		return instance;
	}
	
	public override function init(): Void {
		backbuffer = Image.createRenderTarget(800, 600);
		Level.load("level1", initLevel);
	}

	public function initLevel(): Void {
		font = Loader.the.loadFont("Liberation Sans", new FontStyle(false, false, false), 14);
		startGame();
	}
	
	public function startGame() {
		//getHighscores().load(Storage.defaultFile());
		
		Inventory.init();
		Jumpman.getInstance().reset();
		Scene.the.addHero(Jumpman.getInstance());
		
		adventureCursor = new AdventureCursor();
		kha.Sys.mouse.pushCursor(adventureCursor);
		
		//Dialogue.set(["Hallo", "Holla"], [Jumpman.getInstance(), Jumpman.getInstance()]);
	}
	
	public override function update() {
		switch (mode) {
			case Mode.Game:
				currentOrder.update();
				super.update();
				Scene.the.camx = Std.int(Jumpman.getInstance().x) + Std.int(Jumpman.getInstance().width / 2);
			case Mode.BlaBlaBla:
				super.update();
				Dialogue.update();
				Scene.the.camx = Std.int(Jumpman.getInstance().x) + Std.int(Jumpman.getInstance().width / 2);
			case Mode.Init:
				super.update();
		}
	}
	
	public override function render(frame: Framebuffer) {
		if (Jumpman.getInstance() == null) return;
		
		var g = backbuffer.g2;
		g.begin();
		g.font = font;
		switch (mode) {
		case Init:
				// Nothing todo yet.
		case Game, BlaBlaBla:
			scene.render(g);
			g.transformation = Matrix3.identity();
			BlaBox.render(g);
			Inventory.paint(g);
			//break;
		}
		kha.Sys.mouse.render(g);
		g.end();
		
		startRender(frame);
		Scaler.scale(backbuffer, frame, kha.Sys.screenRotation);
		endRender(frame);
	}

	override public function buttonDown(button : Button) : Void {
		switch (mode) {
		case Game:
			switch (button) {
			case UP, BUTTON_1, BUTTON_2:
				Jumpman.getInstance().setUp();
			case LEFT:
				Jumpman.getInstance().left = true;
			case RIGHT:
				Jumpman.getInstance().right = true;
			default:
			}
		default:
		}
	}
	
	override public function buttonUp(button : Button) : Void {
		switch (mode) {
		case Game:
			switch (button) {
			case UP, BUTTON_1, BUTTON_2:
				Jumpman.getInstance().up = false;
			case LEFT:
				Jumpman.getInstance().left = false;
			case RIGHT:
				Jumpman.getInstance().right = false;
			default:
			}	
		default:
		}
	}
	
	override public function keyDown(key: Key, char: String) : Void {
		if (key == Key.CHAR) {

		}
		else {
			if (key == SHIFT) shiftPressed = true;
		}
	}
	
	override public function keyUp(key : Key, char : String) : Void {
		if (key != null && key == Key.SHIFT) shiftPressed = false;
	}
	
	public var adventureCursor(default, null) : AdventureCursor;
	public var currentOrder(default, null) : MouseOrder = new MouseOrder();
	
	override public function mouseUp(x:Int, y:Int) : Void {
		switch (mode) {
		case Mode.Game:
			currentOrder.cancel();
			currentOrder.type = adventureCursor.hoveredType;
			currentOrder.x = x + scene.screenOffsetX;
			currentOrder.y = y + scene.screenOffsetY;
			currentOrder.object = adventureCursor.hoveredObject;
		case Mode.BlaBlaBla:
			Dialogue.next();
		default:
		}
	}
	
	override public function rightMouseDown(x:Int, y:Int) : Void {
		switch (mode) {
		case Mode.Game:
			Jumpman.getInstance().setUp();
		default:
		}
	}
	override public function rightMouseUp(x:Int, y:Int) : Void {
		switch (mode) {
		case Mode.Game:
			Jumpman.getInstance().up = false;
		default:
		}
	}
}

class MouseOrder {
	public function new() { }
	public var type : OrderType = Nothing;
	public var x : Int = 0;
	public var y : Int = 0;
	public var object : ManipulatableSprite = null;
	
	public function cancel() : Void {
		var jmpMan = Jumpman.getInstance();
		jmpMan.left = false;
		jmpMan.right = false;
	}
	private function moveTo() : Bool {
		var jmpMan = Jumpman.getInstance();
		if (x < jmpMan.x + 0.3 * jmpMan.width) {
			jmpMan.left = true;
			jmpMan.right = false;
		} else if (jmpMan.x + 0.7 * jmpMan.width < x) {
			jmpMan.left = false;
			jmpMan.right = true;
		} else {
			jmpMan.left = false;
			jmpMan.right = false;
			return false;
		}
		return true;
	}
	public function update() {
		switch(type) {
		case Nothing, ToolTip:
			// Nothing to do
			return;
		case WontWork:
			// TODO: say something
		case MoveTo:
			if (!moveTo()) {
				type = Nothing;
			}
			return;
		case Take, Eat, Enter, Slay, Extinguish, Apply:
			if (moveTo()) {
				return;
			}
		case InventoryItem, Bla:
		}
		object.executeOrder(type);
		type = Nothing;
	}
}
