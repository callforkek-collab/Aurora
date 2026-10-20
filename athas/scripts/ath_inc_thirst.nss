// ath_inc_thirst — вода, жажда и жара (карточка 5).
// Состояние хранится на каждом персонаже: компаньоны получат его так же, как игрок.
//   ATH_DRUNK     выпито за текущие сутки, кварт
//   ATH_HALF_NEED 1 = норма на сутки снижена вдвое (ночной переход, отдых в тени)
//   ATH_DRY_LOSS  накопленный штраф Телосложения
//   ATH_IN_SHADE  1 = стоит в триггере тени

#include "ath_inc_const"
#include "ath_inc_text"

int AthCountWater(object oCreature)
{
    int nCount = 0;
    object oItem = GetFirstItemInInventory(oCreature);
    while (GetIsObjectValid(oItem))
    {
        if (GetTag(oItem) == ATH_TAG_WATER)
            nCount += GetItemStackSize(oItem);
        oItem = GetNextItemInInventory(oCreature);
    }
    return nCount;
}

// Забирает до nCount кварт. Если oTo задан, вода переходит к нему. Возвращает, сколько забрано.
int AthTakeWater(object oCreature, int nCount, object oTo = OBJECT_INVALID)
{
    int nTaken = 0;
    object oItem = GetFirstItemInInventory(oCreature);
    while (GetIsObjectValid(oItem) && nTaken < nCount)
    {
        if (GetTag(oItem) == ATH_TAG_WATER)
        {
            int nStack = GetItemStackSize(oItem);
            int nTake = nCount - nTaken;
            if (nTake > nStack)
                nTake = nStack;
            if (GetIsObjectValid(oTo))
                CreateItemOnObject(ATH_RES_WATER, oTo, nTake);
            if (nTake == nStack)
                DestroyObject(oItem);
            else
                SetItemStackSize(oItem, nStack - nTake);
            nTaken += nTake;
        }
        oItem = GetNextItemInInventory(oCreature);
    }
    return nTaken;
}

int AthGetNeed(object oCreature)
{
    if (GetLocalInt(oCreature, "ATH_HALF_NEED"))
        return ATH_WATER_NEED_HALF;
    return ATH_WATER_NEED_DAY;
}

void AthRemoveTagged(object oCreature, string sTag)
{
    effect eEffect = GetFirstEffect(oCreature);
    while (GetIsEffectValid(eEffect))
    {
        if (GetEffectTag(eEffect) == sTag)
            RemoveEffect(oCreature, eEffect);
        eEffect = GetNextEffect(oCreature);
    }
}

int AthHasTagged(object oCreature, string sTag)
{
    effect eEffect = GetFirstEffect(oCreature);
    while (GetIsEffectValid(eEffect))
    {
        if (GetEffectTag(eEffect) == sTag)
            return TRUE;
        eEffect = GetNextEffect(oCreature);
    }
    return FALSE;
}

void AthReportWater(object oCreature)
{
    SendMessageToPC(oCreature, ATH_TXT_WATER_DAY
        + IntToString(GetLocalInt(oCreature, "ATH_DRUNK")) + ATH_TXT_WATER_OF
        + IntToString(AthGetNeed(oCreature)) + ATH_TXT_WATER_CARRY
        + IntToString(AthCountWater(oCreature)));
}

void AthDrink(object oCreature)
{
    int nDrunk = GetLocalInt(oCreature, "ATH_DRUNK") + 1;
    SetLocalInt(oCreature, "ATH_DRUNK", nDrunk);
    FloatingTextStringOnCreature(ATH_TXT_DRINK, oCreature, FALSE);
    if (nDrunk >= AthGetNeed(oCreature) && GetLocalInt(oCreature, "ATH_DRY_LOSS") > 0)
    {
        AthRemoveTagged(oCreature, "ATH_DEHYDRATION");
        DeleteLocalInt(oCreature, "ATH_DRY_LOSS");
        SendMessageToPC(oCreature, ATH_TXT_RECOVERED);
    }
    AthReportWater(oCreature);
}

// Проверка в полночь: меньше половины нормы — минус d6 Телосложения, меньше нормы — минус d4.
void AthDailyCheck(object oCreature)
{
    int nNeed = AthGetNeed(oCreature);
    int nDrunk = GetLocalInt(oCreature, "ATH_DRUNK");
    int nLoss = 0;
    if (nDrunk * 2 < nNeed)
        nLoss = d6();
    else if (nDrunk < nNeed)
        nLoss = d4();

    if (nLoss > 0)
    {
        int nTotal = GetLocalInt(oCreature, "ATH_DRY_LOSS") + nLoss;
        SetLocalInt(oCreature, "ATH_DRY_LOSS", nTotal);
        AthRemoveTagged(oCreature, "ATH_DEHYDRATION");
        if (GetAbilityScore(oCreature, ABILITY_CONSTITUTION, TRUE) - nTotal <= ATH_CON_DEATH)
        {
            SendMessageToPC(oCreature, ATH_TXT_DIED_THIRST);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), oCreature);
        }
        else
        {
            effect eLoss = EffectAbilityDecrease(ABILITY_CONSTITUTION, nTotal);
            eLoss = TagEffect(SupernaturalEffect(eLoss), "ATH_DEHYDRATION");
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLoss, oCreature);
            SendMessageToPC(oCreature, ATH_TXT_DEHYDRATED + IntToString(nTotal) + ".");
        }
    }
    else if (GetLocalInt(oCreature, "ATH_DRY_LOSS") > 0)
    {
        AthRemoveTagged(oCreature, "ATH_DEHYDRATION");
        DeleteLocalInt(oCreature, "ATH_DRY_LOSS");
        SendMessageToPC(oCreature, ATH_TXT_RECOVERED);
    }

    DeleteLocalInt(oCreature, "ATH_DRUNK");
    DeleteLocalInt(oCreature, "ATH_HALF_NEED");
}

// Раз в игровой час: напоминание о жажде, если норма не выпита.
void AthHourly(object oCreature)
{
    int nNeed = AthGetNeed(oCreature);
    int nDrunk = GetLocalInt(oCreature, "ATH_DRUNK");
    if (nDrunk >= nNeed)
        return;
    if (nDrunk * 2 < nNeed && GetIsDay())
        FloatingTextStringOnCreature(ATH_TXT_THIRST_2, oCreature, FALSE);
    else
        FloatingTextStringOnCreature(ATH_TXT_THIRST_1, oCreature, FALSE);
    AthReportWater(oCreature);
}

// Жара: днём в локации с ATH_HOT вне тени — спасбросок Стойкости или утомление (-2 Сил и Лов).
void AthHeatCheck(object oCreature)
{
    object oArea = GetArea(oCreature);
    if (!GetLocalInt(oArea, "ATH_HOT") || !GetIsDay())
        return;
    if (GetLocalInt(oCreature, "ATH_IN_SHADE") || AthHasTagged(oCreature, "ATH_HEAT"))
        return;

    int nDC = ATH_DC_HEAT;
    object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oCreature);
    if (GetIsObjectValid(oArmor) && GetItemACValue(oArmor) >= ATH_HEAT_ARMOR_AC)
        nDC += ATH_HEAT_ARMOR_DC;

    if (FortitudeSave(oCreature, nDC, SAVING_THROW_TYPE_NONE) == 0)
    {
        effect eHeat = EffectLinkEffects(EffectAbilityDecrease(ABILITY_STRENGTH, 2),
                                         EffectAbilityDecrease(ABILITY_DEXTERITY, 2));
        eHeat = TagEffect(SupernaturalEffect(eHeat), "ATH_HEAT");
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eHeat, oCreature);
        FloatingTextStringOnCreature(ATH_TXT_HEAT, oCreature, FALSE);
    }
}

// Записать этап журнала всем игрокам (в одиночной игре — одному).
void AthJournalAll(int nState)
{
    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        AddJournalQuestEntry(ATH_QUEST, nState, oPC, FALSE, FALSE, FALSE);
        oPC = GetNextPC();
    }
}

// Персонаж игрока или его компаньон.
int AthIsPartyCreature(object oCreature)
{
    if (GetObjectType(oCreature) != OBJECT_TYPE_CREATURE)
        return FALSE;
    return GetIsPC(oCreature) || GetIsPC(GetMaster(oCreature));
}
