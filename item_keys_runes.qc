/*
===============================================================================

KEYS

we use .worldtype on the player to store number of keys: first 4 bits are silver keys, 
next higher 4 bits are golds

15 of each key is well above the number of keys a mapper should expect a player to collect

===============================================================================
*/

float(entity cl) key_count_silver =
{
	if (!(cl.items & IT_KEY1))
		return 0;
	return (cl.worldtype & 15) + 1;
}

float(entity cl) key_count_gold =
{
	if (!(cl.items & IT_KEY2))
		return 0;
	return (cl.worldtype & 240)/16 + 1;
}

void(entity cl, float gold) key_sprint_name =
{
	if (gold) sprint(cl, " Gold ");
	else sprint(cl, " Silver ");
	sprint(cl, keyType);
}

float(entity cl) key_give_silver =
{
	if (!(cl.items & IT_KEY1))
	{
		sprint (cl, "You got the");
		key_sprint_name(cl, FALSE);
		sprint (cl, "\n");

		cl.items |= IT_KEY1;
		return TRUE;
	}
		
	if (cl.worldtype & 15 == 15)
		return FALSE;	// we're full
		
	cl.worldtype += 1;
	sprint (cl, "You have ");
	sprint (cl, ftos(key_count_silver(cl)));
	key_sprint_name(cl, FALSE);
	sprint (cl, "s\n");
	
	return TRUE;
}

float(entity cl) key_take_silver =
{
	if (!(cl.items & IT_KEY1))
	{
		return FALSE;	// we're dry
	}
	
	if (cl.worldtype & 15 == 0)
	{
		cl.items = not(cl.items, IT_KEY1);
		return TRUE;
	}
	
	cl.worldtype -= 1;
	float keys = key_count_silver(cl);
	sprint (cl, "You have ");
	sprint (cl, ftos(keys));
	key_sprint_name(cl, FALSE);
	if (keys > 1)
		sprint (cl, "s left\n");
	else
		sprint (cl, " left\n");
	
	return TRUE;
}


float(entity cl, float num) key_take_silvers =
{
	float keys = key_count_silver(cl);
	if (keys < num)
		return FALSE;	// we're dry
	
	if (keys == num)
	{
		cl.worldtype -= num - 1;
		cl.items = not(cl.items, IT_KEY1);
		return TRUE;
	}
	
	cl.worldtype -= num;
	
	keys = key_count_silver(cl);
	sprint (cl, "You have ");
	sprint (cl, ftos(keys));
	key_sprint_name(cl, FALSE);
	if (keys > 1)
		sprint (cl, "s left\n");
	else
		sprint (cl, " left\n");
	
	return TRUE;
}

float(entity cl) key_give_gold =
{
	if (!(cl.items & IT_KEY2))
	{
		sprint (cl, "You got the");
		key_sprint_name(cl, TRUE);
		sprint (cl, "\n");

		cl.items |= IT_KEY2;
		return TRUE;
	}
		
	if (cl.worldtype & 240 == 240)
		return FALSE;	// we're full
	
	cl.worldtype += 16;
	sprint (cl, "You have ");
	sprint (cl, ftos(key_count_gold(cl)));
	key_sprint_name(cl, TRUE);
	sprint (cl, "s\n");
	
	return TRUE;
}

float(entity cl) key_take_gold =
{
	if (!(cl.items & IT_KEY2))
	{
		return FALSE;	// we're dry
	}
	
	if (cl.worldtype & 240 == 0)
	{
		cl.items = not(cl.items, IT_KEY2);
		return TRUE;
	}
	
	cl.worldtype -= 16;
	float keys = key_count_gold(cl);
	sprint (cl, "You have ");
	sprint (cl, ftos(keys));
	key_sprint_name(cl, TRUE);
	if (keys > 1)
		sprint (cl, "s left\n");
	else
		sprint (cl, " left\n");
	
	return TRUE;
}

float(entity cl, float num) key_take_golds =
{
	float keys = key_count_gold(cl);
	if (keys < num)
		return FALSE;	// we're dry

	if (keys == num)
	{
		cl.worldtype -= 16 * (num - 1);
		cl.items = not(cl.items, IT_KEY2);
		return TRUE;
	}
	
	cl.worldtype -= 16 * num;
	
	keys = key_count_gold(cl);
	sprint (cl, "You have ");
	sprint (cl, ftos(keys));
	key_sprint_name(cl, TRUE);
	if (keys > 1)
		sprint (cl, "s left\n");
	else
		sprint (cl, " left\n");
	
	return TRUE;
}

void() key_touch =
{
	if (!CheckValidTouch()) return;

	float gave = FALSE;
	
	if (self.items == IT_KEY1)
	{
		gave = key_give_silver(other);
	}
	else if (self.items == IT_KEY2)
	{
		gave = key_give_gold(other);
	}
	
	if (!gave) return;
	//if (other.items & self.items) return;
	
	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	//other.items = other.items | self.items;

//	if (!coop)
//	{	
		self.solid = SOLID_NOT;
		self.model = string_null;
//	}

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
}

string() key_sound =
{
	if (world.worldtype == 1)
		return "misc/runekey.wav";
	if (world.worldtype == 2)
		return "misc/basekey.wav";

	return "misc/medkey.wav";
}

void() key_setsounds =
{
	string key = key_sound();
	precache_sound_safe (key);
	self.noise = key;
}

/*QUAKED item_key1 (0 .5 .5) (-16 -16 -24) (16 16 32) ? ? SUSPENDED
Silver key. Player can carry up to 15. In order for keys to work you MUST set your maps worldtype (see worldspawn).

Keys:
"target"		fired when picked up
*/
/*
"skin"			flavor
0 = Silver
2 = Iron
4 = Pewter
6 = Lead
*/
/*FGD
@PointClass size(-16 -16 -24, 16 16 32) color(0 128 128) base(Item) model({ "path": ":progs/w_s_key.mdl" }) = 
	item_key1 : "Silver Key. Player can carry up to 15. Remember to set worldtype on worldspawn!" []
*/
void() item_key1 =
{
	if (!SUB_ShouldSpawn()) return;
	if (world.worldtype == 0)
	{
		precache_model_safe ("progs/m_key.mdl");
		setmodel (self, "progs/m_key.mdl");
		keyType = "Key";
		self.skin = 0;
	}
	else if (world.worldtype == 1)
	{
		precache_model_safe ("progs/r_key.mdl");
		setmodel (self, "progs/r_key.mdl");
		keyType = "Runekey";
		self.skin = 0;
	}
	else if (world.worldtype == 2)
	{
		precache_model2_safe ("progs/b_s_key.mdl");
		setmodel (self, "progs/b_s_key.mdl");
		keyType = "Keycard";
	}
	key_setsounds();
	self.touch = key_touch;
	self.items = IT_KEY1;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
}

/*QUAKED item_key2 (.5 .5 0) (-16 -16 -24) (16 16 32) ? ? SUSPENDED
Gold key. Player can carry up to 15. In order for keys to work you MUST set your maps worldtype (see worldspawn).

Keys:
"target"		fired when picked up
*//*
"skin"			flavor
1 = Gold
3 - Copper
5 = Bronze
7 = Brass
*/
/*FGD
@PointClass size(-16 -16 -24, 16 16 32) color(128 128 0) base(Item) model({ "path": ":progs/w_g_key.mdl" }) = 
	item_key2 : "Gold Key. Player can carry up to 15. Remember to set worldtype on worldspawn!" []
*/
void() item_key2 =
{
	if (!SUB_ShouldSpawn()) return;
	if (world.worldtype == 0)
	{
		precache_model_safe ("progs/m_key.mdl");
		setmodel (self, "progs/m_key.mdl");
		keyType = "Key";
		self.skin = 1;
	}
	else if (world.worldtype == 1)
	{
		precache_model_safe ("progs/r_key.mdl");
		setmodel (self, "progs/r_key.mdl");
		keyType = "Runekey";
		self.skin = 1;
	}
	else if (world.worldtype == 2)
	{
		precache_model2_safe ("progs/b_g_key.mdl");
		setmodel (self, "progs/b_g_key.mdl");
		keyType = "Keycard";
	}
	key_setsounds();
	self.touch = key_touch;
	self.items = IT_KEY2;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
}


/*
===============================================================================

RUNES

===============================================================================
*/

void() sigil_touch =
{
	if (!CheckValidTouch()) return;

	self.solid = SOLID_NOT;
	self.model = string_null;
	serverflags |= self.svflags;
	self.classname = string_null;		// so rune doors won't find it
	
	SetAllClientRunes ();
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
	
	centerprint (other, self.message);
	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
}


/*QUAKED item_sigil (0 .5 .5) (-16 -16 -24) (16 16 32) E1 E2 E3 E4 SUSPENDED
End of episode rune. Can be customized through keyvalue manipulation to serve as any generic cross-map inventory item.

Flags:
"E1 -E4" sets episode
"SUSPENDED" do not drop to floor on spawn

Keys:
"noise" override pickup noise
"svflags" set a serverflag other than the episode 1-4 flags on pickup
"model" specify any model
"message" override pickup message
"target" entity to trigger when picked up
"targetname" entity name
*/
/*FGD
@baseclass = svFlags [
	svflags(Flags) =
	[
		1		: "Episode 1" : 0
		2		: "Episode 2" : 0
		4		: "Episode 3" : 0
		8		: "Episode 4" : 0
		16		: "Bit 5" :  0
		32		: "Bit 6" :  0
		64		: "Bit 7" :  0
		128		: "Bit 8" :  0
		256		: "Bit 9" :  0
		512		: "Bit 10" : 0
		1024	: "Bit 11" : 0
		2048	: "Bit 12" : 0
		4096	: "Bit 13" : 0
		8192	: "Bit 14" : 0
		16384	: "Bit 15" : 0
		32768	: "Bit 16" : 0
		65536	: "Bit 17" : 0
		131072	: "Bit 18" : 0
		262144	: "Bit 19" : 0
		524288	: "Bit 20" : 0
		1048576	: "Bit 21" : 0
	]
]

@PointClass size(-16 -16 -24, 16 16 32) color(128 0 128) base(Item, svFlags) model({ "path": ":progs/end1.mdl" }) = 
	item_sigil : "End of episode rune.  Can be customized through keyvalue manipulation to serve as any generic cross-map inventory item."
[
	noise(string) : "Override pickup noise"
	model(string) : "Override model"
	spawnflags(Flags) =
	[
		1 : "Episode 1" : 1
		2 : "Episode 2" : 0
		4 : "Episode 3" : 0
		8 : "Episode 4" : 0
		16 : "Suspended" : 0
	]
]
*/
void() item_sigil =
{
	if (!SUB_ShouldSpawn()) return;

	if (!self.noise)
		self.noise = "misc/runekey.wav";
	precache_sound_safe (self.noise);

	string msg;
	msg = "You got the rune!";
	
	if (self.spawnflags & 8)
	{
		precache_model2_safe ("progs/end4.mdl");
		setmodel (self, "progs/end4.mdl");
		msg = "You got the rune\n of Elder Magic!";
		self.svflags = 8;
	}
	else if (self.spawnflags & 4)
	{
		precache_model2_safe ("progs/end3.mdl");
		setmodel (self, "progs/end3.mdl");
		msg = "You got the rune\n of Hell Magic!";
		self.svflags = 4;
	}
	else if (self.spawnflags & 2)
	{
		precache_model2_safe ("progs/end2.mdl");
		setmodel (self, "progs/end2.mdl");
		msg = "You got the rune\n of Black Magic!";
		self.svflags = 2;
	}
	else if (self.spawnflags & 1)
	{
		precache_model_safe ("progs/end1.mdl");
		setmodel (self, "progs/end1.mdl");
		msg = "You got the rune\n of Earth Magic!";
		self.svflags = 1;
	}
	else
	{
		if (!self.model)
			self.model = "progs/end1.mdl";
		precache_model2_safe(self.model);
		setmodel(self, self.model);
		if (!self.svflags)
		{
			dprint("\bwarning:\b no serverflag or episode set for item_sigil");
			self.svflags = 16;
		}
	}
	
	if (self.message == string_null)
		self.message = msg;
	
	// rearrange extra spawnflags so they align with other items
	self.spawnflags = not(self.spawnflags, SVFL_ALLEPISODES);
	if (self.spawnflags & 16)
		self.spawnflags = self.spawnflags - 16 + ITEM_SUSPENDED;
	self.touch = sigil_touch;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
}
