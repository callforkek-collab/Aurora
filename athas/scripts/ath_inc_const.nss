// ath_inc_const — числа баланса, теги и ресрефы среза «Немного знания».
// Всё, что придётся подкрутить под компаньонов или группу, меняется здесь.

// --- Вода и жажда (карточка 5) ---
const int ATH_WATER_NEED_DAY   = 4;  // кварт в сутки (1 галлон)
const int ATH_WATER_NEED_HALF  = 2;  // ночной переход или дневной отдых в тени
const int ATH_START_DRUNK      = 1;  // утренняя кварта в трюме
const int ATH_CON_DEATH        = 3;  // Телосложение, при котором персонаж гибнет

// --- Жара (дополнение к оригиналу) ---
const int ATH_DC_HEAT          = 10;
const int ATH_HEAT_ARMOR_DC    = 4;  // надбавка к DC в тяжёлой броне
const int ATH_HEAT_ARMOR_AC    = 6;  // броня с AC от 6 считается тяжёлой
const int ATH_HEAT_EVERY_HB    = 20; // проверка раз в N сердцебиений модуля (по 6 с)

// --- Сцены ---
const int   ATH_START_XP       = 3000;  // 3-й уровень
const int   ATH_DC_LOOP        = 18;    // вырвать костяную петлю (Сила)
const int   ATH_DC_PSION_WILL  = 14;
const float ATH_S1_TIMEOUT     = 240.0; // сцена 2 начнётся сама, если игрок бездействует
const float ATH_SEARCH_TIME    = 90.0;  // время на обыск повозки
const int   ATH_CARRY_WATER    = 2;     // сколько кувшинов разрешают унести эльфы
const int   ATH_CARRY_WEAPONS  = 2;
const float ATH_FIRE_DELAY     = 6.0;
const float ATH_BURN_TIME      = 60.0;  // через сколько огонь сменяется пепелищем
const int   ATH_THIRSTY_GUARDS = 4;     // плюс главарь; в оригинале 12 на 4–8 героев
const int   ATH_DC_PERSUADE    = 15;
const int   ATH_DC_INTIMIDATE  = 15;
const int   ATH_DC_BLUFF       = 13;
const int   ATH_BLUFF_LEAVE    = 2;     // сколько охранников уходит после блефа
const int   ATH_SPILL_CHANCE   = 50;    // % разбить кувшин при попадании охранника

// --- Журнал ---
const string ATH_QUEST = "ath_survive";
const int ATH_J_HOLD    = 1;
const int ATH_J_ATTACK  = 2;
const int ATH_J_ELVES   = 3;
const int ATH_J_GUARDS  = 4;
const int ATH_J_ROAD    = 5;
const int ATH_J_TIMIRIS = 6;
const int ATH_J_DAWN    = 7;

// --- Теги предметов (tag-based скрипты называются так же) ---
const string ATH_TAG_WATER  = "ath_water_q";
const string ATH_TAG_THORNS = "ath_thorns_pull";
const string ATH_TAG_MAP    = "ath_map";

// --- Ресрефы шаблонов ---
const string ATH_RES_WATER     = "ath_water_q";
const string ATH_RES_LOINCLOTH = "ath_loincloth";
const string ATH_RES_XBOW      = "ath_xbow";
const string ATH_RES_BOLT      = "ath_bolt_obs";
const string ATH_RES_MAP       = "ath_map";
const string ATH_RES_THORNS    = "ath_thorns_pull";
const string ATH_RES_CHARCOAL  = "ath_charcoal";
const string ATH_RES_SHARD     = "ath_obs_shard";
const string ATH_RES_GLASS     = "ath_glass";
const string ATH_RES_ELF       = "ath_elf_raider";
const string ATH_RES_THIRSTY   = "ath_thirsty";
const string ATH_RES_THIRSTY_L = "ath_thirsty_ldr";
const string ATH_RES_WRECK     = "ath_wreck";
const string ATH_RES_CACHE     = "ath_wreck_cache";
const string ATH_RES_FLAME     = "plc_flamelarge"; // стандартное большое пламя

// --- Теги объектов в локациях ---
const string ATH_TAG_AREA_WAGON  = "ATH_AREA_WAGON";
const string ATH_TAG_AREA_DESERT = "ATH_AREA_DESERT";
const string ATH_TAG_CREW        = "ATH_CREW";      // префикс тегов экипажа
const string ATH_TAG_HOLD_GUARD  = "ATH_CREW_HOLD";
const string ATH_TAG_GUARD       = "ATH_CREW_GUARD";
const string ATH_TAG_PSION       = "ATH_CREW_PSION";
const string ATH_TAG_VOICE       = "ATH_VOICE";
const string ATH_TAG_HOLD_DOOR   = "ATH_HOLD_DOOR";
const string ATH_TAG_WAGON_DOOR  = "ATH_WAGON_DOOR";
const string ATH_TAG_WAGON_PART  = "ATH_WAGON_PART";
const string ATH_TAG_ELF         = "ATH_ELF";       // префикс тегов эльфов
const string ATH_TAG_CHIEF       = "ATH_ELF_CHIEF";
const string ATH_TAG_THIRSTY     = "ATH_THIRSTY";   // префикс; главарь — ATH_THIRSTY_LDR
const string ATH_TAG_THIRSTY_L   = "ATH_THIRSTY_LDR";

const string ATH_WP_CHAIN       = "ATH_WP_CHAIN";
const string ATH_WP_LIGHTNING   = "ATH_WP_LIGHTNING";
const string ATH_WP_DECK        = "ATH_WP_DECK";
const string ATH_WP_BOARD       = "ATH_WP_BOARD";
const string ATH_WP_L2_ARRIVE   = "ATH_WP_L2_ARRIVE";
const string ATH_WP_FIRE        = "ATH_WP_FIRE";
const string ATH_WP_ELF_EXIT    = "ATH_WP_ELF_EXIT";
const string ATH_WP_WRECK       = "ATH_WP_WRECK";
const string ATH_WP_CACHE       = "ATH_WP_CACHE";
const string ATH_WP_GUARDS      = "ATH_WP_GUARDS";
const string ATH_WP_GUARDS_EXIT = "ATH_WP_GUARDS_EXIT";

// --- Диалоги ---
const string ATH_DLG_PSION   = "ath_dlg_psion";
const string ATH_DLG_CHIEF   = "ath_dlg_chief";
const string ATH_DLG_THIRSTY = "ath_dlg_thirsty";
