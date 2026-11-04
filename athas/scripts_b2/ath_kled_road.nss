// ath_kled_road — OnEnter триггера тропы на Клед: конец блока 2.

#include "ath_inc_b2"

void main()
{
    object oPC = GetEnteringObject();
    if (GetIsPC(oPC))
        FloatingTextStringOnCreature(ATH_TXT2_KLED, oPC, FALSE);
}
