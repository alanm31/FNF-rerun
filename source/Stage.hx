package;

import StageData.StageFile;
import flixel.addons.effects.FlxTrail;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import FunkinLua.ModchartSprite;
import sys.FileSystem;
import flixel.system.FlxSound;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.addons.display.FlxBackdrop;
#if LUA_ALLOWED
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
#end

class Stage extends FlxTypedGroup<FlxBasic> {

    // useful vars provided by playstate
    public var gf:Character;
    public var boyfriend:Character;
    public var dad:Character;

	public var curBeat:Int = 0;
	public var curStep:Int = 0;
    public var curSection:Int = 0;
    // static funcs

    public inline static function getDefaultStage(?songName:String){
		if (songName==null)
			if (PlayState.SONG==null)
                songName = PlayState.SONG.song;
            else
                songName = 'test';
        
		switch (songName.toLowerCase())
		{
			default:
				return 'stage';
		}
    }

	public static function getStageFile(stage:String){
		var stageData = StageData.getStageFile(stage);
		if (stageData == null)
		{ // Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}
		return stageData;
    }
    // useful stage things

	public var hudElements:Array<FlxSprite> = []; // any states which use Stage should set these to the HUD cam, after it calls 'stage.afterCharacters()'
	public var foreground:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
    // TODO: maybe some sorta foreground shit idk

    // stage parts
	//------------------------------------------------//

    // week 1
	public var dadbattleBlack:BGSprite;
	public var dadbattleLight:BGSprite;
	public var dadbattleSmokes:FlxSpriteGroup;

	// too slow
	public var angelIsland:Array<FlxSprite> = [];
	public var spotlight1:FlxSprite;
	public var spotlight2:FlxSprite;
	public var firewall:FlxSprite;
	public var fire:FlxSprite;
    // time attack
	public var goodClouds1:BGTiledSprite;
	public var goodClouds2:BGTiledSprite;
	public var goodClouds3:BGTiledSprite;
	public var evilClouds1:BGTiledSprite;
	public var evilClouds2:BGTiledSprite;
	public var evilClouds3:BGTiledSprite;

	public var cutsceneHill:FlxSprite;
	public var cutsceneFlwr:FlxSprite;
	public var goodFlwr:FlxSprite;
	public var goodHill:FlxSprite;
	public var evilFlwr:FlxSprite;
	public var evilHill:FlxSprite;
	public var doWaterUpdate:Bool = false;

	public var goodShader:WaterShader;
	public var evilShader:WaterShader;

	public var waterShaderTimer:Float = 0;

    public var evilSprites:Array<FlxSprite> = [];
    public var goodSprites:Array<FlxSprite> = [];
 
	// Google
	public var streetviewMap:FlxSprite;
	public var mapControls:FlxSprite;
	public var maniacard:FlxSprite;

	// secret Histories Tails
	public var shRoom1:FlxSprite;
	public var shVignette:FlxSprite;

	//piracy,.,.,.,.,.,. is a crime
	public var piracyCircle:FlxSprite;
	public var piracyVignette:FlxSprite;
	public var darkthing:FlxSprite;
	public var piracyCrimetxt:FlxText;
	public var backdropPiracy:FlxBackdrop;
	public var piracy_Error:FlxSprite;
	public var grpPiracyLetters:FlxTypedGroup<FlxText>;
	public var piracyEmitter:FlxEmitter;
	public var piracyphase3:FlxTypedGroup<FlxBasic>;
	var piracyLines:Array<String> = [];


	//taels dol....
	public var tdmenuIntro:FlxSprite;
	public var tdIntro:FlxSprite;
	public var tdspotlight:FlxSprite;
	
	
	//------------------------------------------------//

	public var reusableSprites:Array<FlxSprite>;
    public var curStage:String = '';
    public var luaArray:Array<FunkinLua> = [];

	// wats dis for lol
	// seems kinda sorta very stupid and makes the code harder to read for no reason when if its never used again it can have a local variable
	// or giving it its own class variable if you needa reuse it
	public var reusable1:FlxSprite;
	public var reusable2:FlxSprite;
	public var reusable3:FlxSprite;
	public var reusable4:FlxSprite;
	public var reusable5:FlxSprite;
	public var reusable6:FlxSprite;
	public var reusable7:FlxSprite;
	public var reusable8:FlxSprite;
	public var reusable9:FlxSprite;
	public var reusable10:FlxSprite;


    // copied from PlayState lol
	public function removeParticleEmmissions(){
		if(piracyEmitter.emitting){
			piracyEmitter.forEach(function(p:FlxParticle){p.alpha = 0;});
			remove(piracyEmitter);
		}
	}
	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null):Dynamic
	{
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if (exclusions == null)
			exclusions = [];
		for (script in luaArray)
		{
			if (exclusions.contains(script.scriptName))
				continue;

			var ret:Dynamic = script.call(event, args);
			if (ret == FunkinLua.Function_StopLua && !ignoreStops)
				break;


			// had to do this because there is a bug in haxe where Stop != Continue doesnt work
			var bool:Bool = ret == FunkinLua.Function_Continue;
			if (!bool && ret != 0)
			{
				returnVal = cast ret;
			}
		}
		#end
		// trace(event, returnVal);
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic)
	{
		#if LUA_ALLOWED
		for (i in 0...luaArray.length)
		{
			luaArray[i].set(variable, arg);
		}
		#end
	}

    
    public function new(stage:String) {
        super();

		curStage = stage;
        
		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if (FileSystem.exists(Paths.modFolders(luaFile)))
		{
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		}
		else
		{
			luaFile = Paths.getPreloadPath(luaFile);
			if (FileSystem.exists(luaFile))
			{
				doPush = true;
			}
		}

		if (doPush)
			luaArray.push(new FunkinLua(luaFile));
		#end

        #if LUA_ALLOWED
        for(lua in luaArray){
            Lua_helper.add_callback(lua.lua, "addLuaSprite", function(tag:String, front:Bool = false) {
                if(PlayState.instance.modchartSprites.exists(tag)) {
                    var shit:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
                    if(!shit.wasAdded) {
                        add(shit);
                        shit.wasAdded = true;
                        //trace('added a thing: ' + tag);
                    }
                }
            });
        }
        #end

        buildStage();
    }

	// vanilla/hard-coded stage functions
	public function buildVanillaStage()
	{
		switch (curStage)
		{
			case 'angel-island':

				var baseX = 0;
				var baseY = 0;
				var back = new BGSprite('bgs/too-slow/1back', baseX, baseY, 0.2, 0.8);
				angelIsland.push(back);
				fire = new BGSprite('bgs/too-slow/2fire', baseX, baseY, 0.4, 0.8);
				angelIsland.push(fire);
				firewall = new BGSprite('bgs/too-slow/3firewall', baseX, baseY, 0.4, 0.8);
				angelIsland.push(firewall);
				var plants = new BGSprite('bgs/too-slow/4plants', baseX, baseY, 0.85, 1);
				angelIsland.push(plants);
				var rocks = new BGSprite('bgs/too-slow/5rocks', baseX, baseY, 0.85, 1);
				angelIsland.push(rocks);
				var bushes = new BGSprite('bgs/too-slow/6bushes', baseX, baseY, 1, 1);
				angelIsland.push(bushes);
				var ground = new BGSprite('bgs/too-slow/7ground', baseX, baseY, 1, 1);
				angelIsland.push(ground);
				var rock = new BGSprite('bgs/too-slow/rock', baseX + 1110, baseY + 720, 1, 1);
				angelIsland.push(rock);
				for(i in 0...angelIsland.length){
					add(angelIsland[i]);
					if ((FlxG.state is PlayState))
						angelIsland[i].visible = false; // for the intro
				}

				var fg = new BGSprite('bgs/too-slow/8foreground', baseX + 125, baseY-100, 1.35, 1);
				fg.setGraphicSize(Std.int(fg.width * 1));
				fg.visible = false;
				angelIsland.push(fg);
				foreground.add(fg);
				if ((FlxG.state is PlayState)){
					spotlight1 = new BGSprite('bgs/too-slow/light', (baseX + 675) - 300, baseY + 150, 1, 1);
					spotlight1.alpha = 0;
					add(spotlight1);

					spotlight2 = new BGSprite('bgs/too-slow/light', (baseX + 1470 + 300) - 300, baseY + 150, 1, 1);
					spotlight2.alpha = 0;
					add(spotlight2);
				}
				
			case 'sunky':
				reusable1 = new FlxSprite(1574,542).loadGraphic(Paths.image('bgs/sunky/sunky_bg_6'));
				reusable1.setGraphicSize(3900);
				reusable1.updateHitbox();
				add(reusable1);

				reusable4 = new FlxSprite(680,1024).loadGraphic(Paths.image('bgs/sunky/sunky_bg_3'));
				reusable4.setGraphicSize(4000);
				reusable4.updateHitbox();
				add(reusable4);

				reusable2 = new FlxSprite(-2029,874).loadGraphic(Paths.image('bgs/sunky/sunky_bg_5'));
				reusable2.setGraphicSize(5085);
				reusable2.updateHitbox();
				add(reusable2);

				reusable3 = new FlxSprite(-318,863).loadGraphic(Paths.image('bgs/sunky/sunky_bg_4'));
				reusable3.setGraphicSize(4200);
				reusable3.updateHitbox();
				add(reusable3);

				reusable8 = new FlxSprite(1728,1100);
				reusable8.frames = Paths.getSparrowAtlas('bgs/sunky/flowersping');
				reusable8.animation.addByPrefix('idle','flowerspin',24);
				reusable8.animation.play('idle');
				reusable8.setGraphicSize(540);
				reusable8.updateHitbox();
				add(reusable8);

				reusable6 = new FlxSprite(2071,672).loadGraphic(Paths.image('bgs/sunky/sunky_bg_2'));
				reusable6.setGraphicSize(2675);
				reusable6.updateHitbox();
				add(reusable6);

				reusable5 = new FlxSprite(1590,1773).loadGraphic(Paths.image('bgs/sunky/sunky_bg_1'));
				reusable5.setGraphicSize(3870);
				reusable5.updateHitbox();
				add(reusable5);

				reusable7 = new FlxSprite(2046,1040).loadGraphic(Paths.image('bgs/sunky/sunky_bg_7'));
				reusable7.setGraphicSize(3200);
				reusable7.updateHitbox();
				add(reusable7);

				reusable9 = new FlxSprite(4140,1367);
				reusable9.frames = Paths.getSparrowAtlas('bgs/sunky/skelebop');
				reusable9.animation.addByPrefix('idle','skelebop',24);
				reusable9.animation.play('idle');
				reusable9.setGraphicSize(440);
				reusable9.updateHitbox();
				add(reusable9);

				reusable2.scrollFactor.set(0.2,1);
				reusable3.scrollFactor.set(0.4,1);
				reusable4.scrollFactor.set(0.7,1);
			case 'google':
				var bg = new FlxSprite();
				bg.frames = Paths.getSparrowAtlas('bgs/google/SonicGoogleBG');
				bg.animation.addByPrefix('idle', 'Idle', 12, true);
				bg.animation.play('idle');
				add(bg);

				streetviewMap = new FlxSprite().loadGraphic(Paths.image('bgs/google/SonicGoogleFG3'));
				streetviewMap.scrollFactor.set();
				streetviewMap.setGraphicSize(1280);
				streetviewMap.updateHitbox();
				hudElements.push(streetviewMap);
				mapControls = new FlxSprite().loadGraphic(Paths.image('bgs/google/SonicGoogleFG4'));
				mapControls.scrollFactor.set();
				mapControls.setGraphicSize(1280);
				mapControls.updateHitbox();
				hudElements.push(mapControls);




			case 'piracy': // Third Party
				var kys:Array<String> = [];
				if(FileSystem.exists(Paths.txt("piracy lines"))) kys = CoolUtil.coolTextFile(Paths.txt("piracy lines"));
				for(i in 0...kys.length)piracyLines.push(kys[i]);
			
				grpPiracyLetters = new FlxTypedGroup<FlxText>();
				add(grpPiracyLetters);

				piracyCircle = new BGSprite('bgs/Third Party/piracy_bg2',-20,675);
				piracyCircle.setGraphicSize(1233);				
				add(piracyCircle);

				piracyphase3 = new FlxTypedGroup<FlxBasic>(); //basseck
				piracyphase3.visible = false;
				add(piracyphase3);

				var p3bg = new BGSprite('bgs/Third Party/5',517,-23);
				p3bg.setGraphicSize(1805);
				p3bg.updateHitbox();
				piracyphase3.add(p3bg);

				var p3bg2 = new BGSprite('bgs/Third Party/4',517,-23);
				p3bg2.setGraphicSize(1805);
				p3bg2.updateHitbox();
				piracyphase3.add(p3bg2);
		

				piracyEmitter = new FlxEmitter(517, -100);
				for (i in 0...100)
       		 	{
					var particle = new FlxParticle();
					particle.loadGraphic(Paths.image('bgs/Third Party/particle'));
					particle.animation.addByPrefix('littleheart', 'littleheart', 24, true);
        			particle.exists = false;
					var a = FlxG.random.float(0.2,0.7);
					particle.scale.set(a,a);
        			piracyEmitter.add(particle);
        		}
				piracyEmitter.launchMode = FlxEmitterMode.SQUARE;
				piracyEmitter.velocity.set(-50, -400, 50, -800, -100, 0, 100, -800);
				piracyEmitter.scale.set(.8,.8);
				piracyEmitter.drag.set(10, 0);
				piracyEmitter.height = 2500;
				piracyEmitter.width = 3000;
				piracyEmitter.alpha.set(0.2, 0.6);
				piracyEmitter.lifespan.set(3, 4.5);
				piracyEmitter.start(false, 1, 1000000);
				piracyEmitter.emitting = false;
				piracyphase3.add(piracyEmitter);
				piracyEmitter.frequency = 0.2;

				var p3bg3 = new BGSprite('bgs/Third Party/2',515,-58);
				p3bg3.setGraphicSize(1820);
				p3bg3.updateHitbox();
				piracyphase3.add(p3bg3);

				var p3bg4 = new BGSprite('bgs/Third Party/3',517,-23);
				p3bg4.setGraphicSize(1805);
				p3bg4.updateHitbox();
				piracyphase3.add(p3bg4);

				backdropPiracy = new FlxBackdrop();
				backdropPiracy.loadGraphic(Paths.image('bgs/Third Party/piracy'));
				backdropPiracy.scrollFactor.set();
				//backdropPiracy.repeatAxes=XY;
				backdropPiracy.alpha = 0;
				add(backdropPiracy);

				piracyVignette = new BGSprite('bgs/Third Party/vignete');
				piracyVignette.setGraphicSize(Std.int(1280 * 1.25),Std.int(720 *1.25));
				piracyVignette.alpha = 0;
				piracyVignette.screenCenter();
				add(piracyVignette);
				piracyVignette.cameras = [PlayState.instance.camOther];

				darkthing = new FlxSprite().makeGraphic(1280,720,FlxColor.BLACK);
				darkthing.scrollFactor.set();
				foreground.add(darkthing);
				hudElements.push(darkthing);

				piracyCrimetxt = new FlxText(300, 334, -100, '', 48);
				piracyCrimetxt.setFormat(Paths.font("sonic-cd-menu-font.ttf"), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				piracyCrimetxt.borderSize = 1.4;
				foreground.add(piracyCrimetxt);
				hudElements.push(piracyCrimetxt);

			
			case 'lordx': //nvm....... cries

			case 'nes':
				PlayState.instance.defaultCamZoom = 0.95;
				reusable2 = new FlxSprite(500, 200).loadGraphic(Paths.image('bgs/neshill/sky',"shared"));
				reusable2.antialiasing = false;
				reusable2.scale.set(8, 8);
				add(reusable2);

				reusable1 = new FlxSprite(500, 200);
				reusable1.frames = Paths.getSparrowAtlas('bgs/neshill/tlbg2',"shared");
				reusable1.animation.addByPrefix("tlbg2","tlbg2", 12 , true);
				reusable1.animation.play("tlbg2");
				reusable1.antialiasing = false;
				reusable1.scale.set(8, 8);
				add(reusable1);

			case 'secret histories': // Secret History Tails
				shRoom1 = new FlxSprite().loadGraphic(Paths.image("bgs/sh/sh_tails_bg_","shared"));
				shRoom1.screenCenter();
				add(shRoom1);
				shRoom1.scale.set(0.45,0.45);
				
				shVignette = new FlxSprite().loadGraphic(Paths.image("bgs/sh/sh_tails_bg_vin","shared"));
				shVignette.scrollFactor.set(0, 0);
				shVignette.screenCenter();
				shVignette.setGraphicSize(FlxG.width,FlxG.height);
				shVignette.cameras = [PlayState.instance.camHUD];

				reusable3 = new FlxSprite();
				reusable3.loadGraphic(Paths.image("bgs/sh/sonic_sh_bg_normal","shared"));
				reusable3.screenCenter();
				add(reusable3);
				reusable3.scale.set(0.45,0.45);
				reusable3.alpha = 0;

				reusable1 = new FlxSprite();
				reusable1.frames = Paths.getSparrowAtlas("bgs/sh/ames","shared");
				reusable1.screenCenter();
				reusable1.animation.addByPrefix("amesbop","amesbop",24,true);
				add(reusable1);
				reusable1.alpha = 0;

				reusable2 = new FlxSprite();
				reusable2.frames = Paths.getSparrowAtlas("bgs/sh/bfbop","shared");
				reusable2.screenCenter();
				reusable2.animation.addByPrefix("bfbop","bfbop",24,true);
				add(reusable2);
				reusable2.alpha = 0;

            case 'hill': // Time Attack
				goodShader = new WaterShader();
				evilShader = new WaterShader();

				evilShader.evil = true;
				var baseX:Float = -110;
				var baseY:Float = 373;
				var goodWater:BGSprite = new BGSprite('bgs/osr/accurate/good/layer1', baseX, baseY, 0.9, 0.2);
				goodWater.shader = goodShader;
				add(goodWater);

				var goodWaterfalls:BGSprite = new BGSprite('bgs/osr/accurate/good/layer2', baseX, baseY - 40, 0.9, 0.2);
				goodWaterfalls.shader = goodShader;
				add(goodWaterfalls);

				var goodRocks:BGSprite = new BGSprite('bgs/osr/accurate/good/layer3', baseX, baseY - 88, 0.8, 0.2);
				add(goodRocks);

				goodClouds1 = new BGTiledSprite('bgs/osr/accurate/good/layer4', baseX, baseY-104, 3840, 16, 0.7, 0.2);
				add(goodClouds1);

				goodClouds2 = new BGTiledSprite('bgs/osr/accurate/good/layer5', baseX, baseY-120, 3840, 16, 0.75, 0.2);
				add(goodClouds2);

				goodClouds3 = new BGTiledSprite('bgs/osr/accurate/good/layer6', baseX, baseY-152, 3840, 32, 0.8, 0.2);
				add(goodClouds3);

				goodSprites.push(goodWater);
				goodSprites.push(goodWaterfalls);
				goodSprites.push(goodRocks);
				goodSprites.push(goodClouds1);
				goodSprites.push(goodClouds2);
				goodSprites.push(goodClouds3);

				var evilWater:BGSprite = new BGSprite('bgs/osr/accurate/exe/layer1', baseX, baseY, 0.9, 0.2);
				evilWater.shader = evilShader;
				add(evilWater);

				var evilWaterfalls:BGSprite = new BGSprite('bgs/osr/accurate/exe/layer2', baseX, baseY-40, 0.9, 0.2);
				evilWaterfalls.shader = evilShader;
				add(evilWaterfalls);

				var evilRocks:BGSprite = new BGSprite('bgs/osr/accurate/exe/layer3', baseX, baseY-88, 0.8, 0.2);
				add(evilRocks);

				evilClouds1 = new BGTiledSprite('bgs/osr/accurate/exe/layer4', baseX, baseY-104, 3840, 16, 0.7, 0.2);
				add(evilClouds1);

				evilClouds2 = new BGTiledSprite('bgs/osr/accurate/exe/layer5', baseX, baseY-120, 3840, 16, 0.75, 0.2);
				add(evilClouds2);

				evilClouds3 = new BGTiledSprite('bgs/osr/accurate/exe/layer6', baseX, baseY-152, 3840, 32, 0.8, 0.2);
				add(evilClouds3);

				evilSprites.push(evilWater);
				evilSprites.push(evilWaterfalls);
				evilSprites.push(evilRocks);
				evilSprites.push(evilClouds1);
				evilSprites.push(evilClouds2);
				evilSprites.push(evilClouds3);

				goodHill = new FlxSprite(-112, 221).loadGraphic(Paths.image("bgs/osr/accurate/good/hill"), true, 1024, 256);
				goodHill.animation.add("idle", [0, 1, 1, 2, 2, 2, 2, 1, 0, 0, 0], 0, true);
				goodHill.animation.play("idle", true);
				add(goodHill);
				goodSprites.push(goodHill);

				cutsceneHill = new FlxSprite(912, 221).loadGraphic(Paths.image("bgs/osr/accurate/good/cutsceneHill"), true, 2816, 256);
				cutsceneHill.animation.add("idle", [0, 1, 1, 2, 2, 2, 2, 1, 0, 0, 0], 0, true);
				cutsceneHill.animation.play("idle", true);
				add(cutsceneHill);

				evilHill = new FlxSprite(-112, 221).loadGraphic(Paths.image("bgs/osr/accurate/exe/hill"), true, 1024, 256);
				evilHill.animation.add("idle", [0, 1, 1, 2, 2, 2, 2, 1, 0, 0, 0], 0, true);
				evilHill.animation.play("idle", true);
				add(evilHill);
				evilSprites.push(evilHill);

				goodFlwr = new FlxSprite(-112, 221).loadGraphic(Paths.image("bgs/osr/accurate/good/flowers"), true, 1024, 256);
				goodFlwr.animation.add("idle", [0, 1], 0, true);
				goodFlwr.animation.play("idle", true);
				add(goodFlwr);
				goodSprites.push(goodFlwr);

				cutsceneFlwr = new FlxSprite(912, 221).loadGraphic(Paths.image("bgs/osr/accurate/good/cutsceneFlowers"), true, 2816, 256);
				cutsceneFlwr.animation.add("idle", [0, 1], 0, true);
				cutsceneFlwr.animation.play("idle", true);
				add(cutsceneFlwr);
				goodSprites.push(cutsceneFlwr);

				evilFlwr = new FlxSprite(-112, 221).loadGraphic(Paths.image("bgs/osr/accurate/exe/flowers"), true, 1024, 256);
				evilFlwr.animation.add("idle", [0, 1], 0, true);
				evilFlwr.animation.play("idle", true);
				add(evilFlwr);
				evilSprites.push(evilFlwr);

				for (member in members) // antialiasings everything w/out me having to do it on each member manually lol
				{
					var sprite:FlxSprite = cast member;
					sprite.antialiasing = false;

					sprite.pixelPerfectRender=true;
				}
				
				for(sprite in evilSprites)sprite.visible=false;
			case 'reroy':
				var xy:Array<Float> = [-500,-100]; //kinda uhhh unnecessary
				var bg:BGSprite = new BGSprite('bgs/reroy/bg',xy[0],xy[1]);
				bg.setGraphicSize(2560); //guh
				bg.updateHitbox();
				add(bg);
				
				var floor:BGSprite = new BGSprite('bgs/reroy/floor',xy[0],xy[1]);
				floor.setGraphicSize(2560);
				floor.updateHitbox();
				add(floor);

				var smoke:BGSprite = new BGSprite('bgs/reroy/smoke',xy[0],xy[1]);
				smoke.setGraphicSize(2560);
				smoke.updateHitbox();
				smoke.blend = ADD;				
				foreground.add(smoke);
			case 'redolled': //ogh man im dead
				var setup:Array<FlxSprite> = [];
				
				var blackbg = new FlxSprite().makeGraphic(1029,720,FlxColor.BLACK);
				foreground.add(blackbg);
				hudElements.push(blackbg);

				tdIntro = new FlxSprite();
				tdIntro.frames = Paths.getSparrowAtlas('bgs/redolled/TailsDollIntro');
				tdIntro.animation.addByPrefix('start','idle',24,false);
				tdIntro.animation.play('start');
				foreground.add(tdIntro);
				hudElements.push(tdIntro);
				setup.push(tdIntro);

				tdmenuIntro = new FlxSprite();
				tdmenuIntro.frames = Paths.getSparrowAtlas('bgs/redolled/SonicRSelectBG');
				tdmenuIntro.animation.addByPrefix('idle','wobble',24,false);
				tdmenuIntro.animation.play('idle');
				//add(tdmenuIntro);

				tdspotlight = new FlxSprite().loadGraphic(Paths.image('bgs/redolled/TailsDollBG'));
				tdspotlight.visible = false;
				add(tdspotlight);
				setup.push(tdspotlight);

				for (i in setup) {
					i.pixelPerfectRender = true;
					i.setGraphicSize(0,720);
					i.updateHitbox();
					i.screenCenter();
					i.scrollFactor.set();
				}

				tdIntro.animation.finishCallback = function (name:String){
					tdspotlight.visible = true;
					tdIntro.visible = false;
					remove(tdIntro);
					blackbg.visible = false;
					remove(blackbg);
				}	
		}
	}

	
	public function postCreateVanilla()
	{
		switch(curStage){
			case 'google':
				foreground.add(streetviewMap);
				foreground.add(mapControls);
				if((FlxG.state is PlayState)){
					FlxG.state.remove(PlayState.instance.boyfriendGroup);
					foreground.add(PlayState.instance.boyfriendGroup);
				}else
					add(foreground);
				

				boyfriend.scrollFactor.set();
			case 'angel-island':
				if ((FlxG.state is PlayState))
				{
					PlayState.instance.defaultCamZoom = 0.65;
				}
		}
	}
	
	// Self-explanatory by name
	public function afterCharactersVanilla()
	{
		switch (curStage)
		{
			case 'google':
				var light = new FlxSprite().loadGraphic(Paths.image('bgs/google/SonicGoogleFG'));
				light.setGraphicSize(1280);
				light.updateHitbox();
				foreground.add(light);
				var fg2 = new FlxSprite().loadGraphic(Paths.image('bgs/google/SonicGoogleFG2'));
				fg2.setGraphicSize(1280);
				fg2.updateHitbox();
				foreground.add(fg2);
				if ((FlxG.state is PlayState))
					hudElements.push(PlayState.instance.boyfriendGroup);
				else
					hudElements.push(boyfriend);
			case 'angel-island':
				if ((FlxG.state is PlayState))
					PlayState.instance.boyfriendGroup.x += 300
				else
					boyfriend.x += 300;

				gf.scrollFactor.set(0.95, 1);

				boyfriend.alpha = 0;
				dad.alpha = 0;
				gf.alpha = 0;
			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); // nice
				PlayState.instance.addBehindDad(evilTrail);
		}
	}

	// Self-explanatory by name [2]
    public function afterGroupsVanilla()
    {

    }

	// Used when the state changes. So when changing song, when going to back to menu, etc.
	// Used to cleanup or reset certain variables, such as mouse visibility.
	public function switchingState()
	{
		switch(curStage){
			case 'piracy':
				FlxG.mouse.visible = false;
		}
	}
    
    // called by PlayState on certain events
    // used by vanilla/hard-coded, since lua is already added to the main PlayState luaArray
    override function update(elapsed:Float){
        super.update(elapsed);
		switch (curStage)
		{
			case 'piracy':
				for (i in 0...piracyLetters.length)
				{
					piracyLetters[i].y = FlxMath.lerp(piracyLetters[i].y,
						piracyTxtStartPoint + 16 * Math.cos((Conductor.songPosition / ((dad.curCharacter == 'piracy-sonic2') ? 600 : 4000)
							+ (i * 20) * (Conductor.bpm / 60)) * Math.PI),
						CoolUtil.boundTo(elapsed * 9, 0, 1));
					piracyLetters[i].alpha -= elapsed / ((dad.curCharacter == 'piracy-sonic2') ? 1 : 4);
					piracyLettersAlpha = piracyLetters[i].alpha;
				}
			case 'hill':
				if (doWaterUpdate){
					waterShaderTimer += elapsed * PlayState.instance.playbackRate;
					
					while(waterShaderTimer >= 1/10){ // 10 fps
						waterShaderTimer-=1/10;
						goodShader.frame++;
						if (goodShader.frame >= 32)
							goodShader.frame-=32;// after a certain point the waterfalls look a bit weird so this resets it so it DOESNT look fucked up
						evilShader.frame=goodShader.frame;
					}

					goodClouds1.scrollX -= 0.3 * (elapsed/(1/60)) * PlayState.instance.playbackRate;
					goodClouds2.scrollX -= 0.5 * (elapsed/(1 / 60)) * PlayState.instance.playbackRate;
					goodClouds3.scrollX -= 0.7 * (elapsed/(1 / 60)) * PlayState.instance.playbackRate;
					evilClouds1.scrollX = goodClouds1.scrollX;
					evilClouds2.scrollX = goodClouds2.scrollX;
					evilClouds3.scrollX = goodClouds3.scrollX;
				}
		}
    }

    public function beatHit(curBeat:Int)
	{
        this.curBeat=curBeat;
		this.bumpBoppers();
		switch (curStage)
		{
			case 'google':
				if (curBeat == 1)  {
					var maniacard = new FlxSprite();
					maniacard.frames = Paths.getSparrowAtlas('bgs/google/DATAFUCKYOURAAAAH');
					maniacard.animation.addByPrefix('play','FUCKKKK',24,false);
					maniacard.screenCenter();
					foreground.add(maniacard);
					maniacard.cameras = [PlayState.instance.camSpec];
					maniacard.animation.play('play');
					maniacard.animation.finishCallback = function (name:String){
						maniacard.visible = false;
						remove(maniacard);
					}	

				}

			case 'piracy':
				if (curBeat > 3 && (curBeat+ PiracyRand) % ((PlayState.instance.dad.curCharacter == 'piracy-sonic2') ? 1 : 4) == 0 && piracyLettersAlpha < 0.05)
                    createPiracyText();
	
			case 'secret histories':
				reusable1.animation.play("amesbop");
				reusable2.animation.play("bfbop");

			case 'hill':
				goodFlwr.animation.curAnim.curFrame++;
				if (goodFlwr.animation.curAnim.curFrame >= goodFlwr.animation.curAnim.frames.length)
					goodFlwr.animation.curAnim.curFrame = 0;
				cutsceneFlwr.animation.curAnim.curFrame = goodFlwr.animation.curAnim.curFrame;
				evilFlwr.animation.curAnim.curFrame = goodFlwr.animation.curAnim.curFrame;
				
				goodHill.animation.curAnim.curFrame++;
				if(goodHill.animation.curAnim.curFrame >= goodHill.animation.curAnim.frames.length)
					goodHill.animation.curAnim.curFrame=0;
				cutsceneHill.animation.curAnim.curFrame = goodHill.animation.curAnim.curFrame;
				evilHill.animation.curAnim.curFrame = goodHill.animation.curAnim.curFrame;
        }
    }

    public function stepHit(curStep:Int)
	{
        this.curStep = curStep;
    }

	public function sectionHit(curSex:Int)
	{
		this.curSection = curSex;
	}

    public function bumpBoppersVanilla(){


    }

    // easy callin functions, mainly used by PlayState to setup the stage
	public function bumpBoppers()
	{
		if (luaArray.length == 0)
			bumpBoppersVanilla();
		else
			callOnLuas('bumpBoppers', [], false);
	}

    public function buildStage()
    {
		if (luaArray.length == 0)
			buildVanillaStage();
		else
			callOnLuas('buildStage', [], false);
    }

	public function afterGroups()
	{
		this.gf = PlayState.instance.gf;
		this.boyfriend = PlayState.instance.boyfriend;
		this.dad = PlayState.instance.dad;
		if (luaArray.length == 0)
			afterGroupsVanilla();
		else
			callOnLuas('afterGroups', [], false);
	}

	public function afterCharacters()
	{
        this.gf = PlayState.instance.gf;
        this.boyfriend = PlayState.instance.boyfriend;
        this.dad = PlayState.instance.dad;
		if (luaArray.length == 0)
			afterCharactersVanilla();
		else
			callOnLuas('afterCharacters', [], false);

	}

	public function postCreate()
	{
		if (luaArray.length == 0)
			postCreateVanilla();
		else
			callOnLuas('postCreate', [], false);
	}

    // misc shit used by hard-coded stages lol!

	// piracy words
	public var piracyLetters:Array<FlxText> = [];
	public var piracyLettersAlpha:Float = 0;
	public var PiracyRand:Int = 0;
	public var piracyTxtStartPoint:Float = 0;
	public function createPiracyText()
	{
		piracyLettersAlpha = 0.85;
		piracyTxtStartPoint = FlxG.random.float(190,640);
		var piracyWord:String = 'Password123';
		var piracySpacing:Float = 28;
		var rlStartPoint:Float = 100;
		if (dad.curCharacter == 'piracy-sonic2')
			rlStartPoint = boyfriend.x;
		else
			piracyWord = piracyLines[FlxG.random.int(0,piracyLines.length-1)];
		
		var startTxtPoint:Float = FlxG.random.float(rlStartPoint-75,rlStartPoint+1080);
		if (piracyLetters.length > 2)
			clearPiracyText();
		for (i in 0...piracyWord.length)
		{
			var letterReal:FlxText = new FlxText(startTxtPoint+(piracySpacing*i), FlxG.random.float(190,640), 0, piracyWord.charAt(i), 26);
			letterReal.setFormat(Paths.font("needlemouse-serif.ttf"), 26, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			letterReal.borderSize = 1.4;
			letterReal.ID = i;
			grpPiracyLetters.add(letterReal);
			piracyLetters.push(letterReal);
		}
	}
	public function clearPiracyText()
	{
		for (i in piracyLetters)
			{
				if (i != null)
					{
						i.kill();
						remove(i);
						i.destroy();
						i = null;
					}
			}
		piracyLetters = [];
	}



}