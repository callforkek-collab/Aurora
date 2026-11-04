// ath_brush — OnUsed «Сухого кустарника» (карточка 11): вязанка хвороста, +3 часа.

#include "ath_inc_b2"

void main()
{
    object oPC = GetLastUsedBy();
    CreateItemOnObject(ATH_RES_FUEL, oPC);
    AthAdvanceHours(ATH_FUEL_HOURS);
    FloatingTextStringOnCreature(ATH_TXT2_FUEL, oPC, FALSE);
    DestroyObject(OBJECT_SELF);
}
