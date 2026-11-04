// ath_hive_plug — OnUsed пробки под разбитым куполом (карточка 9).
// Сначала Поиск DC 15; найденная пробка ведёт в зал B улья.

#include "ath_inc_b2"

void main()
{
    object oPC = GetLastUsedBy();
    if (!GetLocalInt(OBJECT_SELF, "ATH_FOUND"))
    {
        if (!GetIsSkillSuccessful(oPC, SKILL_SEARCH, ATH_DC_PLUG))
        {
            FloatingTextStringOnCreature(ATH_TXT2_PLUG_NO, oPC, FALSE);
            return;
        }
        SetLocalInt(OBJECT_SELF, "ATH_FOUND", 1);
        FloatingTextStringOnCreature(ATH_TXT2_PLUG_YES, oPC, FALSE);
        return;
    }
    AssignCommand(oPC, ClearAllActions());
    AssignCommand(oPC, JumpToObject(GetWaypointByTag(ATH_WP_HIVE_B)));
}
