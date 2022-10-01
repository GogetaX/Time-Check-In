extends Control

func FastLoadMonthYear(Month,Year):
	$Month.text = Month
	$Year.text = Year

func SetMonthToNext(MonthName):
	$Month.AnimNext(MonthName)

func SetYearToNext(YearName):
	$Year.AnimNext(YearName)
