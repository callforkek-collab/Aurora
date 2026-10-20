// ath_s2_elves — конец обыска (сцена 2 → 3). Выполняется на модуле.
// Эльфы врываются в повозку, добивают экипаж и выгоняют рабов наружу.

#include "ath_inc_thirst"

void AthKillCrew(object oArea)
{
    object oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject))
    {
        if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE
            && GetStringLeft(GetTag(oObject), GetStringLength(ATH_TAG_CREW)) == ATH_TAG_CREW
            && !GetIsDead(oObject))
        {
            SetPlotFlag(oObject, FALSE);
            SetImmortal(oObject, FALSE);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), oObject);
        }
        oObject = GetNextObjectInArea(oArea);
    }
}

void AthThrowOut(object oPC)
{
    object oArrive = GetWaypointByTag(ATH_WP_L2_ARRIVE);
    DeleteLocalInt(oPC, "ATH_SHACKLED");
    AssignCommand(oPC, ClearAllActions());
    AssignCommand(oPC, JumpToObject(oArrive));
}

void main()
{
    object oModule = GetModule();
    if (GetLocalInt(oModule, "ATH_S2_ELVES"))
        return;
    SetLocalInt(oModule, "ATH_S2_ELVES", 1);

    object oWagon = GetObjectByTag(ATH_TAG_AREA_WAGON);
    AthKillCrew(oWagon);

    object oBoard = GetWaypointByTag(ATH_WP_BOARD);
    object oElf = CreateObject(OBJECT_TYPE_CREATURE, ATH_RES_ELF, GetLocation(oBoard));
    CreateObject(OBJECT_TYPE_CREATURE, ATH_RES_ELF, GetLocation(oBoard));
    AssignCommand(oElf, SpeakString(ATH_TXT_ELF_GETOUT, TALKVOLUME_SHOUT));

    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        if (GetArea(oPC) == oWagon)
        {
            FadeToBlack(oPC, FADE_SPEED_FAST);
            DelayCommand(6.0, AthThrowOut(oPC));
            DelayCommand(7.0, FadeFromBlack(oPC, FADE_SPEED_MEDIUM));
        }
        oPC = GetNextPC();
    }
}
