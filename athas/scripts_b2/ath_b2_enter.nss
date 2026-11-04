// ath_b2_enter — OnEnter пустынных локаций блока 2 (ath_stony, ath_domes, ath_road, ath_oasis).
// Жара и открытое небо; при первом входе — полдня пути; месть ааракокр; предвестники змея;
// ночью — сон охраны лагеря.

#include "ath_inc_b2"

void main()
{
    object oArea = OBJECT_SELF;
    object oPC = GetEnteringObject();
    SetLocalInt(oArea, "ATH_HOT", 1);
    SetLocalInt(oArea, "ATH_OUTDOOR", 1);
    if (GetIsNight())
        AthCampSleep(oArea);
    if (!GetIsPC(oPC))
        return;

    string sSeen = "ATH_SEEN_" + GetTag(oArea);
    if (!GetLocalInt(oPC, sSeen))
    {
        SetLocalInt(oPC, sSeen, 1);
        AthAdvanceHours(12);
        string sTag = GetTag(oArea);
        if (sTag == "ATH_AREA_STONY")
        {
            AthJournal2(oPC, ATH_J2_STONY);
            DelayCommand(1.0, FloatingTextStringOnCreature(ATH_TXT2_STONY, oPC, FALSE));
        }
        else if (sTag == "ATH_AREA_DOMES")
            DelayCommand(1.0, FloatingTextStringOnCreature(ATH_TXT2_DOMES, oPC, FALSE));
        else if (sTag == "ATH_AREA_OASIS")
        {
            AthJournal2(oPC, ATH_J2_OASIS);
            DelayCommand(1.0, FloatingTextStringOnCreature(ATH_TXT2_OASIS, oPC, FALSE));
        }
        DelayCommand(2.0, AthReportWater(oPC));
    }

    object oModule = GetModule();
    if (GetLocalInt(oModule, "ATH_AARA_FLED") && GetCurrentHitPoints(oPC) * 3 < GetMaxHitPoints(oPC)
        && d100() <= ATH_HARASS_CHANCE)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(1, DAMAGE_TYPE_BLUDGEONING), oPC);
        DelayCommand(3.0, FloatingTextStringOnCreature(ATH_TXT2_HARASS, oPC, FALSE));
    }

    if (GetLocalInt(oModule, "ATH_SLV_DONE") && !GetLocalInt(oModule, "ATH_WYRM_DONE"))
    {
        string sOmen = ATH_TXT2_WYRM_DAY;
        if (GetIsNight())
            sOmen = ATH_TXT2_WYRM_NIGHT;
        DelayCommand(5.0, FloatingTextStringOnCreature(sOmen, oPC, FALSE));
    }
}
