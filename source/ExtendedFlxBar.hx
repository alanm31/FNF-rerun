package;
import flixel.FlxG;
import flixel.graphics.frames.FlxFrame.FlxFrameType;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import openfl.geom.ColorTransform;
import flixel.util.FlxColor;
import flixel.ui.FlxBar;
using flixel.util.FlxColorTransformUtil;
class ExtendedFlxBar extends FlxBar {
    public var filledColor(default, set):FlxColor = 0x00FF00;
    
    var _filledTransform = new ColorTransform();

    override function updateColorTransform(){
		if (_filledTransform==null)
			_filledTransform = new ColorTransform();

		_filledTransform.setMultipliers(filledColor.redFloat, filledColor.greenFloat, filledColor.blueFloat, alpha);
        super.updateColorTransform();
    }

    function set_filledColor(clr:FlxColor){
		filledColor = clr;
		updateColorTransform();
        return clr;
    }

	override public function draw():Void
	{
		super.draw();

		if (!FlxG.renderTile)
			return;

		if (alpha == 0)
			return;

		if (percent > 0 && _frontFrame.type != FlxFrameType.EMPTY)
		{
			for (camera in cameras)
			{
				if (!camera.visible || !camera.exists || !isOnScreen(camera))
				{
					continue;
				}

				getScreenPosition(_point, camera).subtractPoint(offset);

				_frontFrame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, flipX, flipY);
				_matrix.translate(-origin.x, -origin.y);
				_matrix.scale(scale.x, scale.y);

				// rotate matrix if sprite's graphic isn't prerotated
				if (angle != 0)
				{
					_matrix.rotateWithTrig(_cosAngle, _sinAngle);
				}

				_point.add(origin.x, origin.y);
				if (isPixelPerfectRender(camera))
				{
					_point.floor();
				}

				_matrix.translate(_point.x, _point.y);
                // TODO: combine the transforms somehow??
				camera.drawPixels(_frontFrame, _matrix, _filledTransform, blend, antialiasing, shader);
			}
		}
	}
    
}