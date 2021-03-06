package dialogue;

import Dialogue.DialogueItem;
import manipulatables.Director;
import manipulatables.GuyWithExtinguisher;
import manipulatables.ManipulatableSprite;

enum ActionType {
	Sleep;
	WakeUp;
	Slay;
	Run;
}

class Action implements DialogueItem {
	var autoAdvance : Bool = true;
	var started : Bool = false;
	var sprites : Array<ManipulatableSprite>;
	var type : ActionType;
	var counter : Int = 0;
	public var finished(default, null) : Bool = false;
	public function new(sprites: Array<ManipulatableSprite>, type: ActionType) {
		this.sprites = sprites;
		this.type = type;
	}
	
	@:access(Dialogue.isActionActive) 
	public function execute() : Void {
		if (!started) {
			started = true;
			counter = 0;
			switch(type) {
				case ActionType.Sleep:
					for (sprite in sprites) {
						try {
							untyped sprite.sleep();
						} catch (e : Dynamic){ }
					}
				case ActionType.WakeUp:
					for (sprite in sprites) {
						try {
							untyped sprite.unsleep();
						} catch (e : Dynamic){ }
					}
				case ActionType.Slay:
					// Nothing here?
				case ActionType.Run:
					GuyWithExtinguisher.the.right = true;
			}
			return;
		} else {
			switch(type) {
			case ActionType.Sleep:
				++counter;
				if (counter < 100) {
					return;
				}
			case ActionType.WakeUp:
				// Nothing todo here.
			case ActionType.Slay:
				Director.the.slayed = true; // TODO
			case ActionType.Run:
				// TODO:
			}
		}
		actionFinished();
	}
	
	@:access(Dialogue.isActionActive) 
	function actionFinished() {
		finished = true;
		if (autoAdvance) {
			Dialogue.next();
		}
	}
}
