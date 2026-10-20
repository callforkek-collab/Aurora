// ath_mod_load — Module OnModuleLoad. Включает tag-based скрипты предметов
// (кувшин воды, шипы, оружие охраны) и вызывает стандартный обработчик.

#include "x2_inc_switches"

void main()
{
    SetModuleSwitch(MODULE_SWITCH_ENABLE_TAGBASED_SCRIPTS, TRUE);
    ExecuteScript("x2_mod_def_load", OBJECT_SELF);
}
