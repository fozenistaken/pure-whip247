-- pure-247 settings. Prices, goods and store spots come from this file; restart the resource after a change. What
-- an item restores (hunger, thirst) is also changed in game: /whip > Economy > Items.

Config = {}

Config.Keeper = 'mp_m_shopkeep_01'       -- who stands behind every counter
Config.ClerkDownMinutes = 10              -- a store whose clerk is killed stays closed this long, then a new clerk comes (1-60)
Config.Blip = { sprite = 52, color = 2 }  -- 0 sprite = no map icon

-- The stores: every convenience store in GTA V, where its shopkeeper stands (behind the tills, facing the customers).
-- Clerk spots from qb-shops' config.lua (github.com/qbcore-framework/qb-shops): its nine "24/7 Supermarket" and five
-- "LTD Gasoline" peds. Checked against the game's own map: those are the 9 v_shop_247 and 5 v_gasstation interiors
-- there are, and each spot sits behind that interior's tills (within 20 cm of the same place in every copy).
-- Not ox_inventory's shop targets: those are boxes on the till, and a keeper put there stands inside the counter.
-- A keeper still standing wrong: change that store's pos here (x, y, z, heading).
Config.Stores = {
    -- 24/7 Supermarket
    { key = 'strawberry', name = '24/7', pos = vector4(24.47, -1346.62, 29.50, 271.66) },     -- Innocence Blvd
    { key = 'vinewood',   name = '24/7', pos = vector4(372.66, 326.98, 103.57, 253.73) },     -- Clinton Ave
    { key = 'tataviam',   name = '24/7', pos = vector4(2556.66, 380.84, 108.62, 356.67) },    -- Palomino Fwy
    { key = 'banham',     name = '24/7', pos = vector4(-3039.54, 584.38, 7.91, 17.27) },      -- Banham Canyon
    { key = 'chumash',    name = '24/7', pos = vector4(-3242.97, 1000.01, 12.83, 357.57) },   -- Chumash
    { key = 'harmony',    name = '24/7', pos = vector4(549.13, 2670.85, 42.16, 99.39) },      -- Route 68, Harmony
    { key = 'senora',     name = '24/7', pos = vector4(2677.47, 3279.76, 55.24, 335.08) },    -- Senora Fwy
    { key = 'sandy',      name = '24/7', pos = vector4(1959.82, 3740.48, 32.34, 301.57) },    -- Sandy Shores
    { key = 'paleto',     name = '24/7', pos = vector4(1728.07, 6415.63, 35.04, 242.95) },    -- Paleto Bay
    -- LTD Gasoline (the same kind of store; named 24/7 here too)
    { key = 'davis',      name = '24/7', pos = vector4(-47.02, -1758.23, 29.42, 45.05) },     -- Grove St, Davis
    { key = 'littleseoul', name = '24/7', pos = vector4(-706.06, -913.97, 19.22, 88.04) },    -- Little Seoul
    { key = 'richman',    name = '24/7', pos = vector4(-1820.02, 794.03, 138.09, 135.45) },   -- Banham Canyon Dr, Richman Glen
    { key = 'mirrorpark', name = '24/7', pos = vector4(1164.71, -322.94, 69.21, 101.72) },    -- Mirror Park Blvd
    { key = 'grapeseed',  name = '24/7', pos = vector4(1697.87, 4922.96, 42.06, 324.71) },    -- Grapeseed Main St
}

-- The shelf's tabs, in order
Config.Categories = { 'Drinks', 'Snacks', 'Food', 'Home' }

-- The groceries this resource registers. Each item's picture is the GTA prop `picture` (from whip_media_props);
-- `prop` is what it looks like dropped or held. hunger / thirst: what one restores (0-100); admins change them per
-- item in /whip > Economy > Items. price: the shops' price in cash.
Config.Items = {
    -- Drinks
    { key = 'pure-247_sprunk',   name = 'Sprunk',        cat = 'Drinks', price = 3, thirst = 20, picture = 'prop_ld_can_01',      desc = 'A can of lime soda.' },
    { key = 'pure-247_ecola',    name = 'eCola',         cat = 'Drinks', price = 3, thirst = 20, picture = 'prop_ecola_can',      desc = 'A can of cola.' },
    { key = 'pure-247_orang',    name = 'Orang-O-Tang',  cat = 'Drinks', price = 3, thirst = 20, picture = 'prop_orang_can_01',   desc = 'A can of orange soda.' },
    { key = 'pure-247_milk',     name = 'Milk',          cat = 'Drinks', price = 4, thirst = 25, hunger = 5, picture = 'prop_cs_milk_01', desc = 'A carton of fresh milk.' },
    { key = 'pure-247_coffee',   name = 'Coffee',        cat = 'Drinks', price = 4, thirst = 15, picture = 'p_ing_coffeecup_01',  desc = 'Hot coffee to go.' },
    { key = 'pure-247_energy',   name = 'Energy Drink',  cat = 'Drinks', price = 5, thirst = 15, picture = 'prop_energy_drink',   desc = 'Sugar and caffeine in a can.' },
    -- Snacks
    { key = 'pure-247_crisps',   name = 'Crisps',        cat = 'Snacks', price = 3, hunger = 10, picture = 'prop_cs_crisps_01',   desc = 'A bag of salted crisps.' },
    { key = 'pure-247_pqs',      name = "P's & Q's",     cat = 'Snacks', price = 2, hunger = 8,  picture = 'prop_candy_pqs',      desc = 'Fruit candy.' },
    { key = 'pure-247_ego',      name = 'Ego Chaser',    cat = 'Snacks', price = 2, hunger = 8,  picture = 'prop_choc_ego',       desc = 'A chocolate bar.' },
    { key = 'pure-247_meteorite', name = 'Meteorite',    cat = 'Snacks', price = 2, hunger = 8,  picture = 'prop_choc_meto',      desc = 'A chocolate bar.' },
    { key = 'pure-247_donut',    name = 'Donut',         cat = 'Snacks', price = 2, hunger = 12, picture = 'prop_amb_donut',      desc = 'A glazed donut.' },
    -- Food
    { key = 'pure-247_sandwich', name = 'Sandwich',      cat = 'Food',   price = 5, hunger = 25, picture = 'prop_sandwich_01',    desc = 'A ready-made sandwich.' },
    { key = 'pure-247_hotdog',   name = 'Hot Dog',       cat = 'Food',   price = 4, hunger = 20, picture = 'prop_cs_hotdog_01',   desc = 'A hot dog from the warmer.' },
    { key = 'pure-247_noodles',  name = 'Cup Noodles',   cat = 'Food',   price = 3, hunger = 30, picture = 'v_ret_247_noodle1', prop = 'prop_ff_noodle_01', desc = 'Instant chicken noodles.' },
    { key = 'pure-247_soup',     name = 'Tomato Soup',   cat = 'Food',   price = 3, hunger = 20, picture = 'v_ret_247_tomsoup1',  desc = 'A can of tomato soup.' },
    { key = 'pure-247_bread',    name = 'Bread',         cat = 'Food',   price = 3, hunger = 15, picture = 'v_ret_247_bread1',    desc = 'A loaf of sliced bread.' },
    { key = 'pure-247_cereal',   name = 'Cereal',        cat = 'Food',   price = 4, hunger = 20, picture = 'v_ret_247_cereal1',   desc = 'A box of breakfast cereal.' },
    -- What else the racks hold (GTA V's own 24/7 racks and fridges): pictures cut from their own labels
    -- (html/img/items/<key>.webp). Home goods are not eaten.
    { key = 'pure-247_ketchup', name = "Ketchup", cat = 'Food', price = 3, hunger = 3, desc = 'Ketchup from the 24/7.' },
    { key = 'pure-247_mayo', name = "Mayonnaise", cat = 'Food', price = 3, hunger = 2, desc = 'Mayonnaise from the 24/7.' },
    { key = 'pure-247_pickles', name = "Pickles", cat = 'Food', price = 3, hunger = 8, desc = 'Pickles from the 24/7.' },
    { key = 'pure-247_sweetcorn', name = "Sweetcorn", cat = 'Food', price = 2, hunger = 15, desc = 'Sweetcorn from the 24/7.' },
    { key = 'pure-247_vegsoup', name = "Vegetable Soup", cat = 'Food', price = 3, hunger = 20, thirst = 5, desc = 'Vegetable Soup from the 24/7.' },
    { key = 'pure-247_tomatoes', name = "Chopped Tomatoes", cat = 'Food', price = 2, hunger = 12, desc = 'Chopped Tomatoes from the 24/7.' },
    { key = 'pure-247_salsa', name = "Salsa", cat = 'Food', price = 3, hunger = 6, desc = 'Salsa from the 24/7.' },
    { key = 'pure-247_mustard', name = "Mustard", cat = 'Food', price = 2, hunger = 3, desc = 'Mustard from the 24/7.' },
    { key = 'pure-247_hotsauce', name = "Hot Sauce", cat = 'Food', price = 3, hunger = 3, desc = 'Hot Sauce from the 24/7.' },
    { key = 'pure-247_coffeejar', name = "Ground Coffee", cat = 'Food', price = 6, thirst = 10, desc = 'Ground Coffee from the 24/7.' },
    { key = 'pure-247_eggs', name = "Eggs", cat = 'Food', price = 4, hunger = 15, desc = 'Eggs from the 24/7.' },
    { key = 'pure-247_tuna', name = "Tuna", cat = 'Food', price = 3, hunger = 20, desc = 'Tuna from the 24/7.' },
    { key = 'pure-247_beer_am', name = "A.M. Beer", cat = 'Drinks', price = 8, thirst = 15, desc = 'A.M. Beer from the 24/7.' },
    { key = 'pure-247_beer_dusche', name = "Dusche Gold", cat = 'Drinks', price = 8, thirst = 15, desc = 'Dusche Gold from the 24/7.' },
    { key = 'pure-247_beer', name = "Pisswasser", cat = 'Drinks', price = 3, thirst = 10, desc = 'Pisswasser from the 24/7.' },
    { key = 'pure-247_yogurt', name = "Yogurt", cat = 'Food', price = 3, hunger = 10, thirst = 5, desc = 'Yogurt from the 24/7.' },
    { key = 'pure-247_juice', name = "Orange Juice", cat = 'Drinks', price = 4, hunger = 5, thirst = 25, desc = 'Orange Juice from the 24/7.' },
    { key = 'pure-247_pizza', name = "Frozen Pizza", cat = 'Food', price = 7, hunger = 35, desc = 'Frozen Pizza from the 24/7.' },
    { key = 'pure-247_detergent', name = "Laundry Powder", cat = 'Home', price = 6, desc = 'Laundry Powder from the 24/7.' },
    { key = 'pure-247_bleach', name = "Bleach", cat = 'Home', price = 3, desc = 'Bleach from the 24/7.' },
    { key = 'pure-247_cleaner', name = "Spray Cleaner", cat = 'Home', price = 3, desc = 'Spray Cleaner from the 24/7.' },
    { key = 'pure-247_sunlotion', name = "Sun Lotion", cat = 'Home', price = 5, desc = 'Sun Lotion from the 24/7.' },
    -- Behind the counter: you ask the clerk (their prompt), they hand it over, it goes on your bill. `counter = true`.
    -- A pack opens into `opens` cigarettes; a cigarette is smoked with WHIP's emote `smoke`.
    { key = 'pure-247_cigs_redwood', name = 'Redwood', cat = 'Counter', price = 10, counter = true, prop = 'ng_proc_cigpak01a',
      opens = { item = 'pure-247_cigarette', amount = 20 }, desc = 'A pack of 20 Redwood cigarettes.' },
    { key = 'pure-247_cigs_estancia', name = 'Estancia', cat = 'Counter', price = 18, counter = true, prop = 'prop_cigar_pack_01',
      opens = { item = 'pure-247_cigarillo', amount = 10 }, desc = 'A pack of 10 Estancia cigarillos.' },
    { key = 'pure-247_cigarette', name = 'Cigarette', cat = 'Counter', price = 1, picture = 'prop_amb_ciggy_01',
      smoke = 'smoke2', maxStack = 40, weight = 0.01, desc = 'One Redwood. Use it to light up.' },
    { key = 'pure-247_cigarillo', name = 'Cigarillo', cat = 'Counter', price = 2, picture = 'prop_cigar_01',
      smoke = 'cigar2', maxStack = 20, weight = 0.01, desc = 'One Estancia cigarillo. Use it to light up.' },
}

-- whip_core's own groceries, sold too (their behaviour is whip_core's): item key = { price, tab }
Config.CoreItems = {
    drink = { price = 2, cat = 'Drinks' },   -- Water Bottle
    food  = { price = 6, cat = 'Food' },     -- Burger
}

-- Shelves: pick groceries off the racks yourself. Each store has a Drinks, a Snacks and a Food prompt on its racks
-- (WHIP world prompts, each item with its picture and price) that put the item in your basket, and a Pay prompt on
-- the clerk (cash or card) that takes the money; the goods go in your pockets. There is no shop screen.
Config.Shelves = {
    enabled = true,
    maxLines = 10,      -- different items in one basket
    maxEach = 20,       -- of one item
    leaveMeters = 25,   -- walk this far from the store and the basket is put back
    -- What you carry while you shop (WHIP HoldProps: everyone sees it; an emote or a hand-over takes it for a moment).
    -- The red hand basket this resource streams (stream/pure247_basket, see CREDITS.md), held by its handle; its origin
    -- is the top of the handle. bone 28422 = the right hand (PH_R_Hand). Solved in Blender on the game skeleton (carry
    -- pose 1): the handle bars in the fist, the basket hanging straight. Fine-tune in game with /basketedit (developer
    -- mode); it prints the line. Set model = false to carry nothing ('prop_shopping_bags01' is GTA's own shopping bag).
    basket = { model = 'pure247_basket', bone = 28422, offset = { 0.0512, 0.0061, -0.0036 }, rot = { 52.55, -141.63, 82.1 }, pose = 1 },
    showList = true,    -- the basket's contents and total on screen while you shop
    -- What each item looks like lying in the basket (client/basket_goods.lua), when its picture prop is not one
    -- packet: a GTA prop of one jar, can or bottle. Items left out use their `prop`, else their `picture`.
    goodsModels = {
        ['pure-247_noodles'] = 'prop_ff_noodle_01',   ['pure-247_soup'] = 'v_res_fa_tintomsoup',
        ['pure-247_bread'] = 'v_res_fa_bread01',      ['pure-247_cereal'] = 'v_res_fa_cereal01',
        ['pure-247_ketchup'] = 'v_res_fa_ketchup',    ['pure-247_mayo'] = 'v_res_fa_potsug',
        ['pure-247_pickles'] = 'v_res_fa_potsug',     ['pure-247_sweetcorn'] = 'v_res_fa_tincorn',
        ['pure-247_vegsoup'] = 'v_res_fa_tintomsoup', ['pure-247_tomatoes'] = 'v_res_fa_tintomsoup',
        ['pure-247_salsa'] = 'v_res_fa_potsug',       ['pure-247_mustard'] = 'prop_food_mustard',
        ['pure-247_hotsauce'] = 'prop_food_ketchup',  ['pure-247_coffeejar'] = 'v_res_fa_potcof',
        ['pure-247_eggs'] = 'v_ret_247_eggs',         ['pure-247_tuna'] = 'v_res_fa_tincorn',
        ['pure-247_beer_am'] = 'prop_beer_am',        ['pure-247_beer_dusche'] = 'prop_amb_beer_bottle',
        ['pure-247_beer'] = 'prop_beer_pissh',        ['pure-247_yogurt'] = 'v_res_fa_potsug',
        ['pure-247_juice'] = 'prop_food_juice01',     ['pure-247_pizza'] = 'prop_pizza_box_01',
        ['pure-247_detergent'] = 'prop_detergent_01a', ['pure-247_bleach'] = 'v_res_fa_washlq',
        ['pure-247_cleaner'] = 'prop_blox_spray',     ['pure-247_sunlotion'] = 'prop_cs_spray_can',
        drink = 'prop_ld_flow_bottle',                food = 'prop_cs_burger_01',
    },
    -- Without a basket the hands carry a little: two small things (one in each hand) or one of these big ones.
    handUnits = 2,
    bigItems = { 'pure-247_pizza', 'pure-247_detergent' },
}

-- Shoplifting: walk out of the door with goods you have not paid for and you keep them; the clerk reacts, and the
-- police may get a call. enabled = false puts the goods back on the shelves as you leave instead.
Config.Shoplift = {
    enabled = true,
    doorMeters = 16.0,    -- metres from the clerk that count as gone (16-24; the farthest product is 10 m away in a 24/7, 13 m in an LTD)
    -- How the clerk reacts, picked at random by these weights (0 turns one off): shout at you, cower behind the
    -- counter, run after you and beat you up (fists; never a downed player), or do nothing.
    reactions = { shout = 45, cower = 25, chase = 20, nothing = 10 },
    chaseMeters = 30.0,   -- how far from the counter the clerk chases (10-60)
    chaseSeconds = 20,    -- how long the clerk keeps after you before walking back (5-60)
    police = {
        resource = 'pure-whip-police',  -- the police resource that takes the call (SendAlert); false: never call
        chance = 0.7,                   -- chance the clerk calls it in, 0-1 (0.7 = 7 times in 10)
        -- seconds before the call, per reaction: a shout is called in at once, a cowering clerk waits till you've gone
        delay = { shout = 5, cower = 25, chase = 3, nothing = 40 },
        cooldown = 60,                  -- seconds before the same store can call again (30-600)
        code = '10-31',                 -- the call's code on the police MDT (pure-whip-police has no shoplifting code of its own)
        priority = 'normal',            -- 'low', 'normal', 'high' or 'critical'
    },
}

-- Where each store's room is in the world (from the game's own map: its v_shop_247 or v_gasstation interior), so
-- the racks and the till below are found in every copy of it, however it is turned.
Config.Rooms = {
    strawberry   = { kind = '247', x = 27.25, y = -1343.68, z = 28.50, yaw = 0.00 },
    vinewood     = { kind = '247', x = 376.14, y = 329.26, z = 102.57, yaw = -14.14 },
    tataviam     = { kind = '247', x = 2553.69, y = 383.74, z = 107.62, yaw = 87.73 },
    banham       = { kind = '247', x = -3043.27, y = 586.07, z = 6.91, yaw = -252.18 },
    chumash      = { kind = '247', x = -3245.65, y = 1003.06, z = 11.83, yaw = 85.06 },
    harmony      = { kind = '247', x = 546.78, y = 2667.38, z = 41.16, yaw = -172.55 },
    senora       = { kind = '247', x = 2676.22, y = 3283.60, z = 54.24, yaw = 60.93 },
    sandy        = { kind = '247', x = 1960.68, y = 3744.55, z = 31.34, yaw = 30.02 },
    paleto       = { kind = '247', x = 1731.96, y = 6417.24, z = 34.04, yaw = -26.35 },
    davis        = { kind = 'ltd', x = -50.87, y = -1751.04, z = 28.42, yaw = -39.99 },
    littleseoul  = { kind = 'ltd', x = -713.71, y = -910.97, z = 18.22, yaw = 0.00 },
    richman      = { kind = 'ltd', x = -1827.54, y = 791.03, z = 137.24, yaw = 42.45 },
    mirrorpark   = { kind = 'ltd', x = 1156.77, y = -321.44, z = 68.21, yaw = 9.98 },
    grapeseed    = { kind = 'ltd', x = 1704.59, y = 4927.61, z = 41.06, yaw = -124.97 },
}

-- Inside each kind of room, in the room's own metres (x, y; z above its floor): where the customer pays at the
-- counter, and the stack of wire baskets by the door, where you take one. The goods
-- themselves are every product already on the game's own racks and in its fridges (shared/racks.lua).
Config.RoomSpots = {
    ['247'] = {
        pay   = vector3(-1.75, -2.45, 1.15),   -- the customer's side of the counter, between the tills
        stand = vector3(3.56, -5.17, 0.62),    -- the basket stack (v_66_shelves), on top of it
    },
    ltd = {
        pay   = vector3(6.25, -3.55, 1.15),    -- the customer's side of the counter, between the tills
        -- the wire baskets on their low stand by the front window, between the fruit display (v_ret_247_fruit, its
        -- end at x -0.67) and the bin (prop_bin_10b, from x -0.01), in their row; on top of the stack
        stand = vector3(-0.34, -5.15, 0.60),
    },
}
