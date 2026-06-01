
/**
 * Возвращает форматированные даты.
 */
class DateFormat_Variants{

  getDayName(){
    local day := Map()
    day[1] := "Sunday"
    day[2] := "Monday"
    day[3] := "Tuesday"
    day[4] := "Wednesday"
    day[5] := "Thursday"
    day[6] := "Friday"
    day[7] := "Saturday"
    local wDay := FormatTime(, "WDay")
    ; MsgBox wDay
    return day.Get(Integer(wDay))
  }

  getEndCharacter(){
    return "."
  }

  ; 2:08 PM Saturday, March 1, 2025
  formatTime_Default(){
    return FormatTime() . this.getEndCharacter()
  }

  ;  1 Mar, 2025, 02:52 PM (Saturday)
  formatTime_1_Feb_2000_AM_Saturday(){
    return FormatTime(, "d MMM, yyyy, hh:mm tt ") . "(" . this.getDayName() . ")" . this.getEndCharacter()
  }

  ; 1 Mar. 2025, 14:56 (Saturday)
  formatTime_1_Feb_2000_10_30_Saturday(){
    return FormatTime(, "d MMM, yyyy, HH:mm ") . "(" . this.getDayName() . ")" . this.getEndCharacter()
  }

  ; 01.03.2025, 15:00 
  formatTime_10_10_2000_10_10(){
    return FormatTime(, "dd.MM.yyyy, HH:mm ") . this.getEndCharacter()
  }

  ; 1 Mar. 2025
  formatTime_1_Feb_2000(){
    return FormatTime(, "d MMM, yyyy") . this.getEndCharacter()
  }

  formatTime_1_Feb_2000_week(){
    return FormatTime(, "d MMM, yyyy") . ", " . this.getDayName() . this.getEndCharacter()
  }

  ; "display": "3/18/2025, 10:30 AM"
  formatTime_moth_day_year_am(){
    return FormatTime(, "M/d/yyyy, hh:mm tt") . this.getEndCharacter()
  }

  ; 1 Mar. 15:06, Saturday, 2025
  formatTime_1_Feb_10_10_Saturday_2000(){
    ; A_Now
    return FormatTime(, "d MMM, HH:mm, ") . this.getDayName() . ", " . FormatTime(, "yyyy")  . this.getEndCharacter()
  }

  ; 1 Mar, 10:06 AM, Saturday, 2025
  formatTime_1_Feb_AM_Saturday_2000(){
    ; A_Now
    return FormatTime(, "d MMM, hh:mm tt, ") . this.getDayName() . ", " . FormatTime(, "yyyy")  . this.getEndCharacter()
  }

  ; 08 Jun 2024, 19:10
  formatTime_1_Feb_Year_23time(){
    return FormatTime(, "dd MMM yyyy, HH:mm") . this.getEndCharacter()
  }



}

; Example:
; callBack := ObjBindMethod(DateFormat_Variants(), "formatTime_1_Feb_10_10_Saturday_2000")
