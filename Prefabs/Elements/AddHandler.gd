extends Node

export (bool) var ShowAds = false setget SetShowAds
export (String, MULTILINE) var DontShowAdsOnDevices = "" setget SetDontShowAds
export (int) var HowManyMonthsNoAds = 3 setget SetHowManyMonthsNoAds
export (int) var MaxInistalarAds = 1 setget SetMaxInistalarAds
export (int) var InterstitalAdDelay = 45 setget SetInterstitalAdDelay

var banner = {"Banner":"4f66203cb47f99c9","Interstitial":"02e2392c449b9ab0"}
var AdsInited = false
var InstAdCounter = 0

var ReadyShowInterstitalID = ""

func _ready():
	InitAds()
	pass

func SetInterstitalAdDelay(new):
	InterstitalAdDelay = new
	
func SetMaxInistalarAds(new):
	MaxInistalarAds = new
	
func SetHowManyMonthsNoAds(new):
	HowManyMonthsNoAds = new
	
func SetShowAds(new):
	ShowAds = new

func SetDontShowAds(new):
	DontShowAdsOnDevices = new
	
func SkipAds():
	var L = DontShowAdsOnDevices.split("\n")
	var ThisDevice = OS.get_unique_id()
	for x in L:
		if x == ThisDevice:
			return true
	return false
	
func InitAds():
	if SkipAds():
		return
	if GlobalSave.HowManyMonthsWorked().size() <= HowManyMonthsNoAds:
		return
	if ShowAds:
		if OS.get_name() == "iOS":
			ATT.connect("requestCompleted", self, "_att_completed")
			ATT.request()
			
		match OS.get_name():
			"iOS","Android":
				AdsInited = true
				print("loading banner!")
# warning-ignore:return_value_discarded
				ApplovinMax.loadBanner(banner.Banner,false,get_instance_id())
				ApplovinMax.loadInterstitial(banner.Interstitial,get_instance_id())
				GlobalTime.connect("ShowInterstitalAd",self,"ShowInterstitalAd")

func _att_completed(status: int):
	print('ATT Status: %d'%status)
	# if status == 3 the user permitted data collection
	
func ShowInterstitalAd():
	if ReadyShowInterstitalID != "":
		print("Showing ReadyShowInterstitalID")
		ApplovinMax.showInterstitial(ReadyShowInterstitalID)
	else:
		print("No ReadyShowInterstitalID to show")
	
	
func _on_banner_loaded(id):
# warning-ignore:return_value_discarded
	print("show banner!")
	ApplovinMax.showBanner(id)

func _on_interstitial_loaded(id):
	print("ready ReadyShowInterstitalID")
	ReadyShowInterstitalID = id

func _on_interstitial_close(id):
	ReadyShowInterstitalID = ""
	ApplovinMax.loadInterstitial(banner.Interstitial,get_instance_id())
