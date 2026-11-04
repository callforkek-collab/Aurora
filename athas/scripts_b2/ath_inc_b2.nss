// ath_inc_b2 — блок 2 (карточки 7–15): константы, тексты и общие функции.
// Подключает систему жажды среза (scripts/ath_inc_thirst).

#include "ath_inc_thirst"

// --- Баланс (для одного героя) ---
const int   ATH_DC_LORE         = 15;   // Знание: кактус, ипр, метелинок
const int   ATH_DC_WORM         = 14;   // Рефлекс против червя
const int   ATH_WORM_ROUNDS     = 3;
const int   ATH_PULP_QUARTS     = 2;    // половина суточной нормы
const float ATH_PULP_SPOIL      = 300.0;
const int   ATH_HARASS_CHANCE   = 40;
const int   ATH_DC_PLUG         = 15;   // Поиск пробки под куполом
const int   ATH_FUEL_NEED       = 4;
const int   ATH_FUEL_HOURS      = 3;
const int   ATH_SMOKE_GUARDS    = 3;    // в оригинале 12 у каждого выхода
const float ATH_SMOKE_TIME      = 180.0;
const int   ATH_TUNNEL_PENALTY  = 2;
const int   ATH_DC_WZ_POISON    = 12;
const int   ATH_DC_EGG          = 14;
const int   ATH_EGG_HATCH_DAYS  = 5;
const int   ATH_QUEEN_REINF     = 3;
const int   ATH_DC_SLV_PERSUADE = 13;
const int   ATH_SNEAK_RANKS     = 4;
const int   ATH_WYRM_MIN_WATER  = 8;
const int   ATH_WYRM_SIP        = 12;   // 3 галлона за раунд
const int   ATH_WYRM_MAX        = 60;   // 15 галлонов
const int   ATH_DC_WYRM         = 14;
const int   ATH_DC_COCOON       = 15;
const int   ATH_MEK_LURE        = 20;   // кварт на земле; в оригинале 40 (10 галлонов)
const int   ATH_MEK_DRINK_BEATS = 20;   // ~2 минуты
const float ATH_MEK_GUARD_DIST  = 8.0;
const int   ATH_DC_POOL         = 18;
const int   ATH_POOL_DAMAGE     = 20;
const float ATH_POOL_ONSET      = 30.0;
const int   ATH_DC_BOIL         = 14;   // d20 + мод. Инт; проверка Инт с -4
const int   ATH_BOIL_QUARTS     = 2;
const int   ATH_FLYER_EVERY_HB  = 50;   // везер над полем куполов, ~5 минут

// --- Журнал блока 2: показывается последнее событие ---
const string ATH_QUEST2 = "ath_block2";
const int ATH_J2_STONY   = 1;
const int ATH_J2_WEZER   = 2;
const int ATH_J2_HIVE    = 3;
const int ATH_J2_EGG     = 4;
const int ATH_J2_DEAL    = 5;
const int ATH_J2_KLED    = 6;
const int ATH_J2_WYRM    = 7;
const int ATH_J2_OASIS   = 8;
const int ATH_J2_POISON  = 9;

// --- Теги и ресрефы ---
const string ATH_TAG_WAX_WATER = "ath_wax_water";
const string ATH_TAG_SKIN      = "ath_skin";
const string ATH_TAG_FUEL      = "ath_fuel";
const string ATH_TAG_CHARCOAL  = "ath_charcoal";
const string ATH_TAG_POT       = "ath_pot";
const string ATH_RES_WAX_WATER = "ath_wax_water";
const string ATH_RES_PULP      = "ath_pulp";
const string ATH_RES_WORM_ROPE = "ath_worm_rope";
const string ATH_RES_FUEL      = "ath_fuel";
const string ATH_RES_EGG_CUT   = "ath_egg_cut";
const string ATH_RES_YYPR      = "ath_yypr";
const string ATH_RES_BOILED    = "ath_boiled";
const string ATH_RES_BOILED_X  = "ath_boiled_bad";
const string ATH_RES_COCOON    = "ath_cocoon_rip";
const string ATH_RES_WZ_WORKER = "ath_wz_worker";
const string ATH_RES_WZ_SOLD   = "ath_wz_soldier";
const string ATH_RES_WZ_LARVA  = "ath_wz_larva";
const string ATH_RES_WZ_FETCH  = "ath_wz_fetch";
const string ATH_RES_AARA      = "ath_aara";
const string ATH_RES_WYRM      = "ath_wyrm";
const string ATH_RES_CORPSE    = "ath_corpse_b";
const string ATH_RES_PLUG      = "ath_plug";

const string ATH_TAG_AARA      = "ATH_AARA";      // префикс
const string ATH_TAG_WZ        = "ATH_WZ";        // префикс всех везеров
const string ATH_TAG_WZ_FETCH  = "ATH_WZ_FETCH";
const string ATH_TAG_QUEEN     = "ATH_WZ_QUEEN";
const string ATH_TAG_MARISTA   = "ATH_SLAVE_MARISTA";
const string ATH_TAG_SLAVE     = "ATH_SLAVE";     // префикс
const string ATH_TAG_CAMP      = "ATH_CAMP";      // префикс охраны лагеря
const string ATH_TAG_CAMP_SLP  = "ATH_CAMP_SLEEP";
const string ATH_TAG_WYRM      = "ATH_WYRM";
const string ATH_TAG_AREA_HIVE = "ATH_AREA_HIVE";

const string ATH_WP_B8         = "ATH_WP_B8";
const string ATH_WP_DOME_C     = "ATH_WP_DOME_C";
const string ATH_WP_HIVE_B     = "ATH_WP_HIVE_B";
const string ATH_WP_BROOD_IN   = "ATH_WP_BROOD_IN";
const string ATH_WP_AMBUSH     = "ATH_WP_AMBUSH";
const string ATH_WP_LAIR       = "ATH_WP_LAIR";
const string ATH_WP_COCOON     = "ATH_WP_COCOON";
const string ATH_WP_POOL       = "ATH_WP_POOL";
const string ATH_WP_MEK_HOME   = "ATH_WP_MEK_HOME";

const string ATH_DLG_SLAVES    = "ath_dlg_slaves";

// --- Тексты ---
const string ATH_TXT2_STONY     = "Каменистые пустоши. Камень, колючки и ни капли воды.";
const string ATH_TXT2_CAC_KNOW  = "Вы узнаёте пурпурный шар: его сок — яд, от которого сохнет тело.";
const string ATH_TXT2_CAC_SICK  = "Сок горчит. Через мгновение вас скручивает сухая слабость.";
const string ATH_TXT2_WORM_GRAB = "Из раны в кактусе вылетает склизкий червь и оплетает вас!";
const string ATH_TXT2_WORM_MISS = "Из кактуса вылетает червь, но вы успеваете отскочить.";
const string ATH_TXT2_WORM_ROPE = "Отрубленный червь длиной в десятки футов. Сойдёт за верёвку.";
const string ATH_TXT2_PULP      = "Мякоть кактуса сочится влагой. Её надо съесть быстро, пока не испортилась.";
const string ATH_TXT2_BUZZ      = "За гребнем — бешеное жужжание и хлопанье крыльев.";
const string ATH_TXT2_AARA_FLEE = "Ааракокра с клёкотом уходит в небо.";
const string ATH_TXT2_AARA_TAKE = "Ааракокры хватают восковой шар и улетают. Вам не достаётся ни капли.";
const string ATH_TXT2_WZ_SAVED  = "Везер дёргается и затихает. Восковой шар у его рта цел — в нём галлон воды.";
const string ATH_TXT2_WZ_BURST  = "Восковой шар лопается и окатывает вас водой. Несколько капель попадают в рот.";
const string ATH_TXT2_HARASS    = "С неба летят гнилые потроха. Высоко кружат две чёрные точки.";
const string ATH_TXT2_FLYER     = "Высоко пролетает красный везер с восковым шаром. Все они летят в одну сторону.";
const string ATH_TXT2_FLYER_X   = "Везер падает, и восковой шар лопается о песок.";
const string ATH_TXT2_DOMES     = "Поле песчаных куполов. Над ними снуют везеры.";
const string ATH_TXT2_CORPSE    = "Внутри смердит. Вздутое тело с язвой на брюхе, а на нём — белая личинка.";
const string ATH_TXT2_WORKER    = "Внутри купола рабочий везер замазывает стены воском. Он с жужжанием бросается на вас!";
const string ATH_TXT2_PLUG_NO   = "Под ногами только песок.";
const string ATH_TXT2_PLUG_YES  = "Под песком и воском нащупывается пробка. Под ней — лаз вниз.";
const string ATH_TXT2_FUEL      = "Вы собираете вязанку сухого хвороста. Солнце сдвинулось на небе.";
const string ATH_TXT2_FUEL_NEED = "Для дымного костра нужно вязанок хвороста: ";
const string ATH_TXT2_SMOKE     = "Дым валит в лаз. Из куполов с гулом вылетают везеры.";
const string ATH_TXT2_SMOKE_END = "Дым рассеялся.";
const string ATH_TXT2_SMOKE_HURT= "Едкий дым разъедает лёгкие.";
const string ATH_TXT2_HIVE      = "Низкий туннель, сырость и запах воска. Здесь не размахнуться.";
const string ATH_TXT2_NUMB      = "Ноги начинают неметь — яд солдата!";
const string ATH_TXT2_PARALYZED = "Тело перестаёт слушаться.";
const string ATH_TXT2_QUEEN     = "Королева вонзает жало в неподвижного эльфа. На вас она пока не смотрит.";
const string ATH_TXT2_QUEEN_UP  = "Королева разворачивается к вам. Из туннелей слышно жужжание.";
const string ATH_TXT2_EGG       = "Жало входит глубоко. Внутри что-то осталось.";
const string ATH_TXT2_EGG_CUT   = "Вы вырезаете из раны белое яйцо. Больно, но оно мертво.";
const string ATH_TXT2_LARVA     = "Внутри шевелится личинка. Она ест вас.";
const string ATH_TXT2_HONEY     = "Густой мёд везеров. Силы возвращаются.";
const string ATH_TXT2_HONEY_NO  = "Сегодня вы уже ели мёд.";
const string ATH_TXT2_SLAVE_HUSH= "Пригнись, дурак, сорвёшь нам засаду!";
const string ATH_TXT2_CAMP_DAY  = "Днём к лагерю не подобраться — вас сразу заметят.";
const string ATH_TXT2_ALARM     = "Вор! Все на ноги!";
const string ATH_TXT2_WYRM_DAY  = "На горизонте вьётся серебристая лента.";
const string ATH_TXT2_WYRM_NIGHT= "Что-то длинное проносится на фоне лун.";
const string ATH_TXT2_WYRM_SIP  = "В темноте тихо журчит вода…";
const string ATH_TXT2_WYRM_SEEN = "Над вашими бурдюками — огромный змей в серебристом панцире!";
const string ATH_TXT2_COCOON    = "Вы приходите в себя в липком коконе. Рядом в тени скал — змей.";
const string ATH_TXT2_COCOON_NO = "Кокон не поддаётся.";
const string ATH_TXT2_COCOON_OK = "Вы прорываете кокон.";
const string ATH_TXT2_COCOON_SIP= "Змей пьёт вашу кровь, пока вы связаны.";
const string ATH_TXT2_OASIS     = "Оазис! Горячая бурая вода, зелёная трава и запах тухлятины.";
const string ATH_TXT2_MEK_BODY  = "Тот самый мекиллот, что тянул повозку. Он напился из оазиса и умер.";
const string ATH_TXT2_MEK_LURE  = "Мекиллот чует воду и тяжело идёт к ней.";
const string ATH_TXT2_POOL_WARN = "Вокруг воды — дохлые птицы, ящерицы и зверьки. Используйте ещё раз, чтобы всё равно выпить.";
const string ATH_TXT2_POOL_SIP  = "Горькая обжигающая вода.";
const string ATH_TXT2_POOL_DIE  = "Яд сводит внутренности.";
const string ATH_TXT2_POOL_HURT = "Вас выворачивает. Вы выжили, но едва.";
const string ATH_TXT2_BOIL_NEED = "Нужен горшок и топливо: уголь или хворост.";
const string ATH_TXT2_BOIL      = "Час у костра — и в горшке немного выпаренной воды.";
const string ATH_TXT2_YYPR      = "Вы набираете плоской жёсткой хвои ипра.";
const string ATH_TXT2_YYPR_KNOW = "Из этой хвои заваривают чай, который помогает восстановить силы.";
const string ATH_TXT2_TEA       = "Терпкий чай из хвои ипра.";
const string ATH_TXT2_TEA_REST  = "Чай из ипра восстановил вам немного сил.";
const string ATH_TXT2_HERB      = "Фиолетовые листья на мостике. Незнакомое растение.";
const string ATH_TXT2_HERB_KNOW = "Метелинок из Поющих гор! Смертельный яд, не действующий на эльфов и канков. Воду отравили эльфы.";
const string ATH_TXT2_KLED      = "Тропа на Клед. Продолжение следует…";

// --- Функции ---

int AthTagStarts(object oObject, string sPrefix)
{
    return GetStringLeft(GetTag(oObject), GetStringLength(sPrefix)) == sPrefix;
}

// Кварт воды в предмете: кувшины по стопке, шары и бурдюки по зарядам.
int AthQuartsIn(object oItem)
{
    string sTag = GetTag(oItem);
    if (sTag == ATH_TAG_WATER)
        return GetItemStackSize(oItem);
    if (sTag == ATH_TAG_WAX_WATER || sTag == ATH_TAG_SKIN)
        return GetItemCharges(oItem);
    return 0;
}

int AthCountAllWater(object oCreature)
{
    int nCount = 0;
    object oItem = GetFirstItemInInventory(oCreature);
    while (GetIsObjectValid(oItem))
    {
        nCount += AthQuartsIn(oItem);
        oItem = GetNextItemInInventory(oCreature);
    }
    return nCount;
}

// Сливает до nQuarts из любых ёмкостей. Возвращает, сколько слито.
int AthDrainWater(object oCreature, int nQuarts)
{
    int nDrained = 0;
    object oItem = GetFirstItemInInventory(oCreature);
    while (GetIsObjectValid(oItem) && nDrained < nQuarts)
    {
        int nIn = AthQuartsIn(oItem);
        if (nIn > 0)
        {
            int nTake = nQuarts - nDrained;
            if (nTake > nIn)
                nTake = nIn;
            if (nTake == nIn)
                DestroyObject(oItem);
            else if (GetTag(oItem) == ATH_TAG_WATER)
                SetItemStackSize(oItem, nIn - nTake);
            else
                SetItemCharges(oItem, nIn - nTake);
            nDrained += nTake;
        }
        oItem = GetNextItemInInventory(oCreature);
    }
    return nDrained;
}

int AthCountTagged(object oCreature, string sTag)
{
    int nCount = 0;
    object oItem = GetFirstItemInInventory(oCreature);
    while (GetIsObjectValid(oItem))
    {
        if (GetTag(oItem) == sTag)
            nCount += GetItemStackSize(oItem);
        oItem = GetNextItemInInventory(oCreature);
    }
    return nCount;
}

// Забирает nCount предметов с тегом (с учётом стопок).
void AthTakeTagged(object oCreature, string sTag, int nCount)
{
    object oItem = GetFirstItemInInventory(oCreature);
    while (GetIsObjectValid(oItem) && nCount > 0)
    {
        if (GetTag(oItem) == sTag)
        {
            int nStack = GetItemStackSize(oItem);
            if (nStack <= nCount)
            {
                DestroyObject(oItem);
                nCount -= nStack;
            }
            else
            {
                SetItemStackSize(oItem, nStack - nCount);
                nCount = 0;
            }
        }
        oItem = GetNextItemInInventory(oCreature);
    }
}

void AthJournal2(object oPC, int nState)
{
    if (GetIsPC(oPC))
        AddJournalQuestEntry(ATH_QUEST2, nState, oPC, FALSE, FALSE, TRUE);
}

int AthIsSmallRace(object oCreature)
{
    int nRace = GetRacialType(oCreature);
    return nRace == RACIAL_TYPE_HALFLING || nRace == RACIAL_TYPE_GNOME || nRace == RACIAL_TYPE_DWARF;
}

int AthHasEffectType(object oCreature, int nType)
{
    effect eEffect = GetFirstEffect(oCreature);
    while (GetIsEffectValid(eEffect))
    {
        if (GetEffectType(eEffect) == nType)
            return TRUE;
        eEffect = GetNextEffect(oCreature);
    }
    return FALSE;
}

void AthMakeHostile(object oArea, string sPrefix, object oTarget = OBJECT_INVALID)
{
    object oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject))
    {
        if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && !GetIsDead(oObject)
            && AthTagStarts(oObject, sPrefix))
        {
            ChangeToStandardFaction(oObject, STANDARD_FACTION_HOSTILE);
            if (GetIsObjectValid(oTarget))
                AssignCommand(oObject, ActionAttack(oTarget));
        }
        oObject = GetNextObjectInArea(oArea);
    }
}

void AthTextToPCsIn(object oArea, string sText)
{
    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        if (GetArea(oPC) == oArea)
            FloatingTextStringOnCreature(sText, oPC, FALSE);
        oPC = GetNextPC();
    }
}

// Сдвиг времени вперёд на nHours (SetTime умеет только вперёд, через полночь — на следующий день).
void AthAdvanceHours(int nHours)
{
    SetTime((GetTimeHour() + nHours) % 24, GetTimeMinute(), 0, 0);
}

// Отравленная вода оазиса: через ATH_POOL_ONSET — Стойкость или смерть; успех — ATH_POOL_DAMAGE.
void AthPoolPoison(object oCreature)
{
    if (GetIsDead(oCreature))
        return;
    if (FortitudeSave(oCreature, ATH_DC_POOL, SAVING_THROW_TYPE_POISON) == 0)
    {
        FloatingTextStringOnCreature(ATH_TXT2_POOL_DIE, oCreature, FALSE);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), oCreature);
    }
    else
    {
        FloatingTextStringOnCreature(ATH_TXT2_POOL_HURT, oCreature, FALSE);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(ATH_POOL_DAMAGE, DAMAGE_TYPE_MAGICAL), oCreature);
    }
}

// Сон спящей охраны лагеря ночью.
void AthCampSleep(object oArea)
{
    object oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject))
    {
        if (GetTag(oObject) == ATH_TAG_CAMP_SLP && !GetIsDead(oObject)
            && !AthHasTagged(oObject, "ATH_SLEEP") && !GetLocalInt(GetModule(), "ATH_CAMP_ALARM"))
        {
            effect eSleep = TagEffect(SupernaturalEffect(EffectSleep()), "ATH_SLEEP");
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eSleep, oObject);
        }
        oObject = GetNextObjectInArea(oArea);
    }
}

// Тревога в лагере караванщиков: спящие просыпаются, вся охрана атакует.
void AthCampAlarm(object oThief)
{
    object oModule = GetModule();
    if (GetLocalInt(oModule, "ATH_CAMP_ALARM"))
        return;
    SetLocalInt(oModule, "ATH_CAMP_ALARM", 1);
    object oArea = GetArea(oThief);
    object oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject))
    {
        if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && AthTagStarts(oObject, ATH_TAG_CAMP))
            AthRemoveTagged(oObject, "ATH_SLEEP");
        oObject = GetNextObjectInArea(oArea);
    }
    AthMakeHostile(oArea, ATH_TAG_CAMP, oThief);
    AthTextToPCsIn(oArea, ATH_TXT2_ALARM);
}
