// ath_start — Module OnClientEnter. Сцена 1: раб в трюме, 3-й уровень, без вещей и денег.

#include "ath_inc_thirst"

void AthStrip(object oPC)
{
    int nSlot;
    for (nSlot = 0; nSlot < NUM_INVENTORY_SLOTS; nSlot++)
    {
        object oEquipped = GetItemInSlot(nSlot, oPC);
        if (GetIsObjectValid(oEquipped))
            DestroyObject(oEquipped);
    }
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        DestroyObject(oItem);
        oItem = GetNextItemInInventory(oPC);
    }
    TakeGoldFromCreature(GetGold(oPC), oPC, TRUE);
}

void AthDressSlave(object oPC)
{
    object oCloth = CreateItemOnObject(ATH_RES_LOINCLOTH, oPC);
    AssignCommand(oPC, ActionEquipItem(oCloth, INVENTORY_SLOT_CHEST));
}

void main()
{
    object oPC = GetEnteringObject();
    object oModule = GetModule();

    if (GetIsPC(oPC) && !GetLocalInt(oPC, "ATH_INIT"))
    {
        SetLocalInt(oPC, "ATH_INIT", 1);
        AthStrip(oPC);
        DelayCommand(1.0, AthDressSlave(oPC));
        if (GetXP(oPC) < ATH_START_XP)
        {
            SetXP(oPC, ATH_START_XP);
            DelayCommand(6.0, SendMessageToPC(oPC, ATH_TXT_LEVEL_UP));
        }
        SetLocalInt(oPC, "ATH_DRUNK", ATH_START_DRUNK);
        SetLocalInt(oPC, "ATH_SHACKLED", 1);
        AddJournalQuestEntry(ATH_QUEST, ATH_J_HOLD, oPC, FALSE, FALSE, FALSE);
        DelayCommand(3.0, FloatingTextStringOnCreature(ATH_TXT_INTRO, oPC, FALSE));

        // Если игрок не пытается бежать, нападение начнётся само.
        if (!GetLocalInt(oModule, "ATH_S1_TIMER"))
        {
            SetLocalInt(oModule, "ATH_S1_TIMER", 1);
            AssignCommand(oModule, DelayCommand(ATH_S1_TIMEOUT, ExecuteScript("ath_s2_attack", oModule)));
        }
    }

    ExecuteScript("x3_mod_def_enter", OBJECT_SELF);
}
