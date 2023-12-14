Config = Config or {}

Config.AllowModels = true

Config.WhitelistedItems = {
	["male"] = {
		["pants"] = {124,125,126,127,128,129,130,131,132,133,134},
		["t-shirt"] = {156,157,158,159,130,161,162,163},
		["torso2"] = {333,334,335,336,337,338,339,340,341,342,343,344,345,346,347,348,349,350,351,352,353,354},
		["vest"] = {53,54,55,56,57,58,59},
		["decals"] = {65,66,67,68,69,70,71,72,73},
		["bag"] = {81,82,83,84,85,86,87,88,89,90,91,92},
        ["hat"] = {138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153}
	},
	["female"] = {
		["torso2"] = {348,349,350,351,352,353,354,355,356,357,358,359,360},
		["vest"] = {53,54,55,56,57,58,59},
		["decals"] = {74,75,76,77,78,79,80,81},
		["bag"] = {81,82,83,84,85,86,87,88,89,90},
		["pants"] = {132,133,134,135,136,137,138},
        ["hat"] = {137,138,139,140,141,142,143,144}
	}
}

Config.PlayerWhitelistedItems = {
    ["male"] = {
        ["torso2"] ={
            {
                id = 22,
                allowed = {
                    ["OHC01182"] = true,
                }
            },
        },
    },
    ["female"] = {
        ["torso2"] ={
            {
                id = 22,
                allowed = {
                    ["OHC01182"] = true,
                }
            },
        },
    }
}

Config.WomanPlayerModels = {
    'mp_f_freemode_01',
    'a_f_m_beach_01',
    'a_f_m_bevhills_01',
    'a_f_m_bevhills_02',
    'a_f_m_bodybuild_01',
    'a_f_m_business_02',
    'a_f_m_downtown_01',
    'a_f_m_eastsa_01',
    'a_f_m_eastsa_02',
    'a_f_m_fatbla_01',
    'a_f_m_fatcult_01',
    'a_f_m_fatwhite_01',
    'a_f_m_ktown_01',
    'a_f_m_ktown_02',
    'a_f_m_prolhost_01',
    'a_f_m_salton_01',
    'a_f_m_skidrow_01',
    'a_f_m_soucentmc_01',
    'a_f_m_soucent_01',
    'a_f_m_soucent_02',
    'a_f_m_tourist_01',
    'a_f_m_trampbeac_01',
    'a_f_m_tramp_01',
    'a_f_o_genstreet_01',
    'a_f_o_indian_01',
    'a_f_o_ktown_01',
    'a_f_o_salton_01',
    'a_f_o_soucent_01',
    'a_f_o_soucent_02',
    'a_f_y_beach_01',
    'a_f_y_bevhills_01',
    'a_f_y_bevhills_02',
    'a_f_y_bevhills_03',
    'a_f_y_bevhills_04',
    'a_f_y_business_01',
    'a_f_y_business_02',
    'a_f_y_business_03',
    'a_f_y_business_04',
    'a_f_y_eastsa_01',
    'a_f_y_eastsa_02',
    'a_f_y_eastsa_03',
    'a_f_y_epsilon_01',
    'a_f_y_fitness_01',
    'a_f_y_fitness_02',
    'a_f_y_genhot_01',
    'a_f_y_golfer_01',
    'a_f_y_hiker_01',
    'a_f_y_hipster_01',
    'a_f_y_hipster_02',
    'a_f_y_hipster_03',
    'a_f_y_hipster_04',
    'a_f_y_indian_01',
    'a_f_y_juggalo_01',
    'a_f_y_runner_01',
    'a_f_y_rurmeth_01',
    'a_f_y_scdressy_01',
    'a_f_y_skater_01',
    'a_f_y_soucent_01',
    'a_f_y_soucent_02',
    'a_f_y_soucent_03',
    'a_f_y_tennis_01',
    'a_f_y_tourist_01',
    'a_f_y_tourist_02',
    'a_f_y_vinewood_01',
    'a_f_y_vinewood_02',
    'a_f_y_vinewood_03',
    'a_f_y_vinewood_04',
    'a_f_y_yoga_01',
    'g_f_y_ballas_01',
    'g_f_y_families_01',
    'g_f_y_lost_01',
    'g_f_y_vagos_01',
    'mp_f_deadhooker',
    'mp_f_freemode_01',
    'mp_f_misty_01',
    'mp_f_stripperlite',
    'mp_s_m_armoured_01',
    's_f_m_fembarber',
    's_f_m_maid_01',
    's_f_m_shop_high',
    's_f_m_sweatshop_01',
    's_f_y_airhostess_01',
    's_f_y_bartender_01',
    's_f_y_baywatch_01',
    's_f_y_cop_01',
    's_f_y_factory_01',
    's_f_y_hooker_01',
    's_f_y_hooker_02',
    's_f_y_hooker_03',
    's_f_y_migrant_01',
    's_f_y_movprem_01',
    'ig_kerrymcintosh',
    'ig_janet',
    'ig_jewelass',
    'ig_magenta',
    'ig_marnie',
    'ig_patricia',
    'ig_screen_writer',
    'ig_tanisha',
    'ig_tonya',
    'ig_tracydisanto',
    'u_f_m_corpse_01',
    'u_f_m_miranda',
    'u_f_m_promourn_01',
    'u_f_o_moviestar',
    'u_f_o_prolhost_01',
    'u_f_y_bikerchic',
    'u_f_y_comjane',
    'u_f_y_corpse_01',
    'u_f_y_corpse_02',
    'u_f_y_hotposh_01',
    'u_f_y_jewelass_01',
    'u_f_y_mistress',
    'u_f_y_poppymich',
    'u_f_y_princess',
    'u_f_y_spyactress',
    'ig_amandatownley',
    'ig_ashley',
    'ig_andreas',
    'ig_ballasog',
    -- 'ig_maryannn',
    'ig_maude',
    'ig_michelle',
    'ig_mrs_thornhill',
    'ig_natalia',
    's_f_y_scrubs_01',
    's_f_y_sheriff_01',
    's_f_y_shop_low',
    's_f_y_shop_mid',
    's_f_y_stripperlite',
    's_f_y_stripper_01',
    's_f_y_stripper_02',
    'ig_mrsphillips',
    'ig_mrs_thornhill',
    'ig_molly',
    'ig_natalia',
    's_f_y_sweatshop_01',
    'ig_paige',
    'a_f_y_femaleagent',
    'a_f_y_hippie_01'
}
    
Config.ManPlayerModels = {
    'mp_m_freemode_01',
    'ig_trafficwarden',
    'ig_bankman',
    'ig_barry',
    'ig_bestmen',
    'ig_beverly',
    'ig_car3guy1',
    'ig_car3guy2',
    'ig_casey',
    'ig_chef',
    'ig_chengsr',
    'ig_chrisformage',
    'ig_clay',
    'ig_claypain',
    'ig_cletus',
    'ig_dale',
    'ig_dreyfuss',
    'ig_fbisuit_01',
    'ig_floyd',
    'ig_groom',
    'ig_hao',
    'ig_hunter',
    'csb_prolsec',
    'ig_joeminuteman',
    'ig_josef',
    'ig_josh',
    'ig_lamardavis',
    'ig_lazlow',
    'ig_lestercrest',
    'ig_lifeinvad_01',
    'ig_lifeinvad_02',
    'ig_manuel',
    'ig_milton',
    'ig_mrk',
    'ig_nervousron',
    'ig_nigel',
    'ig_old_man1a',
    'ig_old_man2',
    'ig_oneil',
    'ig_orleans',
    'ig_ortega',
    'ig_paper',
    'ig_priest',
    'ig_prolsec_02',
    'ig_ramp_gang',
    'ig_ramp_hic',
    'ig_ramp_hipster',
    'ig_ramp_mex',
    'ig_roccopelosi',
    'ig_russiandrunk',
    'ig_siemonyetarian',
    'ig_solomon',
    'ig_stevehains',
    'ig_stretch',
    'ig_talina',
    'ig_taocheng',
    'ig_taostranslator',
    'ig_tenniscoach',
    'ig_terry',
    'ig_tomepsilon',
    'ig_tylerdix',
    'ig_wade',
    'ig_zimbor',
    's_m_m_paramedic_01',
    'a_m_m_afriamer_01',
    'a_m_m_beach_01',
    'a_m_m_beach_02',
    'a_m_m_bevhills_01',
    'a_m_m_bevhills_02',
    'a_m_m_business_01',
    'a_m_m_eastsa_01',
    'a_m_m_eastsa_02',
    'a_m_m_farmer_01',
    'a_m_m_fatlatin_01',
    'a_m_m_genfat_01',
    'a_m_m_genfat_02',
    'a_m_m_golfer_01',
    'a_m_m_hasjew_01',
    'a_m_m_hillbilly_01',
    'a_m_m_hillbilly_02',
    'a_m_m_indian_01',
    'a_m_m_ktown_01',
    'a_m_m_malibu_01',
    'a_m_m_mexcntry_01',
    'a_m_m_mexlabor_01',
    'a_m_m_og_boss_01',
    'a_m_m_paparazzi_01',
    'a_m_m_polynesian_01',
    'a_m_m_prolhost_01',
    'a_m_m_rurmeth_01',
    'a_m_m_salton_01',
    'a_m_m_salton_02',
    'a_m_m_salton_03',
    'a_m_m_salton_04',
    'a_m_m_skater_01',
    'a_m_m_skidrow_01',
    'a_m_m_socenlat_01',
    'a_m_m_soucent_01',
    'a_m_m_soucent_02',
    'a_m_m_soucent_03',
    'a_m_m_soucent_04',
    'a_m_m_stlat_02',
    'a_m_m_tennis_01',
    'a_m_m_tourist_01',
    'a_m_m_trampbeac_01',
    'a_m_m_tramp_01',
    'a_m_m_tranvest_01',
    'a_m_m_tranvest_02',
    'a_m_o_beach_01',
    'a_m_o_genstreet_01',
    'a_m_o_ktown_01',
    'a_m_o_salton_01',
    'a_m_o_soucent_01',
    'a_m_o_soucent_02',
    'a_m_o_soucent_03',
    'a_m_o_tramp_01',
    'a_m_y_beachvesp_01',
    'a_m_y_beachvesp_02',
    'a_m_y_beach_01',
    'a_m_y_beach_02',
    'a_m_y_beach_03',
    'a_m_y_bevhills_01',
    'a_m_y_bevhills_02',
    'a_m_y_breakdance_01',
    'a_m_y_busicas_01',
    'a_m_y_business_01',
    'a_m_y_business_02',
    'a_m_y_business_03',
    'a_m_y_cyclist_01',
    'a_m_y_dhill_01',
    'a_m_y_downtown_01',
    'a_m_y_eastsa_01',
    'a_m_y_eastsa_02',
    'a_m_y_epsilon_01',
    'a_m_y_epsilon_02',
    'a_m_y_gay_01',
    'a_m_y_gay_02',
    'a_m_y_genstreet_01',
    'a_m_y_genstreet_02',
    'a_m_y_golfer_01',
    'a_m_y_hasjew_01',
    'a_m_y_hiker_01',
    'a_m_y_hipster_01',
    'a_m_y_hipster_02',
    'a_m_y_hipster_03',
    'a_m_y_indian_01',
    'a_m_y_jetski_01',
    'a_m_y_juggalo_01',
    'a_m_y_ktown_01',
    'a_m_y_ktown_02',
    'a_m_y_latino_01',
    'a_m_y_methhead_01',
    'a_m_y_mexthug_01',
    'a_m_y_motox_01',
    'a_m_y_motox_02',
    'a_m_y_musclbeac_01',
    'a_m_y_musclbeac_02',
    'a_m_y_polynesian_01',
    'a_m_y_roadcyc_01',
    'a_m_y_runner_01',
    'a_m_y_runner_02',
    'a_m_y_salton_01',
    'a_m_y_skater_01',
    'a_m_y_skater_02',
    'a_m_y_soucent_01',
    'a_m_y_soucent_02',
    'a_m_y_soucent_03',
    'a_m_y_soucent_04',
    'a_m_y_stbla_01',
    'a_m_y_stbla_02',
    'a_m_y_stlat_01',
    'a_m_y_stwhi_01',
    'a_m_y_stwhi_02',
    'a_m_y_sunbathe_01',
    'a_m_y_surfer_01',
    'a_m_y_vindouche_01',
    'a_m_y_vinewood_01',
    'a_m_y_vinewood_02',
    'a_m_y_vinewood_03',
    'a_m_y_vinewood_04',
    'a_m_y_yoga_01',
    'g_m_m_armboss_01',
    'g_m_m_armgoon_01',
    'g_m_m_armlieut_01',
    'g_m_m_chemwork_01',
    'g_m_m_chiboss_01',
    'g_m_m_chicold_01',
    'g_m_m_chigoon_01',
    'g_m_m_chigoon_02',
    'g_m_m_korboss_01',
    'g_m_m_mexboss_01',
    'g_m_m_mexboss_02',
    'g_m_y_armgoon_02',
    'g_m_y_azteca_01',
    'g_m_y_ballaeast_01',
    'g_m_y_ballaorig_01',
    'g_m_y_ballasout_01',
    'g_m_y_famca_01',
    'g_m_y_famdnf_01',
    'g_m_y_famfor_01',
    'g_m_y_korean_01',
    'g_m_y_korean_02',
    'g_m_y_korlieut_01',
    'g_m_y_lost_01',
    'g_m_y_lost_02',
    'g_m_y_lost_03',
    'g_m_y_mexgang_01',
    'g_m_y_mexgoon_01',
    'g_m_y_mexgoon_02',
    'g_m_y_mexgoon_03',
    'g_m_y_pologoon_01',
    'g_m_y_pologoon_02',
    'g_m_y_salvaboss_01',
    'g_m_y_salvagoon_01',
    'g_m_y_salvagoon_02',
    'g_m_y_salvagoon_03',
    'g_m_y_strpunk_01',
    'g_m_y_strpunk_02',
    'mp_m_claude_01',
    'mp_m_exarmy_01',
    'mp_m_shopkeep_01',
    's_m_m_ammucountry',
    's_m_m_autoshop_01',
    's_m_m_autoshop_02',
    's_m_m_bouncer_01',
    's_m_m_chemsec_01',
    's_m_m_cntrybar_01',
    's_m_m_dockwork_01',
    's_m_m_doctor_01',
    's_m_m_fiboffice_01',
    's_m_m_fiboffice_02',
    's_m_m_gaffer_01',
    's_m_m_gardener_01',
    's_m_m_gentransport',
    's_m_m_hairdress_01',
    's_m_m_highsec_01',
    's_m_m_highsec_02',
    's_m_m_janitor',
    's_m_m_lathandy_01',
    's_m_m_lifeinvad_01',
    's_m_m_linecook',
    's_m_m_lsmetro_01',
    's_m_m_mariachi_01',
    's_m_m_marine_01',
    's_m_m_marine_02',
    's_m_m_migrant_01',
    's_m_m_movalien_01',
    's_m_m_movprem_01',
    's_m_m_movspace_01',
    's_m_m_pilot_01',
    's_m_m_pilot_02',
    's_m_m_postal_01',
    's_m_m_postal_02',
    's_m_m_scientist_01',
    's_m_m_security_01',
    's_m_m_strperf_01',
    's_m_m_strpreach_01',
    's_m_m_strvend_01',
    's_m_m_trucker_01',
    's_m_m_ups_01',
    's_m_m_ups_02',
    's_m_o_busker_01',
    's_m_y_airworker',
    's_m_y_ammucity_01',
    's_m_y_armymech_01',
    's_m_y_autopsy_01',
    's_m_y_barman_01',
    's_m_y_baywatch_01',
    's_m_y_blackops_01',
    's_m_y_blackops_02',
    's_m_y_busboy_01',
    's_m_y_chef_01',
    's_m_y_clown_01',
    's_m_y_construct_01',
    's_m_y_construct_02',
    's_m_y_cop_01',
    's_m_y_dealer_01',
    's_m_y_devinsec_01',
    's_m_y_dockwork_01',
    's_m_y_doorman_01',
    's_m_y_dwservice_01',
    's_m_y_dwservice_02',
    's_m_y_factory_01',
    's_m_y_garbage',
    's_m_y_grip_01',
    's_m_y_marine_01',
    's_m_y_marine_02',
    's_m_y_marine_03',
    's_m_y_mime',
    's_m_y_pestcont_01',
    's_m_y_pilot_01',
    's_m_y_prismuscl_01',
    's_m_y_prisoner_01',
    's_m_y_robber_01',
    's_m_y_shop_mask',
    's_m_y_strvend_01',
    's_m_y_uscg_01',
    's_m_y_valet_01',
    's_m_y_waiter_01',
    's_m_y_winclean_01',
    's_m_y_xmech_01',
    's_m_y_xmech_02',
    'u_m_m_aldinapoli',
    'u_m_m_bankman',
    'u_m_m_bikehire_01',
    'u_m_m_fibarchitect',
    'u_m_m_filmdirector',
    'u_m_m_glenstank_01',
    'u_m_m_griff_01',
    'u_m_m_jesus_01',
    'u_m_m_jewelsec_01',
    'u_m_m_jewelthief',
    'u_m_m_markfost',
    'u_m_m_partytarget',
    'u_m_m_prolsec_01',
    'u_m_m_promourn_01',
    'u_m_m_rivalpap',
    'u_m_m_spyactor',
    'u_m_m_willyfist',
    'u_m_o_finguru_01',
    'u_m_o_taphillbilly',
    'u_m_o_tramp_01',
    'u_m_y_abner',
    'u_m_y_antonb',
    'u_m_y_babyd',
    'u_m_y_baygor',
    'u_m_y_burgerdrug_01',
    'u_m_y_chip',
    'u_m_y_cyclist_01',
    'u_m_y_fibmugger_01',
    'u_m_y_guido_01',
    'u_m_y_gunvend_01',
    'u_m_y_imporage',
    'u_m_y_mani',
    'u_m_y_militarybum',
    'u_m_y_paparazzi',
    'u_m_y_party_01',
    'u_m_y_pogo_01',
    'u_m_y_prisoner_01',
    'u_m_y_proldriver_01',
    'u_m_y_rsranger_01',
    'u_m_y_sbike',
    'u_m_y_staggrm_01',
    'u_m_y_tattoo_01',
    'u_m_y_zombie_01',
    'u_m_y_hippie_01',
    'a_m_y_hippy_01',
    'a_m_y_stbla_m',
    'ig_terry_m',
    'a_m_m_ktown_m',
    'a_m_y_skater_m',
    'u_m_y_coop',
    'ig_car3guy1_m',
    'tony',
    'g_m_m_chigoon_02_m',
}

Config.LoadedManModels = {}
Config.LoadedWomanModels = {}

Config.Stores = {
    [1] =   {shopType = "clothing", pos = vector3(1693.32, 4823.48, 41.06)},
	[2] =   {shopType = "clothing", pos = vector3(-712.215881, -155.352982, 37.4151268)},
	[3] =   {shopType = "clothing", pos = vector3(-1192.94495, -772.688965, 17.3255997)},
	[4] =   {shopType = "clothing", pos = vector3(425.236, -806.008, 28.491)},
	[5] =   {shopType = "clothing", pos = vector3(-162.658, -303.397, 38.733)},
	[6] =   {shopType = "clothing", pos = vector3(75.950, -1392.891, 28.376)},
	[7] =   {shopType = "clothing", pos = vector3(-822.194,-1074.134, 10.328)},
	[8] =   {shopType = "clothing", pos = vector3(-1450.711, -236.83, 48.809)},
	[9] =   {shopType = "clothing", pos = vector3(4.254, 6512.813, 30.877)},
	[10] =  {shopType = "clothing", pos = vector3(615.180, 2762.933, 41.088)},
	[11] =  {shopType = "clothing", pos = vector3(1196.785, 2709.558, 37.222)},
	[12] =  {shopType = "clothing", pos = vector3(-3171.453, 1043.857, 19.863)},
	[13] =  {shopType = "clothing", pos = vector3(-1100.959, 2710.211, 18.107)},
	[14] =  {shopType = "clothing", pos = vector3(-1207.65, -1456.88, 4.3784737586975)},
    [15] =  {shopType = "clothing", pos = vector3(121.76, -224.6, 53.56)},
	[16] =  {shopType = "barber",   pos = vector3(-814.3, -183.8, 36.6)},
	[17] =  {shopType = "barber",   pos = vector3(136.8, -1708.4, 28.3)},
	[18] =  {shopType = "barber",   pos = vector3(-1282.6, -1116.8, 6.0)},
	[19] =  {shopType = "barber",   pos = vector3(1931.5, 3729.7, 31.8)},
	[20] =  {shopType = "barber",   pos = vector3(1212.8, -472.9, 65.2)},
	[21] =  {shopType = "barber",   pos = vector3(-32.9, -152.3, 56.1)},
	[22] =  {shopType = "barber",   pos = vector3(-278.1, 6228.5, 30.7)}
}

Config.ClothingRooms = {
    [1] = {requiredJob = "police",    pos = vector3(473.81, -993.41, 25.73),   cameraLocation = {x = 473.81, y = -993.41, z = 25.73, h = 3.5}},
    [2] = {requiredJob = "doctor",    pos = vector3(300.16, -598.93, 43.28),  cameraLocation = {x = 301.09, y = -596.09, z = 43.28, h = 157.5}},
    [3] = {requiredJob = "ambulance", pos = vector3(300.16, -598.93, 43.28),  cameraLocation = {x = 301.09, y = -596.09, z = 43.28, h = 157.5}},
    [4] = {requiredJob = "police",    pos = vector3(1849.74, 3695.36, 34.27), cameraLocation = {x = 1850.10, y = 3695.36, z = 34.27, h = 3.5}}, -- Sandy PD
    [5] = {requiredJob = "ambulance", pos = vector3(-250.5, 6323.98, 32.32),  cameraLocation = {x = -250.5, y = 6323.98, z = 32.32, h = 315.5}},    
    [6] = {requiredJob = "doctor",    pos = vector3(-250.5, 6323.98, 32.32),  cameraLocation = {x = -250.5, y = 6323.98, z = 32.32, h = 315.5}},
    [7] = {requiredJob = "police",    pos = vector3(-569.15, -113.95, 33.88), cameraLocation = {x = -569.15, y =-113.95, z = 33.88, h = 3.5}}, -- Sandy PD
}

Config.Outfits = {
    ["police"] = {
        ["male"] = {
            [1] = {
                minimumGrade = 1,
                outfitLabel = "LSPD Patrol Standard",
                outfitData = {
                    ["pants"]       = { item = 129, texture = 0},  -- Pants
                    -- ["arms"]        = { item = 14, texture = 0},  -- Arms
                    ["t-shirt"]     = { item = 160, texture = 0},  -- T Shirt
                    ["vest"]        = { item = 57, texture = 1},  -- Body Vest
                    ["torso2"]      = { item = 334, texture = 0},  -- Jacket / Vests
                    ["shoes"]       = { item = 25, texture = 0},  -- Shoes
                    -- ["decals"]      = { item = 0, texture = 0},  -- Decals
                    -- ["accessory"]   = { item = 0, texture = 0},  -- Neck
            --      ["bag"]         = { item = 0, texture = 0},  -- Bag
                    -- ["hat"]         = { item = -1, texture = -1},  -- Hat
            --      ["glass"]       = { item = 0, texture = 0},  -- Glasses
            --      ["ear"]         = { item = 0, texture = 0},  -- Ear Accessories
                    -- ["mask"]         = { item = 0, texture = 0},  -- Masks
                },
            },
            [2] = {
                grades = {
                    [1] = true,
                    [3] = true
                },
                outfitLabel = "SASP Trooper Uniform",
                outfitData = {
                    ["pants"]       = { item = 130, texture = 2},  -- Pants
                    ["arms"]        = { item = 1, texture = 0},  -- Arms
                    ["t-shirt"]     = { item = 160, texture = 0},  -- T Shirt
                    ["vest"]        = { item = 59, texture = 0},  -- Body Vest
                    ["torso2"]      = { item = 347, texture = 0},  -- Jacket / Vests
                    ["shoes"]       = { item = 82, texture = 0},  -- Shoes
                    ["decals"]      = { item = 68, texture = 0},  -- Decals
                    ["accessory"]   = { item = 133, texture = 0},  -- Neck
            --      ["bag"]         = { item = 0, texture = 0},  -- Bag
                    ["hat"]         = { item = 151, texture = 0},  -- Hat
            --      ["glass"]       = { item = 0, texture = 0},  -- Glasses
            --      ["ear"]         = { item = 0, texture = 0},  -- Ear Accessories
            --        ["mask"]         = { item = 0, texture = 0},  -- Masks
                },
            },
            [3] = {
                outfitLabel = "SASP Bike unit",
                outfitData = {
                    ["pants"]       = { item = 134, texture = 1},  -- Pants
                    ["arms"]        = { item = 184, texture = 0},  -- Arms
                    ["t-shirt"]     = { item = 161, texture = 0},  -- T Shirt
            --      ["vest"]        = { item = 0, texture = 1},  -- Body Vest
                    ["torso2"]      = { item = 354, texture = 0},  -- Jacket / Vests
                    ["shoes"]       = { item = 33, texture = 0},  -- Shoes
            --      ["decals"]      = { item = 7, texture = 0},  -- Decals
                    ["accessory"]   = { item = 134, texture = 0},  -- Neck
            --      ["bag"]         = { item = 0, texture = 0},  -- Bag
                    ["hat"]         = { item = 140, texture = 0},  -- Hat
            --      ["glass"]       = { item = 0, texture = 0},  -- Glasses
            --      ["ear"]         = { item = 0, texture = 0},  -- Ear Accessories
            --      ["mask"]         = { item = 0, texture = 0},  -- Masks
                },
            },
        --     [5] = {
        --         outfitLabel = "VP Discreetly Short",
        --         outfitData = {
        --             ["pants"]       = { item = 97, texture = 0},  -- Pants
        --             ["arms"]        = { item = 0, texture = 0},  -- Arms
        --             ["t-shirt"]     = { item = 56, texture = 0},  -- T Shirt
        --             ["vest"]        = { item = 7, texture = 2},  -- Body Vest
        --             ["torso2"]      = { item = 2, texture = 1},  -- Jacket / Vests
        --             ["shoes"]       = { item = 24, texture = 0},  -- Shoes
        --             ["decals"]      = { item = 7, texture = 0},  -- Decals
        --             ["accessory"]   = { item = 8, texture = 0},  -- Neck
        --     --      ["bag"]         = { item = 0, texture = 0},  -- Bag
        --             ["hat"]         = { item = -1, texture = -1},  -- Hat
        --     --      ["glass"]       = { item = 0, texture = 0},  -- Glasses
        --     --      ["ear"]         = { item = 0, texture = 0},  -- Ear Accessories
        --             ["mask"]         = { item = 0, texture = 0},  -- Masks
        --         },
        --     },
        --     [6] = {
        --         outfitLabel = "Police bike",
        --         outfitData = {
        --             ["pants"]       = { item = 92, texture = 0},  -- Pants
        --             ["arms"]        = { item = 4, texture = 0},  -- Arms
        --             ["t-shirt"]     = { item = 56, texture = 0},  -- T Shirt
        --             ["vest"]        = { item = 0, texture = 0},  -- Body Vest
        --             ["torso2"]      = { item = 227, texture = 0},  -- Jacket / Vests
        --             ["shoes"]       = { item = 24, texture = 0},  -- Shoes
        --             ["decals"]      = { item = 7, texture = 0},  -- Decals
        --             ["accessory"]   = { item = 8, texture = 0},  -- Neck
        --     --      ["bag"]         = { item = 0, texture = 0},  -- Bag
        --             ["hat"]         = { item = -1, texture = -1},  -- Hat
        --     --      ["glass"]       = { item = 0, texture = 0},  -- Glasses
        --     --      ["ear"]         = { item = 0, texture = 0},  -- Ear Accessories
        --             ["mask"]         = { item = 0, texture = 0},  -- Masks
        --         },
        --     },
        --     [7] = {
        --         outfitLabel = "SWAT",
        --         outfitData = {
        --             ["pants"]       = { item = 4, texture = 2},  -- Pants
        --             ["arms"]        = { item = 17, texture = 0},  -- Arms
        --             ["t-shirt"]     = { item = 58, texture = 0},  -- T Shirt
        --             ["vest"]        = { item = 5, texture = 0},  -- Body Vest
        --             ["torso2"]      = { item = 53, texture = 0},  -- Jacket / Vests
        --             ["shoes"]       = { item = 8, texture = 0},  -- Shoes
        --             ["decals"]      = { item = 7, texture = 0},  -- Decals
        --             ["accessory"]   = { item = 1, texture = 0},  -- Neck
        --             ["bag"]         = { item = 2, texture = 0},  -- Bag
        --             ["hat"]         = { item = 119, texture = 0},  -- Hat
        --     --      ["glass"]       = { item = 0, texture = 0},  -- Glasses
        --     --      ["ear"]         = { item = 0, texture = 0},  -- Ear Accessories
        --             ["mask"]         = { item = 56, texture = 1},  -- Masks
        --         },
        --     },
        },
        ["female"] = {
            [1] = {
                outfitLabel = "LSPD Patrol Standard",
                outfitData = {
                    ["pants"]       = { item = 134, texture = 0},  -- Pants
                    ["arms"]        = { item = 14, texture = 0},  -- Arms
                    ["t-shirt"]     = { item = 152, texture = 0},  -- T Shirt
                    ["vest"]        = { item = 56, texture = 0},  -- Body Vest
                    ["torso2"]      = { item = 355, texture = 0},  -- Jacket / Vests
                    ["shoes"]       = { item = 25, texture = 0},  -- Shoes
            --        ["decals"]      = { item = 7, texture = 0},  -- Decals
            --        ["accessory"]   = { item = 8, texture = 0},  -- Neck
            --      ["bag"]         = { item = 0, texture = 0},  -- Bag
            --        ["hat"]         = { item = -1, texture = -1},  -- Hat
            --      ["glass"]       = { item = 0, texture = 0},  -- Glasses
            --      ["ear"]         = { item = 0, texture = 0},  -- Ear Accessories
            --        ["mask"]         = { item = 0, texture = 0},  -- Masks
                },
            },
        }
    },
    ["ambulance"] = {
        ["male"] = {
   --          [1] = {
   --              outfitLabel = "T-Shirt",
   --              outfitData = {
   --                  ["pants"]       = { item = 49,texture = 0},  -- Pants
   --                  ["arms"]        = { item = 85, texture = 0},  -- Arms
   --                  ["t-shirt"]     = { item = 88, texture = 0},  -- T Shirt
   --                  ["vest"]        = { item = 0, texture = 0},  -- Body Vest
   --                  ["torso2"]      = { item = 32, texture = 6},  -- Jacket / Vests
   --                  ["shoes"]       = { item = 25, texture = 0},  -- Shoes
   --                  ["decals"]      = { item = 0, texture = 0},  -- Decals
   --                  ["accessory"]   = { item = 0, texture = 0},  -- Neck
   --                  ["bag"]         = { item = 0, texture = 0},  -- Bag
   --                  ["hat"]         = { item = -1, texture = -1},  -- Hat
   --                  ["glass"]       = { item = 0, texture = 0},  -- Glasses
   --                  ["ear"]         = { item = 0, texture = 0},  -- Ear Accessories
   --                  ["mask"]        = { item = 121, texture = 0},  -- Masks
   --              },
   --          },
   --          [2] = {
   --              outfitLabel = "Polo",
   --              outfitData = {
   --                  ["pants"]       = { item = 49,texture = 0},  -- Pants
   --                  ["arms"]        = { item = 85, texture = 0},  -- Arms
   --                  ["t-shirt"]     = { item = 88, texture = 0},  -- T Shirt
   --                  ["vest"]        = { item = 0, texture = 0},  -- Body Vest
   --                  ["torso2"]      = { item = 93, texture = 2},  -- Jacket / Vests
   --                  ["shoes"]       = { item = 25, texture = 0},  -- Shoes
   --                  ["decals"]      = { item = 0, texture = 0},  -- Decals
   --                  ["accessory"]   = { item = 0, texture = 0},  -- Neck
   --                  ["bag"]         = { item = 0, texture = 0},  -- Bag
   --                  ["hat"]         = { item = -1, texture = -1},  -- Hat
   --                  ["glass"]       = { item = 0, texture = 0},  -- Glasses
   --                  ["ear"]         = { item = 0, texture = 0},  -- Ear Accessories
   --                  ["mask"]        = { item = 121, texture = 0},  -- Masks
   --              },
   --          },
			-- [3] = {
   --              outfitLabel = "MMT Nurse",
   --              outfitData = {
   --                  ["pants"]       = { item = 59,texture = 5},  -- Pants
   --                  ["arms"]        = { item = 86, texture = 0},  -- Arms
   --                  ["t-shirt"]     = { item = 135, texture = 0},  -- T Shirt
   --                  ["vest"]        = { item = 0, texture = 0},  -- Body Vest
   --                  ["torso2"]      = { item = 151, texture = 4},  -- Jacket / Vests
   --                  ["shoes"]       = { item = 25, texture = 0},  -- Shoes
   --                  ["decals"]      = { item = 0, texture = 0},  -- Decals
   --                  ["accessory"]   = { item = 0, texture = 0},  -- Neck
   --                  ["bag"]         = { item = 0, texture = 0},  -- Bag
   --                  ["hat"]         = { item = 79, texture = 0},  -- Hat
   --                  ["glass"]       = { item = 0, texture = 0},  -- Glasses
   --                  ["ear"]         = { item = 0, texture = 0},  -- Ear Accessories
   --                  ["mask"]        = { item = 121, texture = 0},  -- Masks	
			-- 	},
			-- },
			-- [4] = {
   --              outfitLabel = "T-Shirt Heavy Vest",
   --              outfitData = {
   --                  ["pants"]       = { item = 49,texture = 0},  -- Pants
   --                  ["arms"]        = { item = 85, texture = 0},  -- Arms
   --                  ["t-shirt"]     = { item = 88, texture = 0},  -- T Shirt
   --                  ["vest"]        = { item = 18, texture = 0},  -- Body Vest
   --                  ["torso2"]      = { item = 32, texture = 6},  -- Jacket / Vests
   --                  ["shoes"]       = { item = 25, texture = 0},  -- Shoes
   --                  ["decals"]      = { item = 0, texture = 0},  -- Decals
   --                  ["accessory"]   = { item = 0, texture = 0},  -- Neck
   --                  ["bag"]         = { item = 0, texture = 0},  -- Bag
   --                  ["hat"]         = { item = -1, texture = -1},  -- Hat
   --                  ["glass"]       = { item = 0, texture = 0},  -- Glasses
   --                  ["ear"]         = { item = 0, texture = 0},  -- Ear Accessories
   --                  ["mask"]        = { item = 121, texture = 0},  -- Masks
   --              },
   --          },
   --          [5] = {
   --              outfitLabel = "Polo Heavy Vest",
   --              outfitData = {
   --                  ["pants"]       = { item = 49,texture = 0},  -- Pants
   --                  ["arms"]        = { item = 85, texture = 0},  -- Arms
   --                  ["t-shirt"]     = { item = 88, texture = 0},  -- T Shirt
   --                  ["vest"]        = { item = 18, texture = 0},  -- Body Vest
   --                  ["torso2"]      = { item = 93, texture = 2},  -- Jacket / Vests
   --                  ["shoes"]       = { item = 25, texture = 0},  -- Shoes
   --                  ["decals"]      = { item = 0, texture = 0},  -- Decals
   --                  ["accessory"]   = { item = 0, texture = 0},  -- Neck
   --                  ["bag"]         = { item = 0, texture = 0},  -- Bag
   --                  ["hat"]         = { item = -1, texture = -1},  -- Hat
   --                  ["glass"]       = { item = 0, texture = 0},  -- Glasses
   --                  ["ear"]         = { item = 0, texture = 0},  -- Ear Accessories
   --                  ["mask"]        = { item = 121, texture = 0},  -- Masks
   --              },
   --          },
        },
        ["female"] = {},
    },
    ["doctor"] = {
        ["male"] = {
            [1] = {
                outfitLabel = "Coat For Doctors",
                outfitData = {
                    ["pants"]       = { item = 49,texture = 0},  -- Pants
                    ["arms"]        = { item = 86, texture = 0},  -- Arms
                    ["t-shirt"]     = { item = 88, texture = 0},  -- T Shirt
                    ["vest"]        = { item = 0, texture = 0},  -- Body Vest
                    ["torso2"]      = { item = 118, texture = 7},  -- Jacket / Vests
                    ["shoes"]       = { item = 25, texture = 0},  -- Shoes
                    ["decals"]      = { item = 0, texture = 0},  -- Decals
                    ["accessory"]   = { item = 0, texture = 0},  -- Neck
                    ["bag"]         = { item = 0, texture = 0},  -- Bag
                    ["hat"]         = { item = -1, texture = -1},  -- Hat
                    ["glass"]       = { item = 0, texture = 0},  -- Glasses
                    ["ear"]         = { item = 0, texture = 0},  -- Ear Accessories
                    ["mask"]        = { item = 121, texture = 0},  -- Masks
				},
			},
			[2] = {
                outfitLabel = "T-Shirt Heavy Vest",
                outfitData = {
                    ["pants"]       = { item = 49,texture = 0},  -- Pants
                    ["arms"]        = { item = 85, texture = 0},  -- Arms
                    ["t-shirt"]     = { item = 88, texture = 0},  -- T Shirt
                    ["vest"]        = { item = 18, texture = 0},  -- Body Vest
                    ["torso2"]      = { item = 32, texture = 6},  -- Jacket / Vests
                    ["shoes"]       = { item = 25, texture = 0},  -- Shoes
                    ["decals"]      = { item = 0, texture = 0},  -- Decals
                    ["accessory"]   = { item = 0, texture = 0},  -- Neck
                    ["bag"]         = { item = 0, texture = 0},  -- Bag
                    ["hat"]         = { item = -1, texture = -1},  -- Hat
                    ["glass"]       = { item = 0, texture = 0},  -- Glasses
                    ["ear"]         = { item = 0, texture = 0},  -- Ear Accessories
                    ["mask"]        = { item = 121, texture = 0},  -- Masks
				},
			},			
			[3] = {
                outfitLabel = "OVD-G",
                outfitData = {
                    ["pants"]       = { item = 49,texture = 4},  -- Pants
                    ["arms"]        = { item = 86, texture = 0},  -- Arms
                    ["t-shirt"]     = { item = 51, texture = 0},  -- T Shirt
                    ["vest"]        = { item = 0, texture = 0},  -- Body Vest
                    ["torso2"]      = { item = 151, texture = 2},  -- Jacket / Vests
                    ["shoes"]       = { item = 25, texture = 0},  -- Shoes
                    ["decals"]      = { item = 0, texture = 0},  -- Decals
                    ["accessory"]   = { item = 0, texture = 0},  -- Neck
                    ["bag"]         = { item = 0, texture = 0},  -- Bag
                    ["hat"]         = { item = -1, texture = -1},  -- Hat
                    ["glass"]       = { item = 0, texture = 0},  -- Glasses
                    ["ear"]         = { item = 0, texture = 0},  -- Ear Accessories
                    ["mask"]        = { item = 121, texture = 0},  -- Masks
				},
			},
			[4] = {
                outfitLabel = "MMT Pilot",
                outfitData = {
                    ["pants"]       = { item = 59,texture = 5},  -- Pants
                    ["arms"]        = { item = 86, texture = 0},  -- Arms
                    ["t-shirt"]     = { item = 135, texture = 0},  -- T Shirt
                    ["vest"]        = { item = 0, texture = 0},  -- Body Vest
                    ["torso2"]      = { item = 151, texture = 3},  -- Jacket / Vests
                    ["shoes"]       = { item = 25, texture = 0},  -- Shoes
                    ["decals"]      = { item = 0, texture = 0},  -- Decals
                    ["accessory"]   = { item = 0, texture = 0},  -- Neck
                    ["bag"]         = { item = 0, texture = 0},  -- Bag
                    ["hat"]         = { item = 79, texture = 0},  -- Hat
                    ["glass"]       = { item = 0, texture = 0},  -- Glasses
                    ["ear"]         = { item = 0, texture = 0},  -- Ear Accessories
                    ["mask"]        = { item = 121, texture = 0},  -- Masks	
				},
			},
			[5] = {
                outfitLabel = "MMT Doctor",
                outfitData = {
                    ["pants"]       = { item = 59,texture = 5},  -- Pants
                    ["arms"]        = { item = 86, texture = 0},  -- Arms
                    ["t-shirt"]     = { item = 135, texture = 0},  -- T Shirt
                    ["vest"]        = { item = 0, texture = 0},  -- Body Vest
                    ["torso2"]      = { item = 151, texture = 5},  -- Jacket / Vests
                    ["shoes"]       = { item = 25, texture = 0},  -- Shoes
                    ["decals"]      = { item = 0, texture = 0},  -- Decals
                    ["accessory"]   = { item = 0, texture = 0},  -- Neck
                    ["bag"]         = { item = 0, texture = 0},  -- Bag
                    ["hat"]         = { item = 79, texture = 0},  -- Hat
                    ["glass"]       = { item = 0, texture = 0},  -- Glasses
                    ["ear"]         = { item = 0, texture = 0},  -- Ear Accessories
                    ["mask"]        = { item = 121, texture = 0},  -- Masks	
				},
			},
			[6] = {
                outfitLabel = "MMT Nurse",
                outfitData = {
                    ["pants"]       = { item = 59,texture = 5},  -- Pants
                    ["arms"]        = { item = 86, texture = 0},  -- Arms
                    ["t-shirt"]     = { item = 135, texture = 0},  -- T Shirt
                    ["vest"]        = { item = 0, texture = 0},  -- Body Vest
                    ["torso2"]      = { item = 151, texture = 4},  -- Jacket / Vests
                    ["shoes"]       = { item = 25, texture = 0},  -- Shoes
                    ["decals"]      = { item = 0, texture = 0},  -- Decals
                    ["accessory"]   = { item = 0, texture = 0},  -- Neck
                    ["bag"]         = { item = 0, texture = 0},  -- Bag
                    ["hat"]         = { item = 79, texture = 0},  -- Hat
                    ["glass"]       = { item = 0, texture = 0},  -- Glasses
                    ["ear"]         = { item = 0, texture = 0},  -- Ear Accessories
                    ["mask"]        = { item = 121, texture = 0},  -- Masks	
				},
			},		
		},		
        ["female"] = {
            [1] = {
                outfitLabel = "Female Outfit",
                outfitData = {
                    ["pants"]       = { item = 3,texture = 1},  -- Pants
                    ["arms"]        = { item = 14, texture = 0},  -- Arms
                    ["t-shirt"]     = { item = 3, texture = 0},  -- T Shirt
                    ["vest"]        = { item = 0, texture = 0},  -- Body Vest
                    ["torso2"]      = { item = 14, texture = 1},  -- Jacket / Vests
                    ["shoes"]       = { item = 25, texture = 0},  -- Shoes
                    ["decals"]      = { item = 0, texture = 0},  -- Decals
                    ["accessory"]   = { item = 0, texture = 0},  -- Neck
                    ["bag"]         = { item = 0, texture = 0},  -- Bag
                    ["hat"]         = { item = -1, texture = 0},  -- Hat
                    ["glass"]       = { item = 0, texture = 0},  -- Glasses
                    ["ear"]         = { item = 0, texture = 0},  -- Ear Accessories
                    ["mask"]        = { item = 121, texture = 0},  -- Masks
				},
            },
        },
    },
}

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)