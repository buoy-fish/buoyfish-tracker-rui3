Turn off BLUE light if in ABP on line 272
```
			digitalWrite(LED_BLUE, LOW);
			MYLOG("SETUP", "ABP mode detected - LED turned off");
```

If first fix, do 90s
in .ino
```
		// If first fix has not yet been obtained, allow up to ~90s (36 cycles)
		if (!gnss_first_fix_obtained && check_gnss_max_try < 36)
		{
			check_gnss_max_try = 36;
		}
```
and in app.h
```
extern bool gnss_first_fix_obtained;
```
and in 12500.cpp
```
/** Tracks whether the first GNSS fix has been obtained since boot */
bool gnss_first_fix_obtained = false;
```
and again in 12500
```
        gnss_first_fix_obtained = true;
```