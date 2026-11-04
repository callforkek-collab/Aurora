// ath_b8_buzz — OnEnter триггера у гребня (карточка 8).
// Появляются две ааракокры и везер-водонос: птицы уже дерут его.

#include "ath_inc_b2"

void main()
{
    object oPC = GetEnteringObject();
    object oModule = GetModule();
    if (!GetIsPC(oPC) || GetLocalInt(oModule, "ATH_B8_START"))
        return;
    SetLocalInt(oModule, "ATH_B8_START", 1);

    location lScene = GetLocation(GetWaypointByTag(ATH_WP_B8));
    object oWezer = CreateObject(OBJECT_TYPE_CREATURE, ATH_RES_WZ_FETCH, lScene);
    object oBird1 = CreateObject(OBJECT_TYPE_CREATURE, ATH_RES_AARA, lScene);
    object oBird2 = CreateObject(OBJECT_TYPE_CREATURE, ATH_RES_AARA, lScene);
    AssignCommand(oBird1, ActionAttack(oWezer));
    AssignCommand(oBird2, ActionAttack(oWezer));

    FloatingTextStringOnCreature(ATH_TXT2_BUZZ, oPC, FALSE);
    AthJournal2(oPC, ATH_J2_WEZER);
}
