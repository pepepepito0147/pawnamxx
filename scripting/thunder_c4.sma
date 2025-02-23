#include <amxmodx>
#include <engine>

#define PLUGIN "thunder_c4"
#define VERSION "1.3"
#define AUTHOR "mlibre"

#if !defined MAX_PLAYERS
	#define MAX_PLAYERS 32
#endif

new const g_thunderSound[][] = 
{ 
	"ambience/thunder_clap.wav",
	"garg/gar_stomp1.wav"
}

new g_thunderSpr

public plugin_precache() 
{
	for(new i; i < sizeof g_thunderSound; i++)
	{
		precache_sound(g_thunderSound[i])
	}
	
	g_thunderSpr = precache_model("sprites/lgtning.spr")
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar(PLUGIN, VERSION, FCVAR_SERVER | FCVAR_SPONLY)
	
	if(find_ent_by_class(-1, "func_bomb_target"))
		register_logevent("c4_planted", 3, "2=Planted_The_Bomb")
	else
		pause("a")
}

public c4_planted()
{
	set_task(1.0, "create_thunder")
}

public create_thunder()
{
	new mdl = find_ent_by_model(-1, "grenade", "models/w_c4.mdl")
	
	if( !is_valid_ent(mdl) )
		return
		
	new id = isPlayer()
	
	new Float:fOrigin[3]; eng_get_brush_entity_origin(mdl, fOrigin)
	
#if !defined message_begin_f
	new iOrigin[3]
	
	iOrigin[0] = floatround(fOrigin[0])
	iOrigin[1] = floatround(fOrigin[1])
	iOrigin[2] = floatround(fOrigin[2])
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin, id)
#else
	message_begin_f(MSG_PVS, SVC_TEMPENTITY, fOrigin, id)
#endif
	write_byte(TE_BEAMPOINTS)
#if !defined message_begin_f
	write_coord(iOrigin[0])		//x	start position
	write_coord(iOrigin[1])		//y
	write_coord(iOrigin[2] - 25)	//z
	write_coord(iOrigin[0] + 150)	//x	end position
	write_coord(iOrigin[1] + 150)	//y
	write_coord(iOrigin[2] + 800)	//z
#else
	write_coord_f(fOrigin[0])		//x	start position
	write_coord_f(fOrigin[1])		//y
	write_coord_f(fOrigin[2] - 25)	//z
	write_coord_f(fOrigin[0] + 150)	//x	end position
	write_coord_f(fOrigin[1] + 150)	//y
	write_coord_f(fOrigin[2] + 800)	//z
#endif
	write_short(g_thunderSpr) 
	write_byte(1)	//frame
	write_byte(5)	//frame rate
	write_byte(2)	//life
	write_byte(random_num(20, 40))		//line width
	write_byte(random_num(1500, 3000))	//amplitude
	write_byte(255)	//red
	write_byte(255)	//blue
	write_byte(255)	//green
	write_byte(200)	//brightness
	write_byte(200)	//scroll speed
	message_end()
	
	emit_sound(mdl, CHAN_AUTO, g_thunderSound[random_num(0, charsmax(g_thunderSound))], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	set_task(0.1, "set_ScreenFade")
}

public set_ScreenFade()
{
	static msgScreenFade, x
	
	if( !msgScreenFade )
	{
		msgScreenFade = get_user_msgid("ScreenFade")
	}
	
	switch(x++)
	{
		case 0..3:
		{
			set_task(random_float(0.1, 0.3), "set_ScreenFade")
			
			if(x == 3) x = -1
		}
	}
	
	message_begin(MSG_BROADCAST, msgScreenFade, _, isPlayer())
	write_short(1000*2)	// duration, ~0 is max
	write_short(1000*2)	// hold time, ~0 is max
	write_short(0x0000)	// type FFADE_IN
	write_byte(255)	// Red
	write_byte(255)	// Green
	write_byte(255)	// Blue
	write_byte(random_num(50, 200))	// Alpha
	message_end()
}

stock eng_get_brush_entity_origin(index, Float:origin[3]) 
{
	new Float:mins[3], Float:maxs[3]
	
	entity_get_vector(index, EV_VEC_origin, origin)
	entity_get_vector(index, EV_VEC_mins, mins)
	entity_get_vector(index, EV_VEC_maxs, maxs)

	origin[0] += (mins[0] + maxs[0]) * 0.5
	origin[1] += (mins[1] + maxs[1]) * 0.5
	origin[2] += (mins[2] + maxs[2]) * 0.5

	return 1
}

stock isPlayer()
{
	new players[MAX_PLAYERS], num; get_players(players, num, "ch")
	
	for(new i; i < num; i++)
	{
		if(is_user_connected(players[i]))
		{
			return players[i]
		}
	}
	
	return -1
}
