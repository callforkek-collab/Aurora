// ath_camp_in — OnEnter триггера вокруг лагеря караванщиков (карточка 12).
// Днём героя замечают сразу; ночью работает обычная скрытность NWN.

#include "ath_inc_b2"

void main()
{
    object oPC = GetEnteringObject();
    if (!GetIsPC(oPC))
        return;
    SetLocalInt(oPC, "ATH_IN_CAMP", 1);
    SetLocalInt(oPC, "ATH_CAMP_TRIED", 1);
    if (GetIsDay())
    {
        FloatingTextStringOnCreature(ATH_TXT2_CAMP_DAY, oPC, FALSE);
        AthCampAlarm(oPC);
    }
}
