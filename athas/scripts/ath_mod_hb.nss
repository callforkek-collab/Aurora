// ath_mod_hb — Module OnHeartbeat (каждые 6 с). Полночная проверка воды,
// ежечасные напоминания о жажде и проверка жары — для каждого игрока отдельно.

#include "ath_inc_thirst"

void main()
{
    object oModule = OBJECT_SELF;
    int nHour = GetTimeHour();
    int nDay = GetCalendarDay();
    int bStarted = GetLocalInt(oModule, "ATH_CLOCK");
    int bNewDay = bStarted && nDay != GetLocalInt(oModule, "ATH_LAST_DAY");
    int bNewHour = bStarted && nHour != GetLocalInt(oModule, "ATH_LAST_HOUR");
    SetLocalInt(oModule, "ATH_CLOCK", 1);
    SetLocalInt(oModule, "ATH_LAST_DAY", nDay);
    SetLocalInt(oModule, "ATH_LAST_HOUR", nHour);

    int nBeat = GetLocalInt(oModule, "ATH_BEAT") + 1;
    SetLocalInt(oModule, "ATH_BEAT", nBeat);
    int bHeat = (nBeat % ATH_HEAT_EVERY_HB) == 0;

    if (bNewDay)
        SetLocalInt(oModule, "ATH_DAYNUM", GetLocalInt(oModule, "ATH_DAYNUM") + 1);

    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        if (GetLocalInt(oPC, "ATH_INIT") && !GetIsDead(oPC))
        {
            if (bNewDay)
            {
                AthDailyCheck(oPC);
                ExecuteScript("ath_b2_daily", oPC); // блок 2; без него вызов ничего не делает
            }
            else if (bNewHour)
                AthHourly(oPC);
            if (bHeat)
                AthHeatCheck(oPC);
        }
        oPC = GetNextPC();
    }
}
