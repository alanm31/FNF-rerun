package;

import flixel.system.FlxAssets.FlxShader;

class MosaicShader extends FlxShader
{
    @:isVar
    public var pixelSizeX(get, set):Float = 1;
	@:isVar
	public var pixelSizeY(get, set):Float = 1;
	@:isVar
	public var pixelSize(get, set):Float = 1;


    function get_pixelSizeX(){
        return pSize.value[0];
    }

	function set_pixelSizeX(val:Float)
	{
		return pSize.value[0] = val;
	}

	function get_pixelSizeY()
	{
		return pSize.value[1];
	}

	function set_pixelSizeY(val:Float)
	{
		return pSize.value[1] = val;
	}

	function get_pixelSize()
	{
		return (pSize.value[0] + pSize.value[1])/2;
	}

	function set_pixelSize(val:Float)
	{
		pSize.value = [val, val];
		return val;
	}

	@:glFragmentSource('
        #pragma header

        uniform vec2 pSize;
		void main()
		{
            vec2 size = openfl_TextureSize.xy / pSize;
            gl_FragColor = flixel_texture2D(bitmap, floor(openfl_TextureCoordv.xy * size) / size);
        }
    ')
	public function new()
	{
		super();
		pSize.value = [1, 1];
	}
}