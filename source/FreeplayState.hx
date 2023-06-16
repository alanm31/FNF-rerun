package;

import flixel.FlxBasic;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxBackdrop;
#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import flixel.FlxObject;
import WeekData;
import flixel.util.FlxStringUtil;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class FreeplayState extends MusicBeatState //not done
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var scoreText:FlxText;
	var timeText:FlxText;
	var missText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var curPlaying:Bool = false;

	var intendedColor:Int;
	var colorTween:FlxTween;
	var colorTween2:FlxTween;

	public static var frame:FlxSprite;
	var imggrp:FlxTypedGroup<FlxSprite>;
	var modelgrp:FlxTypedGroup<FlxSprite>;
	var difficbg:FlxSprite;
	var sonicbg:FlxBackdrop;
	var redgradient:FlxSprite;
	var difficArrows:Array<FlxSprite> = [];
	var songarrow:Array<FlxSprite> = [];		
	static var lastsong:String;
	var tempsong:FlxText;

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;



	override function create()
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();

		FlxG.sound.playMusic(Paths.music('FPmenu'), 0);
		FlxG.sound.music.fadeIn(2, 0, 0.7);
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		WeekData.loadTheFirstEnabledMod();

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);
		FlxG.camera.follow(camFollowPos, null, 1);

		var grid = new FlxBackdrop(Paths.image('fp/squares'),XY);
		grid.scrollFactor.set();
		grid.antialiasing = ClientPrefs.globalAntialiasing;
		grid.velocity.x = 20;
		grid.scale.set(2,2);
		grid.active = true;
		add(grid);

		redgradient = new FlxSprite().loadGraphic(Paths.image('fp/grad'));
		redgradient.y = FlxG.height - redgradient.height;
		redgradient.scrollFactor.set();
		redgradient.setGraphicSize(1280);
		redgradient.updateHitbox();
		redgradient.alpha = 0;
		add(redgradient);

		sonicbg = new FlxBackdrop(Paths.image('fp/sonicsonic'),Y);
		sonicbg.setGraphicSize(0,720);
		sonicbg.updateHitbox();
		sonicbg.scrollFactor.set();
		sonicbg.x = FlxG.width - 510;
		sonicbg.velocity.y = -20;
		sonicbg.active = true;
		add(sonicbg);

		var sonicvign = new FlxSprite().loadGraphic(Paths.image('fp/sonicsonic_shadow'));
		sonicvign.setGraphicSize(0,720);
		sonicvign.updateHitbox();
		sonicvign.screenCenter(Y);
		sonicvign.x = FlxG.width - 510;
		sonicvign.scrollFactor.set();
		add(sonicvign);

		var divider = new FlxSprite().loadGraphic(Paths.image('fp/divider'));
		divider.setGraphicSize(0,720);
		divider.updateHitbox();
		divider.screenCenter(Y);
		divider.scrollFactor.set();
		divider.x = sonicbg.x - 10;
		add(divider);

		//blablabla tempnames until muto or gaming make logos
		tempsong = new FlxText(100,90,0,songs[curSelected].songName,28);
		tempsong.scrollFactor.set();
		add(tempsong);	

		imggrp = new FlxTypedGroup<FlxSprite>();		
		add(imggrp);

		frame = new FlxSprite(75,40).loadGraphic(Paths.image('fp/border_silverer'));
		frame.scrollFactor.set();
		frame.setGraphicSize(600);
		frame.updateHitbox();
		add(frame);

		difficbg = new FlxSprite(0,0).loadGraphic(Paths.image('fp/difficulty_bar2'));
		difficbg.scale.set(0.4,0.4);
		difficbg.updateHitbox();
		difficbg.scrollFactor.set();
		difficbg.x = frame.x + (frame.width - difficbg.width)/2;
		add(difficbg);


		modelgrp = new FlxTypedGroup<FlxSprite>();
		add(modelgrp);


		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(0, 575 - 10, 0, "", 38);
		scoreText.setFormat(Paths.font("vcr.ttf"), 38, FlxColor.WHITE, CENTER);
		scoreText.scrollFactor.set();
		add(scoreText);

		missText = new FlxText(0, 625- 10, 0, "Misses: ", 38);
		missText.setFormat(Paths.font("vcr.ttf"), 38, FlxColor.WHITE, CENTER);
		missText.scrollFactor.set();
		add(missText);

		timeText = new FlxText(0, 675- 10, 0, "Time: ", 38);
		timeText.setFormat(Paths.font("vcr.ttf"), 38, FlxColor.WHITE, CENTER);
		timeText.scrollFactor.set();
		add(timeText);

		diffText = new FlxText(0,32, 0, "", 30);
		diffText.font = Paths.font('NiseGenesis.TTF');
		diffText.scrollFactor.set();
		add(diffText);

		var arrowL = new FlxSprite().loadGraphic(Paths.image('fp/arrowD'));
		arrowL.angle = -90;
		add(arrowL);
		difficArrows.push(arrowL);

		var arrowR = new FlxSprite().loadGraphic(Paths.image('fp/arrowD'));
		arrowR.angle = 90;
		add(arrowR);
		difficArrows.push(arrowR);

		for (i in difficArrows) {
			i.scrollFactor.set();
			i.y = 40;
			i.scale.set(0.5,0.5);
			i.updateHitbox();
		}

		var arrowU = new FlxSprite().loadGraphic(Paths.image('fp/arrowD'));
		add(arrowU);
		songarrow.push(arrowU);

		var arrowD = new FlxSprite().loadGraphic(Paths.image('fp/arrowD'));
		arrowD.angle = 180;
		add(arrowD);
		songarrow.push(arrowD);

		for (i in songarrow) {
			i.scale.set(2,2);
			i.updateHitbox();
			i.x = 250;
		}

		if(curSelected >= songs.length) curSelected = 0;
		sonicbg.color = songs[curSelected].color;
		redgradient.color = songs[curSelected].color;
		intendedColor = sonicbg.color;
		intendedColor = redgradient.color;

		if(curSelected >= songs.length) curSelected = 0;
		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		for (i in 0...songs.length)
		{
				var img:FlxSprite = new FlxSprite(75,40).loadGraphic(Paths.image('fp/art/' + songs[i].songName));
				img.setGraphicSize(600,346);
				img.updateHitbox();
				img.scrollFactor.set();
				img.ID = i;
				imggrp.add(img);
	
				var models = new FlxSprite(0, i * 600);
				if (Highscore.getScore(songs[i].songName, 0) != 0 || Highscore.getScore(songs[i].songName, 1) != 0 || Highscore.getScore(songs[i].songName, 2) != 0)
					models.frames = Paths.getSparrowAtlas('fp/3d/' + songs[i].songName + 'Freeplay3D');
	
				else
					models.frames = Paths.getSparrowAtlas('fp/3d/black/' + songs[i].songName + 'Freeplay3DBlack');
					
	
				models.animation.addByPrefix('idle','spin',8);
				models.animation.play('idle');
				models.pixelPerfectRender = true; //floombo i stg u better start putting padding on ur spritesheets
				models.ID = i;
				modelgrp.add(models);
	
				/*var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
				var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
				trace(poop);
				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				var cad = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song)); //bad causes lag spike
				trace('songlong' + FlxStringUtil.formatTime(Math.floor(cad.length / 1000), false));*/

				
				Paths.currentModDirectory = songs[i].folder;
		}
		changeSelection();
		changeDiff();



		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);
			this.songs[this.songs.length-1].color = weekColor;

			if (songCharacters.length != 1)
				num++;
		}
	}*/

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	var gradtween:FlxTween;
	override function update(elapsed:Float)
	{

		if (controls.UI_LEFT) difficArrows[0].scale.set(0.6,0.6);
		else difficArrows[0].scale.set(0.5,0.5);

		if (controls.UI_RIGHT) difficArrows[1].scale.set(0.6,0.6);
		else difficArrows[1].scale.set(0.5,0.5);

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}
		scoreText.text = 'Score: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';

		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if(songs.length > 1)
		{
			if (upP)
			{
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (downP)
			{
				changeSelection(shiftMult);
				holdTime = 0;
			}

			if(controls.UI_DOWN || controls.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					changeDiff();
				}
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeSelection(-shiftMult * FlxG.mouse.wheel, false);
				changeDiff();
			}
		}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		else if (controls.UI_RIGHT_P)
			changeDiff(1);
		else if (upP || downP) changeDiff();

		if (controls.BACK)
		{
			persistentUpdate = false;
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if(ctrl)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if(space)
		{
			if(instPlaying != curSelected)
			{
				#if PRELOAD_ALL
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				Paths.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				if (PlayState.SONG.needsVoices)
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				else
					vocals = new FlxSound();

				FlxG.sound.list.add(vocals);
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
				vocals.play();
				vocals.persist = true;
				vocals.looped = true;
				vocals.volume = 0.7;
				instPlaying = curSelected;
				#end
			}
		}

		else if (accepted)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			/*#if MODS_ALLOWED
			if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}*/
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			if(colorTween != null) {
				colorTween.cancel();
			}
			
			if (FlxG.keys.pressed.SHIFT){
				LoadingState.loadAndSwitchState(new ChartingState());
			}else{
				LoadingState.loadAndSwitchState(new PlayState());
			}

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
		}
		else if(controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];


		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = CoolUtil.difficultyString();

		tempsong.text = songs[curSelected].songName;
		
		//not done
		if (diffText.text == 'HARD') gradtween = FlxTween.tween(redgradient, {y: FlxG.height - redgradient.height},0.5,{ease: FlxEase.cubeOut});
		else {
			if (gradtween != null) {
				gradtween.cancel();
			}
			gradtween = FlxTween.tween(redgradient, {y: FlxG.height},0.5,{ease: FlxEase.linear});			
		}


		if (diffText.text == 'HARD') diffText.color = FlxColor.RED;
		else if (diffText.text == 'NORMAL') diffText.color = FlxColor.WHITE;
		else if (diffText.text == 'EASY') diffText.color = FlxColor.LIME;	

		FlxTween.tween(diffText, {x: difficbg.x + (difficbg.width - diffText.width)/2},0.1, {ease: FlxEase.expoOut});
		FlxTween.tween(difficArrows[0], {x: difficbg.x + (difficbg.width - diffText.width)/2 - 30},0.1, {ease: FlxEase.expoOut});
		FlxTween.tween(difficArrows[1], {x: difficbg.x + (difficbg.width - diffText.width)/2 + diffText.width},0.1, {ease: FlxEase.expoOut});
		positionHighscore();
	}

	var songname:FreeplaySongNames;
	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		modelgrp.forEach(function (g:FlxSprite) {
			if (g.ID == curSelected) {
				camFollow.setPosition(g.getGraphicMidpoint().x - 390, g.getGraphicMidpoint().y - 25);
				FlxTween.tween(songarrow[0], {y: g.y - 40},0.2, {ease: FlxEase.cubeOut}); //temp
				FlxTween.tween(songarrow[1], {y: g.y + g.height - 50},0.2, {ease: FlxEase.cubeOut});
			}
		});

		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
				colorTween2.cancel();
			}

			intendedColor = newColor;
			colorTween = FlxTween.color(sonicbg, 0.5, sonicbg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
			colorTween2 = FlxTween.color(redgradient, 0.5, sonicbg.color, intendedColor, {onComplete: function (twn:FlxTween) {
				colorTween2 = null;
			}});
		}

		imggrp.forEach(function (pic:FlxSprite) {
			if (pic.ID == curSelected) 
				pic.visible = true;
			else
				pic.visible = false;
		});

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		Paths.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);

		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}


		if (lastsong != songs[curSelected].songName) { //haha what?
			trace('wtf');

		}
		remove(songname);			
		songname = new FreeplaySongNames(songs[curSelected].songName);
		add(songname);

		lastsong = songs[curSelected].songName;
	}

	private function positionHighscore() {
		scoreText.x = frame.x + (frame.width - scoreText.width) / 2; 
		missText.x = frame.x + (frame.width - missText.width) / 2; 
		timeText.x = frame.x + (frame.width - timeText.width) / 2; 

	}

}

class FreeplaySongNames extends FlxTypedGroup<FlxBasic> {
	//i have no idea what the ideas for future song titles will be so i feel like doing this is easier and cleaner to work with

	var song:String;

	var framex:Float = 75;
	var framewth:Float = 600;
	var frameheight:Float = 352;
	var gear:FlxSprite;

	public function new(curSong) {
		super();
		this.song = curSong.toLowerCase();
		trace(song);
		

		switch (song) {
			case 'third party':
				var songtitle = new FlxSprite(0,FlxG.height).loadGraphic(Paths.image('fp/names/third_'));
				var songtitle2 = new FlxSprite(0,FlxG.height).loadGraphic(Paths.image('fp/names/party2'));
				songtitle.setGraphicSize(Std.int(600/1.5));
				songtitle.updateHitbox();
				songtitle2.setGraphicSize(Std.int(songtitle.width - 50));
				songtitle2.updateHitbox();
				songtitle.scrollFactor.set();
				songtitle2.scrollFactor.set();
				add(songtitle);
				add(songtitle2);

				FlxTween.tween(songtitle, {y: frameheight + 40},0.2, {ease: FlxEase.expoOut});
				FlxTween.tween(songtitle2, {y: frameheight + 100},0.4, {ease: FlxEase.expoOut});	
				songtitle.x = framex + (framewth - songtitle.width)/2;
				songtitle2.x = framex + (framewth - songtitle.width)/2;	
			case 'enterprise':

				var title = new FlxSprite(0,FlxG.height).loadGraphic(Paths.image('fp/names/ep_1'));
				gear = new FlxSprite(0,FlxG.height).loadGraphic(Paths.image('fp/names/ep_gear'));
				gear.centerOrigin();

				var eyes = new FlxSprite(0,FlxG.height).loadGraphic(Paths.image('fp/names/ep_eyes'));
				title.scale.set(0.5,0.5);
				gear.scale.set(0.5,0.5);
				eyes.scale.set(0.5,0.5);
				title.updateHitbox();
				gear.updateHitbox();
				eyes.updateHitbox();

				title.scrollFactor.set();
				gear.scrollFactor.set();
				eyes.scrollFactor.set();
				add(title);
				add(gear);
				add(eyes);

				FlxTween.tween(title, {y: frameheight + 45},0.2, {ease: FlxEase.expoOut});
				FlxTween.tween(gear, {y: frameheight + 58},0.2, {ease: FlxEase.expoOut});	
				FlxTween.tween(eyes, {y: frameheight + 58},0.2, {ease: FlxEase.expoOut});	

				title.x = framex + (framewth - title.width)/2;
				gear.x = framex + (framewth - gear.width)/2 - 200;	
				eyes.x = framex + (framewth - eyes.width)/2 - 195;	
		}

		

	}

	var tes2 = false;

	override function update(elapsed:Float) {

		switch (song) {
			case 'enterprise':
				if (!tes2) {
					tes2 = true;
					new FlxTimer().start(0.1, function (t:FlxTimer) {
						tes2 = false;
						gear.angle += 5;
	
					});
				}
			case '':
		}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}
