// ath_s4_wreck — OnEnter триггера у пепелища: игрок вернулся к повозке.

#include "ath_inc_s4"

void main()
{
    object oPC = GetEnteringObject();
    if (!GetIsPC(oPC))
        return;
    if (GetLocalInt(GetModule(), "ATH_WRECK_READY") && !GetLocalInt(oPC, "ATH_WRECK_SEEN"))
    {
        SetLocalInt(oPC, "ATH_WRECK_SEEN", 1);
        FloatingTextStringOnCreature(ATH_TXT_WRECK, oPC, FALSE);
    }
    AthSpawnThirsty(oPC);
}
