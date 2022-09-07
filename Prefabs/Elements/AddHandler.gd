extends Node

export (bool) var ShowAds = false setget SetShowAds
export (String, MULTILINE) var DontShowAdsOnDevices = "" setget SetDontShowAds
export (int) var HowManyMonthsNoAds = 3 setget SetHowManyMonthsNoAds

var AdsInited = false

func _ready():
	InitAds()
	
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
		match OS.get_name():
			
			"iOS","Android":
				AdsInited = true
	# warning-ignore:return_value_discarded
				MobileAds.connect("consent_info_update_success",self,"consent_info_update_success")
	# warning-ignore:return_value_discarded
				MobileAds.connect("consent_status_changed",self,"consent_status_changed")
	# warning-ignore:return_value_discarded
				MobileAds.connect("consent_form_load_failure",self,"consent_form_load_failure")
	# warning-ignore:return_value_discarded
				MobileAds.connect("consent_info_update_failure",self,"consent_form_load_failure")
	# warning-ignore:return_value_discarded
				MobileAds.connect("initialization_complete",self,"AdMobInitComplete")
	# warning-ignore:return_value_discarded
				MobileAds.connect("banner_loaded",self,"BannerLoaded")
	# warning-ignore:return_value_discarded
				MobileAds.connect("banner_failed_to_load",self,"banner_failed_to_load")
	# warning-ignore:return_value_discarded
				MobileAds.request_user_consent()

func consent_status_changed(status_message):
	MobileAds.initialize()
	print("Consent status changed: ",status_message)
	
func consent_info_update_success(status_message):
	MobileAds.initialize()
	print("Consent info update success: ",status_message)
	
func consent_form_load_failure(error_code, error_message):
	MobileAds.initialize()
	print("Concert error num ",error_code," msg ",error_message)
	
func BannerLoaded():
	print("Showing Ad!")
	MobileAds.show_banner()
	
func AdMobInitComplete(status : int, _adapter_name : String):
	if status == MobileAds.AdMobSettings.INITIALIZATION_STATUS.READY:
		MobileAds.load_banner()
		print("AdMob initialized on GDScript! With parameters:")
		#for x in MobileAds.config:
			#print(x,": ",MobileAds.config[x])
		#print(JSON.print(MobileAds.config, "\t"))
		print("instance_id: " + str(get_instance_id()))
	else:
		print("AdMob not initialized, check your configuration")
	print("---------------------------------------------------")
	
func banner_failed_to_load(error_code):
	print("Error On Loading Banner, Code: ",error_code)
