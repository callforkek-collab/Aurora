// ath_s4_exit — OnEnter триггера перед выходами из L2.
// Охрана перехватывает игрока, только если у него больше 2 кувшинов (карточка 4).

#include "ath_inc_s4"

void main()
{
    object oPC = GetEnteringObject();
    if (GetIsPC(oPC) && AthCountWater(oPC) > ATH_CARRY_WATER)
        AthSpawnThirsty(oPC);
}
