// ath_water_q — tag-based скрипт предмета «Кувшин воды (кварта)».
// Шаблон: базовый предмет Potion, свойство Cast Spell: Unique Power Self Only (Single Use),
// тег ath_water_q. Использование выпивает одну кварту.

#include "x2_inc_switches"
#include "ath_inc_thirst"

void main()
{
    if (GetUserDefinedItemEventNumber() != X2_ITEM_EVENT_ACTIVATE)
        return;
    AthDrink(GetItemActivator());
    SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
}
