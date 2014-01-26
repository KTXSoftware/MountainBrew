package;

import kha.Image;
import kha.Loader;
import kha.Scene;
import kha.Sound;
import kha.Sprite;

class Coin extends Sprite {
	private static var theimage : Image;
	static var initialized = false;
	
	static function init() {
		if (!initialized) {
			theimage = Loader.the.getImage("coin");
			initialized = true;
		}
	}
	
	public function new(x : Int, y : Int) {
		init();
		super(Coin.theimage, 28, 32, 0);
		this.x = x;
		this.y = y;
		accy = 0;
	}
	
	public override function hit(sprite : Sprite) {
		Scene.the.removeEnemy(this);
		Jumpman.getInstance().selectCoin();
	}
}