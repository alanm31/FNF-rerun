package;

// class that extends FlxSound and makes it so that this sound cant be muted by volume tray or w/e
// have fun lol!
import flixel.system.FlxSound;

class FlxSoundGlobal extends FlxSound {
    @:allow(flixel.sound.FlxSoundGroup)
    override function updateTransform(){
        _transform.volume = (group != null ? group.volume : 1) * _volume * _volumeAdjust;

        if (_channel != null)
            _channel.soundTransform = _transform;
		
    }
}