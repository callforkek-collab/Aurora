// ath_cocoon_rip — tag-based «Рвать кокон» (выдаётся при похищении змеем).
// Сила DC 15 или оружие в руке — свобода. Предмет одноразовый, но выдаётся заново, пока кокон цел.

#include "x2_inc_switches"
#include "ath_inc_b2"

void main()
{
    if (GetUserDefinedItemEventNumber() != X2_ITEM_EVENT_ACTIVATE)
        return;
    object oUser = GetItemActivator();
    SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
    if (!GetLocalInt(oUser, "ATH_IN_COCOON"))
        return;
    int bArmed = GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oUser));
    if (bArmed || d20() + GetAbilityModifier(ABILITY_STRENGTH, oUser) >= ATH_DC_COCOON)
    {
        DeleteLocalInt(oUser, "ATH_IN_COCOON");
        AthRemoveTagged(oUser, "ATH_COCOON_HOLD");
        FloatingTextStringOnCreature(ATH_TXT2_COCOON_OK, oUser, FALSE);
        return;
    }
    FloatingTextStringOnCreature(ATH_TXT2_COCOON_NO, oUser, FALSE);
    CreateItemOnObject(ATH_RES_COCOON, oUser);
}
