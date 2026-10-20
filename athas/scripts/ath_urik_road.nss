// ath_urik_road — OnEnter триггера у северо-восточного края L2: дорога на Урик (тупик среза).

#include "ath_inc_text"

void main()
{
    object oPC = GetEnteringObject();
    if (GetIsPC(oPC))
        FloatingTextStringOnCreature(ATH_TXT_URIK, oPC, FALSE);
}
