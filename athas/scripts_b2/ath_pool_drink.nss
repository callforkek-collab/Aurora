// ath_pool_drink — OnUsed пруда оазиса (карточка 15).
// Первое использование — предупреждение, второе в течение 10 с — глоток.
// Эльфам вода не вредит; остальным — яд типа J через ATH_POOL_ONSET.

#include "ath_inc_b2"

void AthPoolForget(object oPC)
{
    DeleteLocalInt(oPC, "ATH_POOL_WARNED");
}

void main()
{
    object oPC = GetLastUsedBy();
    if (!GetLocalInt(oPC, "ATH_POOL_WARNED"))
    {
        SetLocalInt(oPC, "ATH_POOL_WARNED", 1);
        FloatingTextStringOnCreature(ATH_TXT2_POOL_WARN, oPC, FALSE);
        AssignCommand(oPC, DelayCommand(10.0, AthPoolForget(oPC)));
        return;
    }
    DeleteLocalInt(oPC, "ATH_POOL_WARNED");
    if (GetRacialType(oPC) == RACIAL_TYPE_ELF)
    {
        AthDrink(oPC);
        return;
    }
    FloatingTextStringOnCreature(ATH_TXT2_POOL_SIP, oPC, FALSE);
    AssignCommand(oPC, DelayCommand(ATH_POOL_ONSET, AthPoolPoison(oPC)));
}
