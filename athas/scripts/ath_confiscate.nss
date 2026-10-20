// ath_confiscate — Action Taken в ath_dlg_chief: «Я ухожу».
// Эльфы оставляют 2 кувшина и 2 оружия, забирают монеты и поджигают повозку.

#include "x2_inc_itemprop"
#include "ath_inc_thirst"

int AthIsWeapon(object oItem)
{
    return IPGetIsMeleeWeapon(oItem) || GetWeaponRanged(oItem);
}

void main()
{
    object oPC = GetPCSpeaker();
    object oChief = OBJECT_SELF;

    int nWater = AthCountWater(oPC);
    if (nWater > ATH_CARRY_WATER)
    {
        int nTaken = AthTakeWater(oPC, nWater - ATH_CARRY_WATER, oChief);
        SendMessageToPC(oPC, ATH_TXT_TAKEN_WATER + IntToString(nTaken));
    }

    // Сначала считаются экипированные руки, потом сумка.
    int nKept = 0;
    int nTakenWeapons = 0;
    object oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    if (GetIsObjectValid(oItem) && AthIsWeapon(oItem))
        nKept++;
    oItem = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
    if (GetIsObjectValid(oItem) && AthIsWeapon(oItem))
        nKept++;
    oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        if (AthIsWeapon(oItem))
        {
            if (nKept < ATH_CARRY_WEAPONS)
                nKept++;
            else
            {
                DestroyObject(oItem);
                nTakenWeapons++;
            }
        }
        oItem = GetNextItemInInventory(oPC);
    }
    if (nTakenWeapons > 0)
        SendMessageToPC(oPC, ATH_TXT_TAKEN_WEAPON + IntToString(nTakenWeapons));

    if (GetGold(oPC) > 0)
    {
        TakeGoldFromCreature(GetGold(oPC), oPC, TRUE);
        SendMessageToPC(oPC, ATH_TXT_TAKEN_GOLD);
    }

    object oModule = GetModule();
    AssignCommand(oModule, DelayCommand(ATH_FIRE_DELAY, ExecuteScript("ath_s3_fire", oModule)));
}
