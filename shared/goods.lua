Goods = {}

local S = Config.Shelves or {}
local MODELS = S.goodsModels or {}
local BIG = {}
for _, k in ipairs(S.bigItems or {}) do BIG[k] = true end
local defs = {}
for _, it in ipairs(Config.Items or {}) do defs[it.key] = it end

local PH = { left = 60309, right = 28422 }

Goods.HOLD = {
    ['ng_proc_cigpak01a']    = {
        L = { offset = { 0.064, -0.010, -0.027 }, rot = { -20.1, -3.7, -10.3 } },
        R = { offset = { 0.044, 0.005, -0.021 }, rot = { 20.1, 3.7, -10.3 } },
    },
    ['p_ing_coffeecup_01']   = {
        L = { offset = { 0.064, -0.006, -0.016 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.044, 0.001, -0.010 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['prop_amb_beer_bottle'] = {
        L = { offset = { 0.064, -0.006, -0.016 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.044, 0.001, -0.010 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['prop_amb_donut']       = {
        L = { offset = { 0.064, -0.006, -0.016 }, rot = { 117.9, 60.2, 67.5 } },
        R = { offset = { 0.044, 0.001, -0.010 }, rot = { -117.9, -60.2, 67.5 } },
    },
    ['prop_beer_am']         = {
        L = { offset = { 0.037, -0.137, 0.031 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.017, -0.130, -0.057 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['prop_beer_pissh']      = {
        L = { offset = { 0.036, -0.141, 0.032 }, rot = { -101.0, -90.0, 19.8 } },
        R = { offset = { 0.017, -0.133, -0.059 }, rot = { -101.0, -90.0, -19.8 } },
    },
    ['prop_blox_spray']      = {
        L = { offset = { 0.064, -0.006, -0.016 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.044, 0.001, -0.010 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['prop_candy_pqs']       = {
        L = { offset = { 0.064, -0.006, -0.016 }, rot = { -20.1, -3.7, -10.3 } },
        R = { offset = { 0.044, 0.001, -0.010 }, rot = { 20.1, 3.7, -10.3 } },
    },
    ['prop_choc_ego']        = {
        L = { offset = { 0.058, -0.035, -0.006 }, rot = { 117.9, 60.2, 67.5 } },
        R = { offset = { 0.038, -0.028, -0.021 }, rot = { -117.9, -60.2, 67.5 } },
    },
    ['prop_choc_meto']       = {
        L = { offset = { 0.058, -0.035, -0.006 }, rot = { 117.9, 60.2, 67.5 } },
        R = { offset = { 0.038, -0.028, -0.021 }, rot = { -117.9, -60.2, 67.5 } },
    },
    ['prop_cigar_pack_01']   = {
        L = { offset = { 0.064, -0.006, -0.016 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.044, 0.001, -0.010 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['prop_cs_burger_01']    = {
        L = { offset = { 0.066, -0.009, -0.015 }, rot = { -20.1, -3.7, -10.3 } },
        R = { offset = { 0.047, -0.001, -0.011 }, rot = { 20.1, 3.7, -10.3 } },
    },
    ['prop_cs_crisps_01']    = {
        L = { offset = { 0.064, -0.007, -0.016 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.044, 0.000, -0.011 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['prop_cs_hotdog_01']    = {
        L = { offset = { 0.064, -0.006, -0.014 }, rot = { -20.1, -3.7, -10.3 } },
        R = { offset = { 0.044, -0.000, -0.009 }, rot = { 20.1, 3.7, -10.3 } },
    },
    ['prop_cs_milk_01']      = {
        L = { offset = { 0.043, -0.044, -0.010 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.024, -0.032, -0.029 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['prop_cs_spray_can']    = {
        L = { offset = { 0.056, -0.044, -0.003 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.037, -0.036, -0.024 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['prop_detergent_01a']   = {
        L = { offset = { 0.301, -0.073, 0.008 }, rot = { -152.1, 60.2, 67.5 } },
        R = { offset = { 0.282, -0.066, -0.034 }, rot = { -27.9, -60.2, 67.5 } },
    },
    ['prop_ecola_can']       = {
        L = { offset = { 0.064, -0.006, -0.016 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.044, 0.002, -0.010 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['prop_energy_drink']    = {
        L = { offset = { 0.064, -0.007, -0.016 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.044, 0.000, -0.011 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['prop_ff_noodle_01']    = {
        L = { offset = { 0.064, -0.007, -0.016 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.044, 0.001, -0.010 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['prop_food_juice01']    = {
        L = { offset = { 0.064, -0.006, -0.016 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.044, 0.001, -0.010 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['prop_food_ketchup']    = {
        L = { offset = { 0.039, -0.125, 0.027 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.020, -0.118, -0.053 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['prop_food_mustard']    = {
        L = { offset = { 0.039, -0.125, 0.027 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.020, -0.118, -0.053 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['prop_ld_can_01']       = {
        L = { offset = { 0.064, -0.006, -0.016 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.044, 0.002, -0.010 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['prop_ld_flow_bottle']  = {
        L = { offset = { 0.065, 0.002, -0.019 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.046, 0.009, -0.007 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['prop_orang_can_01']    = {
        L = { offset = { 0.064, -0.006, -0.016 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.044, 0.002, -0.010 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['prop_pizza_box_01']    = {
        L = { offset = { 0.333, -0.063, -0.019 }, rot = { -62.1, 60.2, 67.5 } },
        R = { offset = { 0.313, -0.040, -0.049 }, rot = { 62.1, -60.2, 67.5 } },
    },
    ['prop_sandwich_01']     = {
        L = { offset = { 0.064, -0.006, -0.016 }, rot = { 117.9, 60.2, 67.5 } },
        R = { offset = { 0.044, 0.001, -0.010 }, rot = { -117.9, -60.2, 67.5 } },
    },
    ['v_res_fa_bread01']     = {
        L = { offset = { 0.069, -0.007, -0.016 }, rot = { -101.0, -90.0, 19.8 } },
        R = { offset = { 0.050, 0.000, -0.011 }, rot = { -101.0, -90.0, -19.8 } },
    },
    ['v_res_fa_cereal01']    = {
        L = { offset = { 0.064, -0.006, -0.016 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.044, 0.001, -0.010 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['v_res_fa_ketchup']     = {
        L = { offset = { 0.064, -0.006, -0.016 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.044, 0.001, -0.010 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['v_res_fa_potcof']      = {
        L = { offset = { 0.064, -0.006, -0.016 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.044, 0.001, -0.010 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['v_res_fa_potsug']      = {
        L = { offset = { 0.064, -0.006, -0.016 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.044, 0.001, -0.010 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['v_res_fa_tincorn']     = {
        L = { offset = { 0.064, -0.006, -0.017 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.044, 0.002, -0.011 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['v_res_fa_tintomsoup']  = {
        L = { offset = { 0.064, -0.006, -0.017 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.044, 0.002, -0.011 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['v_res_fa_washlq']      = {
        L = { offset = { 0.064, -0.006, -0.016 }, rot = { -110.1, -3.7, -10.3 } },
        R = { offset = { 0.044, 0.001, -0.010 }, rot = { -69.9, 3.7, -10.3 } },
    },
    ['v_ret_247_eggs']       = {
        L = { offset = { 0.064, -0.006, -0.016 }, rot = { 117.9, 60.2, 67.5 } },
        R = { offset = { 0.044, 0.001, -0.010 }, rot = { -117.9, -60.2, 67.5 } },
    },
}

function Goods.model(item)
    if MODELS[item] then return MODELS[item] end
    local d = defs[item]
    if d and d.prop then return d.prop end

    if d and d.picture and not d.picture:find('^v_ret_247_') then return d.picture end
    return nil
end

function Goods.isBig(item) return BIG[item] == true end

function Goods.hold(item, hand)
    local m = Goods.model(item)
    local h = m and Goods.HOLD[m] and Goods.HOLD[m][hand == 'left' and 'L' or 'R']
    if not h then return nil end
    return { model = m, bone = PH[hand] or PH.right, offset = h.offset, rot = h.rot }
end
