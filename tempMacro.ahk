SetWorkingDir, %A_ScriptDir%

#Include, %A_ScriptDir%\lib\JSON.ahk

; Game executables groups - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
GroupAdd, PoEWindowGrp, Path of Exile ahk_class POEWindowClass ahk_exe PathOfExile.exe
GroupAdd, PoEWindowGrp, Path of Exile ahk_class POEWindowClass ahk_exe PathOfExile_KG.exe
GroupAdd, PoEWindowGrp, Path of Exile ahk_class POEWindowClass ahk_exe PathOfExileSteam.exe
GroupAdd, PoEWindowGrp, Path of Exile ahk_class POEWindowClass ahk_exe PathOfExile_x64.exe
GroupAdd, PoEWindowGrp, Path of Exile ahk_class POEWindowClass ahk_exe PathOfExile_x64_KG.exe
GroupAdd, PoEWindowGrp, Path of Exile ahk_class POEWindowClass ahk_exe PathOfExile_x64Steam.exe


FileRead, JSONFile, %A_ScriptDir%\data\Words.json
parsedJSON := JSON.Load(JSONFile)

global WordList := parsedJSON["data"]
MsgBox, 로딩완료

class ItemInfo {

	Set(name, value) {
		ItemInfo[name] := value
	}

	Get(name, value_default="") {
		result := ItemInfo[name]
		If (result == "") {
			result := value_default
		}
		return result
	}
}

IsUnique(ItemRarity){
	If (RegExMatch(ItemRarity, "희귀도: 고유")) {
		return true
	}
}

GetClipboardName(DropNewlines=False){
	If Not DropNewlines{
		Loop, Parse, Clipboard, `n, `r
		{
			If (a_index = 1 && !IsUnique(A_LoopField)){
				ItemData.Set("rarity", A_LoopField)
			}
			If (a_index = 2 ){
				ItemData.Set("krName", A_LoopField)
				ItemData.Set("enName", GetEnglishName(A_LoopField))
			}
			If (a_index = 3 ){
				ItemData.Set("itemBase", A_LoopField)
			}
		}
	}
}

GetEnglishName(Itemname){

	For idx in WordList {
		If (WordList[idx]["Text2"] = Itemname) {
			output := WordList[idx]["Text"]
			return output
		}
		stdout.WriteLine(word.Text2)
	}
	return ""
}

WikiSearch(Item_name){
	if(Item_name == ""){
		return
	}
	StringReplace, Search, Item_name, %A_SPACE%, +, All
	url = http://pathofexile.gamepedia.com/index.php?search=%Search%
	Run %url%
}

TradeDaumSearch(Item_name, Item_base, league){
	if(Item_name == "" || Item_base == "" || league == ""){
		return
	}
	url = https://poe.game.daum.net/api/trade/search/%league%?redirect&source={"query":{"status":{"option":"online"},"name":"%Item_name%","type":"%Item_base%","stats":[{"type":"and","filters":[]}]},"sort":{"price":"asc"}}
	StringReplace, runUrl, url, ", `%22, All ; double quote 인코딩

	Run, %runUrl%
}

LogOut(){ ; log out to character Selection
	Sleep, 50
	Send {Enter}/{U+0065}{U+0078}{U+0069}{U+0074}{Enter}
}

HideOut(){ ; goto hideout
	Sleep, 50
	Send {Enter}/{U+0068}{U+0069}{U+0064}{U+0065}{U+006F}{U+0075}{U+0074}{Enter}
}

global ItemData := new ItemInfo
CopyText(){
	SendInput ^c
	Sleep, 200
	ItemData := new ItemInfo
	GetClipboardName()
	return
}




; 단축키 항목
#IfWinActive, ahk_group PoEWindowGrp
^w::
{
	CopyText()
	WikiSearch(ItemData.get("enName"))
	return
}

^e::
{
	CopyText()
	clipboard := ItemData.get("enName")  ;0 / Insert
	return
}

^q::
{
	CopyText()
	; league := "Synthesis" ; 챌린지
	; league := "Hardcore Synthesis" ; 챌린지 하드코어
	league := "Synthesis Event (SRE001)" ; 챌린지 이벤트
	; league := "Synthesis Event (SRE001)" ;챌린지 이벤트 하드코어
	; league := "Standard" ;스탠다드
	; league := "Hardcore" ;하드코어
	item_base := ItemData.get("itemBase")
	TradeDaumSearch(ItemData.get("krName"), ItemData.get("itemBase"), league)
	return
}

f4::
{
	LogOut()
}

f5::
{
	HideOut()
}

^WheelUp::Send {Left}  ;cntl-mouse wheel up toggles stash tabs left
^WheelDown::Send {Right}  ;cntl-mouse wheel down toggles stash tabs right.
