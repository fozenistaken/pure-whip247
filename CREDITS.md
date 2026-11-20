# Credits

## Hand basket

`stream/pure247_basket.ydr` is GTA V's own 24/7 wire basket: the top basket of the stack on the store's front shelf
(the game's `v_66_shelves` model, its `gz_v_247_basketwire_a` faces and texture), cut out as a prop of its own so it
can be carried. Nothing is redrawn; its origin is moved to the middle of its top rim, where a hand holds it.
GTA V and its assets belong to Rockstar Games.

## Animations (stream/pure247_shop.ycd)

grab_low, grab_med, grab_high and take_basket were made for this resource in Blender (Sollumz) on the game's
mp_m_freemode_01 skeleton. They start from Rockstar's own clips (anim@scripted@player@freemode@gen_grab@male@, anim@mp_snowball pickup_snowball, move_m@generic idle,
move_weapon@jerrycan@generic idle, missfbi4prepp1 _bag_pickup_garbage_man) with the arms re-posed: they are a
GTA V modification for use with the game, like the basket model.

## Animation (stream/pure247_basket_take.ycd)

basket_take (taking a basket off the stack) was made for this resource in Blender (Sollumz) on the game's
mp_m_freemode_01 skeleton from Rockstar's own clips: anim@scripted@player@freemode@gen_grab@male@ low_rh and med_rh
blended for the stack's height, with move_weapon@jerrycan@generic idle and move_m@generic idle; the right hand is
placed on the handle. A GTA V modification for use with the game.
