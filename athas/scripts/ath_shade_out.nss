// ath_shade_out — OnExit триггера тени.

void main()
{
    DeleteLocalInt(GetExitingObject(), "ATH_IN_SHADE");
}
