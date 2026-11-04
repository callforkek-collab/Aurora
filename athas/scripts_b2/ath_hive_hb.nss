// ath_hive_hb — OnHeartbeat локации «Улей»: пока идёт дым, все живые теряют 1d4 HP за раунд.

#include "ath_inc_b2"

void main()
{
    if (!GetLocalInt(GetModule(), "ATH_SMOKED"))
        return;
    object oObject = GetFirstObjectInArea(OBJECT_SELF);
    while (GetIsObjectValid(oObject))
    {
        if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && !GetIsDead(oObject))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d4(), DAMAGE_TYPE_MAGICAL), oObject);
            if (GetIsPC(oObject))
                FloatingTextStringOnCreature(ATH_TXT2_SMOKE_HURT, oObject, FALSE);
        }
        oObject = GetNextObjectInArea(OBJECT_SELF);
    }
}
