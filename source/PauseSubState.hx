package;

import sys.FileSystem;
import flixel.FlxBasic;
import openfl.geom.Point;
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.FlxStringUtil;
import flixel.math.FlxRect;
using flixel.util.FlxSpriteUtil;

using StringTools;
class PauseSubState extends MusicBeatSubstate //pls do not murder me if i made this very badly
{
	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'options',"credits", 'Exit to menu'];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var skipTimeText:FlxText;
	var skipTimeTracker:Alphabet;
	var curTime:Float = Math.max(0, Conductor.songPosition);
	//var botplayText:FlxText;
	public static var songName:String = '';

	var loopspikes:Bool =  false;
	var spikeL:FlxSprite; //move em into a grp
	var spikeR:FlxSprite;
	var txtGrp:FlxTypedGroup<FlxSprite>; 
	var moveX:Float;
	public var colorSwap:ColorSwap = null;
	public var stuff:Array<FlxSprite> = [];

	public function new(x:Float, y:Float)
	{
		super();
		if(CoolUtil.difficulties.length < 2) menuItemsOG.remove('Change Difficulty'); //No need to change difficulty if there is only one!

		colorSwap = new ColorSwap();
		switch (PlayState.SONG.song.toLowerCase()){
			case 'sonic-kills-you-and-you-die':
				moveX = -350;
				colorSwap.hue = 0.5;
				colorSwap.saturation = -0.6;
				colorSwap.brightness = -0.3;
			default:
				moveX = 0;
		}




		menuItems = menuItemsOG;
		pauseMusic = new FlxSound();
		if(songName != null) {
			pauseMusic.loadEmbedded(Paths.music(songName), true, true);
		} else if (songName != 'None') {
			pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)), true, true);
		}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		var box:FlxSprite = new FlxSprite(0,FlxG.height).loadGraphic(Paths.image('pause/n/boxguh'));
		box.screenCenter(X);
		box.x += moveX;
		FlxTween.tween(box, {y: box.y - 550}, 0.35, {ease: FlxEase.quartOut});
		add(box);
		stuff.push(box);
	
		var spikeglow:FlxSprite = new FlxSprite(0,FlxG.height).loadGraphic(Paths.image('pause/n/glow'));
		spikeglow.screenCenter(X);
		spikeglow.x += moveX;
		FlxTween.tween(spikeglow, {y: spikeglow.y - 550}, 0.35, {ease: FlxEase.quartOut});
		//spikeglow.alpha = 0.3;
		add(spikeglow);
		stuff.push(spikeglow);

		spikeL = new FlxSprite(0,FlxG.height).loadGraphic(Paths.image('pause/n/spike 1'));
		spikeL.x = box.x;
		FlxTween.tween(spikeL, {y: spikeL.y - 550}, 0.35, {ease: FlxEase.quartOut, onComplete: function (twn:FlxTween) {
			loopspikes = true;
		}});
		add(spikeL);
		stuff.push(spikeL);

		spikeR = new FlxSprite(0,FlxG.height).loadGraphic(Paths.image('pause/n/spike 1'));
		spikeR.flipX = true;
		spikeR.x = box.x + box.width - spikeR.width;
		FlxTween.tween(spikeR, {y: spikeR.y - 500}, 0.35, {ease: FlxEase.quartOut});
		add(spikeR);
		stuff.push(spikeR);

		var shadow:FlxSprite = new FlxSprite(0,FlxG.height).loadGraphic(Paths.image('pause/n/shadow'));
		shadow.screenCenter(X);
		shadow.setGraphicSize(Std.int(box.width)); //resize eventually
		shadow.x += moveX;
		FlxTween.tween(shadow, {y: shadow.y - 825}, 0.35, {ease: FlxEase.quartOut});
		add(shadow);

		txtGrp = new FlxTypedGroup<FlxSprite>();
		add(txtGrp);
		regenMenu();

		var top:FlxSprite = new FlxSprite(0,FlxG.height).loadGraphic(Paths.image('pause/n/gen1'));
		top.screenCenter(X);
		top.x += moveX;
		FlxTween.tween(top, {y: top.y - 600}, 0.35, {ease: FlxEase.quartOut});
		add(top);

		var songN:FlxText = new FlxText(0,FlxG.height,0,PlayState.SONG.song.replace('-',' '), 16);
		songN.setFormat('NiseGenesis',40,FlxColor.BLACK);
		FlxTween.tween(songN, {y: 165}, 0.35, {ease: FlxEase.quartOut});
		songN.screenCenter(X);
		songN.x += moveX;
		add(songN);

		var top2:FlxSprite = new FlxSprite(0,FlxG.height).loadGraphic(Paths.image('pause/n/gen1'));
		top2.screenCenter(X);
		top2.x += moveX;
		FlxTween.tween(top2, {y: top2.y - 600}, 0.35, {ease: FlxEase.quartOut});
		top2.blend = ADD;
		top2.alpha = 0.1;
		add(top2);

		var pauseword:FlxSprite = new FlxSprite();
		pauseword.frames = Paths.getSparrowAtlas('pause/n/pause');
		pauseword.animation.addByPrefix('idle','pause',12);
		pauseword.animation.play('idle');
		add(pauseword);
		pauseword.scale.set(2,2);
		pauseword.updateHitbox();
		pauseword.y = 15;
		pauseword.screenCenter(X);
		pauseword.x += 20 + moveX;
		pauseword.alpha = 0;
		FlxTween.tween(pauseword, {alpha: 1}, 0.2, {ease: FlxEase.quartOut, startDelay: 0.3});

		var p = new PauseChars();
		add(p);


		txtGrp.forEach(function (b:FlxSprite) {
			b.x += moveX;
			b.shader = colorSwap.shader;
		}); 
		for (i in stuff) {
			i.shader = colorSwap.shader;
		}
	}

	var holdTime:Float = 0;
	var cantUnpause:Bool=true;
	override function update(elapsed:Float)
	{
		/*if (colorSwap != null) {
			if (FlxG.keys.pressed.T) colorSwap.hue -= elapsed * 0.1;
			if (FlxG.keys.pressed.Y) colorSwap.hue += elapsed * 0.1;
			
			if (FlxG.keys.pressed.B) colorSwap.brightness -= elapsed * 0.1;
			if (FlxG.keys.pressed.N) colorSwap.brightness += elapsed * 0.1;

			if (FlxG.keys.pressed.I) colorSwap.saturation -= elapsed * 0.1;
			if (FlxG.keys.pressed.O) colorSwap.saturation += elapsed * 0.1;

			trace('hue' + colorSwap.hue);
			trace('brightn' + colorSwap.brightness);
			trace('saturation' + colorSwap.saturation);
		}*/

		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);
		updateSkipTextStuff();

		if (loopspikes) {
			loopspikes = false;
			FlxTween.tween(spikeL, {y: spikeL.y + 25},0.5,{ease: FlxEase.linear, onComplete: function (twn:FlxTween) {
				spikeL.y -= 25;
				loopspikes = true;
			}});
			FlxTween.tween(spikeR, {y: spikeR.y - 25},0.5,{ease: FlxEase.linear, onComplete: function (twn:FlxTween) {
				spikeR.y += 25;
			}});
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}
		var daSelected:String = menuItems[curSelected];

		if (accepted && (cantUnpause ==false || !ClientPrefs.controllerMode))
		{

			switch (daSelected)
			{
				case "Resume":
					close();
				case 'options':
					MusicBeatState.switchState(new options.OptionsState());
				case "credits":
					MusicBeatState.switchState(new CreditsState());
				case "Restart Song":
					restartSong();
				case "Exit to menu":
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					WeekData.loadTheFirstEnabledMod();
					if(PlayState.isStoryMode) {
						MusicBeatState.switchState(new StoryMenuState());
					} else {
						MusicBeatState.switchState(new FreeplayState());
					}
					PlayState.instance.cancelMusicFadeTween();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
			}
		}
	}


	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;
		if(change!=0)FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		for (i in txtGrp.members) {
			if (i.ID == curSelected)
				i.color = FlxColor.RED;
			else
				i.color = FlxColor.WHITE;
		}

	}

	function regenMenu():Void {
		for (i in 0...txtGrp.members.length) {
			var obj = txtGrp.members[0];
			obj.kill();
			txtGrp.remove(obj, true);
			obj.destroy();
		}

		for (i in 0...menuItemsOG.length) {
			var box:FlxSprite = new FlxSprite(0,FlxG.height).loadGraphic(Paths.image('pause/n/buttons/000'));
			txtGrp.add(box);
			box.screenCenter(X);
			FlxTween.tween(box,{y:box.y-470 + (i * 94)},0.35,{ease:FlxEase.backOut, startDelay: (i * 0.1)});
			var txt:FlxSprite = new FlxSprite(0,FlxG.height).loadGraphic(Paths.image('pause/n/buttons/' + menuItemsOG[i]));
			txtGrp.add(txt);
			txt.ID = i;
			txt.screenCenter(X);
			FlxTween.tween(txt,{y:txt.y-450 + (i * 94)},0.35,{ease:FlxEase.backOut, startDelay: (i * 0.1)});


		}
		curSelected = 0;
		changeSelection();
	}
	
	function updateSkipTextStuff()
	{
		if(skipTimeText == null || skipTimeTracker == null) return;
		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y;
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
	}

	function updateSkipTimeText() {
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false) + ' / ' + FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
	}
}

class PauseChars extends FlxTypedGroup<FlxBasic>
{
	var dadCharN:String = PlayState.instance.dad.curCharacter;
	var bfCharN:String = PlayState.instance.boyfriend.curCharacter;

	public function new() {

        super();
		switch (PlayState.instance.dad.curCharacter)
		{
			case 'sunky2':
				dadCharN = 'sunky';
			case 'sunkyphone2' | 'sunkyphone':
				dadCharN = 'markiplier';
			case 'googleSonic':
				dadCharN = '';
				bfCharN = 'googleSonic';
		}

		if (FileSystem.exists(Paths.getPath('shared/images/pause/chars/' + dadCharN + '.png',IMAGE))) { //fix for crashing due to width shits

			var dadChar:FlxSprite = new FlxSprite().loadGraphic(Paths.image('pause/chars/$dadCharN'));
			dadChar.setGraphicSize(0,720);
			dadChar.updateHitbox();
			dadChar.x = -dadChar.width;
			add(dadChar);
			FlxTween.tween(dadChar, {x: 0}, 0.35, {ease: FlxEase.quartOut});
				
		}

		if (FileSystem.exists(Paths.getPath('shared/images/pause/chars/' + bfCharN + '.png',IMAGE))) {
			var bfChar:FlxSprite = new FlxSprite().loadGraphic(Paths.image('pause/chars/$bfCharN'));
			bfChar.setGraphicSize(0,720);
			bfChar.updateHitbox();
			bfChar.x = FlxG.width;
			add(bfChar);
			FlxTween.tween(bfChar, {x: FlxG.width - bfChar.width}, 0.35, {ease: FlxEase.quartOut});
		}
	}
}
