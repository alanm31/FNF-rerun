package;

import flixel.addons.display.FlxBackdrop;
import flixel.system.scaleModes.StageSizeScaleMode;
import flixel.system.scaleModes.BaseScaleMode;
import openfl.geom.Rectangle;
import GlitchShader.Fuck;
import GlitchShader.GlitchShaderB;
import Conductor.SongTimer;
import flixel.system.scaleModes.RatioScaleMode;
import openfl.system.Capabilities;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.graphics.FlxGraphic;
import flixel.FlxBasic;
import hscript.Interp;
import openfl.Lib;
import openfl.geom.ColorTransform;
#if desktop
import Discord.DiscordClient;
#end
import Shaders;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxSave;
import flixel.animation.FlxAnimationController;
import animateatlas.AtlasFrameMaker;
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;
import Conductor.Rating;

#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end

#if VIDEOS_ALLOWED
import VideoHandler;
#end
using flixel.util.FlxColorTransformUtil;
using StringTools;


enum abstract HPScroll(String) to String from String
{
	var LEFT_TO_RIGHT = "ltr";
	var RIGHT_TO_LEFT = "rtl";
	var DEFAULT = "rtl";
}

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public var noteMoveMultX:Float = 1;
	public var noteMoveMultY:Float = 1;
	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

	//event variables
	private var isCameraOnForcedPos:Bool = false;

	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var altDadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var altDadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var modchartTweens:Map<String, FlxTween> = new Map();
	public var modchartSprites:Map<String, ModchartSprite> = new Map();
	public var modchartTimers:Map<String, FlxTimer> = new Map();
	public var modchartSounds:Map<String, FlxSound> = new Map();
	public var modchartTexts:Map<String, ModchartText> = new Map();
	public var modchartSaves:Map<String, FlxSave> = new Map();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var altDadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var spawnTime:Float = 2000;

	public var inst:FlxSound;
	public var vocals:FlxSound;

	// time attack
	// TODO: try to make a way to do this w/out hard-coding n shit
	public var exeInst:FlxSound;
	public var exeVox:FlxSound;

	var exeMix(default, set):Bool = false;

	public var dad:Character = null;
	public var altDad:Character = null;
	public var altDad2:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var ringCap = 50;
	public var rings(default, set):Float = 0;
	function set_rings(val:Float){
		if(val<0 && !practiceMode)health=-999;
		
		if(val<0)val=0;
		if (val > ringCap)val = ringCap;
		if(val> 999)val=999; // hard coded ring cap

		return rings=val;
	}
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:ExtendedFlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	public var ratingsData:Array<Rating> = [];
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	// rerun shit
	var zoneCircle:FlxSprite;
	var zoneAct:FlxSprite;
	var zoneLine1:FlxSprite;
	var zoneLine2:FlxSprite;

	var zoneTransOverlay:FlxSprite;
	var zoneTransCount:Int = 0;
	static var zoneTransPalette:Array<FlxColor> = [
		FlxColor.fromRGB(0, 0, 64),
		FlxColor.fromRGB(0, 0, 128),
		FlxColor.fromRGB(0, 64, 192),
		FlxColor.fromRGB(0, 128, 255),
		FlxColor.fromRGB(64, 192, 255),
		FlxColor.fromRGB(128, 255, 255),
		FlxColor.fromRGB(192, 255, 255),
		FlxColor.fromRGB(255, 255, 255),
	];
	
	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camSpec:FlxCamera;
	public var camNotes:FlxCamera;
	public var camGame:FlxCamera;
	public var camSubs:FlxCamera; // JUST for subtitles
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;
	public var noteZoom:Float = 1;
	public var specZoom:Float = 1;

	var heatShader:HeatShader = new HeatShader();

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;
	var subtitles:Null<SubtitleDisplay>;

	public var heyTimer:Float;

	var wiggleShit:WiggleEffect = new WiggleEffect();

	public var stage:Stage;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;
	public var defaultHudZoom:Float = 1;
	
	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	private var controlArray:Array<String>;

	public static var precacheList:Map<String, String> = new Map<String, String>();
	
	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo sprite object
	public static var lastCombo:FlxSprite;
	// stores the last combo score objects in an array
	public static var lastScore:Array<FlxSprite> = [];


	var daVoxVol:Float = 1;
	var exeVoxVol:Float = 0;

	public var beatsPerZoom:Int = 4;
	public var songQueEvents:SongEvents = new SongEvents();

	public var piracyShader:Shaders.NtscFX = new Shaders.NtscFX();
	public var piracyShader2:Dynamic;
	public var bloomShader:BloomEffect = new BloomEffect();
	var defaultPlayerStrumPoses:Array<Dynamic> = [];
	var defaultStrumPoses:Array<Dynamic> = [];
	var defArrowPoses:Array<Dynamic> = [];
	public var script:Script = new Script();
	var sTween:FlxTween;
	var jTween:FlxTween; // moved here cuz was getting initialization errors
	var sunkyHandSpr:FlxSprite;
	public var healthBarVal:Float = 1; //for side switch on healthBarl
	var imgDump:Array<FlxSprite>=[null];
	var balls:Int = -1;
	var homosexualImages:FlxTypedGroup<FlxSprite>;
	var micAlphaCapacity:Float=0.04;
	var micSprite:FlxSprite;
	function set_exeMix(val:Bool)
	{
		if(exeMix==val)return exeMix;
		
		exeMix = val;
		
		inst.volume = exeMix?0:1;
		vocals.volume = exeMix?0:1;
		exeInst.volume = exeMix?1:0;
		exeVox.volume = exeMix?1:0;

		exeVoxVol = exeVox.volume;
		daVoxVol = vocals.volume;

		ringCount.color = exeMix?FlxColor.RED:FlxColor.WHITE;

		FlxG.sound.play(Paths.sound('static'),0.87);
		timeAttackStatic.alpha = 1;

		for(obj in stage.evilSprites)obj.visible = exeMix;
		for(obj in stage.goodSprites)obj.visible = !exeMix;

		triggerEventNote('Change Character', '0', 'osr${exeMix?"Evil":""}', Conductor.songPosition);
		return exeMix;
	}

	var stageData:StageFile;

	override public function create()
	{
		
		precacheList.clear();
		//trace('Playback Rate: ' + playbackRate);
		Paths.clearStoredMemory();

		//piracyShader2 = new NtscFX();

		script.executeFunc("onCreate");
		
		piracyShader2 = new PiracyEffect(false);
		// for lua
		instance = this;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed', 1);

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		controlArray = [
			'NOTE_LEFT',
			'NOTE_DOWN',
			'NOTE_UP',
			'NOTE_RIGHT'
		];

		//Ratings
		ratingsData.push(new Rating('sick')); //default rating

		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.7;
		rating.score = 200;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.4;
		rating.score = 100;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('shit');
		rating.ratingMod = 0;
		rating.score = 50;
		rating.noteSplash = false;
		ratingsData.push(rating);

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camSpec = new FlxCamera();
		camNotes = new FlxCamera();
		camOther = new FlxCamera();
		camSubs = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camSpec.bgColor.alpha = 0;
		camNotes.bgColor.alpha = 0;
		camSubs.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;
		var notesOver:Bool = Paths.formatToSongPath(SONG.song) == 'time-attack';
		FlxG.cameras.reset(camGame);
		if (!notesOver)FlxG.cameras.add(camNotes, false);
		FlxG.cameras.add(camHUD, false);
		if (notesOver)FlxG.cameras.add(camNotes, false);
		FlxG.cameras.add(camSpec, false);
		FlxG.cameras.add(camSubs, false);
		FlxG.cameras.add(camOther, false);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		CustomFadeTransition.nextCamera = camOther;

		persistentUpdate = true;
		persistentDraw = true;


		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = SONG.stage;
		//trace('stage is: ' + curStage);
		if(SONG.stage == null || SONG.stage.length < 1) 
			curStage = Stage.getDefaultStage(songName);
		
		SONG.stage = curStage;

		stageData = Stage.getStageFile(curStage);

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		altDadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);


		stage = new Stage(curStage);
		add(stage);

		for(lua in stage.luaArray)luaArray.push(lua);
		
		switch(Paths.formatToSongPath(SONG.song))
		{
			case 'stress':
				GameOverSubstate.characterName = 'bf-holding-gf-dead';
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		//Needed for blammed lights
		// Shitty layering but whatev it works LOL
		//if (curStage == 'limo')
		//	add(limo);

		switch(stage.curStage.toLowerCase()){
			default:
				add(gfGroup); 
				add(dadGroup);
				add(boyfriendGroup);
			case "secret histories":
				add(dadGroup);
				add(boyfriendGroup);
			case "piracy":
				add(altDadGroup); 
				add(boyfriendGroup);
				add(dadGroup);
		}


		stage.afterGroups();

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1)
		{
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				case 'tank':
					gfVersion = 'gf-tankmen';
				default:
					gfVersion = 'gf';
			}

			switch(Paths.formatToSongPath(SONG.song))
			{
				case 'stress':
					gfVersion = 'pico-speaker';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);

		if(SONG.song.toLowerCase()=="party-streamer") gfVersion="markiplier";
		altDad = new Character(0, 0, gfVersion);
		startCharacterPos(altDad, true);
		altDadGroup.add(altDad);
		if (SONG.song.toLowerCase() == 'third-party') {
			trace('HE IS COMING');
			altDad2 = new Character(0,0, 'piracy-sonicold1');
			startCharacterPos(altDad2, false);
			altDadGroup.add(altDad2);
			altDad2.color = 0xFF7273DF;
		} 
		startCharacterLua(altDad.curCharacter);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);

		if(isPixelStage){
			dad.pixelPerfectRender=true;
			boyfriend.pixelPerfectRender=true;
			if(gf!=null)
			gf.pixelPerfectRender=true;
			altDad.pixelPerfectRender=true;
		}

		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}

		/*switch(curStage)
		{
			case 'limo':
				resetFastCar();
				addBehindGF(fastCar);

			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); //nice
				addBehindDad(evilTrail);
		}*/
		stage.afterCharacters();
		for(stuff in stage.hudElements)stuff.cameras = [camHUD];

		
		

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(file);
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000 / Conductor.songPosition;

		strumLine = new FlxSprite((ClientPrefs.middleScroll) ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);

		startScript();

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection();

		var hpsize = new FlxSprite().loadGraphic(Paths.image('hpbars/third-party/hpframe')); //only really need the size
		if (FileSystem.exists(Paths.getPath('shared/images/hpbars/' + SONG.song.toLowerCase() + '/hpframe' + '.png',IMAGE)))  
			healthBarBG = new AttachedSprite('hpbars/' + SONG.song.toLowerCase() + '/hpframe');	
		else 
			healthBarBG = new AttachedSprite('hpbars/third-party/hpframe'); //temp crash fix until all songs got the new bar	
		
		healthBarBG.y = FlxG.height * 0.775;
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -55;
		healthBarBG.yAdd = -110;
		healthBarBG.y -= 75/2;
		if(ClientPrefs.downScroll) healthBarBG.y = -10; //0.11

		healthBar = new ExtendedFlxBar(healthBarBG.x + 60, healthBarBG.y + 120, LEFT_TO_RIGHT, Std.int(hpsize.width), Std.int(hpsize.height), this,
			'healthBarVal', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		add(healthBar);
		add(healthBarBG);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);
		iconP1.visible = false; //shitty temp lolll

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 85;
		iconP2.x = healthBar.x - 54;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		reloadHealthBarColors();

		scoreTxt = new FlxText(healthBar.x + 100, healthBarBG.y + 20 + 36, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}

		strumLineNotes.cameras = [camNotes];
		grpNoteSplashes.cameras = [camNotes];
		notes.cameras = [camNotes];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		doof.cameras = [camHUD];


		if(fixDoubles) fixDoubleNotes();
		setupSongHUDs();

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		for (event in eventPushedMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_events/' + event + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_events/' + event + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('songs/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('songs/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/songs/' + Paths.formatToSongPath(SONG.song) + '/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/songs/' + Paths.formatToSongPath(SONG.song) + '/' ));// using push instead of insert because these should run after everything else
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		var daSong:String = Paths.formatToSongPath(curSong);
		if (daSong!=null)
		{
			switch (daSong)
			{	
				case 'twisted':
					var tistid=new flixel.FlxSprite();
					tistid.frames=Paths.getSparrowAtlas("bgs/sh/intro","shared");
					tistid.animation.addByPrefix("Enter","Enter",24,false);
					add(tistid);
					tistid.x-=90;
					tistid.alpha=0;
					tistid.scrollFactor.set(0,0);
					tistid.cameras=[camOther];
					tistid.y+=90;
					tistid.alpha=1;
					tistid.animation.play("Enter");
					tistid.animation.finishCallback=function(s){
						tistid.alpha=0;
						tistid.destroy();
					}
					new FlxTimer().start(1,function(s:FlxTimer){startCountdown();});
				default:
					startCountdown();
			}
			seenCutscene = true;
		}
		else
		{
			startCountdown();
		}
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if(ClientPrefs.hitsoundVolume > 0) precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		if (PauseSubState.songName != null) {
			precacheList.set(PauseSubState.songName, 'music');
		} else if(ClientPrefs.pauseMusic != 'None') {
			precacheList.set(Paths.formatToSongPath(ClientPrefs.pauseMusic), 'music');
		}

		precacheList.set('alphabet', 'image');
	
		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		callOnLuas('onCreatePost', []);
		script.executeFunc("onCreatePost");
		stage.postCreate();

		add(stage.foreground);
		if (SONG.song.toLowerCase() == 'third-party')
			FlxTransitionableState.skipNextTransIn = true;
		super.create();

		cacheCountdown();
		cachePopUpScore();
		songQueEvents.setUp(SONG.song);
		for (key => type in precacheList)
		{
			//trace('Key $key is type $type');
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
			}
		}




		switch(curSong.toLowerCase()){
			case 'third-party':
				// add(stage.darkthing);		
				// add(stage.piracyCrimetxt);
				for (i in 0...4)
				{
					FlxTween.tween(strumLineNotes.members[i], {alpha: 0.5}, 2);
					strumLineNotes.members[i].x = -300;
					strumLineNotes.members[i].y = -150;
				}
				stage.piracy_Error = new FlxSprite().loadGraphic(Paths.image('bgs/Third Party/Piracy_Error'));
				stage.piracy_Error.antialiasing = ClientPrefs.globalAntialiasing;
				stage.piracy_Error.cameras = [camOther];
				add(stage.piracy_Error);
				stage.piracy_Error.alpha = 0;
				try{
					if(altDad!=null){
						altDad2.alpha = 0;
						altDad.alpha=0;
					}
				}catch(e){
					trace(e);
				}
			case "twisted":
				GameOverSubstate.characterName = 'sh bf dead';
				for(i in playerStrums){
					i.x -= 645;
				}
				for(i in opponentStrums){
					i.x += 645;
				}
			case "party-streamers":
				GameOverSubstate.characterName = 'sunkybf-dead';
				GameOverSubstate.deathSoundName = 'fog';
				
				sunkyHandSpr = new FlxSprite((ClientPrefs.middleScroll) ? 229 : 528, (ClientPrefs.downScroll) ? -16 : -55);
				sunkyHandSpr.frames = Paths.getSparrowAtlas('mech/sunky/scramblesunky',"shared");
				sunkyHandSpr.animation.addByPrefix('sc','sc',24,false);
				sunkyHandSpr.animation.play('sc');
				sunkyHandSpr.cameras = [camHUD];
				sunkyHandSpr.flipY = ClientPrefs.downScroll;
				sunkyHandSpr.setGraphicSize(815);
				sunkyHandSpr.updateHitbox();
				add(sunkyHandSpr);



				
				altDad = new Character(0, 0, 'markiplier');
				startCharacterPos(altDad, true);
				add(altDad);
				startCharacterLua(altDad.curCharacter);

				altDad.alpha = 0.00001;
				altDad.cameras = [camHUD];
				sunkyHandSpr.alpha = 0.00001;


				homosexualImages = new FlxTypedGroup<FlxSprite>(); //vine boom images
				add(homosexualImages);
		}
		Paths.clearUnusedMemory();
		
		subtitles = SubtitleDisplay.fromSong(SONG.song);
		if(subtitles!=null){
			add(subtitles);
			subtitles.y = 550;
			subtitles.cameras = [camSubs];
		}
		CustomFadeTransition.nextCamera = camOther;
	}
	
	var inTimeAttackCutscene(default, set):Bool = false;
	function set_inTimeAttackCutscene(shit:Bool)
	{
		if(!shit){
			if(isCameraOnForcedPos)isCameraOnForcedPos=false;
			FlxTween.tween(camNotes, {alpha: 1}, 1);
			FlxTween.tween(border, {alpha: 1}, 1);

			FlxTween.tween(timebarimg, {alpha: 1}, 1);
			FlxTween.tween(ringstxt, {alpha: 1}, 1);
			FlxTween.tween(ringCount, {alpha: 1}, 1);
			FlxTween.tween(timeCount, {alpha: 1}, 1);
		}
		return inTimeAttackCutscene=shit;
	}


	// TODO: hscript shit!!
	static var fadeFramerate = 1/24;
	var afterFade = 2.5 + (fadeFramerate * (zoneTransPalette.length - 1));
	public static var fpsSong:String = 'menu';
	var fixDoubles:Bool=true;
	function fixDoubleNotes(){ //fixes the animations clashing on doubles, might recode later just using this rn cuz i was playing too slow and it was annoying me
		for (i in 0...unspawnNotes.length) {
			for (j in i+1...unspawnNotes.length-1) {
				if (unspawnNotes[i].mustPress && unspawnNotes[j].mustPress && unspawnNotes[i].strumTime == unspawnNotes[j].strumTime && unspawnNotes[i].noAnimation == false && unspawnNotes[j].noAnimation==false) {
					unspawnNotes[i].noAnimation = true;
				}
			}
		}
	}

	function setupSongHUDs()
	{
		switch(SONG.song.toLowerCase()){
			case 'reroy':
				healthBarBG.xAdd += -10; //horrid
				healthBarBG.yAdd += 1;			
				healthBar.x += 30;
				iconP2.x += 25;
			case 'third-party':
				updPiracy = true;
				defaultCamZoom = 0.9;
				defaultHudZoom = 0.9;
				
				camNotes.setFilters([new ShaderFilter(piracyShader2.shader)]);
				camGame.setFilters([new ShaderFilter(piracyShader.shader)]);
				camHUD.setFilters([new ShaderFilter(piracyShader2.shader)]);

				var zonecircle = new FlxSprite();
				zonecircle.frames = Paths.getSparrowAtlas('ui/third-party/piracyintro');
				zonecircle.animation.addByPrefix('idle','piracyintro anim',30,false);
				zonecircle.animation.play('idle');
				zonecircle.cameras = [camOther];
				zonecircle.scale.set(3,3);
				zonecircle.updateHitbox();
				zonecircle.screenCenter();
				add(zonecircle);
				new FlxTimer().start(1, function (t:FlxTimer) {
					FlxTween.tween(zonecircle, {x: -zonecircle.width},0.2,{ease: FlxEase.linear, onComplete: function (t:FlxTween) {
						remove(zonecircle);
					}});
				});
			case 'last-chance':
				noteMoveMultX = 0.35;
				noteMoveMultY = 0.35;

				noteZoom = 0.8;
				camNotes.setScale(0.8, 0.8);
				camNotes.height = camNotes.height+170;
				camNotes.width = Math.floor(FlxG.width / 0.8);
				camNotes.x = (FlxG.width - camNotes.width) / 2;
				camNotes.y = -50;
				if (ClientPrefs.downScroll)
					camNotes.y = 30;
				
			case "twisted":
				timeBar.x += 320;
				timeTxt.x += 320;
				timeBarBG.x += 320;
				healthBarBG.x += 270;
				healthBar.x += 270;
				scoreTxt.x += 270;

				iconP1.x += 270;
				//iconP2.x += 270;
				
				add(stage.shVignette);
			case 'sonic-kills-you-and-you-die':
				dad.alpha = 0.00001;
			case 'time-attack':
				noteMoveMultX = 0.5;
				noteMoveMultY = 0.4;
				inTimeAttackCutscene = true;
				exeVox = new FlxSound().loadEmbedded(Paths.voices("time-attack-exe-mix"));
				exeVox.pitch = playbackRate;
				exeVox.volume = 0;
				exeInst = new FlxSound().loadEmbedded(Paths.inst("time-attack-exe-mix"));
				exeInst.pitch = playbackRate;
				exeInst.volume = 0;

				FlxG.sound.list.add(exeVox);
				FlxG.sound.list.add(exeInst);

				addCharacterToList('osrEvil', 0);
				addCharacterToList('osr', 0);

				// TODO: some sort of stage.setupHUDs()
				// and move all of this into it
				var barLeft:FlxSprite = new FlxSprite().makeGraphic(280,720,FlxColor.BLACK);
				barLeft.cameras = [camHUD];
				add(barLeft);

				var barRight:FlxSprite = new FlxSprite(1006).makeGraphic(280,720,FlxColor.BLACK);
				barRight.cameras = [camHUD];
				add(barRight);

				border = new FlxSprite(211,-26).loadGraphic(Paths.image('ui/osr/border'));
				border.setGraphicSize(845);
				border.updateHitbox();
				border.alpha=0;
				border.cameras = [camHUD];
				if (ClientPrefs.downScroll)
					border.flipY = true;
				add(border);
				
				timeAttackStatic = new FlxSprite(80, 64).loadGraphic(Paths.image('bgs/osr/static'), true, 208, 192);
				timeAttackStatic.animation.add('idle', [0, 1], 12);
				timeAttackStatic.animation.play('idle');
				timeAttackStatic.setGraphicSize(945);
				timeAttackStatic.updateHitbox();
				timeAttackStatic.scrollFactor.set(0,0);
				timeAttackStatic.screenCenter(XY);
				timeAttackStatic.cameras = [camHUD];
				timeAttackStatic.alpha = 0.00001;
				add(timeAttackStatic);

				ringstxt = new FlxSprite(756, ClientPrefs.downScroll ? 15 : 645).loadGraphic(Paths.image('ui/osr/ringtxt'));
				ringstxt.setGraphicSize(160);
				ringstxt.updateHitbox();
				ringstxt.alpha = 0;
				ringstxt.cameras = [camHUD];
				add(ringstxt);

				ringCount = new FlxBitmapText(FlxBitmapFont.fromMonospace(Paths.image('ui/osr/ringNum'), '0123456789', new FlxPoint(8, 11)));
				ringCount.setPosition(932, ClientPrefs.downScroll ? 39 : 669);
				ringCount.scale.set(3, 3);
				ringCount.text = '000';
				ringCount.alpha = 0;
				ringCount.cameras = [camHUD];
				add(ringCount);

				timebarimg = new FlxSprite(508,ClientPrefs.downScroll ? 2 : 565).loadGraphic(Paths.image('ui/osr/timebar'));
				timebarimg.setGraphicSize(255);
				timebarimg.updateHitbox();
				timebarimg.cameras = [camHUD];
				timebarimg.alpha = 0;
				add(timebarimg);

				timeCount = new FlxBitmapText(FlxBitmapFont.fromMonospace(Paths.image('ui/osr/timeNum'),'0123456789',new FlxPoint(8,15)));
				timeCount.setPosition(623,ClientPrefs.downScroll ? 89 : 652);
				timeCount.scale.set(4,4);
				timeCount.text = '03 57';
				timeCount.alpha= 0 ;
				timeCount.cameras = [camHUD];
				add(timeCount);

				zoneTransOverlay = new FlxSprite().makeGraphic(1280, 1280, FlxColor.WHITE);
				zoneTransOverlay.scrollFactor.set(0, 0);
				zoneTransOverlay.scale.set(1, 1);
				zoneTransOverlay.blend = BlendMode.DARKEN;
				zoneTransOverlay.alpha = 1;
				zoneTransOverlay.cameras = [camHUD];
				zoneTransOverlay.color = FlxColor.BLACK;
				add(zoneTransOverlay);

				zoneCircle = new FlxSprite(0, 0).loadGraphic(Paths.image("ui/title-cards/circle"));
				zoneAct = new FlxSprite(0, 0).loadGraphic(Paths.image("ui/title-cards/time-attack/act"));
				zoneLine1 = new FlxSprite(0, 0).loadGraphic(Paths.image("ui/title-cards/time-attack/line1"));
				zoneLine2 = new FlxSprite(0, 0).loadGraphic(Paths.image("ui/title-cards/time-attack/line2"));

				zoneCircle.cameras = [camHUD];
				zoneAct.cameras = [camHUD];
				zoneLine1.cameras = [camHUD];
				zoneLine2.cameras = [camHUD];

				zoneCircle.antialiasing = false;
				zoneAct.antialiasing = false;
				zoneLine1.antialiasing = false;
				zoneLine2.antialiasing = false;

				zoneCircle.scale.set(2.5, 2.5);
				zoneAct.scale.set(2.5, 2.5);
				zoneLine1.scale.set(2.5, 2.5);
				zoneLine2.scale.set(2.5, 2.5);

				zoneCircle.updateHitbox();
				zoneAct.updateHitbox();
				zoneLine1.updateHitbox();
				zoneLine2.updateHitbox();

				zoneCircle.screenCenter(XY);
				zoneAct.screenCenter(XY);
				zoneLine1.screenCenter(XY);
				zoneLine2.screenCenter(XY);
				
				zoneCircle.x += FlxG.width;
				zoneAct.x += FlxG.width;
				zoneLine1.x -= FlxG.width;
				zoneLine2.x -= FlxG.width;

				camNotes.alpha = 0;

				add(zoneCircle);
				add(zoneAct);
				add(zoneLine1);
				add(zoneLine2);

				var resX:Int = 780;
				var resY:Int = 720;

				FlxG.resizeWindow(resX, resY);
				FlxG.scaleMode = new RatioScaleMode(true);
				//FlxG.resizeGame(resX, resY);

				var window = lime.app.Application.current.window;
				window.fullscreen = false;
				window.resizable = false;
				window.x = Math.floor((Capabilities.screenResolutionX / 2) - (resX / 2));
				window.y = Math.floor((Capabilities.screenResolutionY / 2) - (resY / 2));

				timeBarBG.visible = false;
				timeBar.visible = false;
				timeTxt.visible = false;
				healthBar.visible = false;
				scoreTxt.visible = false;
				healthBarBG.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				dad.visible = false;
				gf.visible = false;
				updateTime = true;

				noteZoom = 0.6;

				camNotes.setScale(0.6, 0.6);
				camNotes.height = camNotes.height+170;
				camNotes.y = -170;
				if (ClientPrefs.downScroll)
					camNotes.y = 30;

				isCameraOnForcedPos = true;
				camFollow.set(2800, boyfriend.getMidpoint().y - 100);
				camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];
				camFollow.y += 20;

				// TIME ATTACK TIME EVENTS

				new SongTimer().startAbs(afterFade, function(tmr:SongTimer){
					stage.doWaterUpdate=true;
				});
				
				new SongTimer().startAbs(afterFade + 2, function(tmr:SongTimer){
					FlxTween.tween(zoneCircle, {x: FlxG.width}, 0.5, {
						onComplete: function(twn:FlxTween)
						{
							zoneCircle.visible = false;
						}
					});
					FlxTween.tween(zoneAct, {x: FlxG.width}, 0.5, {
						onComplete: function(twn:FlxTween)
						{
							zoneAct.visible = false;
						}
					});
					FlxTween.tween(zoneLine1, {x: -FlxG.width}, 0.5, {
						onComplete: function(twn:FlxTween)
						{
							zoneLine1.visible = false;
						}
					});
					FlxTween.tween(zoneLine2, {x: -FlxG.width}, 0.5, {
						onComplete: function(twn:FlxTween)
						{
							zoneLine2.visible = false;
						}
					});
				});

				for(i in 1...zoneTransPalette.length+1){
					new SongTimer().startAbs(2.5 + (fadeFramerate * i), function(tmr:SongTimer){
						zoneTransOverlay.color = zoneTransPalette[i-1];
						if(i == zoneTransPalette.length)
							zoneTransOverlay.visible=false;
					});
				}
				case 'redolled':
					isCameraOnForcedPos = true;
					noteMoveMultX = 0;
					noteMoveMultY = 0;
					var resX:Int = 1029;
					var resY:Int = 720;
	
					FlxG.resizeWindow(resX, resY);
					FlxG.scaleMode = new RatioScaleMode(true);
	
					var window = lime.app.Application.current.window;
					window.fullscreen = false;
					window.resizable = false;
					window.x = Math.floor((Capabilities.screenResolutionX / 2) - (resX / 2));
					window.y = Math.floor((Capabilities.screenResolutionY / 2) - (resY / 2));
					boyfriend.visible = false; //no bf

					

				case 'top-loader':
					updPiracy = true;
					camNotes.setFilters([new ShaderFilter(piracyShader2.shader)]);
					camGame.setFilters([new ShaderFilter(piracyShader.shader)]);
					camHUD.setFilters([new ShaderFilter(piracyShader2.shader)]);

					addCharacterToList('nesglitch', 0);
					addCharacterToList('neseggman', 0);

					noteMoveMultX = 0.5;
					noteMoveMultY = 0.4;
					var resX:Int = 960;
					var resY:Int = 720;
	
					FlxG.resizeWindow(resX, resY);
					FlxG.scaleMode = new RatioScaleMode(true);
					//FlxG.resizeGame(resX, resY);
	
					var window = lime.app.Application.current.window;
					window.fullscreen = false;
					window.resizable = false;
					window.x = Math.floor((Capabilities.screenResolutionX / 2) - (resX / 2));
					window.y = Math.floor((Capabilities.screenResolutionY / 2) - (resY / 2));

					timeBarBG.visible = false;
					timeBar.visible = false;
					timeTxt.visible = false;
					noteZoom = 0.75;

					//var scanlines = new FlxSprite(0,0).loadGraphic(Paths.image('bgs/neshill/scanlines3',"shared"));
					var scanlines = new FlxBackdrop(Paths.image('bgs/neshill/scanlines3'),Y);
					scanlines.scrollFactor.set();
					scanlines.screenCenter();
					scanlines.alpha = 0.8;
					scanlines.blend = BlendMode.LAYER;
					add(scanlines);
					scanlines.active = true;
					scanlines.velocity.y = -20;
					scanlines.cameras = [camHUD];
		}
	}

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if(!ClientPrefs.shaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.shaders) return false;

		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		var foldersToCheck:Array<String> = [Paths.mods('shaders/')];
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/shaders/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));
		
		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				var frag:String = folder + name + '.frag';
				var vert:String = folder + name + '.vert';
				var found:Bool = false;
				if(FileSystem.exists(frag))
				{
					frag = File.getContent(frag);
					found = true;
				}
				else frag = null;

				if (FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else vert = null;

				if(found)
				{
					runtimeShaders.set(name, [frag, vert]);
					//trace('Found shader $name!');
					return true;
				}
			}
		}
		FlxG.log.warn('Missing shader $name .frag AND .vert files!');
		return false;
	}
	#end

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes) note.resizeByRatio(ratio);
			for (note in unspawnNotes) note.resizeByRatio(ratio);
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		if(generatedMusic)
		{
			if(vocals != null) vocals.pitch = value;
			inst.pitch = value;
			if(exeVox!=null)exeVox.pitch = value;
			if(exeInst!=null)exeInst.pitch = value;
		}
		playbackRate = value;
		FlxAnimationController.globalSpeed = value;
		trace('Anim speed: ' + FlxAnimationController.globalSpeed);
		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000 * value;
		setOnLuas('playbackRate', playbackRate);
		return value;
	}

	public function addTextToDebug(text:String, color:FlxColor) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup, color));
		#end
	}
	var dadTransform:ColorTransform = new ColorTransform();
	var bfTransform:ColorTransform = new ColorTransform();

	public function reloadHealthBarColors() {
		var fill = Paths.image('hpbars/' + SONG.song.toLowerCase() + '/fill');
		var empty = Paths.image('hpbars/' + SONG.song.toLowerCase() + '/empty');
		if (!FileSystem.exists(Paths.getPath('shared/images/hpbars/' + SONG.song.toLowerCase() + '/hpframe' + '.png',IMAGE))) {
			empty = Paths.image('hpbars/third-party/empty');
			fill = Paths.image('hpbars/third-party/fill');
		}

		

		var dadCol = FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]);
		var bfCol = FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]);

		//dadTransform.setMultipliers(dadCol.redFloat, dadCol.greenFloat, dadCol.blueFloat, 1);
		//bfTransform.setMultipliers(bfCol.redFloat, bfCol.greenFloat, bfCol.blueFloat, 1);
		healthBar.createImageBar(empty, fill, dadCol, bfCol);
		healthBar.updateBar();

		/*@:privateAccess {
			if(healthBar._filledBar!=null){
				// render blit
				healthBar._filledBar.colorTransform(new Rectangle(0, 0, healthBar.barWidth, healthBar.barHeight), bfTransform);
				healthBar._emptyBar.colorTransform(new Rectangle(0, 0, healthBar.barWidth, healthBar.barHeight), dadTransform);
			}else{
				// render tile
				healthBar.color = dadCol;
				healthBar.filledColor = bfCol;
			}
		}*/
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					if(isPixelStage)
						newBoyfriend.pixelPerfectRender=true;
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					if(isPixelStage)
						newDad.pixelPerfectRender=true;
					
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					if(isPixelStage)
						newGf.pixelPerfectRender=true;
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		#if MODS_ALLOWED
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		#else
		luaFile = Paths.getPreloadPath(luaFile);
		if(Assets.exists(luaFile)) {
			doPush = true;
		}
		#end

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		if(variables.exists(tag)) return variables.get(tag);
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String)
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;

		var filepath:String = Paths.video(name);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		var video:VideoHandler = new VideoHandler();
		video.playVideo(filepath);
		video.finishCallback = function()
		{
			startAndEnd();
			return;
		}
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		return;
		#end
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			precacheList.set('dialogue', 'sound');
			precacheList.set('dialogueClose', 'sound');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'roses' || songName == 'thorns')
		{
			remove(black);

			if (songName == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (Paths.formatToSongPath(SONG.song) == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}


	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', ['ready', 'set', 'go']);
		introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

		var introAlts:Array<String> = introAssets.get('default');
		if (isPixelStage) introAlts = introAssets.get('pixel');
		
		for (asset in introAlts)
			Paths.image(asset);
		
		Paths.sound('intro3' + introSoundsSuffix);
		Paths.sound('intro2' + introSoundsSuffix);
		Paths.sound('intro1' + introSoundsSuffix);
		Paths.sound('introGo' + introSoundsSuffix);
	}

		public function getBaseX(direction:Int, player:Int):Float
		{
			var x:Float = (camNotes.width* 0.5) - Note.swagWidth - 54 + Note.swagWidth * direction;
			switch (player)
			{
				case 0:
					x += camNotes.width* 0.5 - Note.swagWidth * 2 - 100;
				case 1:
					x -= camNotes.width* 0.5 - Note.swagWidth * 2 - 100;
			}

			x -= 56;

			return x;
		}

	public function startCountdown():Void
	{	
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			
			return;
		}
		script.executeFunc("onStartCountdown");

		
		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', [], false);
		if(ret != FunkinLua.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				//if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
			}

			switch(SONG.song.toLowerCase()){
				case 'redolled':
					for (i in opponentStrums) {
						i.x = -500;
					}
					for (i in 0...2) { //temp positions
						playerStrums.members[i].x -= 550;
					}
					for (i in 2...4) {
						playerStrums.members[i].x -= 100;						
					}
				case 'top-loader':
					for (i in 0...4) {
						var ogopx = opponentStrums.members[i].x;
						opponentStrums.members[i].x = -500;
						playerStrums.members[i].x = ogopx; 
					}
					for (i in playerStrums) {
						if (ClientPrefs.downScroll)
							i.y += 50;
						else 
							i.y -= 50;
					}

				case 'sonic-kills-you-and-you-die':
					for (i in 0...4) {
						opponentStrums.members[i].x = -500;
						//playerStrums.members[i].x = 412 + (i * 113); //ghetto middlescroll 
					}


				case 'time-attack':
					for (arrow in playerStrums)
					{
						arrow.x -= 310;
						if (!ClientPrefs.downScroll)
							arrow.y = arrow.y-40;
						else
							arrow.y = arrow.y+140;
					}

					for(arrow in opponentStrums)
						arrow.visible=false;
				case 'last-chance':
					for (arrow in strumLineNotes)
					{
						//arrow.x -= 310;
						if (!ClientPrefs.downScroll)
							arrow.y = arrow.y-40;
						else
							arrow.y = arrow.y+140;
					}

					for (i in 0...4) {
						playerStrums.members[i].x = getBaseX(i, 1) + 150;
						opponentStrums.members[i].x = getBaseX(i, 0) - 150;
					}
			}

			startedCountdown = true;
			Conductor.songPosition = -Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var swagCounter:Int = 0;

			if(startOnTime < 0) startOnTime = 0;

			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return;
			}

	
			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
				{
					boyfriend.dance();
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
				{
					dad.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}
				var do3:Bool = false;
				var leMult:Float = 1;
				var animated:Bool = false;
				switch (SONG.song)
				{
					case 'party-streamers':
						do3 = true;
						introAlts = ['ui/sunky/2', 'ui/sunky/1', 'ui/sunky/go', 'ui/sunky/3'];
						antialias = false;
						leMult = 2.6;
					case 'time-attack':
						do3 = true;
						introAlts = ['ui/osr/2', 'ui/osr/1', 'ui/osr/go', 'ui/osr/3'];
						antialias = false;
					case 'top-loader':
						do3 = true;
						introAlts = ['ui/top-loader/2', 'ui/top-loader/1', 'ui/top-loader/go', 'ui/top-loader/3'];
						antialias = false;
						animated = true;
				}

				// head bopping for bg characters on Mall
				/*if(curStage == 'mall') {
					if(!ClientPrefs.lowQuality)
						upperBoppers.dance(true);

					bottomBoppers.dance(true);
					santa.dance(true);
				}*/
				stage.bumpBoppers();

				if(swagCounter > 4){
					FlxTween.tween(playerStrums.members[swagCounter], {alpha: 1}, 0.8, {ease: FlxEase.circOut});
					FlxTween.tween(opponentStrums.members[3-swagCounter], {alpha: 1}, 0.8, {ease: FlxEase.circOut});
				}
				
				if(SONG.song.toLowerCase()=='third-party'){
					trace(swagCounter);
				}else{
					switch (swagCounter)
					{
						case 0:
							FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
						case 1:
							if (animated)
							{
								countdownReady = new FlxSprite();
								countdownReady.frames = Paths.getSparrowAtlas(introAlts[0]);
								countdownReady.animation.addByPrefix('idle', '2', 24, true);
								countdownReady.animation.play('idle');
							}
							else
							countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
							countdownReady.cameras = [camHUD];
							countdownReady.scrollFactor.set();
							countdownReady.updateHitbox();

							if (PlayState.isPixelStage)
								countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

							countdownReady.setGraphicSize(Std.int(countdownReady.width * leMult));

							countdownReady.screenCenter();
							countdownReady.antialiasing = antialias;
							insert(members.indexOf(notes), countdownReady);
							FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									remove(countdownReady);
									countdownReady.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
						case 2:
							if (animated)
							{
								countdownSet = new FlxSprite();
								countdownSet.frames = Paths.getSparrowAtlas(introAlts[1]);
								countdownSet.animation.addByPrefix('idle', '1', 24, true);
								countdownSet.animation.play('idle');
							}
							else
							countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
							countdownSet.cameras = [camHUD];
							countdownSet.scrollFactor.set();

							if (PlayState.isPixelStage)
								countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

							countdownSet.setGraphicSize(Std.int(countdownSet.width * leMult));

							countdownSet.screenCenter();
							countdownSet.antialiasing = antialias;
							insert(members.indexOf(notes), countdownSet);
							FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									remove(countdownSet);
									countdownSet.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
						case 3:
							if (animated)
							{
								countdownGo = new FlxSprite();
								countdownGo.frames = Paths.getSparrowAtlas(introAlts[2]);
								countdownGo.animation.addByPrefix('idle', 'go', 24, true);
								countdownGo.animation.play('idle');
							}
							else
							countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
							countdownGo.cameras = [camHUD];
							countdownGo.scrollFactor.set();

							if (PlayState.isPixelStage)
								countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

							countdownGo.setGraphicSize(Std.int(countdownGo.width * leMult));

							countdownGo.updateHitbox();

							countdownGo.screenCenter();
							countdownGo.antialiasing = antialias;
							insert(members.indexOf(notes), countdownGo);
							FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									remove(countdownGo);
									countdownGo.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
						case 4:
							if (zoneTransOverlay != null)
							{ // if this exists then theres probably zone sprites made!!

								// TODO: song-based tween system so this can all be in sync even if you pause n stuff
								FlxTween.tween(zoneCircle, {x: (FlxG.width - zoneCircle.width) / 2}, 0.4);

								FlxTween.tween(zoneLine1, {x: (FlxG.width - zoneLine1.width) / 2}, 0.5, {
									onComplete: function(twn:FlxTween)
									{
										FlxTween.tween(zoneLine2, {x: (FlxG.width - zoneLine2.width) / 2}, 0.5, {
											onComplete: function(twn:FlxTween)
											{
												FlxTween.tween(zoneAct, {x: (FlxG.width - zoneAct.width) / 2}, 0.5, {
													onComplete: function(twn:FlxTween)
													{
													}
												});
											}
										});
									}
								});
							}
					}
				}

				notes.forEachAlive(function(note:Note) {
					if (note.mustPress || (ClientPrefs.opponentStrums))
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if(ClientPrefs.middleScroll && !note.mustPress) {
							note.alpha *= 0.35;
						}
					}
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	public function addBehindGF(obj:FlxObject)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxObject)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad (obj:FlxObject)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function updateScore(miss:Bool = false)
	{
		scoreTxt.text = 'S: ' + songScore
		+ ' | M: ' + songMisses
		+ ' | R: '+ (ratingName == '?' ? '?' : '') + (ratingName != '?' ? '(${Highscore.floorDecimal(ratingPercent * 100, 2)}%) - $ratingFC' : '');

		if(ClientPrefs.scoreZoom && !miss && !cpuControlled)
		{
			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.075;
			scoreTxt.scale.y = 1.075;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
		}
		callOnLuas('onUpdateScore', [miss]);
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		inst.pause();
		vocals.pause();

		inst.time = time;
		inst.pitch = playbackRate;
		inst.play();

		if(exeInst!=null){
			exeInst.pause();
			exeVox.pause();

			exeInst.time = time;
			exeInst.pitch = playbackRate;
			exeInst.play();
		}

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			vocals.pitch = playbackRate;
		}
		vocals.play();
		Conductor.songPosition = time;
		songTime = time;

		if(exeVox!=null){
			exeVox.time = vocals.time;
			exeVox.pitch = vocals.pitch;
			exeVox.play();
		}
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		//FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		inst.pitch = playbackRate;
		inst.onComplete = finishSong.bind();
		vocals.play();

		if(startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			inst.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = inst.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		/*switch(curStage)
		{
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});
		}*/

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
		script.executeFunc("onSongStart");
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();

	var timeAttackStatic:FlxSprite;
	var ringCount:FlxBitmapText;
	var timeCount:FlxBitmapText;

	var timebarimg:FlxSprite;
	var border:FlxSprite;
	var ringstxt:FlxSprite;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		fpsSong = curSong;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		vocals.pitch = playbackRate;

		inst = new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song));
		inst.pitch = playbackRate;

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(inst);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				if(SONG.song.toLowerCase()=='time-attack' || SONG.song.toLowerCase()=='top-loader') swagNote.pixelPerfectRender=true;
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts

				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						if (SONG.song.toLowerCase() == 'time-attack' || SONG.song.toLowerCase()=='top-loader')
							sustainNote.pixelPerfectRender=true;
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if (ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);
			case 'note tutorial':
				var tutorial = new FlxSprite();
				tutorial.frames = Paths.getSparrowAtlas('mech/sunky/SunkyTutorialBox');
				tutorial.cameras = [camHUD];
				tutorial.visible = false;
				tutorial.animation.addByPrefix('play','enter',24,false);
				tutorial.animation.play('play');
				add(tutorial);
			case 'TS Jumpscare':
				var daSound = new FlxSound().loadEmbedded(Paths.sound("datOneSound"));
				daSound.volume = 0.000001;
				daSound.play();
				
				var jumpscare = new FlxSprite();
				jumpscare.frames = Paths.getSparrowAtlas("jumpscrimbo");
				jumpscare.setGraphicSize(camSpec.width, camSpec.height);
				jumpscare.cameras = [camSpec];
				jumpscare.alpha = 0.000001;
				jumpscare.screenCenter();
				jumpscare.animation.addByPrefix("scare", "jumpscare0000", 24, false);
				jumpscare.animation.play("scare");
				add(jumpscare);
				jumpscare.x -= 1400;
			case 'TS PNG Jumpscare':
				// preload this shit
				var jump:FlxSprite = new FlxSprite().loadGraphic(Paths.image("scares/too-slow/jc_1"));
				jump.cameras = [camOther];
				jump.scale.set(0.75, 0.75);
				jump.alpha = 0.00001;
				jump.updateHitbox();
				jump.screenCenter(XY);
				add(jump);
				jump.x -= 1400;

				var jumpEyes:FlxSprite = new FlxSprite().loadGraphic(Paths.image("scares/too-slow/jc_2"));
				jumpEyes.cameras = [camOther];
				jumpEyes.scale.set(0.75, 0.75);
				jumpEyes.alpha = 0.00001;
				jumpEyes.updateHitbox();
				jumpEyes.screenCenter(XY);
				add(jumpEyes);
				jumpEyes.x -= 1400;
			case 'Dadbattle Spotlight':
				stage.dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
				stage.dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				stage.dadbattleBlack.alpha = 0.25;
				stage.dadbattleBlack.visible = false;
				add(stage.dadbattleBlack);

				stage.dadbattleLight = new BGSprite('spotlight', 400, -400);
				stage.dadbattleLight.alpha = 0.375;
				stage.dadbattleLight.blend = ADD;
				stage.dadbattleLight.visible = false;

				stage.dadbattleSmokes.alpha = 0.7;
				stage.dadbattleSmokes.blend = ADD;
				stage.dadbattleSmokes.visible = false;
				add(stage.dadbattleLight);
				add(stage.dadbattleSmokes);

				var offsetX = 200;
				var smoke:BGSprite = new BGSprite('smoke', -1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(15, 22);
				smoke.active = true;
				stage.dadbattleSmokes.add(smoke);
				var smoke:BGSprite = new BGSprite('smoke', 1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(-15, -22);
				smoke.active = true;
				smoke.flipX = true;
				stage.dadbattleSmokes.add(smoke);


		}

		if(!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	var defScale:Float = 1;

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if(!ClientPrefs.opponentStrums ) targetAlpha = 0;
				else if(ClientPrefs.middleScroll) targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote((ClientPrefs.middleScroll) ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				if (ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			defScale = babyArrow.scale.x;
			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (inst != null)
			{
				inst.pause();
				vocals.pause();
			}
			if (exeInst != null)
			{
				exeInst.pause();
				exeVox.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;


			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (inst != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}

			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		inst.play();
		inst.pitch = playbackRate;

		Conductor.songPosition = inst.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			vocals.pitch = playbackRate;
		}
		vocals.play();

		if(exeInst!=null){
			exeVox.pause();
			exeInst.time = inst.time;
			exeVox.time = vocals.time;
			exeInst.pitch = inst.pitch;
			exeVox.pitch = vocals.pitch;
			exeVox.play();
			exeInst.play();
		}
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	var updPiracy:Bool = false;
	var backdropScroll:Array<Float> = [0,0];
    var backdropScrollMult:Float = 1;
	public var bgPhase:Int = -1;
	var healthBarScroll(default, set):HPScroll=DEFAULT;
	function set_healthBarScroll(val:String){
		if(healthBarScroll==val)return val;
		reloadHealthBarColors();
		switch(val){
			case LEFT_TO_RIGHT: // you're on the left and going right
				iconP1.flipX = true;
				iconP2.flipX = true;
				healthBar.fillDirection = LEFT_TO_RIGHT;
			case RIGHT_TO_LEFT: // default, you're on the right and going left
				iconP1.flipX = false;
				iconP2.flipX = false;
				healthBar.fillDirection = RIGHT_TO_LEFT;

		}
		return healthBarScroll = val;
	}

	var grabbedNote:StrumNote; // keeps track of which note you've grabbed
	var sunkerNotesActivated:Bool = false;

	var sunkyNotePos:Array<Array<Float>> = [
		[0,0],
		[0,0],
		[0,0],
		[0,0]
	];

	var singTarget:String = '';

	override public function update(elapsed:Float)
	{

		/*if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}*/
		script.executeFunc("onUpdate", [elapsed]);


		/*if(healthBarScroll!="") healthBarVal=2-health; //left and right switch thingy
		else healthBarVal=health;*/
		
		var daHealth = health;
		switch(healthBarScroll){
			case LEFT_TO_RIGHT:
				daHealth = 2 - health;
			case RIGHT_TO_LEFT:
				daHealth = health;
		}
		healthBarVal = health;

		switch(SONG.song.toLowerCase()){
			case 'third-party':
				if (dad.curCharacter == 'piracy-sonic')
					{
						if (generatedMusic && !endingSong && !isCameraOnForcedPos)
							moveCameraSection();
						
						switch (dad.animation.curAnim.name)
						{
							case 'idle':
								triggerEventNote('Set Char Position','bf','655,85', Conductor.songPosition);
								triggerEventNote('Set Char Rotation','bf','0', Conductor.songPosition);
							case 'singLEFT':
								triggerEventNote('Set Char Position','bf','595,100', Conductor.songPosition);
								triggerEventNote('Set Char Rotation','bf','15', Conductor.songPosition);
							case 'singDOWN':
								triggerEventNote('Set Char Position','bf','660,90', Conductor.songPosition);
								triggerEventNote('Set Char Rotation','bf','15', Conductor.songPosition);
							case 'singUP':
								triggerEventNote('Set Char Position','bf','670,80', Conductor.songPosition);
								triggerEventNote('Set Char Rotation','bf','30', Conductor.songPosition);
							case 'singRIGHT':
								triggerEventNote('Set Char Position','bf','730,75', Conductor.songPosition);
								triggerEventNote('Set Char Rotation','bf','12', Conductor.songPosition);
						}
					}else if(dad.curCharacter == 'piracy-sonic3')
						charZoomMult = 1;
					
				if (bgPhase == 0)
					{
						stage.backdropPiracy.x += backdropScroll[0];
						stage.backdropPiracy.y += 0.2+backdropScroll[1];
						backdropScroll[0] = FlxMath.lerp(backdropScroll[0], 0, CoolUtil.boundTo(elapsed * 12, 0, 1));
						backdropScroll[1] = FlxMath.lerp(backdropScroll[1], 0, CoolUtil.boundTo(elapsed * 12, 0, 1));
					}
				if(updPiracy){
					try{
					//	piracyShader.shader.iTime.value[0] += elapsed; //null object!e!!!!11
						piracyShader2.shader.iTime.value[0] += elapsed;
					}
				}
			case 'top-loader':
				if(updPiracy){
					try{
						piracyShader2.shader.iTime.value[0] += elapsed;
					}
				}

			case 'time-attack':
				if(!practiceMode){
					if (rings < 0)
						health = -9999; // DIE!!!!!!!!
				}
					
				ringCount.text = zeroFormat(Math.floor(rings), 3);
		}
			
		callOnLuas('onUpdate', [elapsed]);

		/*switch (curStage)
		{
			case 'tank':
				moveTank(elapsed);
			case 'schoolEvil':
				if(!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished) {
					bgGhouls.visible = false;
				}
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyWindow.alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;

				if(phillyGlowParticles != null)
				{
					var i:Int = phillyGlowParticles.members.length-1;
					while (i > 0)
					{
						var particle = phillyGlowParticles.members[i];
						if(particle.alpha < 0)
						{
							particle.kill();
							phillyGlowParticles.remove(particle, true);
							particle.destroy();
						}
						--i;
					}
				}
			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoParticles.forEach(function(spr:BGSprite) {
						if(spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch(limoKillingState) {
						case 1:
							limoMetalPole.x += 5000 * elapsed;
							limoLight.x = limoMetalPole.x - 180;
							limoCorpse.x = limoLight.x - 50;
							limoCorpseTwo.x = limoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
							for (i in 0...dancers.length) {
								if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 170) {
									switch(i) {
										case 0 | 3:
											if(i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
									dancers[i].x += FlxG.width * 2;
								}
							}

							if(limoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if(limoSpeed < 1000) limoSpeed = 1000;

							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
							if(Math.round(bgLimo.x) == -150) {
								bgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if(limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + bgLimo.x + 280;
						}
					}
				}
			case 'mall':
				if(heyTimer > 0) {
					heyTimer -= elapsed;
					if(heyTimer <= 0) {
						bottomBoppers.dance(true);
						heyTimer = 0;
					}
				}
		}*/

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed * playbackRate, 0, 1);
			var offX:Float = 0;
			var offY:Float = 0;
			var focus:Character = boyfriend;
			if(SONG.notes[curSection]!=null){
				if (gf != null && SONG.notes[curSection].gfSection)
				{
					focus = gf;
				}else if (!SONG.notes[curSection].mustHitSection)
				{
					focus = dad;
				}
			}
			if(focus.animation.curAnim!=null){
				var name = focus.animation.curAnim.name;
				if(name.startsWith("singLEFT"))
					offX = -20;
				else if(name.startsWith("singRIGHT"))
					offX = 20;

				if(name.startsWith("singUP"))
					offY = -20;
				else if(name.startsWith("singDOWN"))
					offY = 20;


				offX *= noteMoveMultX;
				offY *= noteMoveMultY;
			}

			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x + offX, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y + offY, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		if(timeAttackStatic!=null){
			timeAttackStatic.alpha = FlxMath.lerp(timeAttackStatic.alpha, 0.00001, CoolUtil.boundTo(elapsed * 7, 0, 1));
		}

		camNotes.zoom = noteZoom * camHUD.zoom;
		camSpec.zoom = specZoom * camHUD.zoom;

		if(inTimeAttackCutscene){
			var lVal = ((Conductor.songPosition - (afterFade*1000)) / 1000) / (22 - afterFade);
			if(lVal>1)lVal=1;
			if(lVal<0)lVal=0;

			
			snapCamFollowToPos(FlxMath.lerp(2900, boyfriend.getMidpoint().x, lVal), camFollow.y);
			if(lVal>=1){
				isCameraOnForcedPos = false;
				inTimeAttackCutscene = false;
			}
		}

		for(shit in itimeUpdates){
			try{
				if(curSong.toLowerCase() == "piracy"){ shit.update(elapsed);
				}else{
					shit.iTime.value[0] += elapsed;
				}
			}catch(e){
				trace(e.message);
			}
		}
		
		heatShader.update(elapsed);
		super.update(elapsed);

		setOnLuas('curDecStep', curDecStep);
		setOnLuas('curDecBeat', curDecBeat);

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', [], false);
			if(ret != FunkinLua.Function_Stop) {
				openPauseMenu();
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
		{
			openChartEditor();
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		//var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		//iconP1.scale.set(mult, mult);
		//iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(0.6, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		//var mult:Float = FlxMath.lerp(1, iconP1.beatScale, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		//iconP1.beatScale = mult;

		var mult:Float = FlxMath.lerp(1, iconP2.beatScale, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP2.beatScale = mult;

		var iconOffset:Int = 26;

		var shitPercent = (daHealth / 2) * 100;
		var leftIcon = iconP2;
		var rightIcon = iconP1;
		switch(healthBarScroll){
			case LEFT_TO_RIGHT:
				leftIcon = iconP1;
				rightIcon =iconP2;
			case RIGHT_TO_LEFT: // default
				leftIcon = iconP2;
				rightIcon = iconP1;
		}
		//rightIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(shitPercent, 0, 100, 100, 0) * 0.01)) + (150 * rightIcon.beatScale - 150) / 2 - iconOffset;
		//leftIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(shitPercent, 0, 100, 100, 0) * 0.01)) - (150 * leftIcon.beatScale) / 2 - iconOffset * 2;
		if (health > 2)
			health = 2;

		var realPercent = (health/2) * 100;
		if (realPercent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (realPercent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}
		
		if (startedCountdown)
		{
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;
		}

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if(!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		}
		else
		{
			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if(ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					if(ClientPrefs.timeBarType != 'Song Name')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);

					if (SONG.song.toLowerCase() == 'time-attack')
						timeCount.text = '${zeroFormat(Std.parseInt(FlxStringUtil.formatTime(secondsTotal, false).split(':')[0]), 2)} ${FlxStringUtil.formatTime(secondsTotal, false).split(':')[1]}';
				}
			}

			// Conductor.lastSongPos = inst.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom * charZoomMult, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
			camHUD.zoom = FlxMath.lerp(defaultHudZoom, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned=true;
				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic && !inCutscene)
		{
			if(!cpuControlled) {
				keyShit();
			} else if(boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / inst.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}

			if(startedCountdown)
			{
				var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
				notes.forEachAlive(function(daNote:Note)
				{
					var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
					if(!daNote.mustPress) strumGroup = opponentStrums;

					var strumX:Float = strumGroup.members[daNote.noteData].x;
					var strumY:Float = strumGroup.members[daNote.noteData].y;
					var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
					var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
					var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
					var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

					strumX += daNote.offsetX;
					strumY += daNote.offsetY;
					strumAngle += daNote.offsetAngle;
					strumAlpha *= daNote.multAlpha;

					if (strumScroll) //Downscroll
					{
						//daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
						daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
					}
					else //Upscroll
					{
						//daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
						daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
					}

					var angleDir = strumDirection * Math.PI / 180;
					if (daNote.copyAngle)
						daNote.angle = strumDirection - 90 + strumAngle;

					if(daNote.copyAlpha)
						daNote.alpha = strumAlpha;

					if(daNote.copyX)
						daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

					switch(daNote.noteType){
						case 'Monitor Norm' | 'Monitor Exe' | 'Red Ring':
							daNote.alpha = daNote.evil == exeMix?1:0;
							daNote.blockHit = daNote.evil != exeMix;
					}

					if(daNote.copyY)
					{
						daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

						//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
						if(strumScroll && daNote.isSustainNote)
						{
							if (daNote.animation.curAnim.name.endsWith('end')) {
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
								if(PlayState.isPixelStage) {
									daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
								} else {
									daNote.y -= 19;
								}
							}
							daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
							daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
						}
					}

					if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
					{
						opponentNoteHit(daNote);
					}

					if(!daNote.blockHit && daNote.mustPress && cpuControlled && daNote.canBeHit) {
						if(daNote.isSustainNote) {
							if(daNote.canBeHit) {
								goodNoteHit(daNote);
							}
						} else if(daNote.strumTime <= Conductor.songPosition || daNote.isSustainNote) {
							goodNoteHit(daNote);
						}
					}

					var center:Float = strumY + Note.swagWidth / 2;
					if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
						(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						if (strumScroll)
						{
							if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (center - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
						else
						{
							if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}

					// Kill extremely late notes and cause misses
					if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
					{
						if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
							noteMiss(daNote);
						}

						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
			}
			else
			{
				notes.forEachAlive(function(daNote:Note)
				{
					daNote.canBeHit = false;
					daNote.wasGoodHit = false;
				});
			}
		}
		checkEventNote();

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				inst.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end


		if(sunkerNotesActivated){
			if(!FlxG.mouse.pressed && grabbedNote!=null)
				grabbedNote = null;
			
			for(idx in 1...playerStrums.members.length+1){
				var i = playerStrums.members[playerStrums.members.length-idx];
				if(FlxG.mouse.justPressed && grabbedNote==null){
					var startMousePos = FlxG.mouse.getScreenPosition(camNotes);
					if (startMousePos.x - i.x >= 0 && startMousePos.x - i.x <= i.width && startMousePos.y - i.y >= 0 && startMousePos.y - i.y <= i.height)
					{
						grabbedNote = i;
					}
				}
				if (sunkyNotePos[i.ID][0] != 0 && sunkyNotePos[i.ID][1] != 0)
				{
					i.x = FlxMath.lerp(i.x, sunkyNotePos[i.ID][0], CoolUtil.boundTo(elapsed * 4, 0, 1));
					i.y = FlxMath.lerp(i.y, sunkyNotePos[i.ID][1], CoolUtil.boundTo(elapsed * 4, 0, 1));
				}
			}

			
			if(grabbedNote!=null){
				sunkyNotePos[grabbedNote.ID][0] += FlxG.mouse.deltaX;
				sunkyNotePos[grabbedNote.ID][1] += FlxG.mouse.deltaY;
			}
			
		}

		// vv it does NOT work fine lmao
		// its really glitchy
		// so i rewritten it -neb ^

		/*if (sunkerNotesActivated) //mostly axion code cuz it works fine
		{
			for (i in playerStrums.members)
				{
					if (sunkyNotePos[i.ID][0] != 0 && sunkyNotePos[i.ID][1] != 0)
						{
							i.x = FlxMath.lerp(i.x, sunkyNotePos[i.ID][0], CoolUtil.boundTo(elapsed * 4, 0, 1));
							i.y = FlxMath.lerp(i.y, sunkyNotePos[i.ID][1], CoolUtil.boundTo(elapsed * 4, 0, 1));
						}
					if (FlxG.mouse.overlaps(i) && FlxG.mouse.pressed)
						{
							sunkyNotePos[i.ID] = [FlxG.mouse.getScreenPosition(camHUD).x,FlxG.mouse.getScreenPosition(camHUD).y];
						}
					if (FlxG.mouse.pressed && sortSK == -1)
					{
						var startMousePos = FlxG.mouse.getScreenPosition(camHUD);
						if (startMousePos.x - i.x >= 0 && startMousePos.x - i.x <= i.width && startMousePos.y - i.y >= 0 && startMousePos.y - i.y <= i.height)
						{
							sortSK = i.ID;
						}
					}
					if(!FlxG.mouse.pressed) {
						sortSK = -1;
					}
		
					if(sortSK == i.ID)
					{
						var mousePos = FlxG.mouse.getScreenPosition(camHUD);
						sunkyNotePos[i.ID][0] = mousePos.x - (i.width/2);
						sunkyNotePos[i.ID][1] = mousePos.y - (i.height/2);
					}
				}
		}*/

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
		script.executeFunc("onUpdatePost", [elapsed]);
	}

	var startMousePos:FlxPoint = new FlxPoint();
	var sortSK:Int = -1;
	function openPauseMenu()
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		// 1 / 1000 chance for Gitaroo Man easter egg
		/*if (FlxG.random.bool(0.1))
		{
			// gitaroo man easter egg
			cancelMusicFadeTween();
			MusicBeatState.switchState(new GitarooPause());
		}
		else {*/
		if(inst != null) {
			inst.pause();
			vocals.pause();
		}
		if(exeInst != null) {
			exeInst.pause();
			exeVox.pause();
		}
		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		//}

		#if desktop
		DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnLuas('onGameOver', [], false);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				inst.stop();
				if(exeInst!=null){
					exeVox.stop();
					exeInst.stop();
				}

				persistentUpdate = false;
				persistentDraw = false;
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2, leStrumTime);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	var me:FlxSprite;
	var top:FlxSprite;
	var left:FlxSprite;
	var right:FlxSprite;
	var iAmGod:Array<FlxSprite> = [];

	public function triggerEventNote(eventName:String, value1:String, value2:String, time:Float) {
		switch(eventName) {
			case 'hideScreen':
				var o:Float = Std.parseFloat(value2);
				var e:Null<Float> = Std.parseFloat(value1);
				if (e == null || Math.isNaN(e))
					e == 0.25;
					
				FlxTween.tween(camGame, {alpha: o},e, {ease: FlxEase.linear});
				FlxTween.tween(camHUD, {alpha: o},e, {ease: FlxEase.linear});
				FlxTween.tween(camNotes, {alpha: o},e, {ease: FlxEase.linear});
			case 'CamFlash':
				var val1 = Std.parseFloat(value1);
				camHUD.flash(FlxColor.WHITE,val1);
			case 'ghost mosaic':

			var shader = new MosaicShader();
			shader.pixelSize = 1;
			altDad.shader = shader;
			altDad2.shader = shader;
			FlxTween.tween(shader, {pixelSize: 40}, 0.6, {
				onComplete: function(twn:FlxTween)
				{
					altDad2.shader = null;
					altDad.shader = null;

				}
			});
			case 'dadColorFlash':
				dad.color = FlxColor.RED;
				FlxTween.tween(PlayState.instance.dad, {color: 0xFFFFFF},0.25,{ease: FlxEase.linear});
				

			case 'head transition':
				var val12:Array<Float> = [Std.parseFloat(value1.split(',')[0]),Std.parseFloat(value1.split(',')[1])];
				var val3 = Std.parseFloat(value2);

				//if (val12)

				var shader = new MosaicShader();
				shader.pixelSize = val12[0];
				dad.shader = shader;
				boyfriend.shader = shader;
				stage.backdropPiracy.shader = shader;
				FlxTween.tween(shader, {pixelSize: val12[1]}, val3, {
					onComplete: function(twn:FlxTween)
					{
						dad.shader = null;
						boyfriend.shader = null;
						stage.backdropPiracy.shader = null;
					}
				});

			case 'note tutorial':
				var tutorial = new FlxSprite();
				tutorial.frames = Paths.getSparrowAtlas('mech/sunky/SunkyTutorialBox');
				tutorial.cameras = [camHUD];
				tutorial.screenCenter(Y);
				tutorial.x = FlxG.width - tutorial.width;
				tutorial.animation.addByPrefix('play','enter',24,false);
				tutorial.animation.play('play');
				add(tutorial);
				tutorial.animation.finishCallback = function (name:String){
					tutorial.visible = false;
					remove(tutorial);
				}

			case 'reroyfuckingexplodes':
				var reroyexplodes:FlxSprite = new FlxSprite().loadGraphic(Paths.image('bgs/sunky/bl'),true,90,125);
				reroyexplodes.animation.add('explode',[0,1,2,3,4,5,6,7,8,9,10,11,12,12,12,12,12,12,12,12],12,false);
				reroyexplodes.animation.play('explode',true);
				reroyexplodes.setGraphicSize(2560);
				reroyexplodes.screenCenter();
				add(reroyexplodes);
				reroyexplodes.cameras = [camSpec];
			case 'tween camPos':
				var va1:Null<Float> = Std.parseFloat(value1.split(',')[0]);
				var va2:Null<Float> = Std.parseFloat(value1.split(',')[1]);
				var va3:Null<Float> = Std.parseFloat(value2);

				if ((Math.isNaN(va1)) && (Math.isNaN(va2))) {
					isCameraOnForcedPos = false;
				}
				else {
					FlxTween.tween(camFollow, {x: va1, y:va2},va3, {ease: FlxEase.sineInOut});
					isCameraOnForcedPos = true;
				}
			case 'Hide HUD':
				var d:Null<Float> = Std.parseFloat(value1);
				if (d == null || Math.isNaN(d))
					d = 0.5;
				FlxTween.tween(camHUD, {alpha: 0}, d);
				FlxTween.tween(camNotes, {alpha: 0}, d);
			case 'Show HUD':
				var d:Null<Float> = Std.parseFloat(value1);
				if (d == null || Math.isNaN(d))
					d = 0.5;
				FlxTween.tween(camHUD, {alpha: 1}, d);
				FlxTween.tween(camNotes, {alpha: 1}, d);
			case 'Dismiss Bars':
				FlxTween.tween(me, {y: FlxG.height}, 0.5, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween){
					remove(me);
					me.destroy();
					me = null;
				}});
				FlxTween.tween(top, {y: -top.scale.y}, 0.5, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween){
					remove(top);
					top.destroy();
					top = null;
				}});
				FlxTween.tween(right, {x: FlxG.width}, 0.5, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween){
					remove(right);
					right.destroy();
					right = null;
				}});
				FlxTween.tween(left, {x: -left.scale.x}, 0.5, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween){
					remove(left);
					left.destroy();
					left = null;
				}});
			case 'Letterboxing':
				var v:Null<Int> = Std.parseInt(value1);
				if (v == null || Math.isNaN(v))
					v = 150;
				var h:Null<Int> = Std.parseInt(value2);
				if (h == null || Math.isNaN(h))
					h = 0;

				if(me!=null){
					remove(me);
					me.destroy();
				}
				if(top!=null){
					remove(top);
					top.destroy();
				}
				if(left!=null){
					remove(left);
					left.destroy();
				}
				if(right!=null){
					remove(right);
					right.destroy();
				}
				me = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
				me.setGraphicSize(FlxG.width, v);
				
				me.y = FlxG.height;
				me.cameras = [camSpec];
				me.updateHitbox();

				top = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
				top.setGraphicSize(FlxG.width, v);
				
				top.y = -v;
				top.cameras = [camSpec];
				top.updateHitbox();

				left = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
				left.setGraphicSize(h, FlxG.height);
				
				left.x = -h;
				left.cameras = [camSpec];
				left.updateHitbox();

				right = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
				right.x = FlxG.width;

				right.setGraphicSize(h, FlxG.height);
				right.cameras = [camSpec];
				right.updateHitbox();


				if(v>0){
					add(me);
					add(top);

				}
				if(h>0){
					add(left);
					add(right);
				}
				
				top.screenCenter(X);
				me.screenCenter(X);
				left.screenCenter(Y);
				right.screenCenter(Y);

				FlxTween.tween(me, {y: FlxG.height - (me.scale.y)}, 0.5, {ease: FlxEase.quadOut});
				FlxTween.tween(top, {y: 0}, 0.5, {ease: FlxEase.quadOut});
				FlxTween.tween(right, {x: FlxG.width - (right.scale.x)}, 0.5, {ease: FlxEase.quadOut});
				FlxTween.tween(left, {x: 0}, 0.5, {ease: FlxEase.quadOut});
			case 'TS I Am God':
				var val:Null<Int> = Std.parseInt(value1);
				if(val==null)val = 1;
				if(val > 4)val = 4;
				if(val < 1)val = 1;

				if(val==4){
					for(shit in iAmGod)
						FlxTween.tween(shit, {alpha: 0}, 0.5);

					new SongTimer().startAbs((time / 1000) + 0.75, function(tmr:SongTimer){
						for(shit in iAmGod){
							remove(shit);
							shit.destroy();
						}
						
					});
					
				}else{
					var text:FlxSprite = new FlxSprite().loadGraphic(Paths.image("bgs/too-slow/god/i_am_god_" + val));
					text.cameras = [camSubs];
					text.screenCenter(XY);
					text.scale.set(1.05, 1.05);
					FlxTween.tween(text, {"scale.x": 1, "scale.y": 1}, 0.25);
					iAmGod.push(text);
					add(text);
				}
			case 'TS Jumpscare':
				var jumpscare = new FlxSprite();
				jumpscare.frames = Paths.getSparrowAtlas("jumpscrimbo");
				jumpscare.cameras = [camSpec];
				jumpscare.screenCenter(XY);
				jumpscare.y += 280;
				jumpscare.animation.addByPrefix("scare", "jumpscare", 24, false);
				jumpscare.animation.finishCallback = function(name: String){
					jumpscare.visible=false;
					jumpscare.alpha = 0;
					remove(jumpscare);
				}
				var sound = new FlxSoundGlobal();
				sound.loadEmbedded(Paths.sound("datOneSound"));
				sound.volume = 1;
				FlxG.sound.list.add(sound);
				sound.play();
				sound.autoDestroy = true;
				add(jumpscare);
				jumpscare.animation.play("scare", true);
			case 'TS Intro Flashbacks':
				var val:Null<Int> = Std.parseInt(value1);
				if(val==null)val = 1;
				if(val > 4)val = 4;
				if(val < 1)val = 1;

				var red:FlxSprite = new FlxSprite().loadGraphic(Paths.image("bgs/too-slow/deaths/amongus"));
				red.cameras = [camSpec];
				red.screenCenter(XY);
				var die:FlxSprite = new FlxSprite().loadGraphic(Paths.image("bgs/too-slow/deaths/kill_" + val));
				die.cameras = [camSpec];
				die.screenCenter(XY);
				if(val!=4){
					red.x += (red.width / 2) * (val%2 == 1 ? 1 : -1);
					die.x += (die.width / 2) * (val%2 == 1 ? 1 : -1);
				}else
					red.visible = false;
				
				add(red);
				add(die);
				if(val==4){
					FlxTween.tween(die, {alpha: 0}, 1.5, {startDelay: 2});
				}else{

					FlxTween.tween(red, {alpha: 0}, 0.5, {startDelay: 1});
					FlxTween.tween(die, {alpha: 0}, 0.65, {startDelay: 2});
				}

			case 'TS PNG Jumpscare':
				var val:Null<Float> = Std.parseFloat(value1);
				if (val == null || Math.isNaN(val))
					val = 0.2;
				var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
				bg.setGraphicSize(Std.int(FlxG.width*2), Std.int(FlxG.height*2));
				bg.updateHitbox();
				bg.cameras = [camSpec];
				add(bg);

				var jump:FlxSprite = new FlxSprite().loadGraphic(Paths.image("scares/too-slow/jc_1"));
				jump.cameras = [camOther];
				jump.scale.set(0.75, 0.75);
				jump.updateHitbox();
				jump.screenCenter(XY);
				add(jump);

				var jumpEyes:FlxSprite = new FlxSprite().loadGraphic(Paths.image("scares/too-slow/jc_2"));
				jumpEyes.cameras = [camOther];
				jumpEyes.scale.set(0.75, 0.75);
				jumpEyes.updateHitbox();
				jumpEyes.screenCenter(XY);
				add(jumpEyes);
				FlxG.camera.shake(0.0045, val + 0.2);
				camOther.shake(0.0045, val + 0.2);
				FlxG.sound.play(Paths.sound("PNGsareScary"), 1);
				new SongTimer().startAbs((time / 1000) + val, function(tmr:SongTimer){
					remove(bg);
					remove(jump);
					FlxTween.tween(jumpEyes, {alpha: 0}, 1, {onComplete:function(twn:FlxTween){
						remove(jumpEyes);
					}});
				});

				flashStatic(false, true, val > 0.2 ? val : null);
			case 'TS Intro Spotlight':
				if(stage.curStage!='angel-island'){
					trace("TS Intro Spotlight event should only b used on angel island stage");
					return;
				}
				var val:Null<Int> = Std.parseInt(value1);
				if (val == null)
					val = 0;
				var on:Bool = (Std.parseInt(value2)==null && value2.trim()=='') || !(Std.parseInt(value2) == 0 || value2.toLowerCase()=='false' || value2.toLowerCase()=='off');

				if(value1.toLowerCase() == 'dad')val = 0;
				if(value1.toLowerCase() == 'bf')val = 1;
				switch(val){
					case 0:
						FlxTween.tween(stage.spotlight1, {alpha: on?1:0}, 0.6);
						FlxTween.tween(dad, {alpha: on?1:0}, 0.6);
					case 1:
						FlxTween.tween(stage.spotlight2, {alpha: on?1:0}, 0.6);
						FlxTween.tween(boyfriend, {alpha: on?1:0}, 0.6);
					default:
						trace("too slow spotlight val 1 shud only be 0/dad or 1/bf");
				}
			case 'TS Intro Finish':
				if(stage.curStage!='angel-island'){
					trace("TS Intro Finish event should only b used on angel island stage");
					return;
				}

				defaultCamZoom = stageData.defaultZoom;
				FlxG.camera.flash(ClientPrefs.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 0.5);
				gf.alpha = 1;
				boyfriend.alpha= 1;
				dad.alpha = 1;
				stage.spotlight1.visible = false;
				stage.spotlight2.visible = false;
				for(object in stage.angelIsland){
					if(object!=stage.fire && object != stage.firewall){
						var shader = new MosaicShader();
						shader.pixelSize = 120;
						object.shader = shader;
						object.visible = true;
						FlxTween.tween(shader, {pixelSize: 1}, 1, {
							onComplete: function(twn:FlxTween)
							{
								object.shader = null;
							}
						});
					}
				}
				var shader = new HeatShader();
				shader.pixelSize = 120;
				stage.fire.shader = shader;
				stage.fire.visible = true;
				stage.firewall.shader = shader;
				stage.firewall.visible = true;

				FlxTween.tween(shader, {pixelSize: 1}, 1);
				itimeUpdates.push(shader);

				boyfriendGroup.x -= 300;
			case 'Dadbattle Spotlight':
				var val:Null<Int> = Std.parseInt(value1);
				if(val == null) val = 0;

				switch(Std.parseInt(value1))
				{
					case 1, 2, 3: //enable and target dad
						if(val == 1) //enable
						{
							stage.dadbattleBlack.visible = true;
							stage.dadbattleLight.visible = true;
							stage.dadbattleSmokes.visible = true;
							defaultCamZoom += 0.12;
						}

						var who:Character = dad;
						if(val > 2) who = boyfriend;
						//2 only targets dad
						stage.dadbattleLight.alpha = 0;
						new FlxTimer().start(0.12, function(tmr:FlxTimer) {
							stage.dadbattleLight.alpha = 0.375;
						});
						stage.dadbattleLight.setPosition(who.getGraphicMidpoint().x - stage.dadbattleLight.width / 2, who.y + who.height - stage.dadbattleLight.height + 50);

					default:
						stage.dadbattleBlack.visible = false;
						stage.dadbattleLight.visible = false;
						defaultCamZoom -= 0.12;
						FlxTween.tween(stage.dadbattleSmokes, {alpha: 0}, 1, {onComplete: function(twn:FlxTween)
						{
							stage.dadbattleSmokes.visible = false;
						}});
				}

			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;

						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				if(camFollow != null)
				{
					var val1:Float = Std.parseFloat(value1);
					var val2:Float = Std.parseFloat(value2);
					if(Math.isNaN(val1)) val1 = 0;
					if(Math.isNaN(val2)) val2 = 0;

					isCameraOnForcedPos = false;
					if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
						camFollow.x = val1;
						camFollow.y = val2;
						isCameraOnForcedPos = true;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}


			case 'Change Character':
				var charType:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnLuas('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();

			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2 / playbackRate, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}

			case 'Set Property':
				var killMe:Array<String> = value1.split('.');
				if(killMe.length > 1) {
					FunkinLua.setVarInArray(FunkinLua.getPropertyLoopThingWhatever(killMe, true, true), killMe[killMe.length-1], value2);
				} else {
					FunkinLua.setVarInArray(this, value1, value2);
				}
			case 'Set Char Position':
					var char:Character = dad;
					switch(value1.toLowerCase()) {
						case 'gf' | 'girlfriend':
							char = gf;
						case 'boyfriend' | 'bf':
							char = boyfriend;
						default:
							var val:Int = Std.parseInt(value1);
							if(Math.isNaN(val)) val = 0;
	
							switch(val) {
								case 1: char = boyfriend;
								case 2: char = gf;
							}
					}
	
					char.x = Std.parseFloat(value2.split(',')[0]);
					char.y = Std.parseFloat(value2.split(',')[1]);
				case 'Set Char Rotation':
					var char:Character = dad;
					switch(value1.toLowerCase()) {
						case 'gf' | 'girlfriend':
							char = gf;
						case 'boyfriend' | 'bf':
							char = boyfriend;
						default:
							var val:Int = Std.parseInt(value1);
							if(Math.isNaN(val)) val = 0;
		
							switch(val) {
								case 1: char = boyfriend;
								case 2: char = gf;
							}
					}
		
					char.angle = Std.parseFloat(value2);
				case 'Char Fade': //by axion and edited a bit to look better
					var char = altDad;
					if (value1.contains('dad'))
						char = dad;
					if (value1.contains('bf'))
						char = boyfriend;
				if (SONG.song.toLowerCase() == 'third-party'){
						if(char.alpha == 0){
							char.x = dad.x;
							FlxTween.tween(char, {x: char.x - 200, alpha: Std.parseFloat(value1.split(',')[0])}, Std.parseFloat(value2), {
								ease: FlxEase.cubeInOut
							});
							FlxTween.tween(altDad2, {x: char.x + 200, alpha: Std.parseFloat(value1.split(',')[0])}, Std.parseFloat(value2), {
								ease: FlxEase.cubeInOut
							});
						}else{
							FlxTween.tween(char, {x: dad.x, alpha: Std.parseFloat(value1.split(',')[0])}, Std.parseFloat(value2), {
								ease: FlxEase.cubeInOut
							});
							FlxTween.tween(altDad2, {x: dad.x, alpha: Std.parseFloat(value1.split(',')[0])}, Std.parseFloat(value2), {
								ease: FlxEase.cubeInOut
							});
						}
					}else{
						FlxTween.tween(char, {alpha: Std.parseFloat(value1.split(',')[0])}, Std.parseFloat(value2), {
							ease: FlxEase.cubeInOut
						});
					}
				case 'tween zoom':
					camZooming = true;
					FlxTween.tween(this,{defaultCamZoom:  Std.parseFloat(value1.split(',')[0])},  Std.parseFloat(value1.split(',')[1]), {ease: FlxEase.sineOut});
					FlxTween.tween(this,{defaultHudZoom:  Std.parseFloat(value2.split(',')[0])},  Std.parseFloat(value2.split(',')[1]), {ease: FlxEase.sineOut});
				case 'move cam sec':
					moveCamera(Std.string(value1));
				case 'Set BG phase':
					songQueEvents.switchPhase(Std.parseInt(value1));
				case 'runHaxeCode': //LES GOOO (hscript rip off cuz im lazy) //shit aint even work :😭 //DAMIT I THOUGHT I WAS HIM 😪
					FunkinLua.runHaxeCode(value1);
					FunkinLua.runHaxeCode(value2);
				case 'vine boom':
					balls++;
					// why put it all in an array lol? //was gonna destroy all the images after a while, never got to it tho
					imgDump[balls] = new FlxSprite().loadGraphic(Paths.image(value1));
					imgDump[balls].setGraphicSize(FlxG.width,FlxG.height);
					imgDump[balls].updateHitbox();
					imgDump[balls].cameras = [camHUD];
					homosexualImages.add(imgDump[balls]);
					if (value1 == 'bgs/sunky/wega')
						FlxG.sound.play(Paths.sound('wega'), 0.25); // god this is so unfunny
					FlxTween.tween(imgDump[balls], {alpha: 0}, Std.parseFloat(value2), {
						onComplete: function(twn:FlxTween)
						{
							homosexualImages.remove(imgDump[balls]);
							imgDump[balls].destroy();
						}
					});
				case 'fuck arrows':
					sunkyHandSpr.alpha = 1;
					sunkyHandSpr.animation.play('sc');
					sunkyHandSpr.animation.finishCallback=function(a:String){
						sunkyHandSpr.animation.finishCallback = null;
						sunkyHandSpr.alpha = 0.00001;
					}


					new FlxTimer().start(0.4,function(a:FlxTimer){
						sunkerNotesActivated = true;
						FlxG.mouse.enabled = true;
						FlxG.mouse.visible = true;
						for (i in playerStrums.members)
						{
							if(i!=grabbedNote){
								sunkyNotePos[i.ID][0] = defArrowPoses[i.ID][0]+FlxG.random.int(-180, 180);
								sunkyNotePos[i.ID][1] = defArrowPoses[i.ID][1]+FlxG.random.int(-70, 100);
							}
						}
					});
				case 'markiplier': //dk what the singtarget stuff is but ig ill keep it ??? //axion code
					if (singTarget == '')
					{
						singTarget = 'char1';
						altDad.alpha = 1;
						FlxTween.tween(altDad, {x: altDad.x+400, y: altDad.y+400}, 1, {
							ease: FlxEase.backOut,
							startDelay: Conductor.crochet * 0.002
						});
					}
					else
					{
						singTarget = '';
						FlxTween.tween(altDad, {x: altDad.x-400, y: altDad.y-400}, 1, {
							ease: FlxEase.backIn,
							onComplete: function(twn:FlxTween)
								{
									altDad.destroy();
								}
						});
					}
				case 'Sheet Anim': //idk what the fuck this is like huhhhh, did edit it a bit to work better with the sunky song but its mainly axion code
					if (value1 == 'none')
					{
						triggerEventNote('Change Character','dad',SONG.player2, time);
						dad.specialAnim = false;
						dad.animation.finishCallback = null;
					}
					else
					{
						var strChar:String = 'dad';
						var charType:Int = 1;
						var char = dad;
						if (value2.contains('gf'))
							{
								strChar = 'gf';
								charType = 2;
								char = gf;
							}
						switch(charType) {
							case 0:
								if(boyfriend.curCharacter != value2) {
									if(!boyfriendMap.exists(value2)) {
										addCharacterToList(value2, charType);
									}
		
									var lastAlpha:Float = boyfriend.alpha;
									boyfriend.alpha = 0.00001;
									boyfriend = boyfriendMap.get(value2);
									boyfriend.alpha = lastAlpha;
									iconP1.changeIcon(boyfriend.healthIcon);
								}
								setOnLuas('boyfriendName', boyfriend.curCharacter);
		
							case 1:
								if(dad.curCharacter != value2) {
									if(!dadMap.exists(value2)) {
										addCharacterToList(value2, charType);
									}
		
									var wasGf:Bool = dad.curCharacter.startsWith('gf');
									var lastAlpha:Float = dad.alpha;
									dad.alpha = 0.00001;
									dad = dadMap.get(value2);
									if(!dad.curCharacter.startsWith('gf')) {
										if(wasGf && gf != null) {
											gf.visible = true;
										}
									} else if(gf != null) {
										gf.visible = false;
									}
									dad.alpha = lastAlpha;
									iconP2.changeIcon(dad.healthIcon);
								}
								setOnLuas('dadName', dad.curCharacter);
		
							case 2:
								if(gf != null)
								{
									if(gf.curCharacter != value2)
									{
										if(!gfMap.exists(value2))
										{
											addCharacterToList(value2, charType);
										}
		
										var lastAlpha:Float = gf.alpha;
										gf.alpha = 0.00001;
										gf = gfMap.get(value2);
										gf.alpha = lastAlpha;
									}
									setOnLuas('gfName', gf.curCharacter);
								}
						}
						reloadHealthBarColors();
						char.playAnim(value1, true);
						char.specialAnim = true;
						char.animation.finishCallback = null;
						if (strChar == 'dad' && (value1 != 'gummy' && value2 != 'sunkyphone2'))
							{
								if(value1 != 'gummy2'){
									dad.animation.finishCallback = function(L:String)
										{
											triggerEventNote('Change Character','dad',SONG.player2, time);
											dad.specialAnim = false;
											dad.animation.finishCallback = null;
										}
								}else{
									dad.animation.finishCallback = null;
									triggerEventNote('Change Character','dad',"sunkyphone2", time);
									dad.animation.play("idle");
									dad.specialAnim = true;
								}

							}
					}
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	// TODO: rewrite this code lmao this code sucks
	function moveCameraSection():Void {
		if(SONG.notes[curSection] == null) return;

		if (gf != null && SONG.notes[curSection].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[curSection].mustHitSection || dad.curCharacter == 'piracy-sonic3')
		{
			moveCamera("true");
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera("false");
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var charZoomMult:Float = 1;
	var cameraTwn:FlxTween;
	public function moveCamera(isDadStr:String = "false")
	{	
		var isDad:Bool = false;
		switch(isDadStr){
			case "true":
				isDad = true;
		}

		if(dad.curCharacter == 'sunshineExe')isDad = true;
		if(isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];

			switch(dad.curCharacter){
				case 'piracy-sonic':
					charZoomMult = 0.8;
				default:
					charZoomMult = 1;
			}
			tweenCamIn();
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			switch(boyfriend.curCharacter){
				case 'piracy-bf':
					charZoomMult = 1.3;
				default:
					charZoomMult = 1;
			}

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	function snapCamMove(){
		camFollowPos.setPosition(camFollow.x, camFollow.y);
	}

	var itimeUpdates:Array<Dynamic> = [];

	function layerAoverB(a:Dynamic,b:Dynamic){ //secret histories layering
		remove(a);
		remove(b);
		add(b);
		add(a);
	}

	
	function flashStatic(opaque:Bool = false, mute:Bool = false, ?duration:Float){
		var noteStatic = new FlxSprite();
		noteStatic.frames = Paths.getSparrowAtlas("exestatic");

		noteStatic.setGraphicSize(camOther.width, camOther.height);
		noteStatic.cameras = [camOther];
		noteStatic.screenCenter();
		noteStatic.animation.addByPrefix("static", "staticFLASH", 24, duration==null?false:true);

		if(opaque)
			noteStatic.alpha = 1;
		else
			noteStatic.alpha = FlxG.random.float(0.3, 0.5);

		if(!mute)FlxG.sound.play(Paths.sound("staticBUZZ"), 1);
		if(duration==null){
			noteStatic.animation.finishCallback = function(name: String){
				noteStatic.visible=false;
				noteStatic.alpha = 0;
				remove(noteStatic);
			}
		}else{
			new SongTimer().start(duration, function(tmr:SongTimer){
				noteStatic.visible=false;
				noteStatic.alpha = 0;
				remove(noteStatic);
			});
		}
		noteStatic.animation.play("static", true);
		add(noteStatic);
	}


	function timeAtkJump(){

		FlxTween.tween(camNotes, {alpha: 0}, 1);
		FlxTween.tween(border, {alpha: 0}, 1);

		FlxTween.tween(timebarimg, {alpha: 0}, 1);
		FlxTween.tween(ringstxt, {alpha: 0}, 1);
		FlxTween.tween(ringCount, {alpha: 0}, 1);
		FlxTween.tween(timeCount, {alpha: 0}, 1);

		var glitchShader:Fuck = new Fuck();
		glitchShader.amount = 0;

		itimeUpdates.push(glitchShader);

		var filter = new ShaderFilter(glitchShader);

		camSpec.setFilters([filter]);
		
		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.setGraphicSize(Std.int(FlxG.width*2), Std.int(FlxG.height*2));
		bg.updateHitbox();
		bg.visible = false;
		bg.cameras = [camSpec];
		add(bg);

		var jump:FlxSprite = new FlxSprite().loadGraphic(Paths.image("scares/osr/jumpscare"));
		jump.cameras = [camSpec];
		jump.visible = false;
		jump.scale.set(0.5, 0.5);
		jump.updateHitbox();
		jump.screenCenter(XY);
		jump.pixelPerfectRender=true;
		add(jump);
		
		FlxG.sound.play(Paths.sound("OSRJumpscare"), 1);

		var daStatic = new FlxSprite(80, 64).loadGraphic(Paths.image('bgs/osr/static'), true, 208, 192);
		daStatic.animation.add('idle', [0, 1], 12);
		daStatic.animation.play('idle');
		daStatic.setGraphicSize(945);
		daStatic.updateHitbox();
		daStatic.scrollFactor.set(0, 0);
		daStatic.screenCenter(XY);
		daStatic.cameras = [camHUD];
		daStatic.alpha = 0.000001;
		add(daStatic);

		new FlxTimer().start(0.112, function(tmr:FlxTimer)
		{
			daStatic.alpha = 0.25;
			if(sTween!=null)sTween.cancel();
			sTween = FlxTween.tween(daStatic, {alpha: 0}, 0.85);
		});

		new FlxTimer().start(0.968, function(tmr:FlxTimer)
		{
			daStatic.alpha = 0.5;
			if(sTween!=null)sTween.cancel();
			sTween = FlxTween.tween(daStatic, {alpha: 0}, 0.85);
		});
		
		new FlxTimer().start(1.825, function(tmr:FlxTimer)
		{
			daStatic.alpha = 0.75;
			if(sTween!=null)sTween.cancel();
			sTween = FlxTween.tween(daStatic, {alpha: 0}, 0.85);
		});

		new FlxTimer().start(2.673, function(tmr:FlxTimer)
		{
			daStatic.alpha = 1;
			if(sTween!=null)sTween.cancel();
			sTween = FlxTween.tween(daStatic, {alpha: 0}, 0.85);
		});
		
		var baseY = jump.y;
		new FlxTimer().start(3.54, function(tmr:FlxTimer){
			daStatic.alpha = 0.2;
			if (sTween != null)
				sTween.cancel();
			bg.visible = true;
			jump.visible = true;
			for(i in 0...6){
				new FlxTimer().start(0.225 * i, function(tmr:FlxTimer){
					jump.y = baseY;
					if (jTween != null)
						jTween.cancel();
					jTween = FlxTween.tween(jump, {y: baseY + 25}, 0.225);
				});
			}
		});

		new FlxTimer().start(4.626, function(tmr:FlxTimer){
			glitchShader.amount = 0.5;
		});

		for(i in 0...8){
			new FlxTimer().start(4.626 + (.049 * i), function(tmr:FlxTimer){
				jump.y = baseY;
				if (jTween != null)
					jTween.cancel();
				jTween = FlxTween.tween(jump, {y: baseY + 25}, 0.049);
			});
		}

		new FlxTimer().start(4.991, function(tmr:FlxTimer){
			glitchShader.amount = 0;
			jump.visible=false;
		});

		new FlxTimer().start(5.048, function(tmr:FlxTimer)
		{
			glitchShader.amount = 0.5;
			jump.visible = true;
		});

		new FlxTimer().start(5.103, function(tmr:FlxTimer)
		{
			glitchShader.amount = 0;
			jump.visible = false;
		});

		new FlxTimer().start(5.156, function(tmr:FlxTimer)
		{
			camGame.visible=false;
			camHUD.visible=false;
			camSpec.shake(0.005, 100);
			glitchShader.amount = 0.75;
			glitchShader.speed = 0.25;
			jump.y = baseY;
			if (jTween != null)
				jTween.cancel();
			jump.visible = true;
		});

		new FlxTimer().start(11.963, function(tmr:FlxTimer){
			FlxTween.tween(jump, {"scale.x": 1, "scale.y": 0}, 0.25);
		});

		new FlxTimer().start(15, function(tmr:FlxTimer){
			endSong();
		});

	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		canPause = false;
		camZooming = false;

		inst.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(exeInst!=null){
			exeInst.volume = 0;
			exeVox.volume = 0;
			exeVox.pause();
		}

		if (SONG.song.toLowerCase() == 'third-party') {
			lime.app.Application.current.window.fullscreen = false;
		} 

		if(SONG.song.toLowerCase() == 'time-attack' && exeMix)
			finishCallback = timeAtkJump;
		
		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong():Void
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:String = checkForAchievement(['week1_nomiss', 'week2_nomiss', 'week3_nomiss', 'week4_nomiss',
				'week5_nomiss', 'week6_nomiss', 'week7_nomiss', 'ur_bad',
				'ur_good', 'hype', 'two_keys', 'toastie', 'debugger']);

			if(achieve != null) {
				startAchievement(achieve);
				return;
			}
		}
		#end

		var ret:Dynamic = callOnLuas('onEndSong', [], false);
		if(ret != FunkinLua.Function_Stop && !transitioning) {
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}
			playbackRate = 1;

			if (chartingMode)
			{
				openChartEditor();
				return;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					WeekData.loadTheFirstEnabledMod();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					cancelMusicFadeTween();
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					inst.stop();
					if(exeInst!=null)exeInst.stop();
					

					if(winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelMusicFadeTween();
							LoadingState.loadAndSwitchState(new PlayState());
						});
					} else {
						cancelMusicFadeTween();
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				WeekData.loadTheFirstEnabledMod();
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	public function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	public function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	private function cachePopUpScore()
	{
		var pixelShitPart1:String = '';
		var pixelShitPart2:String = '';
		if (isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		Paths.image(pixelShitPart1 + "sick" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "good" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "bad" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "shit" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "combo" + pixelShitPart2);
		
		for (i in 0...10) {
			Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2);
		}

		if (SONG.song.toLowerCase() == 'time-attack'){
			specZoom = daPixelZoom;
			taJudge = new FlxSprite().loadGraphic(Paths.image("ui/osr/judgements"), true, 66, 32);
			taJudge.animation.add("sick", [0], 0);
			taJudge.animation.add("good", [1], 0);
			taJudge.animation.add("bad", [2], 0);
			taJudge.animation.add("shit", [3], 0);
			taJudge.animation.play("sick", true);
			taJudge.cameras = [camSpec];
			taJudge.screenCenter();
			taJudge.x = (FlxG.width*0.35) -40;
			taJudge.y -= 60;
			taJudge.x += ClientPrefs.comboOffset[0];
			taJudge.y -= ClientPrefs.comboOffset[1];
			taJudge.visible = (!ClientPrefs.hideHud && showRating);
			taJudge.scale.set(0.5, 0.5);
			taJudge.updateHitbox();
			taJudge.pixelPerfectRender = true;
		}
	}

	var taJudge:FlxSprite;
	var taJudgeTween:FlxTween;

	private function osrJudge(judge:String):Void
	{
		taJudge.alpha = 1;
		taJudge.animation.play(judge, true);
		taJudge.screenCenter(XY);
		
		taJudge.y -= 5;
		if(taJudgeTween!=null)taJudgeTween.cancel();
		remove(taJudge);
		insert(members.indexOf(strumLineNotes), taJudge);
		taJudgeTween = FlxTween.tween(taJudge, {y: taJudge.y + 5}, 0.1 / playbackRate, {
			onComplete: function(tween:FlxTween)
			{
				taJudgeTween = FlxTween.tween(taJudge, {alpha: 0}, 0.2 / playbackRate, {
					onComplete: function(tween:FlxTween)
					{
						taJudgeTween = null;
						remove(taJudge);
					},
					startDelay: (Conductor.crochet / 1000) / playbackRate
				});
			},
		});
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		//trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		vocals.volume = daVoxVol;
		if(exeVox!=null)
			exeVox.volume = exeVoxVol;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(note, noteDiff / playbackRate);

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.increase();
		note.rating = daRating.name;
		score = daRating.score;

		if(daRating.noteSplash && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}

		if(!practiceMode && !cpuControlled) {
			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}
		}

		if (SONG.song.toLowerCase() == 'time-attack')
			return osrJudge(daRating.image);

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating.image + pixelShitPart2));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550 * playbackRate * playbackRate;
		rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
		rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
		rating.visible = (!ClientPrefs.hideHud && showRating);
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
		comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
		comboSpr.visible = (!ClientPrefs.hideHud && showCombo);
		comboSpr.x += ClientPrefs.comboOffset[0];
		comboSpr.y -= ClientPrefs.comboOffset[1];
		comboSpr.y += 60;
		comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;
		insert(members.indexOf(strumLineNotes), rating);
		
		if (!ClientPrefs.comboStacking)
		{
			if (lastRating != null) lastRating.kill();
			lastRating = rating;
		}

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		var xThing:Float = 0;
		if (showCombo)
		{
			insert(members.indexOf(strumLineNotes), comboSpr);
		}
		if (!ClientPrefs.comboStacking)
		{
			if (lastCombo != null) lastCombo.kill();
			lastCombo = comboSpr;
		}
		if (lastScore != null)
		{
			while (lastScore.length > 0)
			{
				lastScore[0].kill();
				lastScore.remove(lastScore[0]);
			}
		}
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];
			
			if (!ClientPrefs.comboStacking)
				lastScore.push(numScore);

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
			numScore.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
			numScore.velocity.x = FlxG.random.float(-5, 5) * playbackRate;
			numScore.visible = !ClientPrefs.hideHud;

			//if (combo >= 10 || combo == 0)
			if(showComboNum)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});

			daLoop++;
			if(numScore.x > xThing) xThing = numScore.x;
		}
		comboSpr.x = xThing + 50;
		/*
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2 / playbackRate, {
			startDelay: Conductor.crochet * 0.001 / playbackRate
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2 / playbackRate, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002 / playbackRate
		});
	}

	public var strumsBlocked:Array<Bool> = [];
	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = inst.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (strumsBlocked[daNote.noteData] != true && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && !daNote.blockHit)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else{
					callOnLuas('onGhostTap', [key]);
					if (canMiss) {
						noteMissPress(key);
					}
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				if (SONG.song == 'party-streamers')
					sillyTween(spr);
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var parsedHoldArray:Array<Bool> = parseKeys();

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var parsedArray:Array<Bool> = parseKeys('_P');
			if(parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if(parsedArray[i] && strumsBlocked[i] != true)
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (strumsBlocked[daNote.noteData] != true && daNote.isSustainNote && parsedHoldArray[daNote.noteData] && daNote.canBeHit
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.blockHit) {
					goodNoteHit(daNote);
				}
			});

			if (parsedHoldArray.contains(true) && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			}
			else if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / inst.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode || strumsBlocked.contains(true))
		{
			var parsedArray:Array<Bool> = parseKeys('_R');
			if(parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if(parsedArray[i] || strumsBlocked[i] == true)
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	private function parseKeys(?suffix:String = ''):Array<Bool>
	{
		var ret:Array<Bool> = [];
		for (i in 0...controlArray.length)
		{
			ret[i] = Reflect.getProperty(controls, controlArray[i] + suffix);
		}
		return ret;
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;
		
		switch(SONG.song.toLowerCase()){
			case "time-attack":
				rings -= ((exeMix) ? 2 : 1) * healthLoss;
				ringCount.text = zeroFormat(rings, 3);
			default:
				health -= daNote.missHealth * healthLoss;
			case "twisted":
				health -= daNote.missHealth * healthLoss;
			case "top-loader":
				health -= daNote.missHealth * healthLoss;
		}

		if(instakillOnMiss)
		{
			vocals.volume = 0;
			if(exeVox!=null)exeVox.volume = 0;
			
			doDeathCheck(true);
		}

		//For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		if (exeVox != null)
			exeVox.volume = 0;
		if(!practiceMode) songScore -= 10;

		totalPlayed++;
		RecalculateRating(true);

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char != null && !daNote.noMissAnimation && char.hasMissAnimations)
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daNote.animSuffix;
			char.playAnim(animToPlay, true);
		}
		script.executeFunc("noteMiss", [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if(ClientPrefs.ghostTapping) return; //fuck it

		if (!boyfriend.stunned)
		{
			health -= 0.05 * healthLoss;
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				if (exeVox != null)
					exeVox.volume = 0;
				doDeathCheck(true);
			}

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating(true);

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
			if (exeVox != null)
				exeVox.volume = 0;
		}
		callOnLuas('noteMissPress', [direction]);
	}

	function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection) {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var char2:Character = null;
			switch (dad.curCharacter)
			{
				case 'piracy-sonic2':
					if (FlxG.random.bool(50))
						altAnim = '-alt';

			}
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			trace(altAnim);
			if (singTarget != '' || note.singTarget != '')
			{
				var singTargetSwitch:String = ((singTarget != '') ? singTarget : note.singTarget);
				switch(singTargetSwitch)
				{
					case 'gf':
						char2 = gf;
					case 'char1':
						char = altDad;
					case 'char2':
						char = altDad;
				}
			}
			if(note.gfNote) {
				char = gf;
			}

			if(char != gf){
				iconP2.scale.set(0.8, 0.8);
				iconP2.updateHitbox();
			}

			if(char != null)
			{
				if(SONG.song.toLowerCase() == 'third-party' && altDad.alpha != 0) {
					altDad.playAnim(animToPlay, true);
					altDad2.playAnim(animToPlay, true);					
				}
				char.playAnim(animToPlay, true);
				if (char2 != null)
					char2.playAnim(animToPlay, true);
				char.holdTimer = 0;			}
		}

		if (bgPhase == 0)
			switch (Std.int(Math.abs(note.noteData)))
			{
				case 0:
					backdropScroll[0] = -backdropScrollMult;
				case 1:
					backdropScroll[1] = backdropScrollMult;
				case 2:
					backdropScroll[1] = -backdropScrollMult;
				case 3:
					backdropScroll[0] = backdropScrollMult;
			}

		if (SONG.needsVoices)
			vocals.volume = daVoxVol;

		if(exeVox!=null)
			exeVox.volume = exeVoxVol;

		var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)), time);
		note.hitByOpponent = true;

		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function zeroFormat(leNum:Float,zeros:Int):String
	{
		if(Math.isNaN(leNum)) leNum = 0;
		var returnVal = Std.string(leNum).split('');
		if (returnVal.length < zeros){
			for(idx in returnVal.length...zeros)
				returnVal.unshift('0');
		}
		return returnVal.join("");
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				if(note.noteType == 'Red Ring')
					FlxG.sound.play(Paths.sound('red_ring'), 0.35);
				else
					FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}else if(note.noteType == 'Red Ring')
				FlxG.sound.play(Paths.sound('red_ring'), 0.35);

			switch(note.noteType) {
				case 'Monitor Norm' | 'Monitor Exe':
					exeMix = !exeMix;
				case 'Red Ring':
					if (SONG.song.toLowerCase() == 'time-attack')
						rings = Math.round(Math.abs(rings/2)+1);
					else
						health /= 2;
				default:
					if (SONG.song.toLowerCase() == 'time-attack'){
						if(!note.isSustainNote)
							rings += (exeMix ? -healthLoss : healthGain);
					}
			}
			

			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				if(!note.noMissAnimation)
				{
					switch(note.noteType) {
						case 'Hurt Note': //Hurt note
							if(boyfriend.animation.getByName('hurt') != null) {
								boyfriend.playAnim('hurt', true);
								boyfriend.specialAnim = true;
							}
					}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote && note.noteType != 'Red Ring' && note.noteType != 'Monitor Norm' && note.noteType != 'Monitor Exe')
			{
				combo += 1;
				if(combo > 9999) combo = 9999;
				popUpScore(note);
			}
			health += note.hitHealth * healthGain;

			if(!note.noAnimation) {
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				if(note.gfNote)
				{
					if(gf != null)
					{
						gf.playAnim(animToPlay + note.animSuffix, true);
						gf.holdTimer = 0;
					}
				}
				else
				{
					iconP1.scale.set(1.2, 1.2);
					iconP1.updateHitbox();

					boyfriend.playAnim(animToPlay + note.animSuffix, true);
					boyfriend.holdTimer = 0;
				}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}

					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)), time);
			} else {
				var spr = playerStrums.members[note.noteData];
				if(spr != null)
				{
					if (SONG.song == 'party-streamers')
						sillyTween(spr);
					spr.playAnim('confirm', true);
				}
			}
			note.wasGoodHit = true;
			vocals.volume = daVoxVol;
			if(exeVox!=null)exeVox.volume = exeVoxVol;
			
			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}

		}
	}

	public function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		var hue:Float = 0;
		var sat:Float = 0;
		var brt:Float = 0;
		if (data > -1 && data < ClientPrefs.arrowHSV.length)
		{
			hue = ClientPrefs.arrowHSV[data][0] / 360;
			sat = ClientPrefs.arrowHSV[data][1] / 100;
			brt = ClientPrefs.arrowHSV[data][2] / 100;
			if(note != null) {
				skin = note.noteSplashTexture;
				hue = note.noteSplashHue;
				sat = note.noteSplashSat;
				brt = note.noteSplashBrt;
			}
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}


	var startedMoving:Bool = false;

	override function destroy() {
		for (lua in luaArray) {
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = [];

		#if hscript
		if(FunkinLua.hscript != null) FunkinLua.hscript = null;
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		FlxAnimationController.globalSpeed = 1;
		if (exeInst != null)
			exeInst.pitch = 1;
		inst.pitch = 1;
		super.destroy();
	}

	public function cancelMusicFadeTween() {
		if(inst.fadeTween != null) {
			inst.fadeTween.cancel();
		}

		inst.fadeTween = null;

		if(exeInst!=null){
			if(exeInst.fadeTween != null) {
				exeInst.fadeTween.cancel();
			}
			exeInst.fadeTween = null;
		}
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(inst.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)))
		{
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}
		if(curStep==1){
			for (i in playerStrums)
				defArrowPoses.push([i.x, i.y]);
		}
		

		stage.stepHit(curStep);
		lastStepHit = curStep;
		script.executeFunc("onStepHit");


		songQueEvents.stepHit(curStep,curBeat);
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		super.beatHit();

		script.executeFunc("onBeatHit");

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		//iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(0.8, 0.8);

		//iconP1.beatScale = 1.2;
		iconP2.beatScale = 1.2;
		//iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
		{
			gf.dance();
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
		{
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
		{
			dad.dance();
		}

		/*
		}*/
		stage.beatHit(curBeat);

		if (camZooming && curBeat % beatsPerZoom == 0 && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms)
			{
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
			}

		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat); //DAWGG?????
		callOnLuas('onBeatHit', []);
	}

	override function sectionHit()
	{
		super.sectionHit();
		stage.sectionHit(curSection);

		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
			{
				moveCameraSection();
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[curSection].bpm);
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnLuas('altAnim', SONG.notes[curSection].altAnim);
			setOnLuas('gfSection', SONG.notes[curSection].gfSection);
		}
		
		setOnLuas('curSection', curSection);
		callOnLuas('onSectionHit', []);
	}

	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			var ret:Dynamic = script.call(event, args);
			if(ret == FunkinLua.Function_StopLua && !ignoreStops)
				break;
			
			// had to do this because there is a bug in haxe where Stop != Continue doesnt work
			var bool:Bool = ret == FunkinLua.Function_Continue;
			if(!bool && ret != 0) {
				returnVal = cast ret;
			}
		}
		#end
		//trace(event, returnVal);
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			if (SONG.song == 'party-streamers')
				sillyTween(spr);
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	function sillyTween(spr:FlxSprite)
		{
			FlxTween.tween(spr.scale, {x: (spr.scale.x)+0.2, y: (spr.scale.y)-0.2}, 0.1, {
				ease: FlxEase.expoOut,
				onComplete: function(tween:FlxTween)
				{
					FlxTween.tween(spr.scale, {x: (spr.scale.x)-0.4, y: (spr.scale.y)+0.4}, 0.1, {
						ease: FlxEase.expoOut,
						onComplete: function(tween:FlxTween)
						{
							FlxTween.tween(spr.scale, {x: defScale, y: defScale}, 0.05, {
								ease: FlxEase.expoOut
							});
						}
					});
				}
			});
		}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating(badHit:Bool = false) {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', [], false);
		if(ret != FunkinLua.Function_Stop)
		{
			if(totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if(ratingPercent >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length-1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0) ratingFC = "SFC";
			if (goods > 0) ratingFC = "GFC";
			if (bads > 0 || shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			else if (songMisses >= 10) ratingFC = "Clear";
		}
		updateScore(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce -Ghost
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
	}

	#if ACHIEVEMENTS_ALLOWED
	public function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		if(chartingMode) return null;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		for (i in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[i];
			if(!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled) {
				var unlock:Bool = false;
				
				if (achievementName.contains(WeekData.getWeekFileName()) && achievementName.endsWith('nomiss')) // any FC achievements, name should be "weekFileName_nomiss", e.g: "weekd_nomiss";
				{
					if(isStoryMode && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'HARD'
						&& storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
						unlock = true;
				}
				switch(achievementName)
				{
					case 'ur_bad':
						if(ratingPercent < 0.2 && !practiceMode) {
							unlock = true;
						}
					case 'ur_good':
						if(ratingPercent >= 1 && !usedPractice) {
							unlock = true;
						}
					case 'roadkill_enthusiast':
						if(Achievements.henchmenDeath >= 100) {
							unlock = true;
						}
					case 'oversinging':
						if(boyfriend.holdTimer >= 10 && !usedPractice) {
							unlock = true;
						}
					case 'hype':
						if(!boyfriendIdled && !usedPractice) {
							unlock = true;
						}
					case 'two_keys':
						if(!usedPractice) {
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length) {
								if(keysPressed[j]) howManyPresses++;
							}

							if(howManyPresses <= 2) {
								unlock = true;
							}
						}
					case 'toastie':
						if(/*ClientPrefs.framerate <= 60 &&*/ !ClientPrefs.shaders && ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing) {
							unlock = true;
						}
					case 'debugger':
						if(Paths.formatToSongPath(SONG.song) == 'test' && !usedPractice) {
							unlock = true;
						}
				}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end

	//some gimicks and stuff 

	public function enterprizeGimicks(gimick:String,params:Array<Dynamic>){
        switch(gimick){
            case "hp flip":
                var hps = [healthBar,healthBarBG];
                var timer:Float=0.5;
                if(Std.is(params[0],Float))timer=params[0];
                trace(timer);
                var doneSwitch:Bool;
                for(i in hps){
                    //removed everything from here cuz it was shit and i had to go
                    //will code in a bit
                }
        }
    }


	override function switchTo(state:FlxState){
		stage.switchingState();
		if(SONG.song.toLowerCase()=='time-attack'|| SONG.song.toLowerCase()=='top-loader' || SONG.song.toLowerCase() == 'redolled'){
			var resX:Int = 1280;
			var resY:Int = 720;

			FlxG.resizeWindow(resX, resY);
			//FlxG.resizeGame(resX, resY);

			FlxG.scaleMode = new RatioScaleMode(false);
			lime.app.Application.current.window.resizable = true;

			var window = lime.app.Application.current.window;
			window.resizable = true;
			window.x = Math.floor((Capabilities.screenResolutionX / 2) - (resX / 2));
			window.y = Math.floor((Capabilities.screenResolutionY / 2) - (resY / 2));
		}

		return true;
	}

	var curLight:Int = -1;
	var curLightEvent:Int = -1;





	var formattedFolder:String;
	var path:String;
	var hxdata:String;

	public function startScript(name:String = "script")
		{
			formattedFolder = Paths.formatToSongPath(SONG.song);
			path = Paths.hscript(formattedFolder + '/$name' );
			if (FileSystem.exists(path))
				hxdata = File.getContent(path);
	
			if (hxdata != "")
			{
				script = new Script();
	
				script.setVariable("onSongStart", function()
				{
				});
	
			
				script.setVariable("destroy", function()
				{
				});
	
				script.setVariable("onCreate", function()
				{
				});
				script.setVariable("onCreatePost", function()
				{
				});
				script.setVariable("onStartCountdown", function()
				{
				});
	
				script.setVariable("onStepHit", function()
				{
				});
	
				script.setVariable("goodNoteHit", function()
				{
				});

				script.setVariable("postGoodNoteHit", function()
				{
				});
				script.setVariable("opponentNoteHit", function()
				{
				});

				script.setVariable("noteMiss", function()
				{
				});

				
				script.setVariable("noteMissPress", function()
				{
				});

				script.setVariable("onUpdate", function()
				{
				});
				
				script.setVariable("onUpdatePost",function(){
				});
	
				script.setVariable("import", function(lib:String, ?as:Null<String>) // Does this even work?
				{
					if (lib != null && Type.resolveClass(lib) != null)
					{
						script.setVariable(as != null ? as : lib, Type.resolveClass(lib));
					}
				});

				script.setVariable("BlendMode",flash.display.BlendMode.OVERLAY);

				
	
				script.setVariable("fromRGB", function(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255)
				{
					return FlxColor.fromRGB(Red, Green, Blue, Alpha);
				});

				script.setVariable("ShaderFilter",ShaderFilter);
				script.setVariable("curStep", curStep);
				script.setVariable("bpm", SONG.bpm);
				
				script.setVariable("Note", Note);
				script.setVariable("PlayState", instance);
				script.setVariable("camHUD", instance.camHUD);
				script.setVariable("camOther", instance.camOther);
				script.setVariable("camGame", instance.camGame);
				script.setVariable("FlxTween", FlxTween);
				script.setVariable("FlxEase", FlxEase);
				script.setVariable("PINGPONG", PINGPONG);
				script.setVariable("FlxSprite", FlxSprite);
				script.setVariable("Math", Math);
				script.setVariable("FlxG", FlxG);
				script.setVariable("ClientPrefs", ClientPrefs);
				script.setVariable("FlxTimer", FlxTimer);
				script.setVariable("Main", Main);
				script.setVariable("Conductor", Conductor);
				script.setVariable("Std", Std);
				script.setVariable("FlxTextBorderStyle", FlxTextBorderStyle);
				script.setVariable("Paths", Paths);
				script.setVariable("CENTER", FlxTextAlign.CENTER);
				script.setVariable("FlxTextFormat", FlxTextFormat);
				script.setVariable("InputFormatter", InputFormatter);
				script.setVariable("FlxTextFormatMarkerPair", FlxTextFormatMarkerPair);
				script.setVariable("FlxTypedGroup", FlxTypedGroup);
				script.setVariable("GameOverSubstate", GameOverSubstate);
						//  NOTE FUNCTIONS
				script.setVariable("spawnNote", function(?note:Note) {}); // ! HAS PAUSE
				script.setVariable("hitNote", function(?note:Note) {});
				script.setVariable("oppHitNote", function(?note:Note) {});
				script.setVariable("missNote", function(?note:Note) {});

				script.setVariable("notesUpdate", function() {}); // ! HAS PAUSE

				script.setVariable("ghostTap", function(?direction:Int) {});

				//  EVENT FUNCTIONS
				script.setVariable("event", function(?event:String, ?val1:Dynamic, ?val2:Dynamic) {}); // ! HAS PAUSE
				script.setVariable("earlyEvent", function(event:String) {});

				//  PAUSING / RESUMING
				script.setVariable("pause", function() {}); // ! HAS PAUSE
				script.setVariable("resume", function() {}); // ! HAS PAUSE


				//  GAMEOVER
				script.setVariable("gameOver", function() {}); // ! HAS PAUSE

				//  MISC
				script.setVariable("updatePost", function(?elapsed:Float) {});
				script.setVariable("recalcRating", function(?badHit:Bool = false) {}); // ! HAS PAUSE
				script.setVariable("updateScore", function(?miss:Bool = false) {}); // ! HAS PAUSE

				// VARIABLES

				script.setVariable("onFocusLost", function() {});
				script.setVariable("onFocus", function() {});
				script.setVariable("curStep", 0);
				script.setVariable("curBeat", 0);
				script.setVariable("bpm", 0);

				// OBJECTS
				script.setVariable("camGame", camGame);
				script.setVariable("camHUD", camHUD);
				script.setVariable("camOther", camOther);

				script.setVariable("camFollow", camFollow);
				script.setVariable("camFollowPos", camFollowPos);

				// CHARACTERS
				script.setVariable("boyfriend", boyfriend);
				script.setVariable("dad", dad);
				script.setVariable("gf", gf);

				script.setVariable("boyfriendGroup", boyfriendGroup);
				script.setVariable("dadGroup", dadGroup);
				script.setVariable("gfGroup", gfGroup);

				// NOTES
				script.setVariable("notes", notes);
				script.setVariable("strumLineNotes", strumLineNotes);
				script.setVariable("playerStrums", playerStrums);
				script.setVariable("opponentStrums", opponentStrums);

				script.setVariable("unspawnNotes", unspawnNotes);

				script.setVariable("@:functionCode",function(string:String)
				{
					@:functionCode(string)
					var a = function(res:Int = 1){
						return res;
					}
					a();
				});


				// MISC
				script.setVariable("add", function(obj:FlxBasic, ?front:Bool = false)
				{
					if (front)
					{
						getInstance().add(obj);
					}
					else
					{
						if (PlayState.instance.isDead)
						{
							GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), obj);
						}
						else
						{
							var position:Int = PlayState.instance.members.indexOf(PlayState.instance.gfGroup);
							if (PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup) < position)
							{
								position = PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup);
							}
							else if (PlayState.instance.members.indexOf(PlayState.instance.dadGroup) < position)
							{
								position = PlayState.instance.members.indexOf(PlayState.instance.dadGroup);
							}
							PlayState.instance.insert(position, obj);
						}
					}
				});
				script.runScript(hxdata);
			}
		}	

	public static inline function getInstance()
		{
			return PlayState.instance.isDead ? GameOverSubstate.instance : PlayState.instance;
		}
}






class Script extends FlxBasic
{
	public var hscript:Interp;

	public override function new()
	{
		super();
		hscript = new Interp();
	}

	public function runScript(script:String)
	{
		var parser = new hscript.Parser();

		try
		{
			var ast = parser.parseString(script);

			hscript.execute(ast);
		}
		catch (e)
		{
            trace(e.message);
			Lib.application.window.alert(e.message, "hscript error");
		}
	}

	public function setVariable(name:String, val:Dynamic)
	{
		hscript.variables.set(name, val);
	}

	public function getVariable(name:String):Dynamic
	{
		return hscript.variables.get(name);
	}

	public function executeFunc(funcName:String, ?args:Array<Any>):Dynamic
	{
		if (hscript == null)
			return null;

		if (hscript.variables.exists(funcName))
		{
			var func = hscript.variables.get(funcName);
			if (args == null)
			{
				var result = null;
				try
				{
					result = func();
				}
				catch (e)
				{
					trace('$e');
				}
				return result;
			}
			else
			{
				var result = null;
				try
				{
					result = Reflect.callMethod(null, func, args);
				}
				catch (e)
				{
					trace('$e');
				}
				return result;
			}
		}
		return null;
	}

	public override function destroy()
	{
		super.destroy();
		hscript = null;
	}
}