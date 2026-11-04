// ath_yypr_tree — OnUsed дерева ипр (карточка 15): хвоя для чая; Знание DC 15 — подсказка.

#include "ath_inc_b2"

void main()
{
    object oPC = GetLastUsedBy();
    if (GetLocalInt(OBJECT_SELF, "ATH_PICKED"))
        return;
    SetLocalInt(OBJECT_SELF, "ATH_PICKED", 1);
    CreateItemOnObject(ATH_RES_YYPR, oPC);
    FloatingTextStringOnCreature(ATH_TXT2_YYPR, oPC, FALSE);
    if (GetIsSkillSuccessful(oPC, SKILL_LORE, ATH_DC_LORE))
        DelayCommand(2.0, FloatingTextStringOnCreature(ATH_TXT2_YYPR_KNOW, oPC, FALSE));
}
