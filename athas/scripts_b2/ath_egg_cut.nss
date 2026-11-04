// ath_egg_cut — tag-based «Вырезать яйцо» (Single Use): 1d10 урона, яйцо или личинка удалены.

#include "x2_inc_switches"
#include "ath_inc_b2"

void main()
{
    if (GetUserDefinedItemEventNumber() != X2_ITEM_EVENT_ACTIVATE)
        return;
    object oUser = GetItemActivator();
    if (GetLocalInt(oUser, "ATH_EGG_DAY"))
    {
        DeleteLocalInt(oUser, "ATH_EGG_DAY");
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d10(), DAMAGE_TYPE_SLASHING), oUser);
        FloatingTextStringOnCreature(ATH_TXT2_EGG_CUT, oUser, FALSE);
    }
    SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
}
