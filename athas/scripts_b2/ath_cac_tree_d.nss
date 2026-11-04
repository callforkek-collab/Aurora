// ath_cac_tree_d — OnDeath кактуса-дерева (карточка 7).
// Оставляет мякоть, которая портится через ATH_PULP_SPOIL секунд.

#include "ath_inc_b2"

void main()
{
    object oPulp = CreateObject(OBJECT_TYPE_ITEM, ATH_RES_PULP, GetLocation(OBJECT_SELF));
    AssignCommand(GetModule(), DelayCommand(ATH_PULP_SPOIL, DestroyObject(oPulp)));
    object oKiller = GetLastKiller();
    if (GetIsPC(oKiller))
        FloatingTextStringOnCreature(ATH_TXT2_PULP, oKiller, FALSE);
    ExecuteScript("nw_c2_default7", OBJECT_SELF);
}
