package;


import GlitchShader.GlitchShaderB;
import Conductor.SongTimer;
import flixel.system.scaleModes.RatioScaleMode;
import openfl.system.Capabilities;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.graphics.FlxGraphic;
#if desktop
import Discord.DiscordClient;
#end
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


using StringTools;

//ORIGINIZATION!!!!!


class SongEvents extends FlxBasic{
    var curStep:Int;
    var curBeat:Int;
    var song = "";
    public function setUp(Song = "third-party"){
        song = Song.toLowerCase();
    }
    public function stepHit(S,B){
        curStep=S;
        curBeat=B;

        switch(song){
            case 'third-party':
                switch(curStep)
                {
                    case 1:
                        //FlxTween.tween(PlayState.instance.stage.piracyCrimetxt, {y: 334}, 0.00001, {ease: FlxEase.elasticInOut});
                        //PlayState.instance.boyfriend.color = 0xFF7273DF;
                        //PlayState.instance.dad.color = 0xFF7273DF;
                    case 26:
                        FlxTween.tween(PlayState.instance.stage.darkthing, {alpha: 0}, 0.6);
                        FlxTween.tween(PlayState.instance.stage.piracyCrimetxt, {"scale.x": 9, "scale.y": 9, alpha: 0}, 0.6, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween){
                            PlayState.instance.stage.piracyCrimetxt.destroy();
                        }});           
                    case 412:
                        for (i in PlayState.instance.unspawnNotes) { //TODO redo this later to actually be GOOD
                            i.texture = 'skins/piracy'; //erm lag spike much
                        }
                    case 670:
                        for (i in PlayState.instance.unspawnNotes) {
                            i.texture = 'NOTE_assets';
                        }

                }
        }
    }

    public function switchPhase(p:Int){
        PlayState.instance.bgPhase = p;
        switch(song){
            case 'redolled':
                
            case 'third-party':
                switch(p){ //why is there an event class only for piracy ////// cuz nothing else needs it rn i think ig sunshine enterprize and more songs will eventually
                    case 0: //phase 2
                        for (i in PlayState.instance.playerStrums.members) {
                            i.texture = 'skins/piracy';
                        }
                        PlayState.instance.stage.piracyCircle.alpha = 0;
                        PlayState.instance.stage.backdropPiracy.alpha = 1;
                        PlayState.instance.stage.piracyVignette.alpha = 1;
                        PlayState.instance.camGame.setFilters([new ShaderFilter(PlayState.instance.piracyShader2.shader)]);
                        PlayState.instance.triggerEventNote("Camera Follow Pos",Std.string(PlayState.instance.dad.getGraphicMidpoint().x),Std.string(PlayState.instance.dad.getGraphicMidpoint().y), Conductor.songPosition);
                    case -1: //phase 1
                        for (i in PlayState.instance.playerStrums.members) {
                            i.texture = 'NOTE_assets';
                        }
                    PlayState.instance.stage.piracyphase3.visible = false;
                        PlayState.instance.stage.piracyCircle.alpha = 1;
                        PlayState.instance.stage.backdropPiracy.alpha = 0;
                        PlayState.instance.stage.piracyVignette.alpha = 0;
                        PlayState.instance.camGame.setFilters([new ShaderFilter(PlayState.instance.piracyShader.shader)]);
                        PlayState.instance.stage.removeParticleEmmissions();
                        PlayState.instance.stage.piracyEmitter.emitting = false;
                    case 1: //error screen
                        Main.fpsVar.visible = false;
                        PlayState.instance.stage.piracy_Error.alpha = 1;
                        lime.app.Application.current.window.fullscreen = true;
                        #if sys
                        Sys.sleep(0.1);
                        #end
                    case 2: //phase 3
                        Main.fpsVar.visible = ClientPrefs.showFPS;
                        PlayState.instance.stage.piracy_Error.alpha = 0;
                        PlayState.instance.stage.piracyCircle.alpha = 0.00001;
                        PlayState.instance.stage.piracyphase3.visible = true;
                        PlayState.instance.stage.piracyEmitter.emitting = true;
                }
            }
    }
}