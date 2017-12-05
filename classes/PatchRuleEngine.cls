/*
* This class is generated dynamically from Patch Rules.
*/
public class PatchRuleEngine extends PatchRuleEngineBase
{
  private Id matchGroup1(Target t, List<Id> overlays)
  {
    if(opIn(t.Company, new Set<String> { 'apple', 'charter', 'charter communications', 'ea', 'electronic arts', 'electronic arts inc.', 'google', 'hewlett packard', 'hewlett packard enterprise', 'hewlett-packard', 'honeywell', 'lockheed', 'lockheed martin', 'vmware', 'vmware global inc.', 'wells fargo', 'wells fargo bank' }) || opStart(t.Company, new Set<String> { 'apple', 'vmware', 'hewlett', 'electronic arts', 'lockheed', 'honeywell', 'google' }))return 'a0c50000002dty1AAA';    //Major Accounts
    if(opContain(t.Company, 'AT&T') || opContain(t.Company, 'Verizon'))return 'a0c380000060oWaAAI';    //Service Providers 2
    if(opStart(t.Company, new Set<String> { 'virtela' }) || opContain(t.Company, 'TPX Communications') || opContain(t.Company, 'Airespring'))return 'a0c380000060rOFAAY';    //Service Providers 4
    if(opContain(t.Company, 'Masergy'))return 'a0c380000060oWfAAI';    //Service Providers 3
    if(opContain(t.Company, 'Cygate') || opContain(t.Company, 'Global Cloud Xchange') || opContain(t.Company, 'KDDI'))return 'a0c380000060rOKAAY';    //Service Providers 5
    if(opContain(t.Company, 'Wipro') || opContain(t.Company, 'Cognizant') || opContain(t.Company, 'IGS') || opStart(t.Company, new Set<String> { 'ibm' }) || opStart(t.Company, new Set<String> { 'hcl' }))return 'a0c380000060rOPAAY';    //Service Providers 6
    if(opStart(t.Company, new Set<String> { 'ntt' }) && opIn(t.Country, new Set<String> { 'usa', 'united states', 'united states of america', 'canada', 'u.s.a.' }))return 'a0c380000060zeEAAQ';    //Service Provider 7
    if(opStart(t.Company, new Set<String> { 'ntt' }) && opIn(t.Country, new Set<String> { 'albania', 'andorra', 'armenia', 'austria', 'azerbaijan', 'belarus', 'belgium', 'bosnia and herzegovina', 'bulgaria', 'croatia', 'cyprus', 'czech republic', 'denmark', 'estonia', 'finland', 'france', 'georgia', 'germany', 'greece', 'hungary', 'iceland', 'ireland', 'italy', 'kazakhstan', 'kosovo', 'latvia', 'liechtenstein', 'lithuania', 'luxembourg', 'macedonia', 'malta', 'moldova', 'monaco', 'montenegro', 'netherlands', 'norway', 'poland', 'portugal', 'romania', 'russia', 'san marino', 'serbia', 'slovakia', 'slovenia', 'spain', 'sweden', 'switzerland', 'turkey', 'ukraine', 'united kingdom', 'vatican city' }))return 'a0c380000060zeTAAQ';    //Service Provider 8
    if(opIn(t.Company, new Set<String> { 'esurance', 'financial engines', 'formfactor, inc.', 'granite construction', 'granite construction incorporated', 'kaiser permanente', 'logitec inc.', 'logitech' }))return 'a0c50000002gmHLAAY';    //Named (Bay Area 1)
    if(opIn(t.Company, new Set<String> { 'ebay', 'palo alto networks', 'paypal', 'pg&e', 'pg&e corporation', 'tesla motors', 'tesla motors, inc.', 'williams sonoma', 'williams-sonoma' }))return 'a0c50000002gmHhAAI';    //Named (Bay Area 2)
    if(opIn(t.State, new Set<String> { 'arizona', 'az', 'ca', 'california', 'co', 'colorado', 'montana', 'mt', 'new mexico', 'nm', 'texas', 'tx', 'ut', 'utah', 'wy', 'wyoming' }) || opZipcode(t.ZipCode, '89019,90001~90008,90010~90029,90031~90049,90052,90056~90069,90071,90074,90077,90084,90089,90094~90096,90189,90201~90202,90210~90212,90220~90222,90230~90232,90240~90242,90245,90247~90250,90254~90255,90260,90262~90263,90265~90266,90270,90272,90274~90275,90277~90278,90280,90290~90293,90301~90305,90401~90405,90501~90505,90508,90601~90606,90620~90621,90623,90630~90631,90638~90640,90650,90660,90670,90680,90701~90704,90706,90710,90712~90713,90715~90717,90720,90723,90731~90733,90740,90742~90747,90755,90802~90808,90810,90813~90815,90840,90895,91001,91006~91008,91010~91011,91016~91017,91020,91023~91024,91030,91040,91042~91043,91101,91103~91108,91123,91189,91201~91208,91210,91214,91301~91304,91306~91307,91310~91311,91313,91316,91320~91321,91324~91326,91330~91331,91335,91340,91342~91346,91350~91352,91354~91357,91360~91362,91364~91365,91367,91377,91381,91384,91387,91390,91396,91401~91403,91405~91406,91411,91423,91436,91495,91501~91502,91504~91507,91601~91602,91604~91607,91614,91701~91702,91706,91708~91711,91722~91724,91729~91733,91735,91737,91739~91741,91744~91748,91750,91752,91754~91755,91759,91761~91768,91770,91772~91773,91775~91776,91778,91780,91784,91786,91789~91793,91801,91803,91901~91902,91905~91906,91908~91917,91921,91931~91932,91934~91935,91941~91942,91945,91948,91950,91962~91963,91977~91978,91980,92003~92004,92007~92011,92013~92014,92019~92021,92024~92029,92033,92036~92037,92040,92049,92051,92054,92056~92061,92064~92071,92075,92078~92079,92081~92084,92086,92091~92093,92096,92101~92124,92126~92132,92134~92140,92145,92154~92155,92158~92159,92171,92173,92175,92178~92179,92182,92186,92198,92201,92203,92210~92211,92220,92223,92225~92227,92230~92236,92239~92243,92247,92249~92256,92258~92264,92266~92268,92270,92273~92278,92280~92286,92301,92304~92305,92307~92311,92313~92318,92320~92327,92329,92332~92342,92344~92347,92350,92352,92354,92356,92358~92359,92363~92366,92368~92369,92371~92374,92376~92378,92382,92385~92386,92391~92395,92397~92399,92401,92403~92405,92407~92408,92410~92411,92415,92418,92501~92509,92518,92521~92522,92530,92532,92536,92543~92546,92548~92549,92551~92555,92557,92561~92563,92567,92570~92571,92582~92587,92589~92592,92595~92596,92599,92602~92607,92610,92612,92614~92615,92617~92618,92620,92624~92627,92629~92630,92637,92646~92649,92651,92653~92657,92660~92663,92672~92679,92683,92688,92691~92692,92694,92697,92701,92703~92708,92780,92782,92801~92808,92815,92821~92823,92831~92833,92835,92840~92841,92843~92845,92860~92861,92865~92870,92879~92882,92886~92887,93001~93004,93006~93007,93009~93013,93015,93021~93023,93030~93031,93033,93035~93036,93040~93041,93060,93063~93067,93099,93101,93103,93105~93106,93108~93111,93117,93160,93190,93203,93205~93206,93215,93220,93222,93224~93226,93238,93240~93241,93243,93249~93252,93254~93255,93263,93268,93276,93280,93283,93285,93287,93301,93304~93309,93311~93314,93388,93401~93402,93405~93408,93420,93422~93424,93427~93430,93432~93437,93440~93442,93444~93447,93449,93452,93454~93456,93458,93460,93463,93465,93501~93502,93504~93505,93510,93516,93518~93519,93523~93524,93527~93528,93531~93532,93534~93536,93543~93544,93550~93556,93558,93560~93563,93590~93591'))overlays.add('a0c38000005ZxEAAA0');    //Overlay FCMM West
    if(opIn(t.State, new Set<String> { 'ia', 'il', 'illinois', 'in', 'indiana', 'iowa', 'kansas', 'kentucky', 'ks', 'ky', 'mi', 'michigan', 'missouri', 'mo', 'ne', 'nebraska', 'new york', 'ny', 'oh', 'ohio', 'wi', 'wisconsin' }) || opIn(t.Country, new Set<String> { 'canada', 'ca' }))overlays.add('a0c38000005ZxEUAA0');    //Overlay FCMM Central
    if(opIn(t.State, new Set<String> { 'ak', 'al', 'alabama', 'alaska', 'dc', 'de', 'delaware', 'district of columbia', 'fl', 'florida', 'ga', 'georgia', 'id', 'idaho', 'maryland', 'md', 'mississippi', 'ms', 'nc', 'nevada', 'north carolina', 'nv', 'or', 'oregon', 'sc', 'south carolina', 'tennessee', 'tn', 'va', 'virginia', 'wa', 'washington' }) || opZipcode(t.ZipCode, '15001,15003~15007,15009~15010,15012,15014~15015,15017~15022,15024~15028,15030~15031,15033~15035,15037~15038,15042~15047,15049~15057,15059~15068,15071~15072,15074~15078,15081~15090,15101~15102,15104,15106,15108,15110,15112,15116,15120,15122,15126~15127,15129,15131~15133,15135~15137,15139~15140,15142~15148,15201~15229,15232~15239,15241,15243,15261,15264,15275,15310~15317,15320~15325,15327,15329~15331,15333~15334,15336~15342,15344~15353,15357~15368,15370,15376~15380,15401,15410~15413,15415~15417,15419~15425,15427~15440,15442~15451,15454~15456,15458~15470,15472~15480,15482~15484,15486,15488~15490,15492,15501~15502,15520,15530~15532,15538,15540~15542,15544~15549,15551~15553,15555,15557~15558,15560~15565,15601,15606,15610~15613,15615~15629,15631~15642,15644,15646~15647,15650,15655~15656,15658,15660~15666,15668,15670~15693,15695~15697,15701,15705,15710~15713,15715~15717,15720,15723,15725,15727~15734,15736,15739,15741~15742,15745~15748,15750,15752,15754,15756,15758~15759,15761,15763~15765,15767,15770~15772,15774,15776~15781,15783,15823~15825,15828~15829,15840,15847,15851,15860,15863~15864,15920,15923~15924,15926,15928~15929,15935~15937,15944,15953~15954,15959,16028,16046,16115,16117,16123,16136,16141,16157,16201,16210~16212,16218,16222~16223,16226,16228~16229,16236,16238,16242,16244~16246,16249~16250,16253,16256,16259,16261~16263,8001~8012,8014~8016,8018~8023,8025~8033,8035,8037,8039,8041~8043,8045~8046,8048~8057,8059~8075,8077~8081,8083~8098,8101~8110,8201,8203~8205,8210,8212,8214~8215,8217~8221,8223~8226,8230,8232,8234,8240~8244,8246~8248,8250~8252,8260,8270,8302,8310~8312,8314~8324,8326~8330,8340~8350,8352~8353,8360~8361,8401~8403,8406,8505,8511,8515,8518,8520,8525,8527,8530,8533~8534,8542,8544,8550,8554,8560~8562,8608~8611,8618~8620,8628~8629,8638,8640~8641,8646,8648,8690~8691,8695,8701,8721~8724,8731~8735,8738~8741,8751~8753,8755~8759,92328,92384,92389,93201~93202,93204,93207~93208,93210,93212,93218~93219,93221,93223,93227,93230,93232,93234~93235,93237,93242,93244~93247,93256~93258,93260~93261,93265,93267,93270~93272,93274~93275,93277,93279,93286,93291~93292,93426,93450~93451,93512~93515,93517,93522,93526,93530,93542,93545~93546,93549,93602~93603,93605~93613,93615~93616,93618~93628,93630~93631,93633~93635,93640~93642,93646~93652,93654,93656~93657,93660,93662,93664,93666~93668,93673,93675,93701~93706,93710~93711,93720~93728,93730,93737,93740,93744,93750,93778,93888,93901,93905~93907,93920~93928,93930,93932~93933,93940,93942~93944,93950,93953~93955,93960,93962,94022,94024,94028,94035,94040~94043,94085~94089,94103~94105,94107~94112,94114~94118,94121~94124,94126~94127,94129,94131~94134,94139,94143,94151,94158~94159,94177,94188,94203,94211,94301,94303~94306,94501~94502,94514,94536~94542,94544~94546,94550~94552,94555,94557,94560,94566,94568,94571,94577~94580,94586~94588,94601~94613,94618~94619,94621,94661,94702~94710,94712,94720,94901,94904,94913,94920,94924~94925,94929~94930,94933,94937~94942,94946~94950,94956~94957,94960,94963~94966,94970~94971,94973,94979,95002,95004,95008~95009,95012~95014,95020,95023~95024,95030~95033,95035,95037,95039,95042~95046,95050~95051,95054,95070,95075~95076,95103,95108,95110~95113,95115~95136,95138~95141,95148,95150~95151,95190,95201~95210,95212,95220,95223,95227,95230~95231,95234,95236~95237,95240,95242,95247,95253~95254,95258,95296~95297,95301,95303~95306,95309~95312,95315,95317~95318,95320~95322,95324,95327,95330,95333~95337,95340~95341,95343~95348,95364~95366,95369~95370,95372,95374~95377,95379,95383,95388~95389,95391,95608~95611,95613~95615,95619,95621,95623~95624,95626,95628~95630,95632~95633,95635~95636,95638~95639,95641,95646,95651~95652,95655~95656,95660,95662,95664,95666~95667,95670,95672~95673,95680,95683~95684,95686,95690,95693,95709,95720~95721,95726,95735,95742,95757~95758,95762~95763,95811,95814~95838,95840~95843,95852,95864~95865,96107,96133,96150,96152,96155,96158'))overlays.add('a0c38000005ZxEZAA0');    //Overlay FCMM South
    if(opIn(t.Country, new Set<String> { 'af', 'afg', 'afghanistan' }))return 'a0c50000002dtu0AAA';    //AFGHANISTAN
    if(opIn(t.Country, new Set<String> { 'al', 'alb', 'albania' }))return 'a0c50000002dtu1AAA';    //ALBANIA
    if(opIn(t.Country, new Set<String> { 'dz', 'dza', 'algeria' }))return 'a0c50000002dtu2AAA';    //ALGERIA
    if(opIn(t.Country, new Set<String> { 'as', 'asm', 'american samoa' }))return 'a0c50000002dtu3AAA';    //AMERICAN SAMOA
    if(opIn(t.Country, new Set<String> { 'ad', 'and', 'andorra' }))return 'a0c50000002dtu4AAA';    //ANDORRA
    if(opIn(t.Country, new Set<String> { 'ao', 'ago', 'angola' }))return 'a0c50000002dtu5AAA';    //ANGOLA
    if(opIn(t.Country, new Set<String> { 'aq', 'ata', 'antarctica' }))return 'a0c50000002dtu6AAA';    //ANTARCTICA
    return null;
  }
  private Id matchGroup2(Target t, List<Id> overlays)
  {
    if(opIn(t.Country, new Set<String> { 'ag', 'atg', 'antigua and barbuda', 'antigua & barbuda' }))return 'a0c50000002dtu7AAA';    //ANTIGUA AND BARBUDA
    if(opIn(t.Country, new Set<String> { 'ar', 'arg', 'argentina' }))return 'a0c50000002dtu8AAA';    //ARGENTINA
    if(opIn(t.Country, new Set<String> { 'am', 'arm', 'armenia' }))return 'a0c50000002dtu9AAA';    //ARMENIA
    if(opIn(t.Country, new Set<String> { 'au', 'aus', 'australia' }))return 'a0c50000002dtuAAAQ';    //AUSTRALIA
    if(opIn(t.Country, new Set<String> { 'at', 'aut', 'austria' }))return 'a0c50000002dtuBAAQ';    //AUSTRIA
    if(opIn(t.Country, new Set<String> { 'az', 'aze', 'azerbaijan' }))return 'a0c50000002dtuCAAQ';    //AZERBAIJAN
    if(opIn(t.Country, new Set<String> { 'bh', 'bhr', 'bahrain' }))return 'a0c50000002dtuDAAQ';    //BAHRAIN
    if(opIn(t.Country, new Set<String> { 'bd', 'bgd', 'bangladesh' }))return 'a0c50000002dtuEAAQ';    //BANGLADESH
    if(opIn(t.Country, new Set<String> { 'by', 'blr', 'belarus' }))return 'a0c50000002dtuFAAQ';    //BELARUS
    if(opIn(t.Country, new Set<String> { 'be', 'bel', 'belgium' }))return 'a0c50000002dtuGAAQ';    //BELGIUM
    if(opIn(t.Country, new Set<String> { 'bz', 'blz', 'belize' }))return 'a0c50000002dtuHAAQ';    //BELIZE
    if(opIn(t.Country, new Set<String> { 'bj', 'ben', 'benin' }))return 'a0c50000002dtuIAAQ';    //BENIN
    if(opIn(t.Country, new Set<String> { 'bt', 'btn', 'bhutan' }))return 'a0c50000002dtuJAAQ';    //BHUTAN
    if(opIn(t.Country, new Set<String> { 'bo', 'bol', 'bolivia' }))return 'a0c50000002dtuKAAQ';    //BOLIVIA
    if(opIn(t.Country, new Set<String> { 'ba', 'bih', 'bosnia and herzegowina', 'bosnia' }))return 'a0c50000002dtuLAAQ';    //BOSNIA AND HERZEGOWINA
    if(opIn(t.Country, new Set<String> { 'bw', 'bwa', 'botswana' }))return 'a0c50000002dtuMAAQ';    //BOTSWANA
    if(opIn(t.Country, new Set<String> { 'bv', 'bvt', 'bouvet island' }))return 'a0c50000002dtuNAAQ';    //BOUVET ISLAND
    if(opIn(t.Country, new Set<String> { 'br', 'bra', 'brazil', 'brasil' }))return 'a0c50000002dtuOAAQ';    //BRAZIL
    if(opIn(t.Country, new Set<String> { 'io', 'iot', 'british indian ocean territory' }))return 'a0c50000002dtuPAAQ';    //BRITISH INDIAN OCEAN TERRITORY
    if(opIn(t.Country, new Set<String> { 'bn', 'brn', 'brunei darussalam' }))return 'a0c50000002dtuQAAQ';    //BRUNEI DARUSSALAM
    return null;
  }
  private Id matchGroup3(Target t, List<Id> overlays)
  {
    if(opIn(t.Country, new Set<String> { 'bg', 'bgr', 'bulgaria' }))return 'a0c50000002dtuRAAQ';    //BULGARIA
    if(opIn(t.Country, new Set<String> { 'bf', 'bfa', 'burkina faso' }))return 'a0c50000002dtuSAAQ';    //BURKINA FASO
    if(opIn(t.Country, new Set<String> { 'bi', 'bdi', 'burundi' }))return 'a0c50000002dtuTAAQ';    //BURUNDI
    if(opIn(t.Country, new Set<String> { 'kh', 'khm', 'cambodia' }))return 'a0c50000002dtuUAAQ';    //CAMBODIA
    if(opIn(t.Country, new Set<String> { 'cm', 'cmr', 'cameroon' }))return 'a0c50000002dtuVAAQ';    //CAMEROON
    if(opIn(t.Country, new Set<String> { 'cv', 'cpv', 'cape verde' }))return 'a0c50000002dtuWAAQ';    //CAPE VERDE
    if(opIn(t.Country, new Set<String> { 'cf', 'caf', 'central african republic' }))return 'a0c50000002dtuXAAQ';    //CENTRAL AFRICAN REPUBLIC
    if(opIn(t.Country, new Set<String> { 'td', 'tcd', 'chad' }))return 'a0c50000002dtuYAAQ';    //CHAD
    if(opIn(t.Country, new Set<String> { 'cl', 'chl', 'chile' }))return 'a0c50000002dtuZAAQ';    //CHILE
    if(opIn(t.Country, new Set<String> { 'cn', 'chn', 'china' }))return 'a0c50000002dtuaAAA';    //CHINA
    if(opIn(t.Country, new Set<String> { 'cx', 'cxr', 'christmas island' }))return 'a0c50000002dtubAAA';    //CHRISTMAS ISLAND
    if(opIn(t.Country, new Set<String> { 'cc', 'cck', 'cocos (keeling) islands' }))return 'a0c50000002dtucAAA';    //COCOS (KEELING) ISLANDS
    if(opIn(t.Country, new Set<String> { 'co', 'col', 'colombia' }))return 'a0c50000002dtudAAA';    //COLOMBIA
    if(opIn(t.Country, new Set<String> { 'km', 'com', 'comoros' }))return 'a0c50000002dtueAAA';    //COMOROS
    if(opIn(t.Country, new Set<String> { 'cg', 'cog', 'congo' }))return 'a0c50000002dtufAAA';    //CONGO
    if(opIn(t.Country, new Set<String> { 'cd', 'cod', 'congo', 'the drc' }))return 'a0c50000002dtugAAA';    //CONGO, THE DRC
    if(opIn(t.Country, new Set<String> { 'ck', 'cok', 'cook islands' }))return 'a0c50000002dtuhAAA';    //COOK ISLANDS
    if(opIn(t.Country, new Set<String> { 'cr', 'cri', 'costa rica' }))return 'a0c50000002dtuiAAA';    //COSTA RICA
    if(opIn(t.Country, new Set<String> { 'ci', 'civ', 'cote d\'ivoire', 'ivory coast' }))return 'a0c50000002dtujAAA';    //COTE D'IVOIRE
    if(opIn(t.Country, new Set<String> { 'hr', 'hrv', 'croatia', 'hrvatska' }))return 'a0c50000002dtukAAA';    //CROATIA (local name: Hrvatska)
    return null;
  }
  private Id matchGroup4(Target t, List<Id> overlays)
  {
    if(opIn(t.Country, new Set<String> { 'cu', 'cub', 'cuba' }))return 'a0c50000002dtulAAA';    //CUBA
    if(opIn(t.Country, new Set<String> { 'cy', 'cyp', 'cyprus' }))return 'a0c50000002dtumAAA';    //CYPRUS
    if(opIn(t.Country, new Set<String> { 'cz', 'cze', 'czech republic' }))return 'a0c50000002dtunAAA';    //CZECH REPUBLIC
    if(opIn(t.Country, new Set<String> { 'dk', 'dnk', 'denmark' }))return 'a0c50000002dtuoAAA';    //DENMARK
    if(opIn(t.Country, new Set<String> { 'dj', 'dji', 'djibouti' }))return 'a0c50000002dtupAAA';    //DJIBOUTI
    if(opIn(t.Country, new Set<String> { 'dm', 'dma', 'dominica' }))return 'a0c50000002dtuqAAA';    //DOMINICA
    if(opIn(t.Country, new Set<String> { 'do', 'dom', 'dominican republic' }))return 'a0c50000002dturAAA';    //DOMINICAN REPUBLIC
    if(opIn(t.Country, new Set<String> { 'tp', 'tmp', 'east timor' }))return 'a0c50000002dtusAAA';    //EAST TIMOR
    if(opIn(t.Country, new Set<String> { 'ec', 'ecu', 'ecuador' }))return 'a0c50000002dtutAAA';    //ECUADOR
    if(opIn(t.Country, new Set<String> { 'eg', 'egy', 'egypt' }))return 'a0c50000002dtuuAAA';    //EGYPT
    if(opIn(t.Country, new Set<String> { 'sv', 'slv', 'el salvador' }))return 'a0c50000002dtuvAAA';    //EL SALVADOR
    if(opIn(t.Country, new Set<String> { 'gq', 'gnq', 'equatorial guinea' }))return 'a0c50000002dtuwAAA';    //EQUATORIAL GUINEA
    if(opIn(t.Country, new Set<String> { 'er', 'eri', 'eritrea' }))return 'a0c50000002dtuxAAA';    //ERITREA
    if(opIn(t.Country, new Set<String> { 'ee', 'est', 'estonia' }))return 'a0c50000002dtuyAAA';    //ESTONIA
    if(opIn(t.Country, new Set<String> { 'et', 'eth', 'ethiopia' }))return 'a0c50000002dtuzAAA';    //ETHIOPIA
    if(opIn(t.Country, new Set<String> { 'fk', 'flk', 'falkland islands', 'malvinas' }))return 'a0c50000002dtv0AAA';    //FALKLAND ISLANDS (MALVINAS)
    if(opIn(t.Country, new Set<String> { 'fo', 'fro', 'faroe islands' }))return 'a0c50000002dtv1AAA';    //FAROE ISLANDS
    if(opIn(t.Country, new Set<String> { 'fj', 'fji', 'fiji' }))return 'a0c50000002dtv2AAA';    //FIJI
    if(opIn(t.Country, new Set<String> { 'fi', 'fin', 'finland' }))return 'a0c50000002dtv3AAA';    //FINLAND
    if(opIn(t.Country, new Set<String> { 'fr', 'fra', 'france' }))return 'a0c50000002dtv4AAA';    //FRANCE
    return null;
  }
  private Id matchGroup5(Target t, List<Id> overlays)
  {
    if(opIn(t.Country, new Set<String> { 'fx', 'fxx' }))return 'a0c50000002dtv5AAA';    //FRANCE, METROPOLITAN
    if(opIn(t.Country, new Set<String> { 'gf', 'guf', 'french guiana' }))return 'a0c50000002dtv6AAA';    //FRENCH GUIANA
    if(opIn(t.Country, new Set<String> { 'pf', 'pyf', 'french polynesia' }))return 'a0c50000002dtv7AAA';    //FRENCH POLYNESIA
    if(opIn(t.Country, new Set<String> { 'tf', 'atf', 'french southern territories' }))return 'a0c50000002dtv8AAA';    //FRENCH SOUTHERN TERRITORIES
    if(opIn(t.Country, new Set<String> { 'ga', 'gab', 'gabon' }))return 'a0c50000002dtv9AAA';    //GABON
    if(opIn(t.Country, new Set<String> { 'gm', 'gmb', 'gambia' }))return 'a0c50000002dtvAAAQ';    //GAMBIA
    if(opIn(t.Country, new Set<String> { 'ge', 'geo', 'georgia' }))return 'a0c50000002dtvBAAQ';    //GEORGIA
    if(opIn(t.Country, new Set<String> { 'de', 'deu', 'germany' }))return 'a0c50000002dtvCAAQ';    //GERMANY
    if(opIn(t.Country, new Set<String> { 'gh', 'gha', 'ghana' }))return 'a0c50000002dtvDAAQ';    //GHANA
    if(opIn(t.Country, new Set<String> { 'gi', 'gib', 'gibraltar' }))return 'a0c50000002dtvEAAQ';    //GIBRALTAR
    if(opIn(t.Country, new Set<String> { 'gr', 'grc', 'greece' }))return 'a0c50000002dtvFAAQ';    //GREECE
    if(opIn(t.Country, new Set<String> { 'gl', 'grl', 'greenland' }))return 'a0c50000002dtvGAAQ';    //GREENLAND
    if(opIn(t.Country, new Set<String> { 'gd', 'grd', 'grenada' }))return 'a0c50000002dtvHAAQ';    //GRENADA
    if(opIn(t.Country, new Set<String> { 'gp', 'glp', 'guadeloupe' }))return 'a0c50000002dtvIAAQ';    //GUADELOUPE
    if(opIn(t.Country, new Set<String> { 'gu', 'gum', 'guam' }))return 'a0c50000002dtvJAAQ';    //GUAM
    if(opIn(t.Country, new Set<String> { 'gt', 'gtm', 'guatemala' }))return 'a0c50000002dtvKAAQ';    //GUATEMALA
    if(opIn(t.Country, new Set<String> { 'gn', 'gin', 'guinea' }))return 'a0c50000002dtvLAAQ';    //GUINEA
    if(opIn(t.Country, new Set<String> { 'gw', 'gnb', 'guinea-bissau' }))return 'a0c50000002dtvMAAQ';    //GUINEA-BISSAU
    if(opIn(t.Country, new Set<String> { 'gy', 'guy', 'guyana' }))return 'a0c50000002dtvNAAQ';    //GUYANA
    if(opIn(t.Country, new Set<String> { 'ht', 'hti', 'haiti' }))return 'a0c50000002dtvOAAQ';    //HAITI
    return null;
  }
  private Id matchGroup6(Target t, List<Id> overlays)
  {
    if(opIn(t.Country, new Set<String> { 'hm', 'hmd', 'heard and mc donald islands' }))return 'a0c50000002dtvPAAQ';    //HEARD AND MC DONALD ISLANDS
    if(opIn(t.Country, new Set<String> { 'va', 'vat', 'holy see', 'vatican city', 'vatican city state' }))return 'a0c50000002dtvQAAQ';    //HOLY SEE (VATICAN CITY STATE)
    if(opIn(t.Country, new Set<String> { 'hn', 'hnd', 'honduras' }))return 'a0c50000002dtvRAAQ';    //HONDURAS
    if(opIn(t.Country, new Set<String> { 'hk', 'hkg', 'hong kong' }))return 'a0c50000002dtvSAAQ';    //HONG KONG
    if(opIn(t.Country, new Set<String> { 'hu', 'hun', 'hungary' }))return 'a0c50000002dtvTAAQ';    //HUNGARY
    if(opIn(t.Country, new Set<String> { 'is', 'isl', 'iceland' }))return 'a0c50000002dtvUAAQ';    //ICELAND
    if(opIn(t.Country, new Set<String> { 'in', 'ind', 'india' }))return 'a0c50000002dtvVAAQ';    //INDIA
    if(opIn(t.Country, new Set<String> { 'id', 'idn', 'indonesia' }))return 'a0c50000002dtvWAAQ';    //INDONESIA
    if(opIn(t.Country, new Set<String> { 'ir', 'irn', 'iran', 'islamic republic of iran' }))return 'a0c50000002dtvXAAQ';    //IRAN (ISLAMIC REPUBLIC OF)
    if(opIn(t.Country, new Set<String> { 'iq', 'irq', 'iraq' }))return 'a0c50000002dtvYAAQ';    //IRAQ
    if(opStart(t.ZipCode, new Set<String> { 'ab', 'dd', 'dg', 'eh', 'fk', 'g1', 'g2', 'g3', 'g4', 'g5', 'g6', 'g7', 'g8', 'g9', 'g0', 'hs', 'iv', 'ka', 'kw', 'ky', 'ml', 'pa', 'ph', 'td', 'ze', 'ga', 'gb', 'gc', 'gd', 'ge', 'gf', 'gg', 'gh', 'gi', 'gj', 'gk', 'gm', 'gn', 'go', 'gp', 'gq', 'gr', 'gs', 'gt', 'gv', 'gw', 'gx', 'gy', 'gz' }) && opIn(t.Country, new Set<String> { 'scotland', 'wal', 'wales', 'gb', 'gbr', 'united kingdom', 'uk', 'great britain' }))return 'a0c38000005icf2AAA';    //Scotland
    if(opIn(t.Country, new Set<String> { 'ie', 'irl', 'ireland' }) || (opZipcode(t.ZipCode, 'BT,') && opIn(t.Country, new Set<String> { 'scotland', 'wal', 'wales', 'gb', 'gbr', 'united kingdom', 'uk', 'great britain' })))return 'a0c50000002dtvZAAQ';    //IRELAND
    if(opStart(t.ZipCode, new Set<String> { 'cf', 'im', 'ld', 'll', 'np', 'sa', 'sy' }) && opIn(t.Country, new Set<String> { 'wal', 'wales', 'gb', 'gbr', 'united kingdom', 'uk', 'great britain' }))return 'a0c38000005icf7AAA';    //Wales
    if(opIn(t.Country, new Set<String> { 'il', 'isr', 'israel' }))return 'a0c50000002dtvaAAA';    //ISRAEL
    if(opIn(t.Country, new Set<String> { 'it', 'ita', 'italy' }))return 'a0c50000002dtvbAAA';    //ITALY
    if(opIn(t.Country, new Set<String> { 'jm', 'jam', 'jamaica' }))return 'a0c50000002dtvcAAA';    //JAMAICA
    if(opIn(t.Country, new Set<String> { 'jp', 'jpn', 'japan' }))return 'a0c50000002dtvdAAA';    //JAPAN
    if(opIn(t.Country, new Set<String> { 'jo', 'jor', 'jordan' }))return 'a0c50000002dtveAAA';    //JORDAN
    if(opIn(t.Country, new Set<String> { 'kz', 'kaz', 'kazakhstan' }))return 'a0c50000002dtvfAAA';    //KAZAKHSTAN
    if(opIn(t.Country, new Set<String> { 'ke', 'ken', 'kenya' }))return 'a0c50000002dtvgAAA';    //KENYA
    return null;
  }
  private Id matchGroup7(Target t, List<Id> overlays)
  {
    if(opIn(t.Country, new Set<String> { 'ki', 'kir', 'kiribati' }))return 'a0c50000002dtvhAAA';    //KIRIBATI
    if(opIn(t.Country, new Set<String> { 'kp', 'prk', 'korea', 'd.p.r.o.', 'democratic people\'s republic of korea(dprk)', 'dprk' }))return 'a0c50000002dtviAAA';    //KOREA, D.P.R.O.
    if(opIn(t.Country, new Set<String> { 'kr', 'kor', 'korea', 'republic of korea', 'south korea' }))return 'a0c50000002dtvjAAA';    //KOREA, REPUBLIC OF
    if(opIn(t.Country, new Set<String> { 'kw', 'kwt', 'kuwait' }))return 'a0c50000002dtvkAAA';    //KUWAIT
    if(opIn(t.Country, new Set<String> { 'kg', 'kgz', 'kyrgyzstan' }))return 'a0c50000002dtvlAAA';    //KYRGYZSTAN
    if(opIn(t.Country, new Set<String> { 'la', 'lao', 'laos' }))return 'a0c50000002dtvmAAA';    //LAOS
    if(opIn(t.Country, new Set<String> { 'lv', 'lva', 'latvia' }))return 'a0c50000002dtvnAAA';    //LATVIA
    if(opIn(t.Country, new Set<String> { 'lb', 'lbn', 'lebanon' }))return 'a0c50000002dtvoAAA';    //LEBANON
    if(opIn(t.Country, new Set<String> { 'ls', 'lso', 'lesotho' }))return 'a0c50000002dtvpAAA';    //LESOTHO
    if(opIn(t.Country, new Set<String> { 'lr', 'lbr', 'liberia' }))return 'a0c50000002dtvqAAA';    //LIBERIA
    if(opIn(t.Country, new Set<String> { 'ly', 'lby', 'libyan arab jamahiriya', 'libya' }))return 'a0c50000002dtvrAAA';    //LIBYAN ARAB JAMAHIRIYA
    if(opIn(t.Country, new Set<String> { 'li', 'lie', 'liechtenstein' }))return 'a0c50000002dtvsAAA';    //LIECHTENSTEIN
    if(opIn(t.Country, new Set<String> { 'lt', 'ltu', 'lithuania' }))return 'a0c50000002dtvtAAA';    //LITHUANIA
    if(opIn(t.Country, new Set<String> { 'lu', 'lux', 'luxembourg' }))return 'a0c50000002dtvuAAA';    //LUXEMBOURG
    if(opIn(t.Country, new Set<String> { 'mo', 'mac', 'macau' }))return 'a0c50000002dtvvAAA';    //MACAU
    if(opIn(t.Country, new Set<String> { 'mk', 'mkd', 'macedonia' }))return 'a0c50000002dtvwAAA';    //MACEDONIA
    if(opIn(t.Country, new Set<String> { 'mg', 'mdg', 'madagascar' }))return 'a0c50000002dtvxAAA';    //MADAGASCAR
    if(opIn(t.Country, new Set<String> { 'mw', 'mwi', 'malawi' }))return 'a0c50000002dtvyAAA';    //MALAWI
    if(opIn(t.Country, new Set<String> { 'my', 'mys', 'malaysia' }))return 'a0c50000002dtvzAAA';    //MALAYSIA
    if(opIn(t.Country, new Set<String> { 'mv', 'mdv', 'maldives' }))return 'a0c50000002dtw0AAA';    //MALDIVES
    return null;
  }
  private Id matchGroup8(Target t, List<Id> overlays)
  {
    if(opIn(t.Country, new Set<String> { 'ml', 'mli', 'mali' }))return 'a0c50000002dtw1AAA';    //MALI
    if(opIn(t.Country, new Set<String> { 'mt', 'mlt', 'malta' }))return 'a0c50000002dtw2AAA';    //MALTA
    if(opIn(t.Country, new Set<String> { 'mh', 'mhl', 'marshall islands' }))return 'a0c50000002dtw4AAA';    //MARSHALL ISLANDS
    if(opIn(t.Country, new Set<String> { 'mq', 'mtq', 'martinique' }))return 'a0c50000002dtw5AAA';    //MARTINIQUE
    if(opIn(t.Country, new Set<String> { 'mr', 'mrt', 'mauritania' }))return 'a0c50000002dtw6AAA';    //MAURITANIA
    if(opIn(t.Country, new Set<String> { 'mu', 'mus', 'mauritius' }))return 'a0c50000002dtw7AAA';    //MAURITIUS
    if(opIn(t.Country, new Set<String> { 'yt', 'myt', 'mayotte' }))return 'a0c50000002dtw8AAA';    //MAYOTTE
    if(opIn(t.Country, new Set<String> { 'mx', 'mex', 'mexico', 'curacao' }))return 'a0c50000002dtw9AAA';    //MEXICO
    if(opIn(t.Country, new Set<String> { 'fm', 'fsm', 'micronesia', 'federated states of micronesia' }))return 'a0c50000002dtwAAAQ';    //MICRONESIA, FEDERATED STATES OF
    if(opIn(t.Country, new Set<String> { 'md', 'mda', 'moldova', 'republic of moldova' }))return 'a0c50000002dtwBAAQ';    //MOLDOVA, REPUBLIC OF
    if(opIn(t.Country, new Set<String> { 'mc', 'mco', 'monaco' }))return 'a0c50000002dtwCAAQ';    //MONACO
    if(opIn(t.Country, new Set<String> { 'mn', 'mng', 'mongolia' }))return 'a0c50000002dtwDAAQ';    //MONGOLIA
    if(opIn(t.Country, new Set<String> { 'me', 'mne', 'montenegro' }))return 'a0c50000002dtwEAAQ';    //MONTENEGRO
    if(opIn(t.Country, new Set<String> { 'ms', 'msr', 'montserrat' }))return 'a0c50000002dtwFAAQ';    //MONTSERRAT
    if(opIn(t.Country, new Set<String> { 'ma', 'mar', 'morocco' }))return 'a0c50000002dtwGAAQ';    //MOROCCO
    if(opIn(t.Country, new Set<String> { 'mz', 'moz', 'mozambique' }))return 'a0c50000002dtwHAAQ';    //MOZAMBIQUE
    if(opIn(t.Country, new Set<String> { 'mm', 'mmr', 'myanmar', 'burma' }))return 'a0c50000002dtwIAAQ';    //MYANMAR (Burma)
    if(opIn(t.Country, new Set<String> { 'na', 'nam', 'namibia' }))return 'a0c50000002dtwJAAQ';    //NAMIBIA
    if(opIn(t.Country, new Set<String> { 'nr', 'nru', 'nauru' }))return 'a0c50000002dtwKAAQ';    //NAURU
    if(opIn(t.Country, new Set<String> { 'np', 'npl', 'nepal' }))return 'a0c50000002dtwLAAQ';    //NEPAL
    return null;
  }
  private Id matchGroup9(Target t, List<Id> overlays)
  {
    if(opIn(t.Country, new Set<String> { 'nl', 'nld', 'netherlands', 'the netherlands' }))return 'a0c50000002dtwMAAQ';    //NETHERLANDS
    if(opIn(t.Country, new Set<String> { 'an', 'ant', 'netherlands antilles' }))return 'a0c50000002dtwNAAQ';    //NETHERLANDS ANTILLES
    if(opIn(t.Country, new Set<String> { 'nc', 'ncl', 'new caledonia' }))return 'a0c50000002dtwOAAQ';    //NEW CALEDONIA
    if(opIn(t.Country, new Set<String> { 'nz', 'nzl', 'new zealand' }))return 'a0c50000002dtwPAAQ';    //NEW ZEALAND
    if(opIn(t.Country, new Set<String> { 'ni', 'nic', 'nicaragua' }))return 'a0c50000002dtwQAAQ';    //NICARAGUA
    if(opIn(t.Country, new Set<String> { 'ne', 'ner', 'niger' }))return 'a0c50000002dtwRAAQ';    //NIGER
    if(opIn(t.Country, new Set<String> { 'ng', 'nga', 'nigeria' }))return 'a0c50000002dtwSAAQ';    //NIGERIA
    if(opIn(t.Country, new Set<String> { 'nu', 'niu', 'niue' }))return 'a0c50000002dtwTAAQ';    //NIUE
    if(opIn(t.Country, new Set<String> { 'nf', 'nfk', 'norfolk island' }))return 'a0c50000002dtwUAAQ';    //NORFOLK ISLAND
    if(opIn(t.Country, new Set<String> { 'mp', 'mnp', 'northern mariana islands' }))return 'a0c50000002dtwVAAQ';    //NORTHERN MARIANA ISLANDS
    if(opIn(t.Country, new Set<String> { 'no', 'nor', 'norway' }))return 'a0c50000002dtwWAAQ';    //NORWAY
    if(opIn(t.Country, new Set<String> { 'om', 'omn', 'oman' }))return 'a0c50000002dtwXAAQ';    //OMAN
    if(opIn(t.Country, new Set<String> { 'pk', 'pak', 'pakistan' }))return 'a0c50000002dtwYAAQ';    //PAKISTAN
    if(opIn(t.Country, new Set<String> { 'pw', 'plw', 'palau' }))return 'a0c50000002dtwZAAQ';    //PALAU
    if(opIn(t.Country, new Set<String> { 'pa', 'pan', 'panama' }))return 'a0c50000002dtwaAAA';    //PANAMA
    if(opIn(t.Country, new Set<String> { 'pg', 'png', 'papua new guinea' }))return 'a0c50000002dtwbAAA';    //PAPUA NEW GUINEA
    if(opIn(t.Country, new Set<String> { 'py', 'pry', 'paraguay' }))return 'a0c50000002dtwcAAA';    //PARAGUAY
    if(opIn(t.Country, new Set<String> { 'pe', 'per', 'peru' }))return 'a0c50000002dtwdAAA';    //PERU
    if(opIn(t.Country, new Set<String> { 'ph', 'phl', 'philippines' }))return 'a0c50000002dtweAAA';    //PHILIPPINES
    if(opIn(t.Country, new Set<String> { 'pn', 'pcn', 'pitcairn' }))return 'a0c50000002dtwfAAA';    //PITCAIRN
    return null;
  }
  private Id matchGroup10(Target t, List<Id> overlays)
  {
    if(opIn(t.Country, new Set<String> { 'pl', 'pol', 'poland' }))return 'a0c50000002dtwgAAA';    //POLAND
    if(opIn(t.Country, new Set<String> { 'pt', 'prt', 'portugal' }))return 'a0c50000002dtwhAAA';    //PORTUGAL
    if(opIn(t.Country, new Set<String> { 'pr', 'pri', 'puerto rico' }))return 'a0c50000002dtwiAAA';    //PUERTO RICO
    if(opIn(t.Country, new Set<String> { 'qa', 'qat', 'qatar' }))return 'a0c50000002dtwjAAA';    //QATAR
    if(opIn(t.Country, new Set<String> { 're', 'reu', 'reunion' }))return 'a0c50000002dtwkAAA';    //REUNION
    if(opIn(t.Country, new Set<String> { 'ro', 'rom', 'romania' }))return 'a0c50000002dtwlAAA';    //ROMANIA
    if(opIn(t.Country, new Set<String> { 'ru', 'rus', 'russian federation', 'russia' }))return 'a0c50000002dtwmAAA';    //RUSSIAN FEDERATION
    if(opIn(t.Country, new Set<String> { 'rw', 'rwa', 'rwanda' }))return 'a0c50000002dtwnAAA';    //RWANDA
    if(opIn(t.Country, new Set<String> { 'kn', 'kna', 'saint kitts and nevis' }))return 'a0c50000002dtwoAAA';    //SAINT KITTS AND NEVIS
    if(opIn(t.Country, new Set<String> { 'lc', 'lca', 'saint lucia' }))return 'a0c50000002dtwpAAA';    //SAINT LUCIA
    if(opIn(t.Country, new Set<String> { 'vc', 'vct', 'saint vincent and the grenadines' }))return 'a0c50000002dtwqAAA';    //SAINT VINCENT AND THE GRENADINES
    if(opIn(t.Country, new Set<String> { 'ws', 'wsm', 'samoa' }))return 'a0c50000002dtwrAAA';    //SAMOA
    if(opIn(t.Country, new Set<String> { 'sm', 'smr', 'san marino' }))return 'a0c50000002dtwsAAA';    //SAN MARINO
    if(opIn(t.Country, new Set<String> { 'st', 'stp', 'sao tome and principe' }))return 'a0c50000002dtwtAAA';    //SAO TOME AND PRINCIPE
    if(opIn(t.Country, new Set<String> { 'sa', 'sau', 'saudi arabia' }))return 'a0c50000002dtwuAAA';    //SAUDI ARABIA
    if(opIn(t.Country, new Set<String> { 'sn', 'sen', 'senegal' }))return 'a0c50000002dtwvAAA';    //SENEGAL
    if(opIn(t.Country, new Set<String> { 'rs', 'srb', 'serbia' }))return 'a0c50000002dtwwAAA';    //SERBIA
    if(opIn(t.Country, new Set<String> { 'sc', 'syc', 'seychelles' }))return 'a0c50000002dtwxAAA';    //SEYCHELLES
    if(opIn(t.Country, new Set<String> { 'sl', 'sle', 'sierra leone' }))return 'a0c50000002dtwyAAA';    //SIERRA LEONE
    if(opIn(t.Country, new Set<String> { 'sg', 'sgp', 'singapore' }))return 'a0c50000002dtwzAAA';    //SINGAPORE
    return null;
  }
  private Id matchGroup11(Target t, List<Id> overlays)
  {
    if(opIn(t.Country, new Set<String> { 'sk', 'svk', 'slovakia' }))return 'a0c50000002dtx0AAA';    //SLOVAKIA (Slovak Republic)
    if(opIn(t.Country, new Set<String> { 'si', 'svn', 'slovenia' }))return 'a0c50000002dtx1AAA';    //SLOVENIA
    if(opIn(t.Country, new Set<String> { 'sb', 'slb', 'solomon islands' }))return 'a0c50000002dtx2AAA';    //SOLOMON ISLANDS
    if(opIn(t.Country, new Set<String> { 'so', 'som', 'somalia' }))return 'a0c50000002dtx3AAA';    //SOMALIA
    if(opIn(t.Country, new Set<String> { 'za', 'zaf', 'south africa' }))return 'a0c50000002dtx4AAA';    //SOUTH AFRICA
    if(opIn(t.Country, new Set<String> { 'ss', 'ssd', 'south sudan' }))return 'a0c50000002dtx5AAA';    //SOUTH SUDAN
    if(opIn(t.Country, new Set<String> { 'gs', 'sgs', 'south georgia and south s.s.' }))return 'a0c50000002dtx6AAA';    //SOUTH GEORGIA AND SOUTH S.S.
    if(opIn(t.Country, new Set<String> { 'es', 'esp', 'spain' }))return 'a0c50000002dtx7AAA';    //SPAIN
    if(opIn(t.Country, new Set<String> { 'lk', 'lka', 'sri lanka' }))return 'a0c50000002dtx8AAA';    //SRI LANKA
    if(opIn(t.Country, new Set<String> { 'sh', 'shn', 'st. helena' }))return 'a0c50000002dtx9AAA';    //ST. HELENA
    if(opIn(t.Country, new Set<String> { 'sd', 'sdn', 'sudan' }))return 'a0c50000002dtxAAAQ';    //SUDAN
    if(opIn(t.Country, new Set<String> { 'sr', 'sur', 'suriname' }))return 'a0c50000002dtxBAAQ';    //SURINAME
    if(opIn(t.Country, new Set<String> { 'sj', 'sjm', 'svalbard and jan mayen islands' }))return 'a0c50000002dtxCAAQ';    //SVALBARD AND JAN MAYEN ISLANDS
    if(opIn(t.Country, new Set<String> { 'sz', 'swz', 'swaziland' }))return 'a0c50000002dtxDAAQ';    //SWAZILAND
    if(opIn(t.Country, new Set<String> { 'se', 'swe', 'sweden' }))return 'a0c50000002dtxEAAQ';    //SWEDEN
    if(opIn(t.Country, new Set<String> { 'ch', 'che', 'switzerland' }))return 'a0c50000002dttUAAQ';    //SWITZERLAND
    if(opIn(t.Country, new Set<String> { 'sy', 'syr', 'syrian arab republic' }))return 'a0c50000002dttVAAQ';    //SYRIAN ARAB REPUBLIC
    if(opIn(t.Country, new Set<String> { 'r.o.c.', 'republic of china', 'roc', 'taiwan', 'taiwan r.o.c.', 'taiwan, province of china', 'taiwan,province of china', 'tw', 'twn' }))return 'a0c50000002dttWAAQ';    //TAIWAN, PROVINCE OF CHINA
    if(opIn(t.Country, new Set<String> { 'tj', 'tjk', 'tajikistan' }))return 'a0c50000002dttXAAQ';    //TAJIKISTAN
    if(opIn(t.Country, new Set<String> { 'tz', 'tza', 'tanzania', 'united republic of tanzania' }))return 'a0c50000002dttYAAQ';    //TANZANIA, UNITED REPUBLIC OF
    return null;
  }
  private Id matchGroup12(Target t, List<Id> overlays)
  {
    if(opIn(t.Country, new Set<String> { 'th', 'tha', 'thailand' }))return 'a0c50000002dttZAAQ';    //THAILAND
    if(opIn(t.Country, new Set<String> { 'tg', 'tgo', 'togo' }))return 'a0c50000002dttaAAA';    //TOGO
    if(opIn(t.Country, new Set<String> { 'tk', 'tkl', 'tokelau' }))return 'a0c50000002dttbAAA';    //TOKELAU
    if(opIn(t.Country, new Set<String> { 'to', 'ton', 'tonga' }))return 'a0c50000002dttcAAA';    //TONGA
    if(opIn(t.Country, new Set<String> { 'tt', 'tto', 'trinidad and tobago', 'trinidad & tobago' }))return 'a0c50000002dttdAAA';    //TRINIDAD AND TOBAGO
    if(opIn(t.Country, new Set<String> { 'tn', 'tun', 'tunisia' }))return 'a0c50000002dtteAAA';    //TUNISIA
    if(opIn(t.Country, new Set<String> { 'tr', 'tur', 'turkey' }))return 'a0c50000002dttfAAA';    //TURKEY
    if(opIn(t.Country, new Set<String> { 'tm', 'tkm', 'turkmenistan' }))return 'a0c50000002dttgAAA';    //TURKMENISTAN
    if(opIn(t.Country, new Set<String> { 'tc', 'tca', 'turks and caicos islands' }))return 'a0c50000002dtthAAA';    //TURKS AND CAICOS ISLANDS
    if(opIn(t.Country, new Set<String> { 'tv', 'tuv', 'tuvalu' }))return 'a0c50000002dttiAAA';    //TUVALU
    if(opIn(t.Country, new Set<String> { 'ug', 'uga', 'uganda' }))return 'a0c50000002dttjAAA';    //UGANDA
    if(opIn(t.Country, new Set<String> { 'ua', 'ukr', 'ukraine' }))return 'a0c50000002dttkAAA';    //UKRAINE
    if(opIn(t.Country, new Set<String> { 'ae', 'are', 'united arab emirates', 'uae' }))return 'a0c50000002dttlAAA';    //UNITED ARAB EMIRATES
    if(opStart(t.ZipCode, new Set<String> { 'cv', 'dy', 'gl', 'hr', 'le', 'mk', 'nn', 'ox', 'pe', 'st', 'tf', 'wr', 'ws', 'wv' }) && opIn(t.Country, new Set<String> { 'gb', 'gbr', 'united kingdom', 'uk', 'great britain' }))return 'a0c38000005icedAAA';    //UK - Midlands
    if(opStart(t.ZipCode, new Set<String> { 'ha', 'kt', 'sm', 'tw', 'ub' }) && opIn(t.Country, new Set<String> { 'gb', 'gbr', 'united kingdom', 'uk', 'great britain' }))return 'a0c38000005icceAAA';    //UK - London West Extension
    if(opStart(t.ZipCode, new Set<String> { 'gy', 'je' }) && opIn(t.Country, new Set<String> { 'gb', 'gbr', 'united kingdom', 'uk', 'great britain' }))return 'a0c38000005iccPAAQ';    //UK - Channel Islands
    if(opStart(t.ZipCode, new Set<String> { 'al', 'br', 'ct', 'da', 'lu', 'me', 'po', 'rg', 'rm', 'sg', 'sl', 'so', 'tn', 'wd' }) && opIn(t.Country, new Set<String> { 'gb', 'gbr', 'united kingdom', 'uk', 'great britain' }))return 'a0c38000005iccZAAQ';    //UK - Home Counties 1
    if(opStart(t.ZipCode, new Set<String> { 'cb', 'ip', 'nr' }) && opIn(t.Country, new Set<String> { 'gb', 'gbr', 'united kingdom', 'uk', 'great britain' }))return 'a0c38000005iccUAAQ';    //UK - East
    if(opStart(t.ZipCode, new Set<String> { 'ec1', 'ec3', 'ec 1', 'ec 3' }) && opIn(t.Country, new Set<String> { 'gb', 'gbr', 'united kingdom', 'uk', 'great britain' }))return 'a0c38000005iccjAAA';    //UK - London City West
    if(opStart(t.ZipCode, new Set<String> { 'bc', 'be', 'bf', 'bg', 'bi', 'bj', 'bk', 'bm', 'bo', 'bp', 'bq', 'bu', 'bv', 'bw', 'bx', 'by', 'bz', 'b1', 'b2', 'b3', 'b4', 'b5', 'b6', 'b7', 'b8', 'b9', 'b0' }) && opIn(t.Country, new Set<String> { 'gb', 'gbr', 'united kingdom', 'uk', 'great britain' }))return 'a0c38000005iccKAAQ';    //UK - Birmingham
    return null;
  }
  private Id matchGroup13(Target t, List<Id> overlays)
  {
    if(opStart(t.ZipCode, new Set<String> { 'na', 'nb', 'nc', 'nd', 'nf', 'nh', 'ni', 'nk', 'nl', 'nm', 'no', 'nq', 'ns', 'nt', 'nu', 'nv', 'nw', 'nx', 'ny', 'nz', 'n1', 'n2', 'n3', 'n4', 'n5', 'n6', 'n7', 'n8', 'n9', 'n0', 'sw', 'wb', 'wc', 'we', 'wg', 'wh', 'wi', 'wj', 'wk', 'wl', 'wm', 'wp', 'wo', 'wq', 'wt', 'wu', 'ww', 'wx', 'wy', 'wz', 'w1', 'w2', 'w3', 'w4', 'w5', 'w6', 'w7', 'w8', 'w9', 'w0' }) && opIn(t.Country, new Set<String> { 'gb', 'gbr', 'united kingdom', 'uk', 'great britain' }))return 'a0c38000005icd8AAA';    //UK - London Greater North/West
    if(opStart(t.ZipCode, new Set<String> { 'ec2', 'ec4', 'ec 2', 'ec 4' }) && opIn(t.Country, new Set<String> { 'gb', 'gbr', 'united kingdom', 'uk', 'great britain' }))return 'a0c38000005iccoAAA';    //UK - London City East
    if(opStart(t.ZipCode, new Set<String> { 'ea', 'eb', 'ed', 'ef', 'eg', 'ee', 'eh', 'ei', 'ej', 'ek', 'el', 'em', 'en', 'eo', 'ep', 'eq', 'er', 'es', 'et', 'eu', 'ev', 'ew', 'ex', 'ey', 'ez', 'e1', 'e2', 'e3', 'e4', 'e5', 'e6', 'e7', 'e8', 'e9', 'e0' }) && opIn(t.Country, new Set<String> { 'gb', 'gbr', 'united kingdom', 'uk', 'great britain' }))return 'a0c38000005icctAAA';    //UK - London Greater East
    if(opStart(t.ZipCode, new Set<String> { 'bb', 'bl', 'ch', 'ol', 'sk', 'wn' }) && opIn(t.Country, new Set<String> { 'gb', 'gbr', 'united kingdom', 'uk', 'great britain' }))return 'a0c380000060wDVAAY';    //UK - North West 2
    if(opStart(t.ZipCode, new Set<String> { 'bn', 'cm', 'co', 'cr', 'en', 'gu', 'hp', 'ig', 'rh', 'ss' }) && opIn(t.Country, new Set<String> { 'gb', 'gbr', 'united kingdom', 'uk', 'great britain' }))return 'a0c380000060wDfAAI';    //UK - Home Counties 2
    if(opStart(t.ZipCode, new Set<String> { 'cw', 'fy', 'pr', 'wa', 'l0', 'l1', 'l2', 'l3', 'l4', 'l5', 'l6', 'l7', 'l8', 'l9', 'lb', 'lc', 'ld', 'lf', 'lg', 'lh', 'li', 'lk', 'lm', 'lo', 'lp', 'lq', 'lr', 'lt', 'lv', 'lw', 'lx', 'ly', 'lz' }) && opIn(t.Country, new Set<String> { 'gb', 'gbr', 'united kingdom', 'uk', 'great britain' }))return 'a0c38000005icexAAA';    //UK - North West 1
    if(opStart(t.ZipCode, new Set<String> { 'se' }) && opIn(t.Country, new Set<String> { 'gb', 'gbr', 'united kingdom', 'uk', 'great britain' }))return 'a0c38000005icdmAAA';    //UK - London Greater South/East
    if(opStart(t.ZipCode, new Set<String> { 'bd', 'ca', 'de', 'dh', 'dl', 'dn', 'hd', 'hg', 'hu', 'hx', 'la', 'ln', 'ls', 'ne', 'ng', 'sr', 'ts', 'wf', 'yo', 'sb', 'sc', 'sd', 'sf', 'sh', 'si', 'sj', 'sq', 'su', 'sv', 'sx', 'sz', 's1', 's2', 's3', 's4', 's5', 's6', 's7', 's8', 's9', 's0' }) && opIn(t.Country, new Set<String> { 'gb', 'gbr', 'united kingdom', 'uk', 'great britain' }))return 'a0c38000005iceiAAA';    //UK - North
    if(opStart(t.ZipCode, new Set<String> { 'ma', 'mb', 'mc', 'md', 'mf', 'mg', 'mh', 'mi', 'mj', 'mm', 'mn', 'mo', 'mp', 'mq', 'mr', 'ms', 'mt', 'mw', 'mu', 'mv', 'mx', 'my', 'mz', 'm1', 'm2', 'm3', 'm4', 'm5', 'm6', 'm7', 'm8', 'm9', 'm0' }) && opIn(t.Country, new Set<String> { 'gb', 'gbr', 'united kingdom', 'uk', 'great britain' }))return 'a0c38000005icdrAAA';    //UK - Manchester
    if(opStart(t.ZipCode, new Set<String> { 'ba', 'bh', 'bs', 'dt', 'ex', 'pl', 'sn', 'sp', 'ta', 'tq', 'tr' }) && opIn(t.Country, new Set<String> { 'gb', 'gbr', 'united kingdom', 'uk', 'great britain' }))return 'a0c38000005icesAAA';    //UK - South West
    if(opIn(t.Country, new Set<String> { 'um', 'umi', 'u.s. minor islands' }))return 'a0c50000002dttnAAA';    //U.S. MINOR ISLANDS
    if(opIn(t.Country, new Set<String> { 'uy', 'ury', 'uruguay' }))return 'a0c50000002dttoAAA';    //URUGUAY
    if(opIn(t.Country, new Set<String> { 'uz', 'uzb', 'uzbekistan' }))return 'a0c50000002dttpAAA';    //UZBEKISTAN
    if(opIn(t.Country, new Set<String> { 'vu', 'vut', 'vanuatu' }))return 'a0c50000002dttqAAA';    //VANUATU
    if(opIn(t.Country, new Set<String> { 've', 'ven', 'venezuela' }))return 'a0c50000002dttrAAA';    //VENEZUELA
    if(opIn(t.Country, new Set<String> { 'vn', 'vnm', 'viet nam', 'vietnam' }))return 'a0c50000002dttsAAA';    //VIET NAM
    if(opIn(t.Country, new Set<String> { 'vg', 'vgb', 'british virgin islands', 'virgin islands' }))return 'a0c50000002dtttAAA';    //VIRGIN ISLANDS (BRITISH)
    if(opIn(t.Country, new Set<String> { 'vi', 'vir', 'us virgin islands', 'u.s. virgin islands' }))return 'a0c50000002dttuAAA';    //VIRGIN ISLANDS (U.S.)
    if(opIn(t.Country, new Set<String> { 'wf', 'wlf', 'wallis and futuna islands' }))return 'a0c50000002dttvAAA';    //WALLIS AND FUTUNA ISLANDS
    if(opIn(t.Country, new Set<String> { 'eh', 'esh', 'western sahara' }))return 'a0c50000002dttwAAA';    //WESTERN SAHARA
    return null;
  }
  private Id matchGroup14(Target t, List<Id> overlays)
  {
    if(opIn(t.Country, new Set<String> { 'ye', 'yem', 'yemen' }))return 'a0c50000002dttxAAA';    //YEMEN
    if(opIn(t.Country, new Set<String> { 'zm', 'zmb', 'zambia' }))return 'a0c50000002dttyAAA';    //ZAMBIA
    if(opIn(t.Country, new Set<String> { 'zw', 'zwe', 'zimbabwe' }))return 'a0c50000002dttzAAA';    //ZIMBABWE
    if(opIn(t.State, new Set<String> { 'ak', 'alaska' }))return 'a0c50000002dty3AAA';    //Alaska
    if(opIn(t.State, new Set<String> { 'al', 'alabama' }))return 'a0c50000002dty4AAA';    //Alabama
    if(opIn(t.State, new Set<String> { 'ar', 'arkansas' }))return 'a0c50000002dty5AAA';    //Arkansas
    if(opIn(t.State, new Set<String> { 'az', 'arizona' }))return 'a0c50000002dty6AAA';    //Arizona
    if(opZipcode(t.ZipCode, '93201~93202,93207~93208,93210,93212,93216,93218~93219,93221,93223,93227,93230,93232,93234~93235,93237~93238,93242,93244~93247,93256~93258,93260~93262,93265,93267,93270~93272,93274~93275,93277~93279,93282,93286,93290~93292,93426,93450~93451,93601~93616,93618~93628,93630~93631,93633~93654,93656~93657,93660~93662,93664~93670,93673,93675,93701~93712,93714~93718,93720~93730,93737,93740~93741,93744~93745,93747,93750,93755,93760~93761,93764~93765,93771~93780,93784,93786,93790~93794,93844,93888,93902,93912,93915,93930,93932,93942,93954,94203~94209,94211,94229~94230,94232,94234~94237,94239~94240,94244~94250,94252,94254,94256~94259,94261~94263,94267~94269,94271,94273~94274,94277~94280,94282~94291,94293~94299,94503,94508,94510~94512,94515,94533~94535,94558~94559,94562,94567,94571,94573~94574,94576,94581,94585,94589~94592,94599,94901,94903~94904,94912~94915,94920,94922~94931,94933,94937~94942,94945~94957,94960,94963~94966,94970~94979,94998~94999,95023~95024,95043,95045,95075,95201~95213,95215,95219~95234,95236~95237,95240~95242,95245~95255,95257~95258,95267,95269,95296~95297,95301,95303~95307,95309~95330,95333~95338,95340~95341,95343~95348,95350~95358,95360~95361,95363~95370,95372~95383,95385~95389,95391,95397,95401~95407,95409~95410,95412,95415~95433,95435~95437,95439,95441~95446,95448~95454,95456~95473,95476,95480~95482,95485~95488,95490,95492~95494,95497,95501~95503,95511,95514,95518~95519,95521,95524~95528,95531~95532,95534,95536~95538,95540,95542~95543,95545~95556,95558~95560,95562~95565,95567~95571,95573,95585,95587,95589,95595,95601~95621,95623~95642,95644~95646,95648,95650~95656,95658~95699,95701,95703,95709,95712~95715,95717,95720~95722,95724,95726,95728,95735~95736,95741~95742,95746~95747,95757~95759,95762~95763,95765,95776,95798~95799,95811~95838,95840~95843,95851~95853,95860,95864~95867,95887,95894,95899,95901,95903,95910,95912~95920,95922~95930,95932,95934~95951,95953~95963,95965~95984,95986~95988,95991~95993,96001~96003,96006~96011,96013~96017,96019~96025,96027~96029,96031~96035,96037~96041,96044,96046~96052,96054~96059,96061~96065,96067~96071,96073~96076,96078~96080,96084~96097,96099,96101,96103~96106,96108~96130,96132~96137,96140~96143,96145~96146,96148,96150~96152,96154~96158,96160~96162') && opIn(t.State, new Set<String> { 'ca', 'california' }))return 'a0c50000002dty7AAA';    //Northern California
    if(opZipcode(t.ZipCode, '93901,93905~93908,93920~93928,93933,93940,93943~93944,93950,93953,93955,93960,93962,94002,94005,94010~94011,94013~94028,94030,94035,94037~94044,94060~94066,94070,94074,94080,94083,94085~94089,94101~94147,94150~94156,94158~94164,94171~94172,94175,94177,94188,94199,94301~94306,94309,94401~94404,94497,94501~94502,94505~94507,94509,94513~94514,94516~94531,94536~94553,94555~94557,94560~94561,94563~94566,94568~94570,94572,94575,94577~94580,94582~94583,94586~94588,94595~94598,94601~94615,94617~94625,94649,94659~94662,94666,94701~94710,94712,94720,94801~94808,94820,94850,95001~95015,95017~95021,95026,95030~95033,95035~95039,95041~95042,95044,95046,95050~95056,95060~95067,95070~95071,95073,95076~95077,95101,95103,95106,95108~95113,95115~95136,95138~95141,95148,95150~95161,95164,95170,95172~95173,95190~95194,95196') && opStart(t.Company, new Set<String> { 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '5', '6', '7', '8', '9' }))return 'a0c50000002gqkcAAA';    //SF Penninsula, East/North Bay (Named M-Z)
    if(opZipcode(t.ZipCode, '93901,93905~93908,93920~93928,93933,93940,93943~93944,93950,93953,93955,93960,93962,94002,94005,94010~94011,94013~94028,94030,94035,94037~94044,94060~94066,94070,94074,94080,94083,94085~94089,94101~94147,94150~94156,94158~94164,94171~94172,94175,94177,94188,94199,94301~94306,94309,94401~94404,94497,94501~94502,94505~94507,94509,94513~94514,94516~94531,94536~94553,94555~94557,94560~94561,94563~94566,94568~94570,94572,94575,94577~94580,94582~94583,94586~94588,94595~94598,94601~94615,94617~94625,94649,94659~94662,94666,94701~94710,94712,94720,94801~94808,94820,94850,95001~95015,95017~95021,95026,95030~95033,95035~95039,95041~95042,95044,95046,95050~95056,95060~95067,95070~95071,95073,95076~95077,95101,95103,95106,95108~95113,95115~95136,95138~95141,95148,95150~95161,95164,95170,95172~95173,95190~95194,95196') && opStart(t.Company, new Set<String> { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', '1', '2', '3', '4' }))return 'a0c50000002gqkoAAA';    //SF Penninsula, East/North Bay (Named A-L)
    if(opZipcode(t.ZipCode, '90010,90012,90026~90029,90031~90032,90038~90039,90041~90042,90046,90049,90065,90068~90069,90074,90077,90084,90088~90090,90095~90096,90102~90103,90189,90210,90263,90265,90272,90290,90313,90397~90398,90612,90639,90659,90747,90813~90815,90822,90831~90835,90840,90842,90844~90848,90853,90888,90895,90899,91001,91003,91006~91012,91016~91017,91020~91021,91023~91025,91030~91031,91040~91043,91046,91066,91077,91101~91110,91114~91118,91121,91123~91126,91129,91131,91182,91184~91185,91188~91189,91191,91199,91201~91210,91214,91221~91222,91224~91226,91301~91311,91313,91316,91319~91322,91324~91331,91333~91335,91337,91340~91346,91350~91365,91367,91371~91372,91376~91377,91380~91388,91390,91392~91396,91399,91401~91413,91416,91423,91426,91436,91470,91482,91495~91497,91499,91501~91508,91510,91521~91523,91526,91601~91612,91614~91618,91701~91702,91706,91708,91710~91711,91714~91716,91722~91724,91729~91735,91737,91739~91741,91743~91750,91754~91756,91758~91759,91761~91773,91775~91776,91778,91780,91784~91786,91788~91793,91795,91797~91799,91801~91804,91841,91896,91899,92242,92252,92256,92267~92268,92277~92278,92280,92284~92286,92301,92304~92305,92307~92318,92321~92329,92331~92342,92344~92347,92350,92352,92354,92356~92359,92363~92366,92368~92369,92371~92378,92382,92384~92386,92389,92391~92395,92397~92399,92401~92408,92410~92415,92418,92423~92424,92427,93001~93007,93009~93016,93020~93024,93030~93036,93040~93044,93060~93067,93093~93094,93099,93101~93103,93105~93111,93116~93118,93120~93121,93130,93140,93150,93160,93190,93199,93203~93206,93215,93220,93222,93224~93226,93239~93241,93243,93249~93252,93254~93255,93263,93266,93268,93276,93280,93283,93285,93287,93301~93309,93311~93314,93380~93390,93401~93403,93405~93410,93412,93420~93424,93427~93430,93432~93438,93440~93449,93452~93458,93460~93461,93463~93465,93475,93483,93501~93502,93504~93505,93510,93512~93519,93522~93524,93526~93532,93534~93536,93539,93541~93546,93549~93556,93558,93560~93563,93581,93584,93586,93590~93592,93596,96107') && opIn(t.State, new Set<String> { 'ca', 'california' }))return 'a0c50000002dty9AAA';    //North LA
    if(opZipcode(t.ZipCode, '90001~90009,90011,90013~90025,90030,90033~90037,90040,90043~90045,90047~90048,90050~90064,90066~90067,90070~90073,90075~90076,90078~90083,90086~90087,90091,90093~90094,90099,90101,90201~90202,90209,90211~90213,90220~90224,90230~90233,90239~90242,90245,90247~90251,90254~90255,90260~90262,90264,90266~90267,90270,90274~90275,90277~90278,90280,90291~90296,90301~90312,90401~90411,90501~90510,90601~90610,90637~90638,90640,90650~90652,90660~90662,90670~90671,90701~90704,90706~90707,90710~90717,90723,90731~90734,90744~90746,90748~90749,90755,90801~90810,90813~90815,90822,90831~90835,90853,91003,91009,91012,91017,91021,91023,91025,91031,91041,91043,91046,91066,91077,91102,91109,91114~91118,91124,91209,91221~91222,91224~91226,91305,91308~91310,91313,91322,91327~91328,91333~91334,91337,91341,91346,91353,91357,91365,91372,91376,91380,91382~91383,91385~91386,91392~91396,91412~91413,91416,91426,91503,91507~91508,91510,91603,91609~91610,91614~91618,91706,91708~91710,91714~91716,91722~91724,91730~91734,91743~91749,91752,91754~91755,91761~91770,91778,91786,91788~91793,91802,91804,91896,91899,92242,92252,92256,92267~92268,92277~92278,92280,92284~92286,92305,92308,92313~92318,92320~92322,92324~92326,92331~92333,92335,92337,92339,92341,92346,92352,92354,92356,92359,92363,92374,92376~92378,92382,92385~92386,92391,92399,92401~92402,92404~92405,92408,92410~92411,92427,92509,93539,93584,93586,93590') && opIn(t.State, new Set<String> { 'ca', 'california' }))return 'a0c50000002dtyAAAQ';    //West LA
    if(opZipcode(t.ZipCode, '90620~90624,90630~90633,90680,90720~90721,90740,90742~90743,91752,91901~91903,91905~91906,91908~91917,91921,91931~91935,91941~91948,91950~91951,91962~91963,91976~91980,91987,91990,92003~92004,92007~92011,92013~92014,92018~92030,92033,92036~92040,92046,92049,92051~92052,92054~92061,92064~92072,92074~92075,92078~92079,92081~92086,92088,92090~92093,92096,92101~92124,92126~92140,92142~92143,92145,92147,92149~92150,92152~92155,92158~92179,92182,92184,92186~92187,92190~92199,92201~92203,92210~92211,92220,92222~92223,92225~92227,92230~92236,92239~92241,92243~92244,92247~92251,92253~92255,92257~92264,92266,92270,92273~92276,92281~92283,92292,92320,92373,92501~92509,92513~92519,92521~92522,92530~92532,92536,92539,92543~92546,92548~92549,92551~92557,92561~92564,92567,92570~92572,92581~92587,92589~92593,92595~92596,92599,92602~92607,92609~92610,92612,92614~92620,92623~92630,92637,92646~92663,92672~92679,92683~92685,92688,92690~92694,92697~92698,92701~92712,92725,92728,92735,92780~92782,92799,92801~92809,92811~92812,92814~92817,92821~92823,92825,92831~92838,92840~92846,92850,92856~92857,92859~92871,92877~92883,92885~92887,92899') && opIn(t.State, new Set<String> { 'ca', 'california' }))return 'a0c50000002dtyBAAQ';    //So. LA, San Diego
    if(opIn(t.State, new Set<String> { 'co', 'colorado' }))return 'a0c50000002dtyDAAQ';    //Colorado
    if((opInRange(t.ZipCode, '06001', '06248') || opInRange(t.ZipCode, '06255', '06282') || opInRange(t.ZipCode, '06750', '06759') || opInRange(t.ZipCode, '06776', '06783') || opInRange(t.ZipCode, '06785', '06798') || opZipcode(t.ZipCode, '06250,06331~06332,06354,06373~06374,06377,06387') || opZipcode(t.ZipCode, '06447,06467,06479,06489,06763')) && opIn(t.State, new Set<String> { 'ct', 'connecticut' }))return 'a0c50000002dtyEAAQ';    //Connecticut 1
    if((opInRange(t.ZipCode, '06801', '06928') || opInRange(t.ZipCode, '06492', '06716') || opInRange(t.ZipCode, '06480', '06488') || opInRange(t.ZipCode, '06468', '06478') || opInRange(t.ZipCode, '06450', '06461') || opInRange(t.ZipCode, '06389', '06444') || opInRange(t.ZipCode, '06378', '06385') || opInRange(t.ZipCode, '06355', '06371') || opInRange(t.ZipCode, '06333', '06353') || opZipcode(t.ZipCode, '06249,06254,06320,06330,06375~06376,06762,06770,06784')) && opIn(t.State, new Set<String> { 'ct', 'connecticut' }))return 'a0c50000002dtyFAAQ';    //Connecticut 2
    if(opIn(t.State, new Set<String> { 'dc', 'dist of columbia', 'district of columbia', 'd.c.' }) && opStart(t.Company, new Set<String> { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', '1', '2', '3', '4', '5' }))return 'a0c50000002dtyGAAQ';    //Dist of Columbia A-L
    if(opIn(t.State, new Set<String> { 'dc', 'dist of columbia', 'district of columbia', 'd.c.' }) && opStart(t.Company, new Set<String> { 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '6', '7', '8', '9', '0' }))return 'a0c38000005XRuDAAW';    //Dist of Columbia M-Z
    if(opIn(t.State, new Set<String> { 'de', 'delaware' }) && opStart(t.Company, new Set<String> { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', '1', '2', '3', '4', '5' }))return 'a0c50000002dtyHAAQ';    //Delaware A-L
    if(opIn(t.State, new Set<String> { 'de', 'delaware' }) && opStart(t.Company, new Set<String> { 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '6', '7', '8', '9', '0' }))return 'a0c38000005XRuNAAW';    //Delaware M-Z
    return null;
  }
  private Id matchGroup15(Target t, List<Id> overlays)
  {
    if(opIn(t.State, new Set<String> { 'fl', 'florida' }))return 'a0c50000002dtyIAAQ';    //Florida
    if(opIn(t.State, new Set<String> { 'ga', 'georgia' }))return 'a0c50000002dtyJAAQ';    //Georgia
    if(opIn(t.State, new Set<String> { 'hi', 'hawaii' }))return 'a0c50000002dtyKAAQ';    //Hawaii
    if(opIn(t.State, new Set<String> { 'wa', 'washington', 'or', 'oregon' }) && opStart(t.Company, new Set<String> { 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '5', '6', '7', '8', '9' }))return 'a0c38000004rV3EAAU';    //Pacific NW M-Z
    if(opIn(t.State, new Set<String> { 'ia', 'iowa' }))return 'a0c50000002dtyLAAQ';    //Iowa
    if(opIn(t.State, new Set<String> { 'id', 'idaho' }))return 'a0c50000002dtyMAAQ';    //Idaho
    if(opZipcode(t.ZipCode, '60101,60153~60155,60162~60163,60401~60404,60406~60410,60416~60417,60419~60426,60428~60482,60484,60487,60490~60491,60499,60501~60507,60510~60519,60521~60523,60525~60527,60531~60532,60534,60536~60546,60549,60551,60554~60555,60557~60561,60563~60568,60570,60572,60585~60586,60597~60599,60601~60626,60628~60634,60636~60647,60649,60651~60657,60659~60661,60663~60664,60666,60668~60670,60673~60675,60677~60682,60684~60691,60693~60697,60699,60706~60707,60712,60714,60803,60805,60827,60901,60910~60915,60917~60922,60924,60926~60936,60938~60942,60944~60946,60948~60964,60966~60970,60973~60974,61201,61204,61231~61242,61244,61254,61256~61260,61262~61266,61272~61276,61278~61279,61281~61282,61284,61299,61301,61311~61317,61319~61323,61325~61330,61332~61338,61340~61342,61344~61346,61348~61350,61354,61356,61358~61364,61368~61377,61379,61401~61402,61410~61428,61430~61443,61447~61455,61458~61460,61462,61465~61480,61482~61486,61488~61491,61501,61516~61517,61519~61520,61523~61526,61528~61537,61539~61548,61550,61552~61555,61558~61565,61567~61572,61601~61607,61610~61616,61625,61629~61630,61633~61639,61641,61643,61650~61656,61701~61702,61704~61705,61709~61710,61720~61745,61747~61756,61758~61761,61764,61769~61778,61790~61791,61799,61801~61803,61810~61818,61820~61822,61824~61826,61830~61834,61839~61859,61862~61866,61870~61878,61880,61882~61884,61910~61914,61917,61919~61920,61924~61925,61928~61933,61936~61938,61940~61944,61949,61951,61953,61955~61957,62001~62002,62006,62009~62019,62021~62028,62030~62037,62040,62044~62054,62056,62058~62063,62065,62067,62069~62071,62074~62095,62097~62098,62201~62208,62214~62226,62230~62234,62236~62250,62252~62266,62268~62269,62271~62275,62277~62282,62284~62286,62288~62289,62292~62295,62297~62298,62301,62305~62306,62311~62314,62316,62319~62321,62323~62326,62329~62330,62334,62336,62338~62341,62343~62349,62351~62363,62365~62367,62370,62373~62376,62378~62380,62401,62410~62411,62413~62414,62417~62428,62431~62436,62438~62452,62454,62458~62469,62471,62473~62481,62501,62510,62512~62515,62517~62526,62530~62541,62543~62551,62553~62558,62560~62561,62563,62565,62567~62568,62570~62573,62601,62610~62613,62615,62617~62618,62621~62622,62624~62631,62633~62635,62638~62640,62642~62644,62649~62651,62655~62656,62659~62668,62670~62675,62677,62681~62685,62688~62695,62701~62708,62711~62713,62715~62716,62719,62721~62723,62726,62736,62739,62746,62756~62757,62761~62767,62769,62776~62777,62781,62786,62791,62794,62796,62801,62803,62805~62812,62814~62825,62827~62844,62846,62848~62872,62874~62899,62901~62903,62905~62910,62912,62914~62924,62926~62928,62930~62935,62938~62943,62946~62967,62969~62977,62979,62982~62985,62987~62988,62990,62992~62999') && opIn(t.State, new Set<String> { 'illinois', 'il' }))return 'a0c38000004ratWAAQ';    //Illinois - South
    if(opZipcode(t.ZipCode, '60001~60002,60004~60022,60025~60026,60029~60031,60033~60035,60037~60051,60053,60055~60056,60060~60062,60064~60065,60067~60079,60081~60099,60102~60113,60115~60126,60128~60148,60150~60152,60156~60157,60159~60161,60164~60165,60168~60181,60183~60197,60199,60201~60204,60208~60209,60296~60297,60301~60305,60399,60483,60520,60530,60548,60550,60552~60553,60556,61001,61006~61008,61010~61016,61018~61021,61024~61025,61027~61028,61030~61032,61036~61039,61041~61044,61046~61054,61057~61065,61067~61068,61070~61075,61077~61081,61084~61085,61087~61089,61091,61101~61112,61114~61115,61125~61126,61130~61132,61230,61243,61250~61252,61261,61270,61277,61283,61285,61310,61318,61324,61331,61353,61367,61378') && opIn(t.State, new Set<String> { 'illinois', 'il' }))return 'a0c38000004ratlAAA';    //Illinois - North
    if(opIn(t.State, new Set<String> { 'in', 'indiana' }))return 'a0c50000002dtyOAAQ';    //Indiana
    if(opIn(t.State, new Set<String> { 'ks', 'kansas' }))return 'a0c50000002dtyPAAQ';    //Kansas
    if(opIn(t.State, new Set<String> { 'ky', 'kentucky' }))return 'a0c50000002dtyQAAQ';    //Kentucky
    if(opIn(t.State, new Set<String> { 'la', 'louisiana' }))return 'a0c50000002dtyRAAQ';    //Louisiana
    if(opIn(t.State, new Set<String> { 'or', 'oregon', 'wa', 'washington' }) && opStart(t.Company, new Set<String> { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', '1', '2', '3', '4' }))return 'a0c38000004rV3JAAU';    //Pacific NW A-L
    if(opIn(t.State, new Set<String> { 'ma', 'massachusetts' }))return 'a0c50000002dtySAAQ';    //Massachusetts
    if(opIn(t.State, new Set<String> { 'md', 'maryland' }) && opStart(t.Company, new Set<String> { 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '6', '7', '8', '9', '0' }))return 'a0c50000002dtyTAAQ';    //Maryland M-Z
    if(opIn(t.State, new Set<String> { 'md', 'maryland' }) && opStart(t.Company, new Set<String> { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', '1', '2', '3', '4', '5' }))return 'a0c38000005XRtyAAG';    //Maryland A-L
    if(opIn(t.State, new Set<String> { 'me', 'maine' }))return 'a0c50000002dtyUAAQ';    //Maine
    if(opIn(t.State, new Set<String> { 'mi', 'michigan' }))return 'a0c50000002dtyVAAQ';    //Michigan
    if(opIn(t.State, new Set<String> { 'mn', 'minnesota' }))return 'a0c50000002dtyWAAQ';    //Minnesota
    if(opZipcode(t.ZipCode, '63005,63010~63017,63019~63021,63023,63025~63026,63028,63031,63033~63034,63037~63045,63047~63053,63055~63057,63060~63061,63065~63066,63068~63070,63072~63074,63077,63079,63084,63088~63090,63101~63141,63143~63147,63166~63167,63301,63303~63304,63332,63341~63343,63347~63349,63357,63362,63366~63370,63373,63376~63379,63381,63383,63385~63387,63389~63390') || opEqual(t.State, 'MO, Missouri'))return 'a0c38000004tLU0AAM';    //St Louis Metro
    return null;
  }
  private Id matchGroup16(Target t, List<Id> overlays)
  {
    if(opZipcode(t.ZipCode, '63006,63022,63024,63030,63032,63036,63071,63080,63087,63091,63099,63150~63151,63155~63158,63160,63163~63164,63169,63171,63177~63180,63182,63188,63190,63195~63199,63302,63333~63334,63336,63338~63339,63344~63346,63350~63353,63359,63361,63363,63365,63382,63384,63388,63401,63434~63443,63445~63448,63450~63454,63456~63469,63471~63474,63501,63531~63541,63543~63549,63551~63552,63555~63561,63563,63565~63567,63601,63622~63633,63636~63638,63640,63645,63648,63650~63651,63653~63656,63660,63662~63666,63670,63673~63675,63701~63703,63735~63740,63742~63748,63750~63752,63755,63758,63760,63763~63764,63766~63767,63769~63771,63774~63776,63779~63785,63787,63801,63822~63830,63833~63834,63837,63839~63841,63845~63853,63855,63857,63860,63862~63863,63866~63870,63873~63882,63901~63902,63931~63945,63950~63957,63960~63967,64002,64011~64022,64024,64028~64030,64034~64037,64040,64048,64050~64058,64060~64086,64088~64090,64092~64093,64096~64098,64101~64102,64105~64106,64108~64114,64116~64121,64123~64134,64136~64139,64141,64144~64158,64161,64163~64168,64170~64172,64179~64180,64183~64185,64187~64188,64190~64199,64423~64424,64426~64434,64436~64449,64451,64453~64459,64461,64463,64465~64471,64473~64477,64479~64487,64489~64494,64496~64499,64501~64508,64601,64622~64625,64628,64630~64633,64635~64661,64664,64667~64668,64670~64674,64676,64679~64683,64686,64688~64689,64701,64726,64728,64730,64733~64735,64738~64748,64750,64752,64755~64756,64759,64761~64763,64765~64767,64769~64772,64776,64778~64781,64783~64784,64788~64790,64801~64804,64833~64836,64840~64844,64847~64850,64853~64859,64861~64870,64873~64874,64944,64999,65011,65013~65014,65016~65018,65020,65023~65026,65032,65034~65043,65046~65055,65058~65059,65061~65069,65072,65074~65085,65101~65111,65201~65203,65205,65211~65212,65215~65218,65231~65233,65236~65237,65239~65240,65243~65244,65246~65248,65250~65251,65254~65265,65270,65274~65276,65278~65287,65299,65301~65302,65305,65321~65327,65329~65330,65332~65340,65344~65345,65347~65351,65354~65355,65360,65401~65402,65409,65436,65438~65441,65443~65444,65446,65449,65452~65453,65456~65457,65459,65461~65464,65466,65468,65470,65473,65479,65483~65484,65486,65501,65529,65532,65534~65536,65541~65543,65546,65548,65550,65552,65555~65557,65559~65560,65564~65567,65570~65571,65580,65582~65584,65586,65588~65591,65607~65620,65622~65627,65629~65638,65640~65641,65644~65650,65652~65658,65660~65664,65666~65669,65672~65676,65679~65682,65685~65686,65688~65690,65692,65701~65702,65704~65708,65710~65715,65717,65720~65735,65737~65742,65744~65747,65752~65757,65759~65762,65764~65779,65781,65783~65791,65793,65801~65810,65814,65817,65890,65897~65899') || opIn(t.State, new Set<String> { 'mo', 'missouri' }))return 'a0c50000002dtyXAAQ';    //Missouri
    if(opIn(t.State, new Set<String> { 'ms', 'mississippi' }))return 'a0c50000002dtxHAAQ';    //Mississippi
    if(opIn(t.State, new Set<String> { 'mt', 'montana' }))return 'a0c50000002dtxIAAQ';    //Montana
    if(opIn(t.State, new Set<String> { 'nc', 'north carolina' }))return 'a0c50000002dtxJAAQ';    //North Carolina
    if(opIn(t.State, new Set<String> { 'nd', 'north dakota' }))return 'a0c50000002dtxKAAQ';    //North Dakota
    if(opIn(t.State, new Set<String> { 'ne', 'nebraska' }))return 'a0c50000002dtxLAAQ';    //Nebraska
    if(opIn(t.State, new Set<String> { 'nh', 'new hampshire' }))return 'a0c50000002dtxMAAQ';    //New Hampshire
    if(opIn(t.State, new Set<String> { 'nj', 'n.j.', 'new jersey' }) && opStart(t.Company, new Set<String> { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', '1', '2', '3', '4', '5' }))return 'a0c50000002e7ygAAA';    //New Jersey A-L
    if(opIn(t.State, new Set<String> { 'nj', 'n.j.', 'new jersey' }) && opStart(t.Company, new Set<String> { 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '6', '7', '8', '9', '0' }))return 'a0c38000005XRtZAAW';    //New Jersey M-Z
    if(opZipcode(t.ZipCode, '10301~10314') && opIn(t.State, new Set<String> { 'ny', 'new york' }))return 'a0c38000005XQ83AAG';    //New York - Staten Island
    if(opIn(t.State, new Set<String> { 'nm', 'new mexico' }))return 'a0c50000002dtxOAAQ';    //New Mexico
    if(opIn(t.State, new Set<String> { 'nv', 'nevada' }))return 'a0c50000002dtxQAAQ';    //Nevada -Las Vegas
    if(opZipcode(t.ZipCode, '10200,10509,10512,10516,10524,10537,10541~10542,10579,10910,10912,10914~10919,10921~10922,10924~10926,10928,10930,10932~10933,10940~10941,10943,10949~10950,10953,10958~10959,10963,10969,10973,10975,10979,10981,10985,10987~10988,10990,10992,10996~10998,12007~12010,12015~12020,12022~12025,12027~12029,12031~12033,12035~12037,12040~12043,12045~12047,12050~12078,12082~12087,12089~12090,12092~12095,12106~12108,12110,12115~12118,12120~12125,12128,12130~12134,12136~12141,12143~12144,12147~12151,12153~12161,12164~12170,12172~12177,12180~12190,12192~12198,12201~12212,12214,12220,12222~12250,12252,12255~12257,12260~12261,12288,12301~12309,12325,12345,12401~12402,12404~12407,12409~12414,12416~12424,12427~12436,12438~12444,12446,12448~12461,12463~12466,12468~12475,12477,12480~12487,12489~12496,12498,12501~12504,12506~12508,12510~12518,12520~12531,12533~12534,12537~12538,12540~12553,12555,12561,12563~12572,12574~12575,12577~12578,12580~12586,12588~12590,12592~12594,12601~12604,12701,12719~12727,12729,12732~12734,12736~12738,12740~12743,12745~12752,12754,12758~12760,12762~12771,12775~12781,12783~12792,12801,12803~12804,12808~12812,12814~12817,12819~12824,12827~12828,12831~12839,12841~12866,12870~12874,12878~12879,12883~12887,12901,12903,12910~12924,12926~12930,12932~12937,12939,12941~12946,12949~12950,12952~12953,12955~12962,12964~12967,12969~12970,12972~12981,12983,12985~12987,12989,12992~12993,12995~12998,13020~13022,13024,13026~13037,13039~13045,13051~13054,13056~13057,13060~13066,13068~13069,13071~13074,13076~13078,13080~13084,13087~13090,13092~13093,13101~13104,13107~13108,13110~13124,13126,13131~13132,13134~13148,13152~13160,13162~13167,13201~13212,13214~13215,13217~13221,13224~13225,13235,13244,13250~13252,13261,13290,13301~13305,13308~13310,13312~13329,13331~13335,13337~13343,13345~13346,13348,13350,13352~13355,13357,13360~13365,13367~13368,13401~13404,13406~13411,13413,13415~13418,13420~13421,13424~13426,13428,13431,13433,13435~13442,13449~13450,13452,13454~13457,13459~13461,13464~13465,13468~13473,13475~13480,13482~13486,13488~13495,13501~13505,13599,13601~13603,13605~13608,13611~13628,13630~13643,13645~13652,13654~13662,13664~13685,13687,13690~13697,13699,13730~13734,13736~13740,13743~13758,13760~13763,13774~13778,13780,13782~13784,13786~13788,13790,13794~13797,13801~13804,13806~13815,13820,13825~13827,13830,13832~13835,13837~13851,13856,13859~13865,13901~13905,14001,14004~14006,14008~14013,14020~14021,14024~14043,14047~14048,14051~14052,14054~14063,14065~14070,14072,14075,14080~14083,14085~14086,14091~14092,14094~14095,14098,14101~14103,14105,14107~14113,14120,14125~14127,14129~14136,14138~14141,14143~14145,14150~14151,14166~14174,14201~14228,14231,14233,14240~14241,14260~14261,14263~14265,14267,14269~14270,14272~14273,14276,14280,14301~14305,14410~14411,14413~14416,14418,14420,14422~14425,14427~14430,14432~14433,14435,14437,14441,14443,14445,14449~14450,14452~14454,14456,14461~14464,14466~14472,14475~14482,14485~14489,14502,14504~14508,14510~14522,14525~14527,14529~14530,14532~14534,14536~14539,14541~14551,14555~14561,14563~14564,14568~14569,14571~14572,14580,14585~14586,14588~14592,14602~14627,14638~14639,14642~14647,14649~14653,14664,14673,14683,14692,14694,14701~14702,14706~14712,14714~14724,14726~14733,14735~14745,14747~14748,14750~14758,14760,14766~14767,14769~14770,14772,14774~14775,14777~14779,14781~14788,14801~14810,14812~14827,14830~14831,14836~14843,14845~14847,14850~14861,14863~14865,14867,14869~14874,14876~14887,14889,14891~14895,14897~14898,14901~14905,14925') && opIn(t.State, new Set<String> { 'ny', 'new york' }))return 'a0c50000002dtxRAAQ';    //New York - Up State
    if(opZipcode(t.ZipCode, '10001~10041,10043~10048,10055,10060,10065,10069,10072,10075,10079~10082,10087,10090,10094~10096,10098~10099,10101~10126,10128~10133,10138,10149~10179,10184~10185,10196~10197,10199,10203,10211~10213,10242,10249,10256~10261,10265,10268~10282,10285~10286,10292,10451~10475,10499,10501~10507,10510~10511,10514,10517~10523,10526~10528,10530,10532~10533,10535~10536,10538,10540,10543,10545~10553,10557~10558,10560,10562,10566~10567,10570~10573,10576~10578,10580,10583,10587~10591,10594~10598,10601~10607,10610,10701~10710,10801~10805,10901,10911,10913,10920,10923,10927,10931,10952,10954,10956,10960,10962,10964~10965,10968,10970,10974,10976~10977,10980,10982~10984,10986,10989,10993~10994') && opStart(t.Company, new Set<String> { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', '0', '1', '2', '3', '4' }))return 'a0c50000002dtxFAAQ';    //New York - Manhattan (A-L)
    if(opZipcode(t.ZipCode, '10001~10041,10043~10048,10055,10060,10065,10069,10072,10075,10079~10082,10087,10090,10094~10096,10098~10099,10101~10126,10128~10133,10138,10149~10179,10184~10185,10196~10197,10199,10203,10211~10213,10242,10249,10256~10261,10265,10268~10282,10285~10286,10292,10451~10475,10499,10501~10507,10510~10511,10514,10517~10523,10526~10528,10530,10532~10533,10535~10536,10538,10540,10543,10545~10553,10557~10558,10560,10562,10566~10567,10570~10573,10576~10578,10580,10583,10587~10591,10594~10598,10601~10607,10610,10701~10710,10801~10805,10901,10911,10913,10920,10923,10927,10931,10952,10954,10956,10960,10962,10964~10965,10968,10970,10974,10976~10977,10980,10982~10984,10986,10989,10993~10994') && opStart(t.Company, new Set<String> { 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '5', '6', '7', '8', '9' }))return 'a0c38000005XQ8NAAW';    //New York - Manhattan (M-Z)
    if(opZipcode(t.ZipCode, '00501,00544,06390,10301~10314,11001~11005,11010,11020~11027,11030,11040~11044,11050~11055,11096,11099,11101~11106,11109,11120,11201~11226,11228~11245,11247~11249,11251~11252,11254~11256,11351~11352,11354~11375,11377~11381,11385~11386,11390,11405,11411~11436,11439,11451,11499,11501,11507,11509~11510,11514,11516,11518,11520,11530~11531,11535~11536,11542,11545,11547~11561,11563,11565~11566,11568~11572,11575~11577,11579~11582,11590,11592,11594~11599,11690~11695,11697,11701~11710,11713~11722,11724~11727,11729~11733,11735~11743,11746~11747,11749~11758,11760,11762~11780,11782~11784,11786~11798,11801~11804,11815,11819,11853~11855,11901,11930~11935,11937,11939~11942,11944,11946~11965,11967~11973,11975~11978,11980') && opIn(t.State, new Set<String> { 'ny', 'new york' }))return 'a0c50000002dtxGAAQ';    //New York - Long Island
    if(opZipcode(t.ZipCode, '43001~43004,43007~43010,43013,43015~43018,43021,43023,43025~43027,43029~43033,43035~43036,43040~43041,43044~43047,43054~43056,43058,43060~43062,43064~43074,43076~43078,43080~43086,43093,43098,43101~43103,43105~43107,43109~43113,43115~43117,43119,43123,43125~43128,43130,43135~43138,43140,43142~43158,43160,43162~43164,43194~43196,43198~43199,43201~43207,43209~43224,43226~43232,43234~43236,43240,43251,43260,43265~43266,43268,43270~43272,43279,43287,43291,43299,43310~43311,43318~43319,43324,43331,43333,43336,43343~43345,43347~43348,43357~43358,43360,43701~43702,43711,43713,43716~43725,43727~43728,43730~43736,43738~43740,43746~43750,43752,43754~43762,43764,43766~43768,43771~43773,43777~43780,43782~43783,43786~43789,43791,43793,43802,43821~43822,43830,43842,43902,43905~43906,43909,43912,43914~43916,43927~43928,43931,43933~43935,43937,43940,43942,43946~43947,43950~43951,43967,43972,43977,43983,43985,45001~45005,45011~45015,45018,45025~45026,45030,45032~45034,45036,45039~45044,45050~45056,45061~45071,45101~45103,45105~45106,45110~45112,45115,45118~45123,45130~45133,45135,45140,45142,45144~45145,45147,45150,45152~45158,45160,45162,45167~45168,45171~45172,45174,45176,45201~45209,45211~45255,45258,45262~45264,45267~45271,45273~45275,45277,45280,45296,45298~45299,45301~45312,45314~45328,45330~45354,45356,45358~45363,45365,45367~45374,45377~45378,45380~45385,45387~45390,45400~45406,45408~45410,45412~45420,45422~45424,45426~45435,45437,45439~45441,45448~45449,45454,45458~45459,45463,45469~45470,45475,45479,45481~45482,45490,45501~45506,45601,45612~45614,45616~45624,45628~45631,45633~45634,45636,45638,45640,45642~45648,45650~45654,45656~45663,45669,45671~45675,45677~45688,45690,45692~45699,45712~45715,45720~45721,45724,45727,45729,45734,45741~45746,45750,45760,45767~45773,45775,45779,45783~45784,45786~45789,45819,45822,45826,45828,45845~45846,45860,45862,45865~45866,45869~45871,45882~45885,45888,45895~45896,45999') && opIn(t.State, new Set<String> { 'oh', 'ohio' }))return 'a0c38000005L0vrAAC';    //South Ohio
    if(opZipcode(t.ZipCode, '43005~43006,43011,43014,43019,43022,43028,43037,43048,43050,43301~43302,43306~43307,43314~43317,43320~43323,43325~43326,43330,43332,43334~43335,43337~43338,43340~43342,43346,43349~43351,43356,43359,43402~43403,43406~43408,43410,43412~43414,43416,43420,43430~43443,43445~43447,43449~43452,43456~43458,43460,43462~43469,43501~43502,43504~43506,43510~43512,43515~43537,43540~43543,43545,43547~43558,43560,43565~43567,43569~43571,43601,43603~43620,43623,43635,43652,43654,43656~43657,43659~43661,43666~43667,43681~43682,43697,43699,43803~43805,43811~43812,43824,43828,43832,43836~43837,43840,43843~43845,43901,43903,43907~43908,43910,43913,43917,43920,43925~43926,43930,43932,43938~43939,43941,43943~43945,43948,43952~43953,43961~43964,43968,43970~43971,43973~43974,43976,43981,43984,43986,43988,44001,44003~44005,44010~44012,44017,44021~44024,44026,44028,44030,44032~44033,44035~44036,44039~44041,44044~44050,44052~44057,44060~44062,44064~44065,44067~44068,44070,44072~44074,44076~44077,44080~44082,44084~44090,44092~44097,44099,44101~44147,44149,44178,44181,44185,44188~44195,44197~44199,44201~44203,44210~44212,44214~44217,44221~44224,44230~44237,44240~44243,44250~44251,44253~44256,44258,44260,44262,44264~44266,44270,44272~44276,44278,44280~44282,44285~44288,44301~44317,44319~44322,44325~44326,44328,44333~44334,44372,44393,44396,44398~44399,44401~44406,44408,44410~44413,44415~44418,44420,44422~44425,44427~44432,44436~44446,44449~44455,44460,44470~44471,44473,44481~44486,44488,44490~44493,44501~44507,44509~44515,44555,44601,44606~44615,44617~44622,44624~44634,44636~44641,44643~44648,44650~44654,44656~44657,44659~44663,44665~44667,44669~44672,44675~44683,44685,44687~44691,44693,44695,44697,44699,44701~44711,44714,44718,44720~44721,44730,44735,44750,44767,44799,44802,44804~44805,44807,44809,44811,44813~44818,44820,44822,44824~44828,44830,44833,44836~44851,44853~44857,44859~44862,44864~44867,44870~44871,44874~44875,44878,44880~44883,44887~44890,44901~44907,44999,45107,45113~45114,45138,45146,45148,45159,45164,45166,45169,45177,45701,45710~45711,45716~45717,45719,45723,45732,45735,45739~45740,45761,45764,45766,45776~45778,45780,45782,45801~45802,45804~45810,45812~45817,45820~45821,45827,45830~45833,45835~45841,45843~45844,45848~45851,45853~45856,45858~45859,45861,45863~45864,45867~45868,45872~45877,45879~45881,45886~45887,45889~45891,45893~45894,45897~45899') || opIn(t.State, new Set<String> { 'oh', 'ohio' }))return 'a0c50000002dtxTAAQ';    //Ohio
    if(opIn(t.State, new Set<String> { 'ok', 'oklahoma' }))return 'a0c50000002dtxUAAQ';    //Oklahoma
    if(opZipcode(t.ZipCode, '15001,15003~15007,15009~15010,15012,15014~15015,15017~15022,15024~15028,15030~15035,15037~15038,15042~15047,15049~15057,15059~15069,15071~15072,15074~15078,15081~15091,15095~15096,15101~15102,15104,15106,15108,15110,15112,15116,15120,15122~15123,15126~15127,15129,15131~15137,15139~15140,15142~15148,15201~15244,15250~15255,15257~15265,15267~15268,15270,15272,15274~15279,15281~15283,15285~15286,15289~15290,15295,15301,15310~15317,15320~15325,15327,15329~15334,15336~15342,15344~15353,15357~15368,15370,15376~15380,15401,15410~15413,15415~15417,15419~15425,15427~15438,15440,15442~15451,15454~15456,15458~15470,15472~15480,15482~15486,15488~15490,15492,15501~15502,15510,15520~15522,15530~15535,15537~15542,15544~15555,15557~15565,15601,15605~15606,15610~15613,15615~15629,15631~15642,15644,15646~15647,15650,15655~15656,15658,15660~15666,15668,15670~15693,15695~15698,15701,15705,15710~15717,15720~15725,15727~15734,15736~15742,15744~15748,15750,15752~15754,15756~15765,15767,15770~15781,15783~15784,15801,15821~15825,15827~15829,15831~15832,15834,15840~15841,15845~15849,15851,15853,15856~15857,15860~15861,15863~15866,15868,15870,15901~15902,15904~15907,15909,15915,15920~15931,15934~15938,15940,15942~15946,15948~15949,15951~15963,16001~16003,16016~16018,16020~16025,16027~16030,16033~16041,16045~16046,16048~16059,16061,16063,16066,16101~16103,16105,16107~16108,16110~16117,16120~16121,16123~16125,16127,16130~16134,16136~16137,16141~16143,16145~16146,16148,16150~16151,16153~16154,16156~16157,16159~16161,16172,16201,16210~16215,16217~16218,16220~16226,16228~16230,16232~16236,16238~16240,16242,16244~16246,16248~16250,16253~16263,16301,16311~16314,16316~16317,16319,16321~16323,16326~16329,16331~16335,16340~16347,16350~16354,16360~16362,16364~16375,16388,16401~16407,16410~16413,16415~16417,16420~16424,16426~16428,16430,16432~16436,16438,16440~16444,16475,16501~16512,16514~16515,16522,16530~16534,16538,16541,16544,16546,16550,16553~16554,16563,16565,16611,16613,16616,16619~16624,16627,16629~16630,16633~16634,16636,16638~16641,16644~16647,16650~16652,16654~16657,16659~16661,16663~16664,16666~16672,16674~16675,16677~16681,16683,16685,16692,16694~16695,16698~16699,16701,16720,16724~16735,16738,16740,16743~16746,16748~16750,16801~16805,16820~16821,16823,16825~16830,16832~16841,16843~16845,16847,16849~16856,16858~16861,16863~16866,16868,16870,16872~16879,16881~16882,16915,16922~16923,16927,16937,16941,16948,17002,17052,17060,17211,17213,17239,17243,17249,17253,17255,17260,17264,17729') && opIn(t.State, new Set<String> { 'pa', 'pennsylvania' }))return 'a0c50000002dtxWAAQ';    //Pennsylvania -Western
    return null;
  }
  private Id matchGroup17(Target t, List<Id> overlays)
  {
    if(opZipcode(t.ZipCode, '15266,15273,15288,15439,15536,16140,16155,16601~16603,16617,16625,16631,16635,16637,16648,16662,16665,16673,16682,16684,16686,16689,16691,16693,16822,16848,16871,16901,16910~16912,16914,16917~16918,16920~16921,16925~16926,16928~16930,16932~16933,16935~16936,16938~16940,16942~16943,16945~16947,16950,17001,17003~17030,17032~17051,17053~17059,17061~17078,17080~17091,17093~17094,17097~17099,17101~17113,17120~17130,17140,17177,17201~17202,17210,17212,17214~17215,17217,17219~17225,17228~17229,17231~17233,17235~17238,17240~17241,17244,17246~17247,17250~17252,17254,17256~17257,17261~17263,17265~17268,17270~17272,17301~17304,17306~17307,17309~17327,17329,17331~17335,17337,17339~17340,17342~17345,17347,17349~17350,17352~17356,17358,17360~17366,17368,17370~17372,17375,17401~17408,17415,17501~17509,17512,17516~17522,17527~17529,17532~17538,17540,17543,17545,17547,17549~17552,17554~17555,17557,17560,17562~17570,17572~17573,17575~17576,17578~17585,17601~17608,17611,17622,17699,17701~17703,17705,17720~17721,17723~17724,17726~17728,17730~17731,17735,17737~17740,17742,17744~17745,17747~17752,17754,17756,17758,17760,17762~17765,17767~17769,17771~17774,17776~17779,17801,17810,17812~17815,17820~17824,17827,17829~17837,17839~17847,17850~17851,17853,17855~17862,17864~17868,17870,17872,17876~17878,17880~17889,17901,17920~17923,17925,17929~17936,17938,17941~17946,17948~17949,17951~17954,17957,17959~17961,17963~17968,17970,17972,17974,17976,17978~17983,17985,18001~18003,18010~18018,18020,18025,18030~18032,18034~18046,18049~18056,18058~18060,18062~18074,18076~18081,18083~18088,18091~18092,18098~18099,18101~18106,18109,18175,18195,18201~18202,18210~18212,18214,18216,18218~18225,18229~18232,18234~18235,18237,18239~18242,18244~18252,18254~18256,18301~18302,18320~18328,18330~18337,18340~18344,18346~18357,18360,18370~18373,18403,18405,18407,18410~18411,18413~18417,18419~18421,18424~18428,18430~18431,18433~18441,18443~18449,18451~18466,18469~18473,18501~18505,18507~18510,18512,18514~18515,18517~18519,18522,18540,18577,18601~18603,18610~18612,18614~18619,18621~18632,18634~18636,18640~18644,18651,18653~18657,18660~18661,18690,18701~18711,18762,18764~18767,18769,18773,18801,18810,18812~18818,18820~18834,18837,18840,18842~18848,18850~18851,18853~18854,18901~18902,18910~18918,18920~18936,18938,18940,18942~18944,18946~18947,18949~18951,18953~18958,18960,18962~18964,18966,18968~18972,18974,18976~18977,18979~18981,18991,19001~19004,19006~19010,19012~19023,19025~19041,19043~19044,19046~19050,19052~19058,19060~19061,19063~19067,19070,19072~19076,19078~19083,19085~19096,19098~19099,19101~19116,19118~19155,19160~19162,19170~19173,19175~19179,19181~19185,19187~19188,19190~19197,19244,19255,19301,19310~19312,19316~19320,19330~19331,19333,19335,19339~19348,19350~19355,19357~19358,19360,19362~19363,19365~19367,19369,19371~19376,19380~19383,19388,19390,19395,19397~19399,19401,19403~19409,19415,19420~19426,19428~19430,19432,19435~19438,19440~19444,19446,19450~19451,19453~19457,19460,19462,19464~19465,19468,19470,19472~19475,19477~19478,19480~19490,19492~19496,19501,19503~19508,19510~19512,19516,19518~19520,19522~19523,19525~19526,19529~19530,19533~19536,19538~19545,19547~19551,19554~19555,19559~19560,19562,19564~19565,19567,19601~19612,19640') && opIn(t.State, new Set<String> { 'pa', 'pennsylvania' }) && opStart(t.Company, new Set<String> { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', '1', '2', '3', '4', '5' }))return 'a0c50000002dtxXAAQ';    //Pennsylvania -Eastern A-L
    if(opZipcode(t.ZipCode, '15266,15273,15288,15439,15536,16140,16155,16601~16603,16617,16625,16631,16635,16637,16648,16662,16665,16673,16682,16684,16686,16689,16691,16693,16822,16848,16871,16901,16910~16912,16914,16917~16918,16920~16921,16925~16926,16928~16930,16932~16933,16935~16936,16938~16940,16942~16943,16945~16947,16950,17001,17003~17030,17032~17051,17053~17059,17061~17078,17080~17091,17093~17094,17097~17099,17101~17113,17120~17130,17140,17177,17201~17202,17210,17212,17214~17215,17217,17219~17225,17228~17229,17231~17233,17235~17238,17240~17241,17244,17246~17247,17250~17252,17254,17256~17257,17261~17263,17265~17268,17270~17272,17301~17304,17306~17307,17309~17327,17329,17331~17335,17337,17339~17340,17342~17345,17347,17349~17350,17352~17356,17358,17360~17366,17368,17370~17372,17375,17401~17408,17415,17501~17509,17512,17516~17522,17527~17529,17532~17538,17540,17543,17545,17547,17549~17552,17554~17555,17557,17560,17562~17570,17572~17573,17575~17576,17578~17585,17601~17608,17611,17622,17699,17701~17703,17705,17720~17721,17723~17724,17726~17728,17730~17731,17735,17737~17740,17742,17744~17745,17747~17752,17754,17756,17758,17760,17762~17765,17767~17769,17771~17774,17776~17779,17801,17810,17812~17815,17820~17824,17827,17829~17837,17839~17847,17850~17851,17853,17855~17862,17864~17868,17870,17872,17876~17878,17880~17889,17901,17920~17923,17925,17929~17936,17938,17941~17946,17948~17949,17951~17954,17957,17959~17961,17963~17968,17970,17972,17974,17976,17978~17983,17985,18001~18003,18010~18018,18020,18025,18030~18032,18034~18046,18049~18056,18058~18060,18062~18074,18076~18081,18083~18088,18091~18092,18098~18099,18101~18106,18109,18175,18195,18201~18202,18210~18212,18214,18216,18218~18225,18229~18232,18234~18235,18237,18239~18242,18244~18252,18254~18256,18301~18302,18320~18328,18330~18337,18340~18344,18346~18357,18360,18370~18373,18403,18405,18407,18410~18411,18413~18417,18419~18421,18424~18428,18430~18431,18433~18441,18443~18449,18451~18466,18469~18473,18501~18505,18507~18510,18512,18514~18515,18517~18519,18522,18540,18577,18601~18603,18610~18612,18614~18619,18621~18632,18634~18636,18640~18644,18651,18653~18657,18660~18661,18690,18701~18711,18762,18764~18767,18769,18773,18801,18810,18812~18818,18820~18834,18837,18840,18842~18848,18850~18851,18853~18854,18901~18902,18910~18918,18920~18936,18938,18940,18942~18944,18946~18947,18949~18951,18953~18958,18960,18962~18964,18966,18968~18972,18974,18976~18977,18979~18981,18991,19001~19004,19006~19010,19012~19023,19025~19041,19043~19044,19046~19050,19052~19058,19060~19061,19063~19067,19070,19072~19076,19078~19083,19085~19096,19098~19099,19101~19116,19118~19155,19160~19162,19170~19173,19175~19179,19181~19185,19187~19188,19190~19197,19244,19255,19301,19310~19312,19316~19320,19330~19331,19333,19335,19339~19348,19350~19355,19357~19358,19360,19362~19363,19365~19367,19369,19371~19376,19380~19383,19388,19390,19395,19397~19399,19401,19403~19409,19415,19420~19426,19428~19430,19432,19435~19438,19440~19444,19446,19450~19451,19453~19457,19460,19462,19464~19465,19468,19470,19472~19475,19477~19478,19480~19490,19492~19496,19501,19503~19508,19510~19512,19516,19518~19520,19522~19523,19525~19526,19529~19530,19533~19536,19538~19545,19547~19551,19554~19555,19559~19560,19562,19564~19565,19567,19601~19612,19640') && opIn(t.State, new Set<String> { 'pa', 'pennsylvania' }) && opStart(t.Company, new Set<String> { 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '6', '7', '8', '9', '0' }))return 'a0c38000005XRt5AAG';    //Pennsylvania -Eastern M-Z
    if(opIn(t.State, new Set<String> { 'pr', 'puerto rico' }))return 'a0c50000002dtxYAAQ';    //Puerto Rico
    if(opIn(t.State, new Set<String> { 'ri', 'rhode island' }))return 'a0c50000002dtxZAAQ';    //Rhode Island
    if(opIn(t.State, new Set<String> { 'sc', 'south carolina' }))return 'a0c50000002dtxaAAA';    //South Carolina
    if(opIn(t.State, new Set<String> { 'sd', 'south dakota' }))return 'a0c50000002dtxbAAA';    //South Dakota
    if(opIn(t.State, new Set<String> { 'tn', 'tennessee' }))return 'a0c50000002dtxcAAA';    //Tennessee
    if(opIn(t.State, new Set<String> { 'tx', 'texas' }) && opZipcode(t.ZipCode, '75001~75002,75006~75007,75009~75011,75013~75017,75019~75030,75032,75034~75035,75037~75054,75056~75058,75060~75063,75065,75067~75071,75074~75078,75080~75083,75085~75094,75097~75099,75101,75103~75106,75109~75110,75114~75121,75123~75127,75132,75134~75135,75137~75138,75140~75144,75146~75161,75163~75169,75172~75173,75180~75182,75185,75187,75189,75201~75212,75214~75238,75240~75254,75258,75260~75267,75270,75275,75277,75283~75287,75301,75303,75310,75312~75313,75315,75320,75323,75326,75334,75336,75339~75340,75342~75344,75353~75360,75363~75364,75367~75368,75370~75374,75376,75378~75382,75386~75398,75401~75404,75407,75409~75418,75420~75426,75428~75429,75431~75439,75441~75444,75446~75462,75468~75483,75485~75497,75501,75503~75505,75507,75550~75551,75554~75556,75558~75574,75599,75601~75608,75615,75631,75633,75636~75645,75647,75650~75654,75656~75663,75666~75672,75680~75689,75691~75694,75751~75752,75754~75759,75764~75766,75770,75772~75773,75778,75780,75782~75785,75789~75790,75797,75838,75840,75848,75859~75860,75925,75976,76001~76008,76010~76023,76028,76031,76033~76036,76039~76041,76043~76044,76048~76055,76058~76061,76063~76068,76070~76071,76073,76077~76078,76082,76084~76088,76092~76099,76101~76124,76126~76127,76129~76137,76140,76147~76148,76150,76155,76161~76164,76166,76177,76179~76182,76185,76191~76193,76195~76199,76201~76210,76225~76228,76230,76233~76234,76238~76241,76244~76253,76255,76258~76259,76261~76268,76270~76273,76299,76301~76302,76305~76311,76351~76352,76354,76357,76360,76363~76367,76369~76374,76377,76379,76384~76385,76388~76389,76401~76402,76424,76426,76429~76431,76433,76435~76437,76439,76442~76446,76448~76450,76452~76455,76457~76472,76474~76476,76481,76483~76487,76490~76491,76518~76520,76523,76531,76556~76557,76565,76567,76577,76621~76624,76626~76628,76630~76631,76633~76642,76644~76645,76648~76655,76657,76660,76664~76667,76670~76671,76673,76676,76678~76679,76681~76682,76684,76686~76687,76689~76693,76701~76708,76710~76712,76714~76716,76795,76797~76799,76820,76828,76834,76842,76844~76845,76856,76864,76869~76870,76873,76878,76880,76882,76884,76888,76933,76945,76949,76951,76953,77857,79001,79003,79005,79007~79016,79018~79019,79021~79022,79024~79025,79027,79029,79031~79036,79039~79046,79051~79053,79056,79058~79059,79061~79064,79068,79070,79072~79073,79077~79088,79091~79098,79101~79111,79114,79116~79121,79124,79159,79166,79168,79172,79174,79178,79185,79187,79189,79201,79220~79221,79223,79225~79227,79229~79231,79233~79237,79239~79241,79243~79245,79247~79248,79250~79252,79255~79259,79261,79311~79314,79316,79322~79323,79325~79326,79329,79331,79336,79338~79339,79342~79343,79345~79346,79350~79351,79353,79355,79357~79360,79363~79364,79366~79367,79369~79373,79376~79383,79401~79416,79423~79424,79430,79452~79453,79457,79464,79490~79491,79493,79499,79501~79506,79508,79510~79512,79516~79521,79525~79530,79532~79533,79535~79541,79544~79545,79547~79550,79553,79556,79561~79563,79565,79601~79608,79697~79699,79701~79708,79710~79714,79719~79721,79733,79741~79742,79748~79749,79754,79756,79758~79766,79768~79769,79776~79777,79782~79783,79788'))return 'a0c50000002dtxdAAA';    //Texas1
    if(opIn(t.State, new Set<String> { 'tx', 'texas' }) && opZipcode(t.ZipCode, '73301,73344,75033,75102,75440,75630,75701~75713,75750,75760,75762~75763,75771,75779,75788,75791~75792,75798~75799,75801~75803,75831~75835,75839,75844~75847,75849~75853,75855~75856,75858,75861~75862,75865,75880,75882,75884,75886,75901~75904,75915,75926,75928~75939,75941~75944,75946,75948~75949,75951,75954,75956,75958~75966,75968~75969,75972~75975,75977~75980,75990,76009,76380,76427,76432,76501~76505,76508,76511,76513,76522,76524~76528,76530,76533~76534,76537~76550,76554,76558~76559,76561,76564,76566,76569~76571,76573~76574,76578~76579,76596~76599,76629,76632,76643,76656,76661,76680,76685,76801~76804,76821,76823~76825,76827,76831~76832,76836~76837,76841,76848~76849,76852~76855,76857~76859,76861~76862,76865~76866,76871~76872,76874~76875,76877,76883,76885~76887,76890,76901~76906,76908~76909,76930,76932,76934~76937,76939~76941,76943,76950,76955,76957~76958,77001~77099,77201~77210,77212~77213,77215~77231,77233~77238,77240~77263,77265~77280,77282,77284~77294,77296~77299,77301~77306,77315~77316,77318,77320,77325~77328,77331~77351,77353~77360,77362~77365,77367~77369,77371~77389,77391,77393,77396,77399,77401~77402,77404,77406~77407,77410~77415,77417~77420,77422~77423,77426,77428~77437,77440~77461,77463~77471,77473~77489,77491~77494,77496~77498,77501~77508,77510~77512,77514~77523,77530~77536,77538~77539,77541~77542,77545~77547,77549~77555,77560~77566,77568,77571~77575,77577~77578,77580~77588,77590~77592,77597~77598,77611~77617,77619,77622~77627,77629~77632,77639~77643,77650~77651,77655~77657,77659~77665,77670,77701~77710,77713,77720,77725~77726,77801~77803,77805~77808,77830~77831,77833~77838,77840~77845,77850,77852~77853,77855~77856,77859,77861~77873,77875~77876,77878~77882,77901~77905,77950~77951,77954,77957,77960~77964,77967~77971,77973~77979,77982~77984,77986~77991,77993~77995,78001~78017,78019,78021~78029,78039~78046,78049~78050,78052,78054~78067,78069~78076,78101~78102,78104,78107~78109,78111~78119,78121~78125,78130~78133,78135,78140~78148,78150~78152,78154~78156,78159~78164,78201~78266,78268~78270,78275,78278~78280,78283~78289,78291~78299,78330,78332~78333,78335~78336,78338~78344,78347,78349~78353,78355,78357~78364,78368~78377,78379~78385,78387,78389~78391,78393,78401~78419,78426~78427,78460~78461,78463,78465~78478,78480,78501~78505,78516,78520~78523,78526,78535~78543,78545,78547~78553,78557~78570,78572~78580,78582~78586,78588~78599,78602,78604~78624,78626~78636,78638~78646,78648,78650~78667,78669~78677,78680~78683,78691,78701~78705,78708~78739,78741~78742,78744~78769,78772~78774,78778~78781,78783,78785~78786,78788~78789,78798~78799,78801~78802,78827~78830,78832~78834,78836~78843,78847,78850~78853,78860~78861,78870~78873,78877,78879~78881,78883~78886,78931~78935,78938,78940~78954,78956~78957,78959~78963,79002,79054,79057,79065~79066,79320,79324,79330,79344,79347,79356,79534,79543,79546,79560,79566~79567,79718,79730~79731,79734~79735,79738~79740,79743~79745,79752,79755,79770,79772,79778,79780~79781,79785~79786,79789,79821,79830~79832,79834~79839,79842~79843,79845~79849,79851~79855,79901~79908,79910~79918,79920,79922~79932,79934~79938,79940~79955,79958,79960~79961,79968,79976,79978,79980,79990,79995~79999,88510~88521,88523~88536,88538~88550,88553~88563,88565~88590,88595'))return 'a0c50000002h0JuAAI';    //Texas2
    if(opIn(t.State, new Set<String> { 'ut', 'utah' }))return 'a0c50000002dtxfAAA';    //Utah
    if(opZipcode(t.ZipCode, '20101~20107,20109,20112~20113,20115~20122,20124,20128~20132,20134~20144,20146~20149,20151~20153,20155~20156,20158~20160,20163~20172,20175~20178,20180~20182,20184~20199,20598,22003,22009,22015,22025~22027,22030~22039,22041~22044,22060,22066~22067,22079,22081~22082,22092~22093,22095~22096,22101~22103,22106~22109,22116,22118~22122,22124~22125,22134~22135,22150~22153,22156,22158~22161,22172,22180~22185,22191~22195,22199,22201~22207,22209~22219,22222~22223,22225~22227,22229~22230,22234,22240~22246,22303,22306~22310,22312,22315,22405~22406,22430,22463,22471,22545,22554~22556,22601~22604,22611,22620,22622~22627,22637,22639~22641,22643~22646,22649~22650,22652,22654~22657,22660,22663~22664,22701,22709,22711~22716,22718~22743,22746~22749,22810,22824,22835,22842,22844~22845,22847,22849,22851,22948') && opIn(t.State, new Set<String> { 'va', 'virginia' }) && opStart(t.Company, new Set<String> { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', '1', '2', '3', '4', '5' }))return 'a0c50000002dtxgAAA';    //Virginia - North A-L
    if(opZipcode(t.ZipCode, '20101~20107,20109,20112~20113,20115~20122,20124,20128~20132,20134~20144,20146~20149,20151~20153,20155~20156,20158~20160,20163~20172,20175~20178,20180~20182,20184~20199,20598,22003,22009,22015,22025~22027,22030~22039,22041~22044,22060,22066~22067,22079,22081~22082,22092~22093,22095~22096,22101~22103,22106~22109,22116,22118~22122,22124~22125,22134~22135,22150~22153,22156,22158~22161,22172,22180~22185,22191~22195,22199,22201~22207,22209~22219,22222~22223,22225~22227,22229~22230,22234,22240~22246,22303,22306~22310,22312,22315,22405~22406,22430,22463,22471,22545,22554~22556,22601~22604,22611,22620,22622~22627,22637,22639~22641,22643~22646,22649~22650,22652,22654~22657,22660,22663~22664,22701,22709,22711~22716,22718~22743,22746~22749,22810,22824,22835,22842,22844~22845,22847,22849,22851,22948') && opIn(t.State, new Set<String> { 'va', 'virginia' }) && opStart(t.Company, new Set<String> { 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '6', '7', '8', '9', '0' }))return 'a0c38000005XRtoAAG';    //Virginia - North M-Z
    if(opZipcode(t.ZipCode, '20108,20110~20111,22040,22046~22047,22301~22302,22304~22305,22311,22313~22314,22320~22321,22331~22334,22336,22350,22401~22404,22407~22408,22412,22427~22428,22432~22433,22435~22438,22442~22443,22446,22448,22451,22454,22456,22460,22469,22472~22473,22476,22480~22482,22485,22488,22501,22503~22504,22507~22509,22511,22513~22514,22517,22520,22523~22524,22526,22528~22530,22534~22535,22538~22539,22542,22544,22546~22548,22551~22553,22558,22560,22565,22567,22570,22572,22576~22581,22610,22630,22642,22801~22803,22807,22811~22812,22815,22820~22821,22827,22830~22834,22840~22841,22843,22846,22848,22850,22853,22901~22911,22920,22922~22924,22931~22932,22935~22940,22942~22943,22945~22947,22949,22952,22957~22960,22963~22965,22967~22969,22971~22974,22976,22980,22987,22989,23001~23005,23009,23011,23014~23015,23018,23021~23025,23027,23030~23032,23035,23038~23040,23043,23045,23047,23050,23055~23056,23058~23072,23075~23076,23079,23081,23083~23086,23089~23093,23101~23103,23105~23117,23119~23120,23123~23131,23138~23141,23146~23150,23153~23156,23160~23163,23168~23170,23173,23175~23178,23180~23181,23183~23188,23190,23192,23218~23238,23240~23242,23249~23250,23255,23260~23261,23269,23273~23274,23276,23278~23279,23282,23284~23286,23288~23295,23297~23298,23301~23304,23306~23308,23310,23313~23316,23320~23328,23336~23337,23341,23345,23347,23350,23354,23356~23359,23389,23395~23399,23401,23404~23405,23407~23410,23412~23424,23426~23427,23429~23443,23450~23467,23471,23479~23480,23482~23483,23486~23488,23501~23515,23517~23521,23523,23529,23541,23551,23601~23609,23612,23628,23630,23651,23661~23670,23681,23690~23694,23696,23701~23705,23707~23709,23801,23803~23806,23821~23822,23824~23825,23827~23834,23836~23847,23850~23851,23856~23857,23860,23866~23868,23870,23872~23876,23878~23879,23881~23885,23887~23891,23893~23894,23897~23899,23901,23909,23915,23917,23919~23924,23927,23930,23934,23936~23939,23941~23944,23947,23950,23952,23954~23955,23958~23960,23962~23964,23966~23968,23970,23974,23976,24001~24020,24022~24038,24040,24042~24045,24048,24050,24053~24055,24058~24070,24072~24073,24076~24079,24082~24093,24095,24101~24102,24104~24105,24111~24115,24120~24122,24124,24126~24134,24136~24139,24141~24143,24146~24151,24153,24155,24157,24161~24162,24165,24167~24168,24171,24174~24179,24184~24185,24201~24203,24205,24209~24212,24215~24221,24224~24226,24228,24230,24236~24237,24239,24243~24246,24248,24250~24251,24256,24258,24260,24263,24265~24266,24269~24273,24277,24279~24283,24290,24292~24293,24301,24311~24319,24322~24328,24330,24333,24340,24343,24347~24348,24350~24352,24354,24360~24361,24363,24366,24368,24370,24374~24375,24377~24378,24380~24382,24401~24402,24411~24413,24415~24416,24421~24422,24426,24430~24433,24435,24437~24442,24445,24448,24450,24457~24460,24463~24465,24467~24469,24471~24474,24476~24477,24479,24482~24487,24501~24506,24512~24515,24517,24520~24523,24526~24531,24533~24536,24538~24541,24543~24544,24549~24551,24553~24558,24562~24563,24565~24566,24569~24572,24574,24576~24581,24586,24588~24590,24592~24595,24597~24599,24601~24609,24612~24614,24619~24620,24622,24624,24627~24628,24630~24631,24634~24635,24637,24639~24641,24646~24647,24649,24651,24656~24658') && opIn(t.State, new Set<String> { 'va', 'virginia' }))return 'a0c38000005XRttAAG';    //Virginia - South
    if(opIn(t.State, new Set<String> { 'vt', 'vermont' }))return 'a0c50000002dtxhAAA';    //Vermont
    if(opIn(t.State, new Set<String> { 'wi', 'wisconsin' }))return 'a0c50000002dtxjAAA';    //Wisconsin
    if(opIn(t.State, new Set<String> { 'wv', 'west virginia' }))return 'a0c50000002dtxkAAA';    //West Virginia
    if(opIn(t.State, new Set<String> { 'wy', 'wyoming' }))return 'a0c50000002dtxlAAA';    //Wyoming
    if(opIn(t.State, new Set<String> { 'ny', 'new york' }))return 'a0c50000002dtxSAAQ';    //New York - Catch All
    if(opIn(t.State, new Set<String> { 'ca', 'california' }))return 'a0c50000002dtyCAAQ';    //California -Catchall
    if(opIn(t.Country, new Set<String> { 'ai', 'aia', 'anguilla', 'aw', 'abw', 'aruba', 'bs', 'bhs', 'bahamas', 'bb', 'brb', 'barbados', 'bm', 'bmu', 'bermuda', 'ky', 'cym', 'cayman islands', 'pm', 'spm', 'st. pierre and miquelon' }))return 'a0c50000002dttTAAQ';    //Carribean Catchall
    return null;
  }
  private Id matchGroup18(Target t, List<Id> overlays)
  {
    if(opIn(t.State, new Set<String> { 'tx', 'texas' }))return 'a0c50000002dtxeAAA';    //Texas -Catch All
    if(opIn(t.State, new Set<String> { 'al', 'alabama', 'ar', 'arkansas', 'ct', 'connecticut', 'dc', 'dist of columbia', 'de', 'delaware', 'fl', 'florida', 'ga', 'georgia' }) || opIn(t.State, new Set<String> { 'ia', 'iowa', 'il', 'illinois', 'in', 'indiana', 'ky', 'kentucky', 'ma', 'massachusetts', 'md', 'maryland', 'me', 'maine', 'mi', 'michigan' }) || opIn(t.State, new Set<String> { 'mn', 'minnesota', 'ms', 'mississippi', 'nc', 'north carolina', 'nd', 'north dakota', 'nh', 'new hampshire', 'nj', 'new jersey' }) || opIn(t.State, new Set<String> { 'ny', 'new york', 'pa', 'pennsylvania', 'pr', 'puerto rico', 'ri', 'rhode island', 'sc', 'south carolina', 'sd', 'south dakota', 'oh', 'ohio' }) || opIn(t.State, new Set<String> { 'tn', 'tennessee', 'va', 'virginia', 'vt', 'vermont', 'wi', 'wisconsin', 'wv', 'west virginia' }))return 'a0c50000002dtyYAAQ';    //Eastern US Catchall
    if(opIn(t.State, new Set<String> { 'ak', 'alaska', 'az', 'arizona', 'ca', 'california', 'co', 'colorado', 'hi', 'hawaii', 'id', 'idaho', 'ks', 'kansas' }) || opIn(t.State, new Set<String> { 'la', 'louisiana', 'mo', 'missouri', 'mt', 'montana', 'ne', 'nebraska' }) || opIn(t.State, new Set<String> { 'nm', 'new mexico', 'nv', 'nevada', 'ok', 'oklahoma', 'or', 'oregon', 'tx', 'texas', 'ut', 'utah', 'wa', 'washington', 'wy', 'wyoming' }))return 'a0c50000002dtyZAAQ';    //Western US catchall
    if(opIn(t.Country, new Set<String> { 'us', 'usa', 'u.s.', 'u.s.a', 'united states', 'united stated of america' }))return 'a0c50000002dtxmAAA';    //UNITED STATES -Catch All
    if(opIn(t.State, new Set<String> { 'ab', 'alberta' }))return 'a0c38000003VdbMAAS';    //Alberta
    if(opIn(t.State, new Set<String> { 'bc', 'british columbia' }))return 'a0c50000002dtxnAAA';    //British Columbia
    if(opIn(t.State, new Set<String> { 'lb', 'labrador' }))return 'a0c50000002dtxoAAA';    //Labrador
    if(opIn(t.State, new Set<String> { 'mb', 'manitoba' }))return 'a0c50000002dtxpAAA';    //Manitoba
    if(opIn(t.State, new Set<String> { 'nb', 'new brunswick' }))return 'a0c50000002dtxqAAA';    //New Brunswick
    if(opIn(t.State, new Set<String> { 'nf', 'newfoundland' }))return 'a0c50000002dtxrAAA';    //Newfoundland
    if(opIn(t.State, new Set<String> { 'ns', 'nova scotia' }))return 'a0c50000002dtxsAAA';    //Nova Scotia
    if(opIn(t.State, new Set<String> { 'nu', 'nunavut' }))return 'a0c50000002dtxtAAA';    //Nunavut
    if(opIn(t.State, new Set<String> { 'nw', 'north west terr.' }))return 'a0c50000002dtxuAAA';    //North West Terr.
    if(opIn(t.State, new Set<String> { 'on', 'ontario' }) && opStart(t.ZipCode, new Set<String> { 'm' }))return 'a0c38000005aFgPAAU';    //Toronto
    if(opIn(t.State, new Set<String> { 'on', 'ontario' }) && opStart(t.ZipCode, new Set<String> { 'k', 'l', 'n', 'p' }))return 'a0c50000002dtxvAAA';    //Ontario (Less Toronto)
    if(opIn(t.State, new Set<String> { 'pe', 'prince edward is.' }))return 'a0c50000002dtxwAAA';    //Prince Edward Is.
    if(opIn(t.State, new Set<String> { 'qc', 'quebec' }))return 'a0c50000002dtxxAAA';    //Quebec
    if(opIn(t.State, new Set<String> { 'sk', 'saskatchewen' }))return 'a0c50000002dtxyAAA';    //Saskatchewen
    if(opIn(t.State, new Set<String> { 'yu', 'yukon' }))return 'a0c50000002dtxzAAA';    //Yukon
    if(opIn(t.Country, new Set<String> { 'ca', 'canada' }))return 'a0c50000002dty0AAA';    //CANADA Catch All
    return null;
  }
  private Id matchGroup19(Target t, List<Id> overlays)
  {
    if(opStart(t.Company, new Set<String> { 'ntt' }))return 'a0c380000060zedAAA';    //Service Provider 9
    if(!opEqual(t.Company, '') || !opEqual(t.EmailDomain, ''))return 'a0c50000002dtw3AAA';    //ROW Catchall
    return null;
  }
  //returns the matched patch
  public override Match match(Target t)
  {
    Match result = null;
    Id patchId = null;
    List<Id> overlays = new List<Id>();
    patchId = matchGroup1(t, overlays);
    if(patchId != null)
    {
      return new Match(patchId, overlays);
    }
    patchId = matchGroup2(t, overlays);
    if(patchId != null)
    {
      return new Match(patchId, overlays);
    }
    patchId = matchGroup3(t, overlays);
    if(patchId != null)
    {
      return new Match(patchId, overlays);
    }
    patchId = matchGroup4(t, overlays);
    if(patchId != null)
    {
      return new Match(patchId, overlays);
    }
    patchId = matchGroup5(t, overlays);
    if(patchId != null)
    {
      return new Match(patchId, overlays);
    }
    patchId = matchGroup6(t, overlays);
    if(patchId != null)
    {
      return new Match(patchId, overlays);
    }
    patchId = matchGroup7(t, overlays);
    if(patchId != null)
    {
      return new Match(patchId, overlays);
    }
    patchId = matchGroup8(t, overlays);
    if(patchId != null)
    {
      return new Match(patchId, overlays);
    }
    patchId = matchGroup9(t, overlays);
    if(patchId != null)
    {
      return new Match(patchId, overlays);
    }
    patchId = matchGroup10(t, overlays);
    if(patchId != null)
    {
      return new Match(patchId, overlays);
    }
    patchId = matchGroup11(t, overlays);
    if(patchId != null)
    {
      return new Match(patchId, overlays);
    }
    patchId = matchGroup12(t, overlays);
    if(patchId != null)
    {
      return new Match(patchId, overlays);
    }
    patchId = matchGroup13(t, overlays);
    if(patchId != null)
    {
      return new Match(patchId, overlays);
    }
    patchId = matchGroup14(t, overlays);
    if(patchId != null)
    {
      return new Match(patchId, overlays);
    }
    patchId = matchGroup15(t, overlays);
    if(patchId != null)
    {
      return new Match(patchId, overlays);
    }
    patchId = matchGroup16(t, overlays);
    if(patchId != null)
    {
      return new Match(patchId, overlays);
    }
    patchId = matchGroup17(t, overlays);
    if(patchId != null)
    {
      return new Match(patchId, overlays);
    }
    patchId = matchGroup18(t, overlays);
    if(patchId != null)
    {
      return new Match(patchId, overlays);
    }
    patchId = matchGroup19(t, overlays);
    if(patchId != null)
    {
      return new Match(patchId, overlays);
    }
    return result;
  }
}