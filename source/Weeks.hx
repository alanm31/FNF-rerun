package;

class Weeks extends MusicBeatState
{
    public static var weeks:Array<Dynamic> = [
        // song name  , icon name,   color ig
        ['too-slow','sonicexe',[224,46,40]],
        ['enterprise','majin',[24,46,140]],
        ['torment','lordx',[114,200,240]],
        ['party-streamers','sunky',[85,85,235]],
        ['top-loader','topnuts',[255,204,197]],
        ['google','googleSonic-icon',[20,20,70]],
        ['time-attack','osr',[234,34,120]],
        ['third-party','piracy-sonic',[34,34,120]],
        ['redolled','tails-doll',[225,225,0]]
    ];

    // ADD THE SHIT HERE OR ITLL CRASH
	public static var randmap:Map<String, Array<String>> = [
		'menu' => ['Y̷̛̰̣̥͖͋̓o̷̳̠̤͛͐̅͝ų̴̬̼̖̃̃̾̏ ̶̼̼͑̐̔̌ͅć̷̘̞̾̓̄a̸̛̼͕̮̎n̸̠̘͈͑̎̋̎t̷̢̧̤̲̋̌̍̃ ̵̣̈́̽ë̷̡̪͍̈́s̶̥̫̝̃͌̿̚c̷̢͓̠̎ͅą̵̜̎ṕ̶̤͂͛͜e̴̛̱̦͎͗͛ ̴̣̹̌h̶̜̮͈́̋e̵͎͍͍̔̈́͝l̶̨̝̊͝l̷̓̀ͅ','Y̵o̷u̸ ̵c̷a̶n̴t̷ ̸e̸s̶c̸a̵p̸e̷ ̵h̴e̶l̶l̶','Y̴̡̒o̴̺͊u̴̘͑ ̸̳̾c̴̳̾a̷͕̚ň̶̟t̸͍̋ ̶̩͘ȅ̴̫s̴͎͝c̸̣̈́a̸̟͒p̵̯̎e̵͓̅ ̴̹͒ḧ̷̥e̵̲͐l̷͓̊l̶̙͛','Y̷o̵u̵ ̷c̴a̷n̵t̶ ̸e̴s̷c̸a̴p̴e̷ ̷h̶e̸l̶l̴','Y̸̥̝̪̳̅͆͐̾͘͝͝ö̴̢̨̪̳̲̩̯́̊̈́̚ų̶̰̠͔̘̅ ̶̱̈́̊͑͘̕͠c̶͖͈̹̎̿̌̔͂͝a̴̢̨̗̪̖̜̺̐͆n̸͈̈́̊̎͗̆̈t̵͎͚̖̥̼̥̘͊̊̅͐̓͆̍ ̵̨͔̰̲̾́̅̏̈́͂̒e̷̩͖̺̥͙̰͙͆̇̈́͒̔̚s̷͖̠͙̩͋̆̀̈́̓͠c̷̫̎̇̋͑̎̉͜͝ã̶̰̘̥̙̋̍̐͝p̶̞̲͈͆͗e̴̹̺̣̻̎̋͌̈̕͝ ̴̥͎̟͑̌ḧ̴͉͓̞̯̠́͊̒e̵̜̹͓̗̯͓̟̜͛͐ļ̷͚̑̈l̶̬̽̉','Y̴̥̾o̵̯̍ú̵͙ ̵̭̉c̵̯͝a̸̡̾ņ̴̄ṱ̴̏ ̵̢̊ẻ̶͚s̷̢̉c̸̮͐ą̴͋p̶̞̉ẽ̴ͅ ̴̛̲h̶̥͠e̷̢̕l̸̹̒l̶̺̾','Y̴̥̾o̵̯̍ú̵͙ ̵̭̉c̵̯͝a̸̡̾ņ̴̄ṱ̴̏ ̵̢̊ẻ̶͚s̷̢̉c̸̮͐ą̴͋p̶̞̉ẽ̴ͅ ̴̛̲h̶̥͠e̷̢̕l̸̹̒l̶̺̾'],
		'too-slow' => ['Y̷̛̰̣̥͖͋̓o̷̳̠̤͛͐̅͝ų̴̬̼̖̃̃̾̏ ̶̼̼͑̐̔̌ͅć̷̘̞̾̓̄a̸̛̼͕̮̎n̸̠̘͈͑̎̋̎t̷̢̧̤̲̋̌̍̃ ̵̣̈́̽ë̷̡̪͍̈́s̶̥̫̝̃͌̿̚c̷̢͓̠̎ͅą̵̜̎ṕ̶̤͂͛͜e̴̛̱̦͎͗͛ ̴̣̹̌h̶̜̮͈́̋e̵͎͍͍̔̈́͝l̶̨̝̊͝l̷̓̀ͅ','Y̵o̷u̸ ̵c̷a̶n̴t̷ ̸e̸s̶c̸a̵p̸e̷ ̵h̴e̶l̶l̶','Y̴̡̒o̴̺͊u̴̘͑ ̸̳̾c̴̳̾a̷͕̚ň̶̟t̸͍̋ ̶̩͘ȅ̴̫s̴͎͝c̸̣̈́a̸̟͒p̵̯̎e̵͓̅ ̴̹͒ḧ̷̥e̵̲͐l̷͓̊l̶̙͛','Y̷o̵u̵ ̷c̴a̷n̵t̶ ̸e̴s̷c̸a̴p̴e̷ ̷h̶e̸l̶l̴','Y̸̥̝̪̳̅͆͐̾͘͝͝ö̴̢̨̪̳̲̩̯́̊̈́̚ų̶̰̠͔̘̅ ̶̱̈́̊͑͘̕͠c̶͖͈̹̎̿̌̔͂͝a̴̢̨̗̪̖̜̺̐͆n̸͈̈́̊̎͗̆̈t̵͎͚̖̥̼̥̘͊̊̅͐̓͆̍ ̵̨͔̰̲̾́̅̏̈́͂̒e̷̩͖̺̥͙̰͙͆̇̈́͒̔̚s̷͖̠͙̩͋̆̀̈́̓͠c̷̫̎̇̋͑̎̉͜͝ã̶̰̘̥̙̋̍̐͝p̶̞̲͈͆͗e̴̹̺̣̻̎̋͌̈̕͝ ̴̥͎̟͑̌ḧ̴͉͓̞̯̠́͊̒e̵̜̹͓̗̯͓̟̜͛͐ļ̷͚̑̈l̶̬̽̉','Y̴̥̾o̵̯̍ú̵͙ ̵̭̉c̵̯͝a̸̡̾ņ̴̄ṱ̴̏ ̵̢̊ẻ̶͚s̷̢̉c̸̮͐ą̴͋p̶̞̉ẽ̴ͅ ̴̛̲h̶̥͠e̷̢̕l̸̹̒l̶̺̾','Y̴̥̾o̵̯̍ú̵͙ ̵̭̉c̵̯͝a̸̡̾ņ̴̄ṱ̴̏ ̵̢̊ẻ̶͚s̷̢̉c̸̮͐ą̴͋p̶̞̉ẽ̴ͅ ̴̛̲h̶̥͠e̷̢̕l̸̹̒l̶̺̾'],
		'torment' => [''],
		'google' => [''],
		'top-loader' => [''],
		'improbable-outset' => [''],
		'redolled' => [''],
		'enterprise' => ['∞','∞','∞','∞','∞','∞','∞','∞','∞ ∞','∞ ∞∞∞','∞ ∞∞ ∞∞','∞∞ ∞ ∞∞ ∞','∞∞∞ ∞ ∞∞∞∞','∞∞ ∞ ∞ ∞∞ ∞'],
		//'enterprise' => ['たのしさ∞'],
		'party-streamers' => [':P'],
		'time-attack' => [''],
		'third-party' => ['PIRACY IS A CRIME','PLEASE RETURN THIS CARTAGE IMMEDIATELY'],
		'best-friends' => ['I WAS YOUR BEST FRIEND SONIC', 'THEY WHERE IMPOSTERS'],
		'test' => [''],
		'tutorial' => ['penois']
	];
}