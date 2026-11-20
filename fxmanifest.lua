-- pure-247 (Pure 24/7): every 24/7 and LTD store in GTA V, shopped by hand on WHIP.
-- Take goods off the game's own racks (a WHIP prompt on each product), carry them in your hands or in a basket from
-- the stack by the door, and pay the clerk (a WHIP NPC) in cash or by card; the clerk also hands over cigarettes from
-- behind the counter (client/shelves.lua, server/shelves.lua, server/clerks.lua). Rooms and rack spots come from the
-- game's own map (config.lua, shared/racks.lua).

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'pure-247'
description 'Pure 24/7 by PureFX: every 24/7 store on WHIP, shopped by hand (racks, basket, clerk and checkout) with groceries'
author 'fozen'
website 'https://purefx.dev'
version '1.0.0'

dependency 'whip_core'
whip_requires '1.0'

shared_scripts {
    '@whip_core/lib/satellite.lua',
    'config.lua',
    'shared/rooms.lua',
    'shared/goods.lua',
    'shared/racks.lua',   -- generated: every product on the game's own 24/7 racks
}

client_scripts {
    'client/basketedit.lua',   -- /basketedit, and the carry poses
    'client/shelves.lua',
    'client/basket_goods.lua',   -- what is in a basket, drawn inside it
}

server_scripts {
    'server/main.lua',
    'server/clerks.lua',
    'server/shelves.lua',
}

-- The groceries' pictures come from WHIP's prop picture pack (whip_media_props, installed with WHIP in
-- resources/[assets]/[media]). Without it the shop shows WHIP's "missing" picture; nothing else changes.

-- The hand basket you carry while shopping (stream/pure247_basket.ydr): the 24/7's own wire basket, the top one of
-- the stack on the store's front shelf (GTA V's v_66_shelves, its basketwire faces and texture), as a prop of its own.
files { 'stream/pure247_basket.ytyp', 'html/img/items/*.webp' }   -- the basket's archetype; the rack goods' pictures
data_file 'DLC_ITYP_REQUEST' 'stream/pure247_basket.ytyp'
